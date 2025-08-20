import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

/// Ported 1:1 from template chat_screen.dart (icons switched to solar_icons)
class MatchProfilesPage extends StatefulWidget {
  const MatchProfilesPage({super.key});

  @override
  State<MatchProfilesPage> createState() => _MatchProfilesPageState();
}

class _MatchProfilesPageState extends State<MatchProfilesPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_ChatMessage> _messages = [];

  bool _sending = false;

  @override
  void initState() {
    super.initState();
    // Guard: if role is already set (not guest), go to home
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirectIfRoleSet());
  }

  Future<void> _redirectIfRoleSet() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      // Fetch the current user's role_id; assume 1 = GUEST, others = non-guest
      final res = await Supabase.instance.client
          .from('users')
          .select('role_id')
          .eq('id', user.id)
          .maybeSingle();
      final roleId = (res != null) ? res['role_id'] as int? : null;
      if (roleId != null && roleId != 1 && mounted) {
        // Not a guest -> route to home
        context.go('/home');
      }
    } catch (_) {
      // ignore errors; stay on page
    }
  }

  void _handleCameraTap() {}

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() {
      _messages.add(_ChatMessage.text(text, isMine: true, timestamp: _now()));
      _sending = true;
      _messageController.clear();
    });
    _autoScroll();

    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      setState(() {
        _messages.add(
          _ChatMessage.text(
            'GEMINI_API_KEY is not set in .env',
            isMine: false,
            timestamp: _now(),
          ),
        );
        _sending = false;
      });
      _autoScroll();
      return;
    }

    try {
      final reply = await _geminiFlashReply(
        apiKey: apiKey,
        userText: text,
        history: _asHistory(),
      );
      setState(() {
        _messages.add(
          _ChatMessage.text(reply, isMine: false, timestamp: _now()),
        );
        _sending = false;
      });
      _autoScroll();
    } catch (e) {
      setState(() {
        _messages.add(
          _ChatMessage.text('오류: $e', isMine: false, timestamp: _now()),
        );
        _sending = false;
      });
      _autoScroll();
    }
  }

  List<Map<String, dynamic>> _asHistory() {
    final List<Map<String, dynamic>> contents = [];
    for (final m in _messages) {
      if (m.type != _MsgType.text) continue;
      contents.add({
        'role': m.isMine ? 'user' : 'model',
        'parts': [
          {'text': m.text},
        ],
      });
    }
    return contents;
  }

  Future<String> _geminiFlashReply({
    required String apiKey,
    required String userText,
    required List<Map<String, dynamic>> history,
  }) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
    );
    final body = jsonEncode({
      'contents': [
        ...history,
        {
          'role': 'user',
          'parts': [
            {'text': userText},
          ],
        },
      ],
    });
    final dio = Dio();
  final res = await dio
    .post(url.toString(), data: body, options: Options(headers: {'Content-Type': 'application/json'}))
    .timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) {
      throw 'HTTP ${res.statusCode}: ${res.data}';
    }
    final decoded = jsonDecode(res.data is String ? res.data : jsonEncode(res.data)) as Map<String, dynamic>;
    final candidates = decoded['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) throw 'No candidates';
    final content =
        candidates.first['content'] as Map<String, dynamic>? ??
        (candidates.first['content'] == null
            ? {}
            : Map<String, dynamic>.from(candidates.first['content']));
    final parts = content['parts'] as List<dynamic>?;
    if (parts == null || parts.isEmpty) throw 'No parts in response';
    final text = parts.first['text']?.toString();
    if (text == null || text.isEmpty) throw 'Empty response text';
    return text;
  }

  String _now() {
    final now = DateTime.now();
    final mm = now.minute.toString().padLeft(2, '0');
    return '${now.hour}:$mm';
  }

  void _autoScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(SolarIconsOutline.altArrowLeft),
          onPressed: () => Navigator.of(context).maybePop(),
          color: Colors.black,
        ),
        title: Text(
          'Annette Black',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              SolarIconsOutline.phone,
              color: Colors.black,
              size: 24,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              SolarIconsOutline.videocamera,
              color: Colors.black,
              size: 24,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              SolarIconsOutline.menuDots,
              color: Colors.black,
              size: 24,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                // No date chip rendering per user request
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: _MessageBubble(
                    text: m.text,
                    timestamp: m.timestamp,
                    isSentByMe: m.isMine,
                  ),
                );
              },
            ),
          ),
          _MessageInput(
            controller: _messageController,
            onSend: _sendMessage,
            onCameraTap: _handleCameraTap,
            sending: _sending,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

enum _MsgType { text }

class _ChatMessage {
  final _MsgType type;
  final String text;
  final bool isMine;
  final String timestamp;
  const _ChatMessage._(this.type, this.text, this.isMine, this.timestamp);
  const _ChatMessage.text(
    String text, {
    required bool isMine,
    required String timestamp,
  }) : this._(_MsgType.text, text, isMine, timestamp);
}

// Date chip removed per user request

class _MessageBubble extends StatelessWidget {
  final String text;
  final String timestamp;
  final bool isSentByMe;
  const _MessageBubble({
    required this.text,
    required this.timestamp,
    required this.isSentByMe,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    const Color receivedBubbleColor = Color(0xFFF4F6F7);

    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: isSentByMe ? primaryColor : receivedBubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: isSentByMe
              ? const Radius.circular(16)
              : const Radius.circular(4),
          bottomRight: isSentByMe
              ? const Radius.circular(4)
              : const Radius.circular(16),
        ),
        border: isSentByMe
            ? null
            : Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 15,
          color: isSentByMe ? Colors.white : Colors.black,
        ),
      ),
    );

    final time = Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        timestamp,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 10,
          color: isSentByMe ? Colors.white70 : Colors.grey[600],
        ),
      ),
    );

    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 4.0,
          bottom: 4.0,
          left: isSentByMe ? 60.0 : 0.0,
          right: isSentByMe ? 0.0 : 60.0,
        ),
        child: Column(
          crossAxisAlignment: isSentByMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [bubble, time],
        ),
      ),
    );
  }
}

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onCameraTap;
  final bool sending;
  const _MessageInput({
    required this.controller,
    required this.onSend,
    required this.onCameraTap,
    this.sending = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6F7),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Type message...',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(
                      SolarIconsOutline.camera,
                      color: Colors.grey,
                    ),
                    onPressed: onCameraTap,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                minLines: 1,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
              ),
            ),
          ),
          const SizedBox(width: 8),
          RawMaterialButton(
            onPressed: sending ? null : onSend,
            fillColor: primaryColor,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(12),
            child: sending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    SolarIconsBold.plain,
                    color: Colors.white,
                    size: 24,
                  ),
          ),
        ],
      ),
    );
  }
}

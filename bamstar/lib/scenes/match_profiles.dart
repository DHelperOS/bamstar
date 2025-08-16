import 'package:flutter/material.dart';

/// Clean, single implementation of the flat chat layout requested.
class MatchProfilesPage extends StatefulWidget {
  const MatchProfilesPage({super.key});

  @override
  State<MatchProfilesPage> createState() => _MatchProfilesPageState();
}

class _MatchProfilesPageState extends State<MatchProfilesPage> {
  final List<_ChatMessage> _messages = [
    _ChatMessage(text: 'How can I help you? Let me know.', isMine: false, time: '10:45 AM'),
    _ChatMessage(text: 'I just finished it in 2 days', isMine: true, time: '10:50 AM'),
    _ChatMessage(text: 'Wowow', isMine: true, time: '10:55 AM'),
    _ChatMessage(text: 'Nice! 🎉', isMine: false, time: '10:56 AM'),
  ];

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final primary = cs.primary;
    final onPrimary = cs.onPrimary;

        return Scaffold(
          backgroundColor: cs.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth > 600 ? 600.0 : constraints.maxWidth;
            return Center(
              child: SizedBox(
                width: maxWidth,
                height: constraints.maxHeight,
                child: Column(
                  children: [
                    // Curved purple header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundImage: const AssetImage('assets/images/icon/avatar.png'),
                            backgroundColor: primary.withAlpha((0.18 * 255).round()),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Eleanor Pena', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: onPrimary, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text('is typing...', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: onPrimary.withAlpha((0.9 * 255).round()))),
                              ],
                            ),
                          ),
                          IconButton(onPressed: () {}, icon: Icon(Icons.call, color: onPrimary)),
                          IconButton(onPressed: () {}, icon: Icon(Icons.videocam, color: onPrimary)),
                        ],
                      ),
                    ),

                    // Messages list
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final msg = _messages[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                mainAxisAlignment: msg.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (!msg.isMine) ...[
                                    CircleAvatar(radius: 12, backgroundImage: const AssetImage('assets/images/icon/avatar.png')),
                                    const SizedBox(width: 8),
                                  ],
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: msg.isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: msg.isMine ? primary : cs.surface,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(msg.isMine ? 12 : 4),
                                              topRight: Radius.circular(msg.isMine ? 4 : 12),
                                              bottomLeft: const Radius.circular(12),
                                              bottomRight: const Radius.circular(12),
                                            ),
                                            boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.03 * 255).round()), blurRadius: 6, offset: const Offset(0, 2))],
                                          ),
                                          child: Text(msg.text, style: TextStyle(color: msg.isMine ? onPrimary : Theme.of(context).textTheme.bodyMedium?.color)),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(msg.time, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha((0.6 * 255).round()))),
                                      ],
                                    ),
                                  ),
                                  if (msg.isMine) ...[
                                    const SizedBox(width: 8),
                                    const CircleAvatar(radius: 12, backgroundImage: AssetImage('assets/images/icon/avatar.png')),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Input bar (non-interactive to avoid keyboard/back button behavior)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha((0.5 * 255).round()),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {}, // do nothing to avoid opening keyboard
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(24)),
                                child: Row(
                                  children: [
                                    const Icon(Icons.emoji_emotions_outlined, size: 20, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text('Than', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha((0.9 * 255).round())))),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
                            child: IconButton(onPressed: () {}, icon: const Icon(Icons.send, color: Colors.white)),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isMine;
  final String time;
  _ChatMessage({required this.text, required this.isMine, required this.time});
}

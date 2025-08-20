import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:bamstar/services/community/community_repository.dart';

class ChannelExplorerPage extends StatefulWidget {
  const ChannelExplorerPage({super.key});

  @override
  State<ChannelExplorerPage> createState() => _ChannelExplorerPageState();
}

class _ChannelExplorerPageState extends State<ChannelExplorerPage> {
  List<HashtagChannel> _channels = const [];
  String _q = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await CommunityRepository.instance.fetchSubscribedChannels(
      limit: 24,
    );
    if (!mounted) return;
    setState(() => _channels = res);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _channels
        .where((c) => _q.isEmpty || c.name.contains(_q.toLowerCase()))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('채널 탐색'),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(SolarIconsOutline.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: '채널 검색 (#없이 입력)',
                prefixIcon: Icon(SolarIconsOutline.magnifier),
              ),
              onChanged: (v) => setState(() => _q = v.trim()),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 3.2,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final c = filtered[i];
                return _ChannelTile(channel: c);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelTile extends StatefulWidget {
  final HashtagChannel channel;
  const _ChannelTile({required this.channel});
  @override
  State<_ChannelTile> createState() => _ChannelTileState();
}

class _ChannelTileState extends State<_ChannelTile> {
  bool _subscribed = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final ok = await CommunityRepository.instance.isSubscribed(
      hashtagId: widget.channel.id,
    );
    if (!mounted) return;
    setState(() {
      _subscribed = ok;
      _loading = false;
    });
  }

  Future<void> _toggle() async {
    setState(() => _loading = true);
    bool ok;
    if (_subscribed) {
      ok = await CommunityRepository.instance.unsubscribeFromChannel(
        hashtagId: widget.channel.id,
      );
    } else {
      ok = await CommunityRepository.instance.subscribeToChannel(
        hashtagId: widget.channel.id,
      );
    }
    if (!mounted) return;
    setState(() {
      if (ok) _subscribed = !_subscribed;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final c = widget.channel;
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: cs.surface,
          border: Border.all(color: cs.outlineVariant),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(SolarIconsOutline.hashtagSquare),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '#${c.name}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    '${c.postCount} posts · ${c.subscriberCount} subs',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            _loading
                ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : (_subscribed
                      ? FilledButton.tonal(
                          onPressed: _toggle,
                          child: const Text('구독중'),
                        )
                      : FilledButton.tonal(
                          onPressed: _toggle,
                          child: const Text('+ 구독'),
                        )),
          ],
        ),
      ),
    );
  }
}

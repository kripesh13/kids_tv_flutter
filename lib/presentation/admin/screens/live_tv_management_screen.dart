import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/live_channel_model.dart';
import '../../providers/live_tv_provider.dart';

class LiveTvManagementScreen extends ConsumerWidget {
  const LiveTvManagementScreen({super.key});

  void _openChannelDialog(BuildContext context, WidgetRef ref, [LiveChannelModel? channel]) {
    final nameCtrl = TextEditingController(text: channel?.name ?? '');
    final urlCtrl = TextEditingController(text: channel?.streamUrl ?? '');
    final logoCtrl = TextEditingController(text: channel?.logoUrl ?? '');
    final numberCtrl = TextEditingController(text: channel?.channelNumber ?? '');
    final programCtrl = TextEditingController(text: channel?.currentProgram ?? '');
    bool isActive = channel?.isActive ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(channel == null ? 'Add Live Channel' : 'Edit Live Channel'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Channel Name *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'HLS Stream URL (.m3u8) *',
                    hintText: 'https://.../master.m3u8',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: logoCtrl,
                  decoration: const InputDecoration(labelText: 'Logo Image URL *'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: numberCtrl,
                        decoration: const InputDecoration(labelText: 'CH #', hintText: '01'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: programCtrl,
                        decoration: const InputDecoration(labelText: 'Current Program'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Channel Active'),
                  value: isActive,
                  onChanged: (val) => setState(() => isActive = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty || urlCtrl.text.trim().isEmpty) return;
                final now = DateTime.now();
                final saved = LiveChannelModel(
                  id: channel?.id ?? const Uuid().v4(),
                  name: nameCtrl.text.trim(),
                  streamUrl: urlCtrl.text.trim(),
                  logoUrl: logoCtrl.text.trim(),
                  channelNumber: numberCtrl.text.trim().isNotEmpty ? numberCtrl.text.trim() : null,
                  currentProgram: programCtrl.text.trim().isNotEmpty ? programCtrl.text.trim() : null,
                  isActive: isActive,
                  createdAt: channel?.createdAt ?? now,
                  updatedAt: now,
                );
                ref.read(liveTvProvider.notifier).saveChannel(saved);
                Navigator.pop(ctx);
              },
              child: const Text('Save Channel'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveTvState = ref.watch(liveTvProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Live TV Channels Manager', style: AppTypography.headlineLarge),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Add Channel'),
              onPressed: () => _openChannelDialog(context, ref),
            ),
          ),
        ],
      ),
      body: liveTvState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : liveTvState.channels.isEmpty
              ? const Center(child: Text('No channels added yet.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: liveTvState.channels.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final ch = liveTvState.channels[index];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Text(
                            ch.channelNumber ?? '${index + 1}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(ch.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            if (ch.isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'LIVE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Text(
                          ch.currentProgram != null
                              ? 'Now: ${ch.currentProgram}'
                              : ch.streamUrl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: AppColors.info),
                              onPressed: () => _openChannelDialog(context, ref, ch),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.error),
                              onPressed: () {
                                ref.read(liveTvProvider.notifier).deleteChannel(ch.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

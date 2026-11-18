import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';
import '../providers/watch_history_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final historyState = ref.watch(watchHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Watch History', style: AppTypography.displayMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (historyState.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Clear History',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear Watch History?'),
                    content: const Text('This will remove all playback progress from your history.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  ref.read(watchHistoryProvider.notifier).clearHistory();
                }
              },
            ),
        ],
      ),
      body: !authState.isAuthenticated
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.history_rounded, size: 64, color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text('Sign In to View Watch History', style: AppTypography.displayMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Signed-in members have automatic cloud sync for all watched cartoons.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => context.push('/user-login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Sign In Now'),
                    ),
                  ],
                ),
              ),
            )
          : historyState.items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.history_rounded, size: 56, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text('No Watch History Yet', style: AppTypography.displayMedium),
                      const SizedBox(height: 8),
                      Text(
                        'Start playing videos to track your history here.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: historyState.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final h = historyState.items[index];
                    final item = h.contentItem;

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(10),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              item?.thumbnailUrl ?? 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=200',
                              width: 90,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 90,
                                height: 56,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.movie_rounded),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item?.title ?? 'Kids Video',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: h.progressPercentage,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                  minHeight: 4,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  h.completed
                                      ? 'Watched completely'
                                      : 'Resumed at ${(h.lastPositionSeconds ~/ 60)}:${(h.lastPositionSeconds % 60).toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    color: h.completed ? AppColors.success : AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.play_circle_fill_rounded, color: AppColors.primary, size: 36),
                            onPressed: () => context.push('/player/${h.contentId}'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

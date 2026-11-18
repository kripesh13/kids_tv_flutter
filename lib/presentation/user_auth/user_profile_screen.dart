import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/tv/tv_focusable.dart';
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/watch_history_provider.dart';
import '../shared/widgets/kids_button.dart';
import '../shared/widgets/section_header.dart';
import '../shared/widgets/video_card.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isGuest = !authState.isAuthenticated;
    final favoritesState = ref.watch(favoritesProvider);
    final watchHistoryState = ref.watch(watchHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Profile', style: AppTypography.displayMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Header Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isGuest
                          ? [Colors.orange.shade400, Colors.deepOrange.shade400]
                          : [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: (isGuest ? Colors.orange : AppColors.primary).withAlpha(50),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Center(
                          child: Icon(
                            isGuest ? Icons.face_rounded : Icons.child_care_rounded,
                            size: 42,
                            color: isGuest ? Colors.deepOrange : AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isGuest ? 'Guest Explorer' : (user?.displayName ?? 'Kids TV Explorer'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isGuest ? 'Browse public videos & live channels' : user!.email,
                              style: TextStyle(
                                color: Colors.white.withAlpha(220),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(50),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isGuest ? 'Guest Mode' : 'Free Member',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Guest Banner CTA (if not logged in)
                if (isGuest) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.secondary.withAlpha(120), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.stars_rounded, color: AppColors.secondary, size: 28),
                            const SizedBox(width: 10),
                            Text('Unlock Full Kids TV', style: AppTypography.displayMedium),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create a free account to save favorite rhymes, like cartoons, and resume watching right where you left off!',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: KidsButton(
                                label: 'Sign In',
                                icon: Icons.login_rounded,
                                height: 46,
                                onPressed: () => context.push('/user-login'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: KidsButton(
                                label: 'Register Free',
                                icon: Icons.person_add_rounded,
                                variant: KidsButtonVariant.secondary,
                                height: 46,
                                onPressed: () => context.push('/user-register'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Favorites Section
                SectionHeader(
                  title: 'My Favorites (${favoritesState.favoriteItems.length})',
                  emoji: '💖',
                  onSeeAll: favoritesState.favoriteItems.isNotEmpty
                      ? () => context.push('/favorites')
                      : null,
                ),
                const SizedBox(height: 12),
                if (isGuest)
                  _buildGuestRestrictedCard(
                    context,
                    title: 'Favorites are locked for Guests',
                    subtitle: 'Sign in to keep your child\'s favorite shows in one quick place.',
                  )
                else if (favoritesState.favoriteItems.isEmpty)
                  _buildEmptyState(
                    icon: Icons.favorite_border_rounded,
                    message: 'No favorites yet! Tap the heart on any video to save it here.',
                  )
                else
                  SizedBox(
                    height: 210,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: favoritesState.favoriteItems.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final item = favoritesState.favoriteItems[index];
                        return VideoCard(
                          item: item,
                          width: 220,
                          onTap: () => context.push('/video/${item.id}'),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 28),

                // Watch History / Continue Watching Section
                SectionHeader(
                  title: 'Watch History (${watchHistoryState.items.length})',
                  emoji: '🕒',
                  onSeeAll: watchHistoryState.items.isNotEmpty
                      ? () => context.push('/history')
                      : null,
                ),
                const SizedBox(height: 12),
                if (isGuest)
                  _buildGuestRestrictedCard(
                    context,
                    title: 'Watch History is locked for Guests',
                    subtitle: 'Sign in to track progress and continue watching across devices.',
                  )
                else if (watchHistoryState.items.isEmpty)
                  _buildEmptyState(
                    icon: Icons.history_rounded,
                    message: 'No watch history yet. Start streaming to track your shows!',
                  )
                else
                  Column(
                    children: watchHistoryState.items.take(4).map((h) {
                      final item = h.contentItem;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                item?.thumbnailUrl ?? 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=200',
                                width: 80,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  width: 80,
                                  height: 50,
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
                                  Text(
                                    h.completed
                                        ? 'Watched completely'
                                        : 'Progress: ${(h.progressPercentage * 100).toInt()}%',
                                    style: TextStyle(
                                      color: h.completed ? AppColors.success : AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.play_circle_fill_rounded, color: AppColors.primary, size: 32),
                              onPressed: () => context.push('/player/${h.contentId}'),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 32),

                // Account Actions
                if (!isGuest) ...[
                  TvFocusable(
                    onPressed: () async {
                      await ref.read(authProvider.notifier).signOut();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Logged out of Kids TV')),
                        );
                        context.go('/');
                      }
                    },
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await ref.read(authProvider.notifier).signOut();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Logged out of Kids TV')),
                          );
                          context.go('/');
                        }
                      },
                      icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                      label: const Text('Log Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.error.withAlpha(80)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuestRestrictedCard(BuildContext context, {required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondary.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_outline_rounded, color: AppColors.secondary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push('/user-login'),
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

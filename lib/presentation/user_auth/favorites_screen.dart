import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import '../shared/widgets/video_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final favState = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Favorite Shows', style: AppTypography.displayMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: !authState.isAuthenticated
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.favorite_border_rounded, size: 64, color: AppColors.secondary),
                    const SizedBox(height: 16),
                    Text('Sign In to Save Favorites', style: AppTypography.displayMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Keep all your child\'s favorite cartoons and songs saved in one place.',
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
          : favState.favoriteItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite_border_rounded, size: 56, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text('No Favorites Saved Yet', style: AppTypography.displayMedium),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the heart icon on any cartoon or song to add it here!',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.82,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: favState.favoriteItems.length,
                  itemBuilder: (context, index) {
                    final item = favState.favoriteItems[index];
                    return VideoCard(
                      item: item,
                      onTap: () => context.push('/video/${item.id}'),
                    );
                  },
                ),
    );
  }
}

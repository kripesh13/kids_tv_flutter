import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/tv/tv_focusable.dart';
import '../../../data/models/banner_model.dart';

class BannerCarousel extends StatefulWidget {
  final List<BannerModel> banners;
  final ValueChanged<BannerModel>? onBannerTap;
  final double height;
  final bool isDark;

  const BannerCarousel({
    super.key,
    required this.banners,
    this.onBannerTap,
    this.height = 200,
    this.isDark = false,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.94);
    _startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer?.cancel();
    if (widget.banners.length <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_pageController.hasClients) {
        final next = (_currentIndex + 1) % widget.banners.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.banners.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: TvFocusable(
                  onPressed: () => widget.onBannerTap?.call(banner),
                  borderRadius: BorderRadius.circular(22),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background Banner Image
                        CachedNetworkImage(
                          imageUrl: banner.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            decoration: const BoxDecoration(
                              gradient: AppColors.primaryGradient,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: widget.isDark
                                ? AppColors.tvCard
                                : AppColors.cardSecondary,
                          ),
                        ),

                        // Gradient Shade
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.black.withAlpha(200),
                                Colors.black.withAlpha(120),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),

                        // Content Details
                        Positioned(
                          left: 20,
                          bottom: 20,
                          top: 20,
                          right: 100,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'FEATURED',
                                  style: AppTypography.labelLarge.copyWith(
                                    color: AppColors.text,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                banner.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: (widget.isDark
                                        ? AppTypography.tvHeadline
                                        : AppTypography.displayMedium)
                                    .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (banner.subtitle != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  banner.subtitle!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: Colors.white70,
                                    fontSize: widget.isDark ? 15 : 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Watch Button Icon
                        Positioned(
                          right: 20,
                          bottom: 20,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black45,
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Animated Dots Indicator
        if (widget.banners.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.banners.length,
              (index) {
                final isSelected = index == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isSelected ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (widget.isDark ? AppColors.secondary : AppColors.primary)
                        : (widget.isDark ? Colors.white24 : AppColors.primary.withAlpha(50)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

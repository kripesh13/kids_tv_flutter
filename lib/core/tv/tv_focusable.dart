import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'tv_key_handler.dart';

class TvFocusable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final FocusNode? focusNode;
  final bool autofocus;
  final double scaleFactor;
  final BorderRadius? borderRadius;
  final Color focusBorderColor;
  final Color? focusGlowColor;
  final EdgeInsetsGeometry padding;
  final bool autoScroll;
  final double scrollAlignment;
  final ValueChanged<bool>? onFocusChange;

  const TvFocusable({
    super.key,
    required this.child,
    this.onPressed,
    this.focusNode,
    this.autofocus = false,
    this.scaleFactor = 1.06,
    this.borderRadius,
    this.focusBorderColor = AppColors.tvFocusBorder,
    this.focusGlowColor,
    this.padding = EdgeInsets.zero,
    this.autoScroll = true,
    this.scrollAlignment = 0.5,
    this.onFocusChange,
  });

  @override
  State<TvFocusable> createState() => _TvFocusableState();
}

class _TvFocusableState extends State<TvFocusable>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  bool _isFocused = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChanged);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    ));

    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChanged);
    }
    _animController.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    final focused = _focusNode.hasFocus;
    if (_isFocused != focused) {
      setState(() {
        _isFocused = focused;
      });
      widget.onFocusChange?.call(focused);

      if (focused) {
        _animController.forward();
        if (widget.autoScroll && mounted) {
          Scrollable.ensureVisible(
            context,
            alignment: widget.scrollAlignment,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOutCubic,
          );
        }
      } else {
        _animController.reverse();
      }
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (TvKeyHandler.isSelectKey(event)) {
      widget.onPressed?.call();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.borderRadius ?? BorderRadius.circular(16);
    final glow = widget.focusGlowColor ?? AppColors.tvFocusGlow;

    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTap: () {
          _focusNode.requestFocus();
          widget.onPressed?.call();
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: widget.padding,
                decoration: BoxDecoration(
                  borderRadius: r,
                  boxShadow: _isFocused
                      ? [
                          BoxShadow(
                            color: glow,
                            blurRadius: 18,
                            spreadRadius: 3,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : const [],
                  border: _isFocused
                      ? Border.all(
                          color: widget.focusBorderColor,
                          width: 3.2,
                        )
                      : Border.all(
                          color: Colors.transparent,
                          width: 3.2,
                        ),
                ),
                child: ClipRRect(
                  borderRadius: r,
                  child: child,
                ),
              ),
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

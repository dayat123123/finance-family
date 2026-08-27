import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/liquid_glass_theme.dart';

/// Classy Luxury Diffused Background for Glassmorphism
class LiquidGlassBackground extends StatelessWidget {
  final Widget child;
  final bool showFloatingOrbs;

  const LiquidGlassBackground({
    super.key,
    required this.child,
    this.showFloatingOrbs = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: LiquidGlassTheme.backgroundDark,
      child: Stack(
        children: [
          if (showFloatingOrbs) ...[
            // Top Right Subtle Indigo Ambient Aura
            Positioned(
              top: -100,
              right: -80,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      LiquidGlassTheme.primaryViolet.withValues(alpha: 0.12),
                      const Color(0xFF4F46E5).withValues(alpha: 0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Top Left Soft Sapphire Light
            Positioned(
              top: 180,
              left: -100,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      LiquidGlassTheme.secondaryCyan.withValues(alpha: 0.08),
                      LiquidGlassTheme.secondaryAqua.withValues(alpha: 0.02),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Emerald / Muted Ambient Glow
            Positioned(
              bottom: 60,
              left: -60,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      LiquidGlassTheme.surplusEmerald.withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],

          // Content Layer
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

/// Core Glassmorphic Container with BackdropFilter and gradient border
class LiquidGlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final Gradient? gradient;
  final Color? color;
  final Gradient? borderGradient;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;

  const LiquidGlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = LiquidGlassTheme.glassBorderRadius,
    this.blur = LiquidGlassTheme.glassBlur,
    this.gradient,
    this.color,
    this.borderGradient,
    this.borderColor,
    this.borderWidth = 1.0,
    this.boxShadow,
    this.onTap,
    this.width,
    this.height,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = BorderRadius.circular(borderRadius);

    Widget content = Container(
      width: width,
      height: height,
      alignment: alignment,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? (gradient == null ? null : Colors.transparent),
        gradient: color == null
            ? (gradient ?? LiquidGlassTheme.glassSurfaceGradient)
            : null,
        borderRadius: effectiveBorderRadius,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
      ),
      child: child,
    );

    // Hairline gradient specular border
    if (borderColor == null && borderWidth > 0) {
      content = CustomPaint(
        painter: _GradientBorderPainter(
          borderRadius: borderRadius,
          borderWidth: borderWidth,
          gradient: borderGradient ?? LiquidGlassTheme.glassBorderGradient,
        ),
        child: content,
      );
    }

    Widget glassCard = ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: content,
      ),
    );

    if (onTap != null) {
      glassCard = Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: effectiveBorderRadius,
          onTap: onTap,
          splashColor: Colors.white.withValues(alpha: 0.08),
          highlightColor: Colors.white.withValues(alpha: 0.04),
          child: glassCard,
        ),
      );
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: effectiveBorderRadius,
        boxShadow: boxShadow ?? LiquidGlassTheme.glassShadow,
      ),
      child: glassCard,
    );
  }
}

/// Custom painter for ultra-clean gradient specular borders on frosted glass
class _GradientBorderPainter extends CustomPainter {
  final double borderRadius;
  final double borderWidth;
  final Gradient gradient;

  _GradientBorderPainter({
    required this.borderRadius,
    required this.borderWidth,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.gradient != gradient;
  }
}

/// Dedicated, proportionate, perfectly-bounded Circular Glass Back Button
class LiquidGlassBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final double size;

  const LiquidGlassBackButton({
    super.key,
    this.onPressed,
    this.icon = Icons.arrow_back_ios_new_rounded,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              splashColor: Colors.white.withValues(alpha: 0.15),
              highlightColor: Colors.white.withValues(alpha: 0.08),
              onTap: onPressed ?? () => Navigator.maybePop(context),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dedicated, proportionate, perfectly-bounded Circular Glass Icon Button
class LiquidGlassIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color? iconColor;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color? borderColor;
  final double size;
  final String? tooltip;

  const LiquidGlassIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.iconColor,
    this.gradient,
    this.backgroundColor,
    this.borderColor,
    this.size = 40.0,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    Widget btn = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              splashColor: Colors.white.withValues(alpha: 0.15),
              highlightColor: Colors.white.withValues(alpha: 0.08),
              onTap: onPressed,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: gradient == null
                      ? (backgroundColor ??
                          Colors.white.withValues(alpha: 0.07))
                      : null,
                  gradient: gradient,
                  border: Border.all(
                    color: borderColor ?? Colors.white.withValues(alpha: 0.18),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: iconColor ?? Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: btn);
    }
    return btn;
  }
}

/// Glowing Liquid Gradient Button
class LiquidGlassButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final Gradient? gradient;
  final Color? glowColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool isFullWidth;
  final bool isLoading;

  const LiquidGlassButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.gradient,
    this.glowColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    this.borderRadius = 30.0,
    this.isFullWidth = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradient =
        gradient ?? LiquidGlassTheme.primaryLiquidGradient;
    final effectiveGlow = glowColor ?? LiquidGlassTheme.primaryViolet;

    Widget buttonContent = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        else ...[
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
                letterSpacing: 0.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );

    return Container(
      width: isFullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: effectiveGlow.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            child: Ink(
              padding: padding,
              decoration: BoxDecoration(
                gradient: effectiveGradient,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: buttonContent,
            ),
          ),
        ),
      ),
    );
  }
}

/// Liquid Glass Badge / Pill
class LiquidGlassBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool isGlowing;
  final EdgeInsetsGeometry padding;

  const LiquidGlassBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.isGlowing = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: isGlowing ? 0.5 : 0.2),
          width: 1,
        ),
        boxShadow: isGlowing
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 4),
          ] else ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.7),
                    blurRadius: 4,
                  )
                ],
              ),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Liquid Progress Bar with glowing gradient fill
class LiquidProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final Gradient? gradient;
  final Color? color;
  final double height;
  final Color backgroundColor;

  const LiquidProgressBar({
    super.key,
    required this.value,
    this.gradient,
    this.color,
    this.height = 8.0,
    this.backgroundColor = Colors.white10,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    final effectiveGradient = gradient ??
        (color != null
            ? LinearGradient(colors: [color!, color!])
            : LiquidGlassTheme.primaryLiquidGradient);

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                width: constraints.maxWidth * clamped,
                height: height,
                decoration: BoxDecoration(
                  gradient: effectiveGradient,
                  borderRadius: BorderRadius.circular(height / 2),
                  boxShadow: [
                    BoxShadow(
                      color: (color ?? LiquidGlassTheme.primaryViolet)
                          .withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Avatar Pill / Circle with initial monogram and subtle glass styling
class FamilyActorBadge extends StatelessWidget {
  final String fullName;
  final Color? accentColor;
  final double size;

  const FamilyActorBadge({
    super.key,
    required this.fullName,
    this.accentColor,
    this.size = 28.0,
  });

  @override
  Widget build(BuildContext context) {
    final isHidayat = fullName.toLowerCase().contains('hidayat');
    final color = accentColor ??
        (isHidayat
            ? LiquidGlassTheme.actorHidayat
            : LiquidGlassTheme.actorDeasy);
    final initial = isHidayat ? 'H' : 'D';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.8),
            color.withValues(alpha: 0.3),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 6,
          )
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.45,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

/// Quick selection chip for fast suggestions in form popups
class LiquidQuickChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isSelected;
  final Color? activeColor;

  const LiquidQuickChip({
    super.key,
    required this.label,
    this.icon,
    required this.onTap,
    this.isSelected = false,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = activeColor ?? LiquidGlassTheme.primaryVioletLight;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? effectiveColor.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? effectiveColor.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.08),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isSelected ? effectiveColor : Colors.white70,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Premium Liquid Glass Dialog with Keyboard safety and glowing header
class LiquidGlassDialog extends StatelessWidget {
  final IconData icon;
  final Gradient? iconGradient;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final Widget content;
  final List<Widget> actions;

  const LiquidGlassDialog({
    super.key,
    required this.icon,
    this.iconGradient,
    this.iconColor,
    required this.title,
    this.subtitle,
    required this.content,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = iconColor ?? LiquidGlassTheme.primaryVioletLight;
    final effectiveGradient =
        iconGradient ?? LiquidGlassTheme.primaryLiquidGradient;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: LiquidGlassContainer(
        borderRadius: 28,
        padding: const EdgeInsets.all(22),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.25),
            effectiveColor.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Icon & Title Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: effectiveGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: effectiveColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  LiquidGlassBackButton(
                    icon: Icons.close_rounded,
                    size: 34,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Subtle Divider
              Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.06),
              ),
              const SizedBox(height: 18),

              // Content Body
              content,

              const SizedBox(height: 22),

              // Action Buttons Row
              Row(
                children: actions
                    .map((action) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: action,
                          ),
                        ))
                    .toList(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

/// Frosted Glass Selector Tile (Modern Liquid Glass replacement for DropdownButton)
class LiquidGlassSelectorTile extends StatelessWidget {
  final String label;
  final String value;
  final Widget? leading;
  final VoidCallback onTap;
  final Color? activeColor;
  final bool enabled;

  const LiquidGlassSelectorTile({
    super.key,
    required this.label,
    required this.value,
    this.leading,
    required this.onTap,
    this.activeColor,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassContainer(
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onTap: enabled ? onTap : null,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (enabled) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white.withValues(alpha: 0.7),
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Responsive wrapper widget that constrains content width on large screens
/// and centers it for better readability on desktop/web
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets? padding;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        child: padding != null
            ? Padding(
                padding: padding!,
                child: child,
              )
            : child,
      ),
    );
  }
}

/// Responsive padding that adapts to screen size
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets mobilePadding;
  final EdgeInsets? desktopPadding;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobilePadding = const EdgeInsets.all(16.0),
    this.desktopPadding,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;
    
    return Padding(
      padding: isDesktop
          ? (desktopPadding ?? const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0))
          : mobilePadding,
      child: child,
    );
  }
}

/// Responsive text size that adapts to screen width
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double mobileFontSize;
  final double? desktopFontSize;
  final TextAlign? textAlign;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.mobileFontSize = 14.0,
    this.desktopFontSize,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;
    final fontSize = isDesktop
        ? (desktopFontSize ?? mobileFontSize * 1.1)
        : mobileFontSize;

    return Text(
      text,
      style: style?.copyWith(fontSize: fontSize) ?? TextStyle(fontSize: fontSize),
      textAlign: textAlign,
    );
  }
}


import 'package:flutter/material.dart';
import 'glass_container.dart';

class GlassButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final double? width;
  final double height;
  final Color? color;
  final BorderRadiusGeometry borderRadius;

  const GlassButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.width,
    this.height = 56.0,
    this.color,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: borderRadius as BorderRadius,
        child: GlassContainer(
          width: width,
          height: height,
          borderRadius: borderRadius,
          blur: 12.0,
          child: Center(
            child: DefaultTextStyle(
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

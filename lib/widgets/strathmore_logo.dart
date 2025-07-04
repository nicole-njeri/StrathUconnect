import 'package:flutter/material.dart';

/// A custom Flutter widget that draws the Strathmore University logo using vector graphics.
/// This avoids asset/image dependencies and ensures crisp rendering at any size.
class StrathmoreLogo extends StatelessWidget {
  final double size;
  const StrathmoreLogo({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _StrathmoreLogoPainter()),
    );
  }
}

class _StrathmoreLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw shield background (red and blue halves)
    paint.color = const Color(0xFF0A2B6B); // Blue
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, h),
        Radius.circular(w * 0.18),
      ),
      paint,
    );
    paint.color = const Color(0xFFD32F2F); // Red
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w * 0.5, h),
        Radius.circular(w * 0.18),
      ),
      paint,
    );

    // Draw yellow cross
    paint.color = const Color(0xFFFFC107);
    final crossWidth = w * 0.14;
    final crossRectV = Rect.fromLTWH(w * 0.43, h * 0.18, crossWidth, h * 0.64);
    final crossRectH = Rect.fromLTWH(w * 0.18, h * 0.43, w * 0.64, crossWidth);
    canvas.drawRect(crossRectV, paint);
    canvas.drawRect(crossRectH, paint);

    // Optional: Add more details for realism (e.g., border, text, etc.)
    paint.style = PaintingStyle.stroke;
    paint.color = Colors.black.withOpacity(0.18);
    paint.strokeWidth = w * 0.04;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, h),
        Radius.circular(w * 0.18),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

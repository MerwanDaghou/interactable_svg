import 'package:flutter/material.dart';

import '../models/region.dart';
import '../size_controller.dart';

class RegionPainter extends CustomPainter {
  final Region region;
  final List<String> selectedRegion;
  final Color? strokeColor;
  final Color? selectedColor;
  final Color? dotColor;
  final double? strokeWidth;
  final double? centerDotWidth;
  final bool? centerTextEnable;
  final TextStyle? centerTextStyle;
  final String? unSelectableId;

  final sizeController = SizeController.instance;

  double _scale = 1.0;

  RegionPainter({
    required this.region,
    required this.selectedRegion,
    this.selectedColor,
    this.strokeColor,
    this.dotColor,
    this.centerDotWidth = 3,
    this.centerTextEnable,
    this.centerTextStyle,
    this.strokeWidth,
    this.unSelectableId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pen = Paint()
      ..color = strokeColor ?? Colors.black45
      ..strokeWidth = strokeWidth ?? 1.0
      ..style = PaintingStyle.stroke;

    final selectedPen = Paint()
      ..color = selectedColor ?? Colors.blue
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill;

    final redDot = Paint()
      ..color = dotColor ?? Colors.red
      ..strokeWidth = 3.0
      ..style = PaintingStyle.fill;

    final bounds = region.path.getBounds();

    _scale = sizeController.calculateScale(size);
    canvas.scale(_scale);

    if (selectedRegion.where((element) => element == region.id).isNotEmpty) {
      canvas.drawPath(region.path, selectedPen);
    }
    if (centerDotWidth != null && region.id != unSelectableId) {
      canvas.drawCircle(bounds.center, centerDotWidth!, redDot);
    }
    if ((centerTextEnable ?? false) && region.id != unSelectableId) {
      TextSpan span = TextSpan(
          style: centerTextStyle ?? const TextStyle(color: Colors.black),
          text: region.name);
      TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, bounds.center);
    }

    canvas.drawPath(region.path, pen);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  @override
  bool hitTest(Offset position) {
    double inverseScale = sizeController.inverseOfScale(_scale);
    return region.path.contains(position.scale(inverseScale, inverseScale));
  }
}

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StudentPainter extends CustomPainter {
  final int total;
  final int present;

  StudentPainter({this.total, this.present});

  @override
  void paint(Canvas canvas, Size size) {
    var centerX = size.width / 2;
    var centerY = size.height / 2;

    var center = Offset(centerX, centerY);

    var radius = min(centerX, centerY);

    var paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30.0;

    var paint1 = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30.0;
    var sweepAngle = present / total * 2 * pi;

    canvas.drawCircle(center, radius, paint);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2,
        sweepAngle, false, paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

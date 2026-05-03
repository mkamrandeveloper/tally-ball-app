import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/game_models.dart';

class TargetDiagram extends StatelessWidget {
  final TargetZone? highlightedZone;
  final double height;

  const TargetDiagram({
    super.key,
    this.highlightedZone,
    this.height = 250,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final currentHeight = constraints.maxHeight != double.infinity ? constraints.maxHeight : height;
        return Container(
          height: currentHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.colors.bgSecondary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.border),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background net lines
              CustomPaint(
                size: Size(double.infinity, currentHeight),
                painter: _NetPainter(color: context.colors.textTertiary.withOpacity(0.1)),
              ),
              
              // Goalpost Frame
              Positioned(
                top: 20,
                bottom: 0,
                left: 20,
                right: 20,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: context.colors.textPrimary, width: 6),
                      left: BorderSide(color: context.colors.textPrimary, width: 6),
                      right: BorderSide(color: context.colors.textPrimary, width: 6),
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                ),
              ),
              
              // Top Left Target (20 pts)
              Positioned(
                top: 22,
                left: 24,
                child: _buildTarget(context, TargetZone.topLeft, '20', 'Top Left'),
              ),
              
              // Top Right Target (20 pts)
              Positioned(
                top: 22,
                right: 24,
                child: _buildTarget(context, TargetZone.topRight, '20', 'Top Right'),
              ),
              
              // Dead Center Target (30 pts)
              Positioned(
                top: currentHeight / 2 - 40,
                child: _buildTarget(context, TargetZone.center, '30', 'Center'),
              ),
              
              // Bottom Left Target (10 pts)
              Positioned(
                bottom: 10,
                left: 24,
                child: _buildTarget(context, TargetZone.bottomLeft, '10', 'Bottom Left'),
              ),
              
              // Bottom Right Target (10 pts)
              Positioned(
                bottom: 10,
                right: 24,
                child: _buildTarget(context, TargetZone.bottomRight, '10', 'Bottom Right'),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildTarget(BuildContext context, TargetZone zone, String pts, String label) {
    final isHighlighted = highlightedZone == zone;
    final double circleSize = isHighlighted ? 58 : 50;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isHighlighted ? context.colors.precisionBlue : context.colors.bgCard,
            border: Border.all(
              color: isHighlighted ? context.colors.optimisticYellow : context.colors.precisionBlue,
              width: isHighlighted ? 3 : 2,
            ),
            boxShadow: isHighlighted
                ? [BoxShadow(color: context.colors.blueGlow, blurRadius: 15, spreadRadius: 5)]
                : [],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  pts,
                  style: TextStyle(
                    fontSize: isHighlighted ? 18 : 15,
                    fontWeight: FontWeight.bold,
                    color: isHighlighted ? context.colors.textPrimary : context.colors.precisionBlue,
                    height: 1.1,
                  ),
                ),
                Text(
                  'pts',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: isHighlighted
                        ? context.colors.textPrimary.withOpacity(0.7)
                        : context.colors.precisionBlue.withOpacity(0.6),
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            fontSize: 9,
            fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w600,
            letterSpacing: 0.5,
            color: isHighlighted
                ? context.colors.optimisticYellow
                : context.colors.textSecondary,
          ),
          child: Text(label.toUpperCase()),
        ),
      ],
    );
  }
}

class _NetPainter extends CustomPainter {
  final Color color;

  _NetPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    // Draw grid pattern inside goalpost area roughly
    const double margin = 20;
    const double startY = 20;
    final double endY = size.height;
    const double spacing = 15;

    for (double x = margin; x <= size.width - margin; x += spacing) {
      canvas.drawLine(Offset(x, startY), Offset(x, endY), paint);
    }
    
    for (double y = startY; y <= endY; y += spacing) {
      canvas.drawLine(Offset(margin, y), Offset(size.width - margin, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

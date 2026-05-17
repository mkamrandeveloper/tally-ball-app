import 'package:flutter/material.dart';
import '../models/game_models.dart';

/// Football goal target diagram.
///
/// Turf-green gradient background, white goalpost frame with visible corner
/// joints, realistic net mesh, and colour-coded targets at the 4 inner
/// corners + center. Shared across Practice, VS, and Match modes for
/// guaranteed visual consistency.
///
///   ┌──────────────────────────────────────────┐
///   │ [TL 20]  ── crossbar ──  [TR 20]         │
///   │  |                               |        │
///   │  |         [CTR 30]              |        │
///   │  |                               |        │
///   │ [BL 10]                [BR 10]  │
///   └──────────────────────────────────────────┘
class TargetDiagram extends StatelessWidget {
  final TargetZone? highlightedZone;
  final double height;

  const TargetDiagram({
    super.key,
    this.highlightedZone,
    this.height = 260,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final h = constraints.maxHeight != double.infinity
          ? constraints.maxHeight
          : height;

      return Container(
        height: h,
        width: double.infinity,
        decoration: BoxDecoration(
          // Clean turf-green gradient — realistic training environment feel
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E7D32), // deep turf green at top (net depth)
              Color(0xFF388E3C), // mid pitch
              Color(0xFF43A047), // lighter at base (near camera)
            ],
            stops: [0.0, 0.55, 1.0],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF1B5E20).withValues(alpha: 0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // ── 1. Realistic net grid (tight white mesh) ──
              Positioned.fill(
                child: CustomPaint(
                  painter: _NetPainter(),
                ),
              ),

              // ── 2. Goalpost frame drawn with CustomPainter ──
              Positioned.fill(
                child: CustomPaint(
                  painter: _GoalPainter(
                    postColor: Colors.white,
                    cornerColor: const Color(0xFFFFD54F), // amber joint
                    shadowColor: Colors.black.withValues(alpha: 0.25),
                  ),
                ),
              ),

              // ── 3. Targets ──
              _TargetOverlay(highlightedZone: highlightedZone),
            ],
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────
// Realistic net painter — tight white mesh inside goal frame
// ─────────────────────────────────────────────────────────────
class _NetPainter extends CustomPainter {
  const _NetPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Net only inside the goal opening
    const double l = 40.0;  // match _GoalPainter._frameL + _postW
    const double t = 36.0;  // match crossbar bottom
    final double r = size.width - 40.0;
    final double b = size.height;

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..strokeWidth = 0.7;

    const double spacing = 14.0;

    // Vertical strands
    for (double x = l; x <= r; x += spacing) {
      canvas.drawLine(Offset(x, t), Offset(x, b), linePaint);
    }
    // Horizontal strands
    for (double y = t; y <= b; y += spacing) {
      canvas.drawLine(Offset(l, y), Offset(r, y), linePaint);
    }

    // Subtle diagonal tension lines for depth
    final diagPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 0.5;
    const double dSpacing = 28.0;
    for (double x = l - b; x <= r; x += dSpacing) {
      canvas.drawLine(Offset(x, t), Offset(x + b, b), diagPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _NetPainter old) => false;
}

// ─────────────────────────────────────────────────────────────
// Goalpost painter — white frame with corner joints, no text
// ─────────────────────────────────────────────────────────────
class _GoalPainter extends CustomPainter {
  final Color postColor;
  final Color cornerColor;
  final Color shadowColor;

  const _GoalPainter({
    required this.postColor,
    required this.cornerColor,
    required this.shadowColor,
  });

  // Shared geometry — keep in sync with _TargetOverlay and _NetPainter
  static const double _frameL  = 32.0;   // left post X
  static const double _frameT  = 28.0;   // crossbar top Y
  static const double _postW   = 8.0;    // post thickness
  static const double _cornerR = 5.0;    // corner joint radius

  @override
  void paint(Canvas canvas, Size size) {
    final double frameR = size.width - _frameL;
    final double frameB = size.height;

    // ── Drop shadow layer ──
    final shadowPaint = Paint()
      ..color = shadowColor
      ..style = PaintingStyle.fill;
    _drawPost(canvas, Rect.fromLTWH(_frameL + 3, _frameT + 3, _postW, frameB - _frameT), shadowPaint);
    _drawPost(canvas, Rect.fromLTWH(frameR - _postW + 3, _frameT + 3, _postW, frameB - _frameT), shadowPaint);
    _drawPost(canvas, Rect.fromLTWH(_frameL + 3, _frameT + 3, frameR - _frameL, _postW), shadowPaint);

    // ── Post gradient paint (gives a 3-D tube feel) ──
    final postPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFFFFF), Color(0xFFCFD8DC)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Left post
    _drawPost(canvas, Rect.fromLTWH(_frameL, _frameT, _postW, frameB - _frameT), postPaint);
    // Right post
    _drawPost(canvas, Rect.fromLTWH(frameR - _postW, _frameT, _postW, frameB - _frameT), postPaint);
    // Crossbar
    _drawPost(canvas, Rect.fromLTWH(_frameL, _frameT, frameR - _frameL, _postW), postPaint);

    // ── Corner joint bolts (amber accent) ──
    final cornerPaint = Paint()
      ..color = cornerColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(_frameL + _postW / 2, _frameT + _postW / 2),
      _postW * 0.85,
      cornerPaint,
    );
    canvas.drawCircle(
      Offset(frameR - _postW / 2, _frameT + _postW / 2),
      _postW * 0.85,
      cornerPaint,
    );

    // ── Ground line ──
    final groundPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.30)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(_frameL - 16, frameB - 2),
      Offset(frameR + 16, frameB - 2),
      groundPaint,
    );
  }

  void _drawPost(Canvas canvas, Rect rect, Paint paint) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(_cornerR)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _GoalPainter old) =>
      old.postColor != postColor || old.cornerColor != cornerColor;
}

// ─────────────────────────────────────────────────────────────
// Target overlay — positions 5 circles inside the goal frame
// Must mirror _LightGoalPainter geometry
// ─────────────────────────────────────────────────────────────
class _TargetOverlay extends StatelessWidget {
  final TargetZone? highlightedZone;
  const _TargetOverlay({this.highlightedZone});

  static const double _frameL = _GoalPainter._frameL;
  static const double _frameT = _GoalPainter._frameT;
  static const double _postW  = _GoalPainter._postW;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final W = constraints.maxWidth;
      final H = constraints.maxHeight;

      final double goalL = _frameL + _postW;
      final double goalR = W - _frameL - _postW;
      final double goalT = _frameT + _postW;
      // Inset from the inner edge of each post so targets sit inside the goal
      const double hInset = 44.0; // horizontal
      const double vInsetTop = 44.0;
      const double vInsetBot = 44.0;

      final positions = {
        TargetZone.topLeft:     Offset(goalL + hInset,       goalT + vInsetTop),
        TargetZone.topRight:    Offset(goalR - hInset,       goalT + vInsetTop),
        TargetZone.center:      Offset((goalL + goalR) / 2,  (goalT + H) / 2),
        TargetZone.bottomLeft:  Offset(goalL + hInset,       H - vInsetBot),
        TargetZone.bottomRight: Offset(goalR - hInset,       H - vInsetBot),
      };

      return Stack(
        children: positions.entries.map((e) {
          final zone   = e.key;
          final pos    = e.value;
          final isHit  = highlightedZone == zone;

          int    pts;
          Color  zoneColor;
          String label;

          switch (zone) {
            case TargetZone.topLeft:
              pts = 20; zoneColor = const Color(0xFF1565C0); label = 'TOP LEFT';
            case TargetZone.topRight:
              pts = 20; zoneColor = const Color(0xFF1565C0); label = 'TOP RIGHT';
            case TargetZone.center:
              pts = 30; zoneColor = const Color(0xFFB71C1C); label = 'CENTER';
            case TargetZone.bottomLeft:
              pts = 10; zoneColor = const Color(0xFFE65100); label = 'BOT LEFT';
            case TargetZone.bottomRight:
              pts = 10; zoneColor = const Color(0xFFE65100); label = 'BOT RIGHT';
          }

          final double size = isHit ? 62 : 50;

          return Positioned(
            left: pos.dx - size / 2,
            top:  pos.dy - size / 2,
            child: _TargetCircle(
              pts: pts, label: label, color: zoneColor,
              size: size, isHit: isHit,
            ),
          );
        }).toList(),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────
// Individual target circle
// ─────────────────────────────────────────────────────────────
class _TargetCircle extends StatelessWidget {
  final int pts;
  final String label;
  final Color color;
  final double size;
  final bool isHit;

  const _TargetCircle({
    required this.pts,
    required this.label,
    required this.color,
    required this.size,
    required this.isHit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Light fill — white when not hit, solid color when hit
            // On green background: use solid color fill always for legibility
            color: isHit ? color : color.withValues(alpha: 0.85),
            border: Border.all(
              color: Colors.white.withValues(alpha: isHit ? 0.9 : 0.6),
              width: isHit ? 3.0 : 2.0,
            ),
            boxShadow: isHit
                ? [
                    BoxShadow(color: color.withValues(alpha: 0.55), blurRadius: 22, spreadRadius: 6),
                    BoxShadow(color: color.withValues(alpha: 0.20), blurRadius: 40, spreadRadius: 10),
                  ]
                : [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 8, spreadRadius: 1),
                  ],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$pts',
                  style: TextStyle(
                    fontSize: isHit ? 18 : 15,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
                    shadows: [
                      Shadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 4),
                    ],
                  ),
                ),
                Text(
                  'pts',
                  style: TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.0,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 3),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 280),
          style: TextStyle(
            fontSize: 8,
            fontWeight: isHit ? FontWeight.w800 : FontWeight.w600,
            letterSpacing: 0.6,
            color: Colors.white.withValues(alpha: isHit ? 1.0 : 0.80),
            shadows: [
              Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 3),
            ],
          ),
          child: Text(label),
        ),
      ],
    );
  }
}

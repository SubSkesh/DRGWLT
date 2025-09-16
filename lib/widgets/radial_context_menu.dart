import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'radial_action.dart';

class RadialContextMenu extends StatefulWidget {
  final Offset position;
  final List<RadialAction> actions;
  final VoidCallback onClose;

  const RadialContextMenu({
    super.key,
    required this.position,
    required this.actions,
    required this.onClose,
  });

  @override
  State<RadialContextMenu> createState() => _RadialContextMenuState();
}

class _RadialContextMenuState extends State<RadialContextMenu> {
  int? _selectedIndex;
  final double radius = 100.0;
  final double innerRadius = 40.0;
  Offset _center = Offset.zero; // variabile usata per il calcolo del centro della finestra
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateCenter();
    });
  }


  void _calculateCenter() {
    final screen = MediaQuery.of(context).size;
    double cx = widget.position.dx;
    double cy = widget.position.dy;
    const edge = 120.0;

    if (cx < edge) cx = edge;
    if (cy < edge) cy = edge;
    if (cx > screen.width - edge) cx = screen.width - edge;
    if (cy > screen.height - edge) cy = screen.height - edge;

    setState(() {
      _center = Offset(cx, cy);
    });
  }



  void _safeClose() {
    if (!_isClosing) {
      _isClosing = true;
      widget.onClose();// this
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Full screen gesture detector to capture all touches
        Positioned.fill(// widget che contiene l'intero schermo si occupa con gesture detector di tutta la finestra
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,//
        onPanUpdate: (details) {
          final dx = details.globalPosition.dx - _center.dx;
          final dy = details.globalPosition.dy - _center.dy;
          final dist = sqrt(dx * dx + dy * dy);

          if (dist < innerRadius || dist > radius) {
            setState(() => _selectedIndex = null);
            return;
          }

          final angle = atan2(dy, dx);
          final sector = (_angleToIndex(angle, widget.actions.length) + widget.actions.length) % widget.actions.length;

          if (sector != _selectedIndex) {
            setState(() => _selectedIndex = sector);
            HapticFeedback.selectionClick();
          }
        }
,
            onPanEnd: (_) async {
              if (_selectedIndex != null) {
                widget.actions[_selectedIndex!].onSelect();
              }
              _safeClose();
            },
            onPanCancel: () {
              _safeClose();
            },
            onTap: () {
              _safeClose();
            },
          ),
        ),
        // The radial menu
        Positioned(
          left: _center.dx - radius,
          top: _center.dy - radius,
          /*- Sottraendo radius da _center.dx e _center.dy,
           l’angolo in alto a sinistra del widget viene spostato affinché
           il centro del widget coincida con _center
          */
          child: Container(
            width: radius * 2,
            height: radius * 2,
            child: CustomPaint(//- è un widget che delega il disegno a un CustomPainter.

            painter: _PieMenuPainter(
                actions: widget.actions,
                selectedIndex: _selectedIndex,
                innerRadius: innerRadius,
              ),
            ),
          ),
        ),
        // Add icons in the middle of each sector
        for (int i = 0; i < widget.actions.length; i++)
          _buildSectorIcon(
            widget.actions[i],
            i,
            widget.actions.length,
            _center.dx,
            _center.dy,
            radius,
            innerRadius,
            _selectedIndex,
            Theme.of(context),
          ),
      ],
    );
  }

  Widget _buildSectorIcon(
      RadialAction action,
      int index,
      int count,
      double cx,
      double cy,
      double radius,
      double innerRadius,
      int? selectedIndex,
      ThemeData theme,
      ) {
    final middleRadius = (innerRadius + radius) / 2;
    final angle = 2 * pi * index / count - pi / 2 + pi / count;
    final dx = cos(angle) * middleRadius;
    final dy = sin(angle) * middleRadius;

    final isSelected = selectedIndex == index;

    return Positioned(
      left: cx + dx - 15,
      top: cy + dy - 15,
      child: Container(
        width: 30,
        height: 30,
        decoration: isSelected
            ? BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        )
            : null,
        child: Icon(
          action.icon,
          color: isSelected
              ? Colors.white
              : action.color ?? const Color(0xFFE3B873),
          size: 24,
        ),
      ),
    );
  }

  int _angleToIndex(double angle, int count) {
    final normalized = (angle + 2 * pi) % (2 * pi);
    final sectorSize = 2 * pi / count;
    return (normalized ~/ sectorSize);
  }
}

class _PieMenuPainter extends CustomPainter {
  final List<RadialAction> actions;
  final int? selectedIndex;
  final double innerRadius;

  _PieMenuPainter({
    required this.actions,
    required this.selectedIndex,
    required this.innerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sweepAngle = 2 * pi / actions.length;

    // Draw all unselected sectors first
    for (int i = 0; i < actions.length; i++) {
      if (i == selectedIndex) continue;

      final startAngle = i * sweepAngle - pi / 2;//angolo di inizio del settore

      final paint = Paint()
        ..color = const Color(0xFF1F1F1F).withOpacity(0.8)
        ..style = PaintingStyle.fill;

      final path = Path()//
        ..moveTo(center.dx, center.dy)//posiziona il punto di partenza al centro del cerchio
        ..lineTo(
          center.dx + cos(startAngle) * innerRadius,
          center.dy + sin(startAngle) * innerRadius,
        )
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
        )
        ..lineTo(center.dx, center.dy)
        ..close();

      canvas.drawPath(path, paint);//esegue il rendering di ciascun percorso col relativo Paint, popolando il cerchio con tutte le fette non selezionate.

    }

    // Draw selected sector on top (if any)
    if (selectedIndex != null) {
      final startAngle = selectedIndex! * sweepAngle - pi / 2;

      final selectedPaint = Paint()
        ..color = actions[selectedIndex!].color ?? const Color(0xFFE3B873)
        ..style = PaintingStyle.fill;

      final selectedPath = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + cos(startAngle) * innerRadius,
          center.dy + sin(startAngle) * innerRadius,
        )
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
        )
        ..lineTo(center.dx, center.dy)
        ..close();

      canvas.drawPath(selectedPath, selectedPaint);

      // Add a subtle glow around the selected sector
      final glowPaint = Paint()
        ..color = actions[selectedIndex!].color ?? const Color(0xFFE3B873)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

      canvas.drawPath(selectedPath, glowPaint);
    }

    // Draw inner circle
    final innerCirclePaint = Paint()
      ..color = const Color(0xFF121212)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, innerRadius, innerCirclePaint);
  }

  @override
  bool shouldRepaint(covariant _PieMenuPainter oldDelegate) {
    return oldDelegate.actions != actions ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}
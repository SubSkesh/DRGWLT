import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContextAction {
  final IconData icon;
  final String label;
  final Color? color;
  const ContextAction({
    required this.icon,
    required this.label,
    this.color,
  });
}

// Track if a menu is currently open
bool _isMenuOpen = false;

Future<int?> showDragContextMenu(
    BuildContext context,
    Offset globalPosition,
    List<ContextAction> actions, {
      bool applyOnHover = true,
    }) async
{


  assert(actions.isNotEmpty);

  // Ottieni il container dal context
  final container = ProviderScope.containerOf(context, listen: false);

  // Prevent multiple menus from opening
  if (container.read(menuOpenProvider)) return null;
  container.read(menuOpenProvider.notifier).setOpen(true);

  final overlay = Overlay.of(context);
  if (overlay == null) {
    container.read(menuOpenProvider.notifier).setOpen(false);
    return null;
  }

  final screen = MediaQuery.of(context).size;
  final itemSize = 72.0;
  final spacing = 8.0;
  final menuWidth = actions.length * itemSize + (actions.length - 1) * spacing;
  const edgePadding = 16.0;

  // Calculate position with bounds checking
  double left = globalPosition.dx - menuWidth / 2;
  if (left < edgePadding) left = edgePadding;
  if (left + menuWidth > screen.width - edgePadding) {
    left = screen.width - edgePadding - menuWidth;
  }

  double top = globalPosition.dy - itemSize - 16;
  if (top < edgePadding) top = globalPosition.dy + 16;
  if (top + itemSize * 1.5 > screen.height - edgePadding) {
    top = globalPosition.dy - itemSize * 1.5 - 16;
  }

  top = top.clamp(edgePadding, screen.height - edgePadding - itemSize * 1.5);
  left = left.clamp(edgePadding, screen.width - edgePadding - menuWidth);

  final selected = ValueNotifier<int?>(null);
  final completer = Completer<int?>();
  late OverlayEntry entry;
  bool _isRemoved = false;

  void _safeRemove() {
    if (!_isRemoved && entry.mounted) {
      _isRemoved = true;
      container.read(menuOpenProvider.notifier).setOpen(false); // Reset the flag
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (entry.mounted) {
          entry.remove();
        }
      });
    }
  }

  entry = OverlayEntry(builder: (ctx) {
    final theme = Theme.of(ctx);
    final actualMenuWidth = menuWidth.clamp(100.0, screen.width - edgePadding * 2);

    return Stack(
      children: [
        // Semi-transparent overlay to capture taps outside the menu
        Positioned.fill(
          child: Container(
            color: Colors.transparent,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _safeRemove();
                if (!completer.isCompleted) completer.complete(null);
              },
            ),
          ),
        ),
        // The context menu
        Positioned(
          left: left,
          top: top,
          child: Material(
            elevation: 10,
            borderRadius: BorderRadius.circular(14),
            color: theme.cardColor,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              constraints: BoxConstraints(
                minWidth: actualMenuWidth,
                maxWidth: screen.width - edgePadding * 2,
              ),
              child: ValueListenableBuilder<int?>(
                valueListenable: selected,
                builder: (_, sel, __) {
                  return GestureDetector(
                    onPanUpdate: (details) {
                      final localX = details.localPosition.dx;
                      int? newIndex;

                      if (localX >= 0 && localX <= actualMenuWidth) {
                        final index = (localX / (itemSize + spacing)).floor();
                        if (index >= 0 && index < actions.length) newIndex = index;
                      }

                      if (newIndex != selected.value) {
                        selected.value = newIndex;
                        HapticFeedback.selectionClick();
                        if (applyOnHover && newIndex != null) {
                          _safeRemove();
                          if (!completer.isCompleted) completer.complete(newIndex);
                        }
                      }
                    },
                    onPanEnd: (details) {
                      if (!applyOnHover) {
                        final sel = selected.value;
                        _safeRemove();
                        if (!completer.isCompleted) completer.complete(sel);
                      }
                    },
                    onPanCancel: () {
                      _safeRemove();
                      if (!completer.isCompleted) completer.complete(null);
                    },
                    onTapUp: (details) {
                      final localX = details.localPosition.dx;
                      int? sel;

                      if (localX >= 0 && localX <= actualMenuWidth) {
                        final index = (localX / (itemSize + spacing)).floor();
                        if (index >= 0 && index < actions.length) sel = index;
                      }

                      _safeRemove();
                      if (!completer.isCompleted) completer.complete(sel);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(actions.length, (i) {
                        final a = actions[i];
                        final highlighted = sel == i;

                        return Flexible(
                          child: Padding(
                            padding: EdgeInsets.only(right: i == actions.length - 1 ? 0 : spacing),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 120),
                              curve: Curves.easeOut,
                              height: highlighted ? itemSize * 1.12 : itemSize,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: highlighted
                                    ? (a.color ?? theme.colorScheme.primary).withOpacity(0.12)
                                    : Colors.transparent,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                      a.icon,
                                      size: highlighted ? 28 : 24,
                                      color: a.color ?? theme.iconTheme.color
                                  ),
                                  const SizedBox(height: 4),
                                  Flexible(
                                    child: Text(
                                      a.label,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontSize: 10,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  });

  overlay.insert(entry);

  // Safety timeout to ensure menu closes
  Future.delayed(const Duration(seconds: 5), () {
    if (!completer.isCompleted) {
      _safeRemove();
      completer.complete(null);
    }
  });

  return completer.future;
}
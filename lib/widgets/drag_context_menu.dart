import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drgwallet/providers/providers.dart';

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

enum MenuOpenMode { dragToSelect, tapToSelect }
enum MenuScreenSource {homescreen,
walletdetailscreen,}

Future<int?> showDragContextMenu(
    BuildContext context,
    Offset globalPosition,//rapresenta la posizione globale della finestra in cui viene mostrato il menu
    List<ContextAction> actions,
    String menuScreenSource,
    {
      MenuOpenMode mode = MenuOpenMode.dragToSelect,
    }) async {
  final container = ProviderScope.containerOf(context);
  final menuOpen = container.read(menuOpenProvider);
  if (menuOpen) return null;
  container.read(menuOpenProvider.notifier).open();

  final resultCompleter = Completer<int?>();
  final overlay = Overlay.of(context);
  if (overlay == null) {
    container.read(menuOpenProvider.notifier).close();
    return null;
  }

  final screen = MediaQuery.of(context).size;

  // --- CONFIG ---



   const double itemSize = 72.0;

  const double spacing = 8.0;
  const double horizontalPadding = 12.0;
  const double verticalPadding = 12.0;
  const double edgePadding = 16.0;
  const double marginFromFinger = 8.0;

  final int n = actions.length;
  final double desiredMenuWidth = n * itemSize + (n - 1) * spacing;
  final double maxMenuWidth = screen.width - edgePadding * 2;// * 2 perché sono due lati dell'immagine
  final double actualMenuWidth = desiredMenuWidth.clamp(100.0, maxMenuWidth);

  double left = globalPosition.dx - actualMenuWidth / 2;
  left = left.clamp(edgePadding, screen.width - edgePadding - actualMenuWidth);// centra il menu rispetto al tocco, posizionandolo in modo che il tocco sia al centro del menu.

  final double menuHeight = itemSize + verticalPadding * 2;
  double top = globalPosition.dy - menuHeight - marginFromFinger;
  if (top < edgePadding + kToolbarHeight) top = globalPosition.dy + marginFromFinger;
  top = top.clamp(edgePadding, screen.height - edgePadding - menuHeight);

  final double innerWidth = actualMenuWidth - horizontalPadding * 2;
  final double totalSpacing = (n - 1) * spacing;
  final double slotWidth = (innerWidth - totalSpacing) / n;
  final double step = slotWidth + spacing;

  final selected = ValueNotifier<int?>(null);
  late OverlayEntry entry;
  bool removed = false;

  void _safeRemove([int? sel]) {
    if (removed) return;
    removed = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (entry.mounted) entry.remove();
    });
    if (!resultCompleter.isCompleted) resultCompleter.complete(sel);
    container.read(menuOpenProvider.notifier).close();
  }

  entry = OverlayEntry(builder: (ctx) {
    final theme = Theme.of(ctx);

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _safeRemove(),
          ),
        ),
        Positioned(
          left: left,
          top: top,
          child: Material(
            elevation: 10,
            borderRadius: BorderRadius.circular(14),
            color: theme.cardColor,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.primary, width: 2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
              constraints: BoxConstraints(
                minWidth: actualMenuWidth,
                maxWidth: actualMenuWidth,
              ),
              child: ValueListenableBuilder<int?>(
                valueListenable: selected,
                builder: (_, sel,__) {
                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onPanUpdate: (details) {
                      if (mode != MenuOpenMode.dragToSelect) return;
                      final local = details.localPosition;

                      int? newIndex;
                      for (int i = 0; i < n; i++) {
                        final double cx = step * i + slotWidth / 2;
                        final double cy = itemSize / 2;
                        final double dx = local.dx - cx;
                        final double dy = local.dy - cy;
                        final double rx = slotWidth / 2;
                        final double ry = itemSize / 2;
                        if ((dx * dx) / (rx * rx) + (dy * dy) / (ry * ry) <= 1) {
                          newIndex = i;
                          break;
                        }
                      }

                      if (newIndex != selected.value) {
                        selected.value = newIndex;
                        if (newIndex != null) HapticFeedback.selectionClick();
                      }
                    },
                    onPanEnd: (_) {
                      if (mode != MenuOpenMode.dragToSelect) return;
                      _safeRemove(selected.value);
                    },
                    onTapUp: (details) {
                      final local = details.localPosition;
                      int? selIndex;
                      for (int i = 0; i < n; i++) {
                        final double cx = step * i + slotWidth / 2;
                        final double cy = itemSize / 2;
                        final double dx = local.dx - cx;
                        final double dy = local.dy - cy;
                        final double rx = slotWidth / 2;
                        final double ry = itemSize / 2;
                        if ((dx * dx) / (rx * rx) + (dy * dy) / (ry * ry) <= 1) {
                          selIndex = i;
                          break;
                        }
                      }
                      _safeRemove(selIndex);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(n, (i) {
                        final a = actions[i];
                        final highlighted = sel == i;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: i == n - 1 ? 0 : spacing),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 170),
                              curve: Curves.easeInQuart,
                              height: itemSize,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(itemSize / 2), // ovale verticale
                                color: highlighted
                                    ? (a.color ?? theme.colorScheme.primary).withOpacity(0.12)
                                    : Colors.transparent,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    a.icon,
                                    size: highlighted ? 30 : 24,
                                    color: a.color ?? theme.iconTheme.color,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    a.label,
                                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
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

  // Future.delayed(const Duration(seconds: 6), () {
  //   if (!resultCompleter.isCompleted) _safeRemove();
  // });// senon vuoi far tenere aperta la finestra per 6 secondi

  return resultCompleter.future;
}

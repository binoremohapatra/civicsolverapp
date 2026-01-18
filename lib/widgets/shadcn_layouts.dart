import 'package:flutter/material.dart';
import '../theme/app_theme.dart';


// ==========================================
// 36. RESIZABLE PANEL GROUP
// ==========================================
class ShadcnResizablePanelGroup extends StatefulWidget {
  final Widget child1;
  final Widget child2;
  final Axis direction;
  final double initialRatio;

  const ShadcnResizablePanelGroup({
    super.key,
    required this.child1,
    required this.child2,
    this.direction = Axis.horizontal,
    this.initialRatio = 0.5,
  });

  @override
  State<ShadcnResizablePanelGroup> createState() => _ShadcnResizablePanelGroupState();
}

class _ShadcnResizablePanelGroupState extends State<ShadcnResizablePanelGroup> {
  late double _ratio;

  @override
  void initState() {
    super.initState();
    _ratio = widget.initialRatio;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalSize = widget.direction == Axis.horizontal ? constraints.maxWidth : constraints.maxHeight;

        return Flex(
          direction: widget.direction,
          children: [
            SizedBox(
              width: widget.direction == Axis.horizontal ? totalSize * _ratio : null,
              height: widget.direction == Axis.vertical ? totalSize * _ratio : null,
              child: widget.child1,
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: widget.direction == Axis.horizontal
                  ? (d) => setState(() => _ratio = (_ratio + d.delta.dx / totalSize).clamp(0.1, 0.9))
                  : null,
              onVerticalDragUpdate: widget.direction == Axis.vertical
                  ? (d) => setState(() => _ratio = (_ratio + d.delta.dy / totalSize).clamp(0.1, 0.9))
                  : null,
              child: MouseRegion(
                cursor: widget.direction == Axis.horizontal ? SystemMouseCursors.resizeColumn : SystemMouseCursors.resizeRow,
                child: Container(
                  width: widget.direction == Axis.horizontal ? 8 : double.infinity,
                  height: widget.direction == Axis.vertical ? 8 : double.infinity,
                  color: Colors.transparent, // Invisible hit target
                  alignment: Alignment.center,
                  child: Container(
                    color: ShadcnTheme.border,
                    width: widget.direction == Axis.horizontal ? 1 : double.infinity,
                    height: widget.direction == Axis.vertical ? 1 : double.infinity,
                  ),
                ),
              ),
            ),
            Expanded(child: widget.child2),
          ],
        );
      },
    );
  }
}

// ==========================================
// 37. SCROLL AREA
// ==========================================
class ShadcnScrollArea extends StatelessWidget {
  final Widget child;
  final double? height;
  final double? width;

  const ShadcnScrollArea({super.key, required this.child, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(border: Border.all(color: Colors.transparent)),
      child: Scrollbar(
        thumbVisibility: true,
        radius: const Radius.circular(10),
        child: SingleChildScrollView(child: child),
      ),
    );
  }
}

// ==========================================
// 38. SIDEBAR (Layout)
// ==========================================
class ShadcnSidebarLayout extends StatelessWidget {
  final Widget sidebar;
  final Widget content;
  final bool isMobile; // Pass from MediaQuery

  const ShadcnSidebarLayout({super.key, required this.sidebar, required this.content, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Scaffold(
        drawer: Drawer(width: 250, child: sidebar),
        body: content, // Content needs to include a Drawer Trigger button
      );
    }

    return Row(
      children: [
        Container(
          width: 250,
          decoration: const BoxDecoration(
            color: ShadcnTheme.background,
            border: Border(right: BorderSide(color: ShadcnTheme.border)),
          ),
          child: sidebar,
        ),
        Expanded(child: content),
      ],
    );
  }
}
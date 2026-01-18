import 'package:flutter/material.dart';
import '../theme/app_theme.dart'; // Adjust path if your theme is elsewhere

// ==========================================
// 1. COMMAND PALETTE (CMDK)
// ==========================================
class ShadcnCommand extends StatelessWidget {
  final Map<String, List<String>> groups;
  final ValueChanged<String> onSelect;

  const ShadcnCommand({super.key, required this.groups, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: ShadcnTheme.popover,
        borderRadius: BorderRadius.circular(ShadcnTheme.radiusDefault),
        border: Border.all(color: ShadcnTheme.border),
      ),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, size: 16, color: ShadcnTheme.mutedForeground),
              hintText: "Type a command or search...",
              hintStyle: ShadcnTheme.textStyle.copyWith(color: ShadcnTheme.mutedForeground),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const Divider(height: 1, color: ShadcnTheme.border),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(4),
              children: groups.entries.expand((entry) {
                return [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(entry.key, style: ShadcnTheme.small),
                  ),
                  ...entry.value.map((item) => InkWell(
                    onTap: () => onSelect(item),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Text(item, style: ShadcnTheme.textStyle),
                    ),
                  ))
                ];
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. MENUS (Context & Dropdown)
// ==========================================
class ShadcnMenu extends StatelessWidget {
  final List<ShadcnMenuItem> items;
  final Widget child;
  final bool isContext;

  const ShadcnMenu({super.key, required this.items, required this.child, this.isContext = false});

  void _showMenu(BuildContext context, Offset position) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      color: ShadcnTheme.popover,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ShadcnTheme.radiusSm),
        side: const BorderSide(color: ShadcnTheme.border),
      ),
      // FIXED: Explicitly typed as PopupMenuEntry<dynamic>
      items: items.map<PopupMenuEntry<dynamic>>((item) {
        if (item is ShadcnMenuDivider) return const PopupMenuDivider();
        final action = item as ShadcnMenuAction;
        return PopupMenuItem(
          height: 32,
          onTap: action.onTap,
          child: Row(
            children: [
              if (action.icon != null) ...[Icon(action.icon, size: 14), const SizedBox(width: 8)],
              Text(action.label, style: ShadcnTheme.textStyle),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: isContext ? null : (details) => _showMenu(context, details.globalPosition),
      onSecondaryTapDown: isContext ? (details) => _showMenu(context, details.globalPosition) : null,
      child: child,
    );
  }
}

abstract class ShadcnMenuItem {}
class ShadcnMenuAction extends ShadcnMenuItem {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final String? shortcut;
  ShadcnMenuAction({required this.label, required this.onTap, this.icon, this.shortcut});
}
class ShadcnMenuDivider extends ShadcnMenuItem {}

// ==========================================
// 3. DIALOG
// ==========================================
class ShadcnDialog extends StatelessWidget {
  final Widget trigger;
  final Widget content;
  final String title;
  final String? description;

  const ShadcnDialog({
    super.key,
    required this.trigger,
    required this.content,
    required this.title,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // FIXED: Implemented showGeneralDialog directly to remove external dependency
      onTap: () {
        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: "Dismiss",
          barrierColor: Colors.black.withOpacity(0.5),
          transitionDuration: const Duration(milliseconds: 200),
          pageBuilder: (ctx, _, __) => Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: const BoxConstraints(maxWidth: 512),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: ShadcnTheme.card,
                  borderRadius: BorderRadius.circular(ShadcnTheme.radiusLg),
                  border: Border.all(color: ShadcnTheme.border),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: ShadcnTheme.textStyle.copyWith(fontSize: 18, fontWeight: FontWeight.w600)),
                    if (description != null) ...[
                      const SizedBox(height: 8),
                      Text(description!, style: ShadcnTheme.textStyle.copyWith(color: ShadcnTheme.mutedForeground)),
                    ],
                    const SizedBox(height: 16),
                    content,
                  ],
                ),
              ),
            ),
          ),
          transitionBuilder: (_, anim, __, child) => Transform.scale(
            scale: 0.95 + (0.05 * Curves.easeOut.transform(anim.value)),
            child: Opacity(opacity: anim.value, child: child),
          ),
        );
      },
      child: trigger,
    );
  }
}

// ==========================================
// 4. TOASTER
// ==========================================
void showShadcnToast(BuildContext context, {required String title, String? description}) {
  final scaffold = ScaffoldMessenger.of(context);
  scaffold.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ShadcnTheme.background,
          borderRadius: BorderRadius.circular(ShadcnTheme.radiusDefault),
          border: Border.all(color: ShadcnTheme.border),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: ShadcnTheme.textStyle.copyWith(fontWeight: FontWeight.w600)),
            if (description != null)
              Text(description, style: ShadcnTheme.textStyle.copyWith(color: ShadcnTheme.mutedForeground)),
          ],
        ),
      ),
    ),
  );
}
import 'package:flutter/material.dart';

/// Tap the search icon to expand the filter field; it collapses when focus is lost.
class CategoryNameFilterBar extends StatefulWidget {
  const CategoryNameFilterBar({
    super.key,
    required this.isDark,
    required this.onChanged,
  });

  final bool isDark;
  final ValueChanged<String> onChanged;

  @override
  State<CategoryNameFilterBar> createState() => _CategoryNameFilterBarState();
}

class _CategoryNameFilterBarState extends State<CategoryNameFilterBar> {
  final TextEditingController _controller = TextEditingController();
  late final FocusNode _focusNode;

  bool _expanded = false;

  static const Duration _kAnimDuration = Duration(milliseconds: 320);
  static const Curve _kAnimCurve = Curves.easeOutCubic;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus && _expanded && mounted) {
      setState(() => _expanded = false);
    }
  }

  void _expandAndFocus() {
    setState(() => _expanded = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hintColor =
        widget.isDark ? Colors.grey[500] : Colors.grey[600];
    final borderRadius = BorderRadius.circular(12);
    final defaultBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(
        color: widget.isDark ? Colors.grey[700]! : Colors.grey[300]!,
      ),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(
        color: widget.isDark
            ? Colors.white
            : Theme.of(context).colorScheme.primary,
        width: widget.isDark ? 1.5 : 1,
      ),
    );

    final iconColor = widget.isDark ? Colors.grey[300] : Colors.grey[800];
    final hasFilterText = _controller.text.isNotEmpty;

    final collapsed = SizedBox(
      height: 48,
      child: Align(
        alignment: Alignment.centerRight,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasFilterText
                ? (widget.isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Theme.of(context).colorScheme.primary.withValues(alpha: 0.12))
                : Colors.transparent,
          ),
          child: IconButton(
            tooltip: 'Filter by name',
            icon: Icon(Icons.search, color: iconColor, size: 26),
            onPressed: _expandAndFocus,
          ),
        ),
      ),
    );

    final field = TextField(
      focusNode: _focusNode,
      controller: _controller,
      cursorColor: widget.isDark ? Colors.white : null,
      onChanged: (v) {
        setState(() {});
        widget.onChanged(v);
      },
      style: TextStyle(
        color: widget.isDark ? Colors.white : Colors.black87,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Filter by name',
        hintStyle: TextStyle(color: hintColor, fontSize: 15),
        prefixIcon: Icon(
          Icons.search,
          color: widget.isDark ? Colors.grey[400] : Colors.grey[700],
          size: 22,
        ),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                icon: Icon(
                  Icons.clear,
                  color: widget.isDark ? Colors.grey[400] : Colors.grey[700],
                  size: 20,
                ),
                onPressed: () {
                  _controller.clear();
                  widget.onChanged('');
                  setState(() {});
                },
              ),
        filled: true,
        fillColor: widget.isDark ? Colors.grey[900] : Colors.white,
        border: defaultBorder,
        enabledBorder: defaultBorder,
        focusedBorder: focusedBorder,
        disabledBorder: defaultBorder,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: AnimatedSize(
        duration: _kAnimDuration,
        curve: Curves.easeInOutCubic,
        alignment: Alignment.topCenter,
        child: AnimatedSwitcher(
          duration: _kAnimDuration,
          switchInCurve: _kAnimCurve,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.06, 0),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
          child: _expanded
              ? KeyedSubtree(
                  key: const ValueKey<String>('expanded'),
                  child: field,
                )
              : KeyedSubtree(
                  key: const ValueKey<String>('collapsed'),
                  child: collapsed,
                ),
        ),
      ),
    );
  }
}

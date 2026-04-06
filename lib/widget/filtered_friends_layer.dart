import 'package:flutter/material.dart';

import 'package:stay_connected/util/filter_friends.dart';
import 'package:stay_connected/widget/category_name_filter_bar.dart';

/// When [friends] is empty, shows [emptyChild]. Otherwise shows a name filter
/// bar and [contentBuilder] with the filtered list (and the full list for indexing).
class FilteredFriendsLayer extends StatefulWidget {
  const FilteredFriendsLayer({
    super.key,
    required this.isDark,
    required this.friends,
    required this.emptyChild,
    required this.contentBuilder,
    this.noMatchesChild,
  });

  final bool isDark;
  final List<Map<String, String>> friends;
  final Widget emptyChild;
  final Widget Function(
    BuildContext context,
    List<Map<String, String>> filtered,
    List<Map<String, String>> allFriends,
  ) contentBuilder;

  /// Shown when the filter matches nobody; defaults to a simple message.
  final Widget? noMatchesChild;

  @override
  State<FilteredFriendsLayer> createState() => _FilteredFriendsLayerState();
}

class _FilteredFriendsLayerState extends State<FilteredFriendsLayer> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final all = widget.friends;
    if (all.isEmpty) {
      return widget.emptyChild;
    }
    final filtered = filterFriendsByNameQuery(all, _query);
    void unfocusFilter() =>
        FocusManager.instance.primaryFocus?.unfocus();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CategoryNameFilterBar(
          isDark: widget.isDark,
          onChanged: (q) => setState(() => _query = q),
        ),
        Expanded(
          child: GestureDetector(
            onTap: unfocusFilter,
            behavior: HitTestBehavior.opaque,
            child: filtered.isEmpty
                ? (widget.noMatchesChild ??
                    Center(
                      child: Text(
                        'No people match your filter',
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.isDark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                    ))
                : widget.contentBuilder(context, filtered, all),
          ),
        ),
      ],
    );
  }
}

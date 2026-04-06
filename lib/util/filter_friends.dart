/// Filters saved people by display name (case-insensitive substring).
List<Map<String, String>> filterFriendsByNameQuery(
  List<Map<String, String>> friends,
  String query,
) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return friends;
  return friends
      .where((f) => (f['name'] ?? '').toLowerCase().contains(q))
      .toList();
}

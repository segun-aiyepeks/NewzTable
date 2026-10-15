## 2024-05-23 - Removing O(N) Database Counts for Pagination
**Learning:** Using `countDocuments()` for infinite scroll pagination causes unnecessary O(N) operations and degrades database performance as collections grow. The frontend only needs a boolean `hasMore` flag, not the absolute total count.
**Action:** When implementing infinite scroll, use the 'limit + 1' pattern: fetch `limit + 1` items. If you get `limit + 1` back, there are more items (`hasMore: true`), then return only `limit` items to the client. This avoids expensive count queries entirely.

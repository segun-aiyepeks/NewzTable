
## 2023-10-23 - Avoid countDocuments() for infinite scroll
**Learning:** MongoDB `countDocuments()` is an O(N) operation that becomes a severe performance bottleneck for large collections, especially on frequent queries like feeds or search results. The frontend mobile and web apps here don't actually use the `total` count parameter.
**Action:** Use the "limit + 1" pattern. Fetch one extra document beyond the requested limit (e.g., `limit(limit + 1)`). If the result length exceeds the `limit`, set `hasMore` to true and pop the extra document before returning to avoid an expensive full collection scan.

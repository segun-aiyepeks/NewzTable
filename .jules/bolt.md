## 2023-10-25 - Avoid O(N) countDocuments in Pagination
**Learning:** Using `countDocuments()` along with `find()` for pagination creates an O(N) bottleneck, especially on large collections, simply to determine if there are more pages.
**Action:** Always prefer the "limit + 1" pattern. Fetch `limit + 1` documents; if `results.length > limit`, set `hasMore` to true and pop the extra document before returning the response. This pattern completely eliminates the expensive count query while supporting infinite scroll functionality.

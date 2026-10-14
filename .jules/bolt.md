## 2024-05-20 - Pagination Optimization
**Learning:** `countDocuments` can be an expensive operation in MongoDB on large collections. The "limit + 1" pattern is more performant when only `hasMore` is needed.
**Action:** Use `.limit(limit + 1)` to determine if there are more items instead of querying the total count.

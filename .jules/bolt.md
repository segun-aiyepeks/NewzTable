## 2024-10-16 - Replace countDocuments with limit + 1 pattern
**Learning:** Using `countDocuments()` for infinite scroll pagination is an O(N) operation and a major performance bottleneck in MongoDB, especially for large datasets. Since the frontend doesn't need the exact total count, this is wasted computation.
**Action:** Always use the "limit + 1" pattern (requesting `limit + 1` items and checking if the extra item exists to determine `hasMore`) for infinite scroll or when the exact total is unnecessary, avoiding expensive count operations.

## 2024-10-24 - Efficient Pagination Without countDocuments
**Learning:** MongoDB `countDocuments()` is O(N) and can be a significant performance bottleneck for large collections, especially on simple queries or text searches without a specific index. The frontend doesn't actually use the `total` property.
**Action:** Replace `countDocuments` queries used for infinite scrolling boolean checks (`hasMore`) with the 'limit + 1' pattern. Query for one extra document (`limit + 1`); if it exists, `hasMore` is true, then `pop()` the extra document before sending the payload.

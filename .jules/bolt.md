
## 2024-05-24 - Limit + 1 Pagination Pattern
**Learning:** Using `countDocuments()` for infinite scroll pagination is an unnecessary performance bottleneck in MongoDB, as it scans index entries and scales poorly with large collections. Clients only need to know if there's a next page (`hasMore`), not the exact total.
**Action:** When implementing infinite scroll, use the 'limit + 1' pattern: request one extra document (`limit + 1`) from the database. If it exists, set `hasMore: true`, then slice the results to return only the requested `limit` to the client. Hardcode `total: 0` if removing the field would break the API contract.

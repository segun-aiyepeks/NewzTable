## 2024-05-24 - Avoid countDocuments in infinite scroll APIs
**Learning:** The application uses infinite scroll APIs, and computing `total` using `countDocuments` is an O(N) operation that scales poorly and causes unnecessary DB load. The frontend doesn't even use `total`.
**Action:** Use the "limit + 1" pattern. Request `limit + 1` from the database. If `results.length > limit`, then `hasMore` is true. `pop()` the extra item before returning the results. Never use `countDocuments` unless a hard `total` is strictly required.

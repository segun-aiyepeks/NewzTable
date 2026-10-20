## 2024-06-25 - [Limit + 1 Pagination Pattern]
**Learning:** For continuous scroll feeds, doing a countDocuments query is an expensive O(N) operation that scales poorly on large databases. We don't need the exact total count, only whether more data is available.
**Action:** Use the limit + 1 pattern for continuous scroll. Query for limit + 1 documents, and if the returned list is larger than the limit, you have a hasMore=true, and can slice off the extra item before returning.
## 2024-06-25 - [Removed unused total field from API]
**Learning:** The frontend only uses `hasMore` for infinite scroll pagination, explicitly omitting the usage of the `total` parameter.
**Action:** Always check both web and mobile frontend clients before making breaking API changes. Since `total` isn't used, removing it along with `countDocuments` is perfectly safe.

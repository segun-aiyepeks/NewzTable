## 2024-10-27 - Backend Pagination Optimization: Avoiding countDocuments()
**Learning:** The backend API utilizes a 'limit + 1' pattern for pagination queries to determine 'hasMore' boolean flags for infinite scroll, deliberately avoiding expensive O(N) MongoDB countDocuments() operations which don't scale well with large datasets.
**Action:** Always prefer the 'limit + 1' approach over countDocuments() when implementing or refactoring pagination for endpoints that only need to support infinite scroll (like feeds) rather than absolute page numbers.

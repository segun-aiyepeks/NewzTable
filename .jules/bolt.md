
## 2024-11-08 - Avoid redundant database roundtrips using findOneAndUpdate
**Learning:** Combining `findOne` and `.save()` operations in Mongoose into a single `findOneAndUpdate` query eliminates a redundant database roundtrip, improving query performance.
**Action:** Use `.findOneAndUpdate` directly when reading a document and immediately updating a field like `lastSeenAt`.

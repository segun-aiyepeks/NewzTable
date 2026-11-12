## 2024-11-10 - Reduce database roundtrips with findOneAndUpdate
**Learning:** In Mongoose, using `findOne()` to fetch a document and then calling `.save()` to update it requires two database roundtrips. When the update is simple (e.g. setting a timestamp like `lastSeenAt`), this can be optimized into a single roundtrip using `findOneAndUpdate()`.
**Action:** Prefer `findOneAndUpdate()` with `{ returnDocument: 'after' }` over a read-modify-save pattern when only basic field updates are required, as it improves backend performance.

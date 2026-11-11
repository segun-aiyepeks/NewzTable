## 2025-02-12 - Mongoose Optimization Pattern
**Learning:** For Mongoose endpoints that fetch a document just to update a timestamp and save it, doing `findOne()` followed by `save()` creates unnecessary database roundtrips and loads heavy Mongoose documents into memory just to modify them.
**Action:** Replace `findOne()` + `save()` with a single `findOneAndUpdate()` operation using `{ returnDocument: 'after' }` to get the updated document in one trip while avoiding deprecation warnings associated with `{ new: true }`.

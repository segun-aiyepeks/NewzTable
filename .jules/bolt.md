## 2024-05-15 - Mongoose findOneAndUpdate hook behavior
**Learning:** Combining `findOne()` and `.save()` into `findOneAndUpdate()` saves a DB roundtrip, but bypasses Mongoose `save` middleware hooks (e.g., `pre('save')`).
**Action:** Always verify if the Mongoose schema relies on `save` hooks for critical side-effects before refactoring away from `.save()`.

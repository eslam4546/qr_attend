/// Firestore Data Model Reference for QR-Attend
///
/// ┌──────────────────────────────────────────────────────────────┐
/// │ Collection: users/{uid}                                      │
/// ├──────────────────────────────────────────────────────────────┤
/// │ email       : String                                         │
/// │ name        : String                                         │
/// │ role        : String ('professor' | 'student')               │
/// │ createdAt   : Timestamp                                      │
/// └──────────────────────────────────────────────────────────────┘
///
/// ┌──────────────────────────────────────────────────────────────┐
/// │ Collection: courses/{courseId}                                │
/// ├──────────────────────────────────────────────────────────────┤
/// │ name        : String                                         │
/// │ code        : String  (unique join code)                     │
/// │ professorId : String  (uid of the professor)                 │
/// │ createdAt   : Timestamp                                      │
/// │                                                              │
/// │  └─ Subcollection: enrollments/{studentUid}                  │
/// │     ├─ studentName : String                                  │
/// │     └─ enrolledAt  : Timestamp                               │
/// └──────────────────────────────────────────────────────────────┘
///
/// ┌──────────────────────────────────────────────────────────────┐
/// │ Collection: sessions/{sessionId}                             │
/// ├──────────────────────────────────────────────────────────────┤
/// │ courseId    : String                                          │
/// │ professorId : String                                         │
/// │ token       : String  (UUID — embedded in QR payload)        │
/// │ startedAt   : Timestamp                                      │
/// │ expiresAt   : Timestamp                                      │
/// │ isActive    : bool                                           │
/// │                                                              │
/// │  └─ Subcollection: attendance/{studentUid}                   │
/// │     ├─ studentName : String                                  │
/// │     └─ scannedAt   : Timestamp                               │
/// └──────────────────────────────────────────────────────────────┘
library;

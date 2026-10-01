import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_attend/features/auth/domain/entities/user_entity.dart';

/// Data-layer model that maps between Firestore documents and [UserEntity].
///
/// Extends [UserEntity] so it can be used anywhere the domain entity is
/// expected, while adding serialization methods for the data layer.
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.name,
    required super.role,
  });

  /// Creates a [UserModel] from a Firestore document snapshot.
  ///
  /// Expects the document to contain `email`, `name`, and `role` fields
  /// matching the schema in `firestore_schema.dart`.
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      uid: doc.id,
      email: data['email'] as String,
      name: data['name'] as String,
      role: UserRole.fromString(data['role'] as String),
    );
  }

  /// Converts this model to a Firestore-writable map.
  ///
  /// Used when creating the user document in `users/{uid}` after registration.
  /// Includes `createdAt` as a server timestamp per the security rules
  /// requirement (`request.resource.data.keys().hasAll([..., 'createdAt'])`).
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role.value,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Creates a [UserModel] from raw field values.
  ///
  /// Useful for constructing the model immediately after FirebaseAuth
  /// registration, before the Firestore document exists.
  factory UserModel.fromRegistration({
    required String uid,
    required String email,
    required String name,
    required UserRole role,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      name: name,
      role: role,
    );
  }
}

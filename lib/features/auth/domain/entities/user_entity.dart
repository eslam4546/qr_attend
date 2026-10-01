import 'package:equatable/equatable.dart';

/// Enum representing the two roles in the QR-Attend system.
enum UserRole {
  professor('professor'),
  student('student');

  const UserRole(this.value);

  /// The string value stored in Firestore.
  final String value;

  /// Parses a Firestore string back into the enum.
  /// Throws [ArgumentError] if the value is unrecognized.
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => throw ArgumentError('Unknown UserRole: $value'),
    );
  }
}

/// Domain entity representing an authenticated user.
///
/// This is the pure domain representation — it has no dependency on Firebase
/// or any data-layer serialization. The [UserModel] in the data layer maps
/// to/from this entity.
class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String name;
  final UserRole role;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
  });

  /// Convenience getter used throughout the app for route guards.
  bool get isProfessor => role == UserRole.professor;
  bool get isStudent => role == UserRole.student;

  @override
  List<Object?> get props => [uid, email, name, role];
}

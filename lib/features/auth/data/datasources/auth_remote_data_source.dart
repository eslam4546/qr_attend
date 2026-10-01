import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_attend/core/error/exceptions.dart';
import 'package:qr_attend/features/auth/data/models/user_model.dart';
import 'package:qr_attend/features/auth/domain/entities/user_entity.dart';

/// Contract for remote auth operations.
///
/// Separating the interface from the implementation allows for easier
/// testing and swapping of data sources.
abstract class AuthRemoteDataSource {
  /// Creates a FirebaseAuth account, then writes the user profile
  /// document to Firestore `users/{uid}`.
  ///
  /// Throws [AuthException] on Firebase Auth errors.
  /// Throws [ServerException] on Firestore write errors.
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  });

  /// Signs in with email/password via FirebaseAuth, then fetches the
  /// user profile from Firestore.
  ///
  /// Throws [AuthException] on credential errors.
  /// Throws [ServerException] if the Firestore document is missing.
  Future<UserModel> signIn({
    required String email,
    required String password,
  });

  /// Signs out the current FirebaseAuth user.
  ///
  /// Throws [AuthException] on failure.
  Future<void> signOut();

  /// Returns the currently signed-in user's profile from Firestore,
  /// or `null` if no user is signed in.
  ///
  /// Throws [ServerException] if the user is signed in but their
  /// Firestore document is missing or unreadable.
  Future<UserModel?> getCurrentUser();
}

/// Concrete implementation backed by [FirebaseAuth] and [FirebaseFirestore].
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  /// Reference to the `users` top-level collection.
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      firestore.collection('users');

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    try {
      // 1. Create the Firebase Auth account.
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException('Account creation returned null user.');
      }

      // 2. Build the model to persist.
      final userModel = UserModel.fromRegistration(
        uid: user.uid,
        email: email,
        name: name,
        role: role,
      );

      // 3. Write the user document to Firestore.
      await _usersCollection.doc(user.uid).set(userModel.toFirestore());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthErrorCode(e.code));
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException('Sign-up failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Authenticate with Firebase Auth.
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException('Sign-in returned null user.');
      }

      // 2. Fetch the user profile from Firestore.
      return await _fetchUserDocument(user.uid);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthErrorCode(e.code));
    } on AuthException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Sign-in failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw AuthException('Sign-out failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    return await _fetchUserDocument(firebaseUser.uid);
  }

  // ─── Private Helpers ───────────────────────────────────────────

  /// Fetches and deserializes the user document from `users/{uid}`.
  ///
  /// Throws [ServerException] if the document doesn't exist or can't
  /// be read — this would indicate data corruption or a race condition.
  Future<UserModel> _fetchUserDocument(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        throw ServerException(
          'User profile not found in Firestore for uid: $uid',
        );
      }
      return UserModel.fromFirestore(doc);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        'Failed to fetch user profile: ${e.toString()}',
      );
    }
  }

  /// Maps Firebase Auth error codes to human-readable messages.
  String _mapAuthErrorCode(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email address is already registered.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled.';
      case 'weak-password':
        return 'The password is too weak. Use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication error: $code';
    }
  }
}

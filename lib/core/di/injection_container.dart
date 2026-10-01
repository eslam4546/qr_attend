import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:qr_attend/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:qr_attend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:qr_attend/features/auth/domain/repositories/auth_repository.dart';
import 'package:qr_attend/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:qr_attend/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:qr_attend/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:qr_attend/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:qr_attend/features/auth/presentation/bloc/auth_cubit.dart';

final sl = GetIt.instance;

/// Initialize all dependencies.
/// Called once at app startup before runApp().
Future<void> init() async {
  //--------------------------------------------------
  // Features — Auth
  //--------------------------------------------------
  // Bloc / Cubit
  sl.registerFactory(
    () => AuthCubit(
      signInUseCase: sl(),
      signUpUseCase: sl(),
      signOutUseCase: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      sharedPreferences: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
    ),
  );

  //--------------------------------------------------
  // Features — Courses
  //--------------------------------------------------
  // Bloc / Cubit
  // Use cases
  // Repositories
  // Data sources

  //--------------------------------------------------
  // Features — Sessions
  //--------------------------------------------------
  // Bloc / Cubit
  // Use cases
  // Repositories
  // Data sources

  //--------------------------------------------------
  // Features — Attendance
  //--------------------------------------------------
  // Bloc / Cubit
  // Use cases
  // Repositories
  // Data sources

  //--------------------------------------------------
  // External
  //--------------------------------------------------
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
}

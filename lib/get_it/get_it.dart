import 'package:evacuation_project/services/firebase_service.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  getIt.registerLazySingleton<FirebaseService>(() => FirebaseService());
}

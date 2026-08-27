import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../features/finance/data/datasources/secure_local_datasource.dart';
import '../../features/finance/data/repositories/finance_repository_impl.dart';
import '../../features/finance/domain/repositories/finance_repository.dart';
import '../../features/finance/domain/usecases/manage_finance_usecase.dart';
import '../../features/finance/presentation/bloc/finance_bloc.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  sl.registerLazySingleton(() => secureStorage);
  sl.registerLazySingleton<SecureLocalDataSource>(
      () => SecureLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<FinanceRepository>(
      () => FinanceRepositoryImpl(sl()));
  sl.registerLazySingleton(() => ManageFinanceUseCase(sl()));
  sl.registerFactory(() => FinanceBloc(sl()));
}

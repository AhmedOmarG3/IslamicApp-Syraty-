import 'package:siraty/features/azkar/data/datasource/azkar_local_data_source.dart';
import 'package:siraty/features/azkar/domain/entities/azkar_entity.dart';
import 'package:siraty/features/azkar/domain/repositories/azkar_repository.dart';

class AzkarRepositoryImpl implements AzkarRepository {
  final AzkarLocalDataSource localDataSource;

  AzkarRepositoryImpl({required this.localDataSource});

  @override
  Future<List<AzkarEntity>> getAllAzkar() async {
    return await localDataSource.getAllAzkar();
  }
}

import 'package:siraty/features/azkar/domain/entities/azkar_entity.dart';
import 'package:siraty/features/azkar/domain/repositories/azkar_repository.dart';

class GetAzkarUseCase {
  final AzkarRepository repository;

  GetAzkarUseCase({required this.repository});

  Future<List<AzkarEntity>> call() async {
    return await repository.getAllAzkar();
  }
}

import 'package:siraty/features/azkar/domain/entities/azkar_entity.dart';

abstract class AzkarRepository {
  Future<List<AzkarEntity>> getAllAzkar();
}

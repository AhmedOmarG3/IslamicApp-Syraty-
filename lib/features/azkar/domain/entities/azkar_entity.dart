import 'package:equatable/equatable.dart';
import 'package:siraty/features/azkar/domain/entities/zekr_item_entity.dart';

class AzkarEntity extends Equatable {
  final int id;
  final String category;
  final List<ZekrItemEntity> zekrItems;

  const AzkarEntity({
    required this.id,
    required this.category,
    required this.zekrItems,
  });

  @override
  List<Object?> get props => [id, category, zekrItems];
}

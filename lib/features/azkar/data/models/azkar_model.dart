import 'package:siraty/features/azkar/domain/entities/azkar_entity.dart';
import 'package:siraty/features/azkar/domain/entities/zekr_item_entity.dart';

class AzkarModel extends AzkarEntity {
  const AzkarModel({
    required super.id,
    required super.category,
    required super.zekrItems,
  });

  factory AzkarModel.fromJson(Map<String, dynamic> json) {
    return AzkarModel(
      id: json['id'] ?? 0,
      category: json['category'] ?? '',
      zekrItems: (json['array'] as List<dynamic>?)
              ?.map((item) => ZekrItemModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class ZekrItemModel extends ZekrItemEntity {
  const ZekrItemModel({
    required super.id,
    required super.text,
    required super.count,
  });

  factory ZekrItemModel.fromJson(Map<String, dynamic> json) {
    return ZekrItemModel(
      id: json['id'] ?? 0,
      text: json['text'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

import 'package:equatable/equatable.dart';

class ZekrItemEntity extends Equatable {
  final int id;
  final String text;
  final int count;

  const ZekrItemEntity({
    required this.id,
    required this.text,
    required this.count,
  });

  @override
  List<Object?> get props => [id, text, count];
}

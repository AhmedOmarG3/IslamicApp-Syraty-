class AzkarModel {
  int? id;
  String? category;
  List<ZekrItem>? zekrItems;

AzkarModel({
    this.id,
    this.category,
    this.zekrItems,
  });

factory AzkarModel.fromJson(Map<String, dynamic> json) {
    return AzkarModel(
      id: json['id'],
      category: json['category'],
      zekrItems: (json['array'] as List<dynamic>?)
          ?.map((item) => ZekrItem.fromJson(item))
          .toList(),
    );
  }




}



class ZekrItem {
  int? id;
  
  String? text;
  int? count;
  

  ZekrItem({
    this.id,
    
    this.text,
    this.count,
    
  });

  factory ZekrItem.fromJson(Map<String, dynamic> json) {
    return ZekrItem(
      id: json['id'],
      text: json['text'],
      count: json['count'],
    );
  }
}
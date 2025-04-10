class AzanModel {
  
List<String> azanTimes;
   
   AzanModel({
     required this. azanTimes,
  });

  factory AzanModel.fromJson(Map<String, dynamic> json) {
    return AzanModel(
      
      azanTimes: [
        json['data']['timings']['Fajr'],
        json['data']['timings']['Dhuhr'],
        json['data']['timings']['Asr'],
        json['data']['timings']['Maghrib'],
        json['data']['timings']['Isha'],
      ],
    );
  }
  List<String> timesName(){
    return [
      'الفجر',
      'الظهر',
      'العصر',
      'المغرب',
      'العشاء',
    ];
  }
}
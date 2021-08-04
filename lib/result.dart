import 'dart:convert';

/// CityPicker 返回的 **Result** 结果函数
class Result {
  /// provinceId
  final String provinceId;

  /// cityId
  final String cityId;

  /// areaId
  final String areaId;

  /// provinceName
  final String provinceName;

  /// cityName
  final String cityName;

  /// areaName
  final String areaName;

  Result(
      {this.provinceId = "",
      this.cityId = "",
      this.areaId = "",
      this.provinceName = "",
      this.cityName = "",
      this.areaName = ""});

  /// string json
  @override
  String toString() {
    Map<String, dynamic> obj = {
      'provinceName': provinceName,
      'provinceId': provinceId,
      'cityName': cityName,
      'cityId': cityId,
      'areaName': areaName,
      'areaId': areaId
    };
    obj.removeWhere((key, value) => value == null);
    return json.encode(obj);
  }
}

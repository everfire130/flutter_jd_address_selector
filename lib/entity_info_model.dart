import 'package:azlistview/azlistview.dart';

class EntityInfo extends ISuspensionBean {
  String name;
  String? tagIndex;
  String? namePinyin;

  EntityInfo({
    required this.name,
    this.tagIndex,
    this.namePinyin,
  });

  EntityInfo.fromJson(Map<String, dynamic> json) : name = json['name'] ?? "";

  Map<String, dynamic> toJson() => {
        'name': name,
        'tagIndex': tagIndex,
        'namePinyin': namePinyin,
        'isShowSuspension': isShowSuspension
      };

  @override
  String getSuspensionTag() => tagIndex.toString();

  @override
  String toString() =>
      "CityBean {" + " \"name\":\"" + name.toString() + "\"" + '}';
}

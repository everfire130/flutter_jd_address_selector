class Province {
  final String name;
  final String no;
  final List<City> cityList;

  const Province(
      {required this.name, required this.no, required this.cityList});

  Province.fromJson(Map<String, dynamic> json)
      : this.name = json['name'] ?? '',
        this.no = json['no'] ?? '',
        this.cityList = [] {
    if (json['cityList'] != null) {
      json['cityList'].forEach((itemJson) {
        cityList.add(City.fromJson(itemJson));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['no'] = this.no;
    data['cityList'] = this.cityList.map((e) => e.toJson()).toList();
    return data;
  }
}

class City {
  final String name;
  final String no;
  final List<County> countyList;

  City({required this.name, required this.no, required this.countyList});

  City.fromJson(Map<String, dynamic> json)
      : this.name = json['name'],
        this.no = json['no'],
        this.countyList = [] {
    if (json['countyList'] != null) {
      json['countyList'].forEach((itemJson) {
        this.countyList.add(County.fromJson(itemJson));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['no'] = this.no;
    data['countyList'] = this.countyList.map((e) => e.toJson()).toList();
    return data;
  }
}

class County {
  final String name;
  final String no;

  const County({required this.name, required this.no});

  County.fromJson(Map<String, dynamic> json)
      : this.name = json['name'] ?? '',
        this.no = json['no'] ?? '';

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['no'] = this.no;
    return data;
  }
}

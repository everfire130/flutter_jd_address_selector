# flutter_jd_address_selector

仿京东地址选择器

从https://github.com/shenhuaxiyuan/flutter_jd_address_selector 改编而来。空安全 ，代码简单重构，去掉热门

## Use

### pubspec.yaml

```yaml
dependencies:
  flutter_jd_address_selector:
    git:
      url: https://github.com/everfire130/flutter_jd_address_selector
      ref: 1.0.0
```

### import

```dart
    import 'package:flutter_jd_address_selector/flutter_jd_address_selector.dart';
```

### use

```dart
    void _choiceAddressDialog() async {
    print('======');
    Result? result = await showAddressSelectorDialog(
        context: context,
        province: _result.provinceName,
        city: _result.cityName,
        area: _result.areaName);

    if (result != null) {
      _result = result;
      address =
          '${result.provinceName}-${result.cityName}-${result.areaName}\n' +
              "${result.provinceId}-${result.cityId}-${result.areaId}";

      print('$address');
      setState(() {});
    }
  }
```

## 运行截图

| ![1](https://github.com/shenhuaxiyuan/flutter_jd_address_selector/blob/master/screen_pic/Screenshot_1591667475.png)) |
| :------------------------------------------------------------------------------------------------------------------: |


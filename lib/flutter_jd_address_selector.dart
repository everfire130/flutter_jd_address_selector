library flutter_jd_address_selector;

import 'dart:async';
import 'dart:convert';

import 'package:azlistview/azlistview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_jd_address_selector/province.dart';
import 'package:flutter_jd_address_selector/result.dart';
import 'package:lpinyin/lpinyin.dart';
import 'entity_info_model.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class JDAddressDialog extends StatefulWidget {
  final String? title;

  final Color unselectedColor;
  final Color selectedColor;
  final double itemTextFontSize;
  final TextStyle titleTextStyle;

  final String? provinceName;
  final String? cityName;
  final String? areaName;

  JDAddressDialog(
      {Key? key,
      this.title,
      this.unselectedColor = Colors.grey,
      this.selectedColor = Colors.blue,
      this.itemTextFontSize = 14.0,
      this.provinceName,
      this.cityName,
      this.areaName,
      this.titleTextStyle: const TextStyle(
          fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.bold)})
      : super(key: key);

  @override
  createState() => _JDAddressDialogState();
}

class _JDAddressDialogState extends State<JDAddressDialog>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final ItemScrollController _itemScrollController;
  List<Province> _provinces = [];

  /// 当前列表数据
  List<EntityInfo> _list = [];

  /// 三级联动选择的position
  final List<int> _positions = List.generate(3, (index) => -1, growable: false);
  static const double _ITEM_HEIGHT = 48.0;
  static const double _SUS_HEIGHT = 20;

  @override
  void initState() {
    super.initState();
    _itemScrollController = ItemScrollController();
    _tabController = TabController(vsync: this, length: _positions.length);

    _loadData().then((value) => setState(() {
          _provinces = value;
          int provinceIndex = -1;
          int cityIndex = -1;
          int areaIndex = -1;

          if (widget.provinceName != null) {
            provinceIndex = _provinces
                .indexWhere((province) => province.name == widget.provinceName);
          }

          if (provinceIndex >= 0 && widget.cityName != null) {
            cityIndex = _provinces[provinceIndex]
                .cityList
                .indexWhere((city) => city.name == widget.cityName);
          }

          if (cityIndex >= 0 && widget.areaName != null) {
            areaIndex = _provinces[provinceIndex]
                .cityList[cityIndex]
                .countyList
                .indexWhere((area) => area.name == widget.areaName);
          }

          _positions[0] = provinceIndex;
          _positions[1] = cityIndex;
          _positions[2] = areaIndex;
          _tabController.index = _index;
          _resetList();

          if (areaIndex >= 0) {
            final jumpIndex =
                _list.indexWhere((item) => item.name == widget.areaName);
            WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
              _itemScrollController.jumpTo(index: jumpIndex);
            });
          }
        }));
  }

  _resetList() {
    if (_positions[0] >= 0) {
      final province = _provinces[_positions[0]];

      if (_positions[1] >= 0) {
        final city = province.cityList[_positions[1]];

        _list =
            city.countyList.map((item) => EntityInfo(name: item.name)).toList();
      } else {
        _list = province.cityList
            .map((item) => EntityInfo(name: item.name))
            .toList();
      }
    } else {
      _list = _provinces.map((item) => EntityInfo(name: item.name)).toList();
    }
    _handleList(_list);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int get _index {
    for (var i = _positions.length - 1; i >= 0; i--) {
      if (_positions[i] != -1) {
        final index = i + 1;
        if (index >= _positions.length) {
          return _positions.length - 1;
        }
        return index;
      }
    }
    return 0;
  }

  List<String> get _tabStrings {
    final strings = List.generate(_positions.length, (index) => '');
    if (_positions[0] >= 0) {
      final province = _provinces[_positions[0]];
      strings[0] = province.name;

      if (_positions[1] >= 0) {
        final city = province.cityList[_positions[1]];
        strings[1] = city.name;
        if (_positions[2] >= 0) {
          final area = city.countyList[_positions[2]];
          strings[2] = area.name;
        }
      }
    }
    return strings;
  }

  List<Tab> get _tabs {
    bool firstEmpty = false;
    return _tabStrings.map((item) {
      if (!firstEmpty && item.isEmpty) {
        firstEmpty = true;
        item = '请选择';
      }
      return Tab(
        text: item,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.white,
        child: Container(
            height: MediaQuery.of(context).size.height * 11.0 / 16.0,
            child: Column(children: <Widget>[
              Stack(children: <Widget>[
                Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child:
                        Text("${widget.title}", style: widget.titleTextStyle)),
                Positioned(
                    right: 0,
                    child: IconButton(
                        icon: Icon(Icons.close, size: 22),
                        onPressed: () => Navigator.maybePop(context)))
              ]),
              _line,
              Container(
                  color: Colors.white,
                  alignment: Alignment.centerLeft,
                  child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      onTap: (index) {
                        if (_positions[index] == -1) {
                          _tabController.index = _index;
                          return;
                        }
                        for (var i = index; i < _positions.length; i++) {
                          _positions[i] = -1;
                        }
                        _resetList();
                        setState(() {});
                        _itemScrollController.jumpTo(index: 0);
                      },
                      indicatorSize: TabBarIndicatorSize.label,
                      unselectedLabelColor: Colors.black,
                      labelColor: widget.selectedColor,
                      tabs: _tabs)),
              _line,
              Expanded(
                  child: _provinces.length > 0
                      ? _buildListView()
                      : CupertinoActivityIndicator(animating: true))
            ])));
  }

  Future<List<Province>> _loadData() async {
    final jsonData = await rootBundle.loadString(
        'packages/flutter_jd_address_selector/assets/chinese_cities.json');
    return (json.decode(jsonData) as List)
        .map((e) => Province.fromJson(e))
        .toList();
  }

  clickItem(String name) {
    if (_index == 0) {
      _positions[_index] = _provinces.indexWhere((item) => item.name == name);
    } else if (_index == 1) {
      _positions[_index] = _provinces[_positions[0]]
          .cityList
          .indexWhere((element) => element.name == name);
    } else {
      _positions[_index] = _provinces[_positions[0]]
          .cityList[_positions[1]]
          .countyList
          .indexWhere((element) => element.name == name);
    }
    _resetList();
    _tabController.animateTo(_index);
    setState(() {});

    if (_index == 2 && _positions[_index] != -1) {
      final province = _provinces[_positions[0]];
      final city = province.cityList[_positions[1]];
      final area = city.countyList[_positions[2]];

      Navigator.of(context).maybePop(Result(
          provinceId: province.no,
          provinceName: province.name,
          cityId: city.no,
          cityName: city.name,
          areaId: area.no,
          areaName: area.name));
    } else {
      _itemScrollController.jumpTo(index: 0);
    }
  }

  Widget _buildListItem(EntityInfo info) {
    final tabStrings = _tabStrings;

    return InkWell(
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.0),
            height: _ITEM_HEIGHT,
            alignment: Alignment.centerLeft,
            child: Row(children: <Widget>[
              Text(info.name,
                  style: TextStyle(
                      fontSize: widget.itemTextFontSize,
                      color: info.name == tabStrings[_index]
                          ? widget.selectedColor
                          : widget.unselectedColor)),
              SizedBox(height: 8),
              Offstage(
                  offstage: info.name != tabStrings[_index],
                  child: Icon(Icons.check,
                      size: 14.0, color: widget.selectedColor))
            ])),
        onTap: () {
          clickItem(info.name);
        });
  }

  Widget _buildSusWidget(String susTag) {
    susTag = (susTag == "★" ? "热门城市" : susTag);
    return Container(
      height: _SUS_HEIGHT,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(left: 15.0),
      color: Color(0xfff3f4f5),
      alignment: Alignment.centerLeft,
      child: Text(
        '$susTag',
        softWrap: false,
        style: TextStyle(
          fontSize: 14.0,
          color: Color(0xff999999),
        ),
      ),
    );
  }

  Widget _buildListView() {
    return AzListView(
      itemScrollController: _itemScrollController,
      data: _list,
      itemCount: _list.length,
      itemBuilder: (context, index) {
        return _buildListItem(_list[index]);
      },
      susItemHeight: _SUS_HEIGHT,
      susItemBuilder: (ctx, index) {
        return _buildSusWidget(_list[index].tagIndex.toString());
      },
      indexBarData: SuspensionUtil.getTagIndexList(_list),
      indexBarOptions: IndexBarOptions(
        needRebuild: true,
        color: Colors.transparent,
        downColor: Color(0xFFEEEEEE),
      ),
    );
  }

  Widget _line = Container(height: 0.6, color: Color(0xFFEEEEEE));

  void _handleList(List<EntityInfo> list) {
    if (list.isEmpty) return;
    for (int i = 0, length = list.length; i < length; i++) {
      String pinyin = PinyinHelper.getPinyinE(list[i].name);
      String tag = pinyin.substring(0, 1).toUpperCase();
      list[i].namePinyin = pinyin;
      if (RegExp("[A-Z]").hasMatch(tag)) {
        list[i].tagIndex = tag;
      } else {
        list[i].tagIndex = "#";
      }
    }
    //根据A-Z排序
    SuspensionUtil.sortListBySuspensionTag(list);
    SuspensionUtil.setShowSuspensionStatus(list);
  }
}

Future<Result?> showAddressSelectorDialog({
  required BuildContext context,
  String? title = '',
  String? province,
  String? city,
  String? area,
  Color? selectedColor,
  Color? unselectedColor,
  double? itemTextFontSize,
  TextStyle? titleTextStyle,
}) {
  return showModalBottomSheet(
      context: context,
      isScrollControlled: true, //设为true，此时为全屏展示
      builder: (BuildContext context) {
        return JDAddressDialog(
            itemTextFontSize: itemTextFontSize ?? 14,
            titleTextStyle: titleTextStyle ??
                const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
            provinceName: province,
            cityName: city,
            areaName: area,
            title: title,
            selectedColor: selectedColor ?? Colors.red,
            unselectedColor: unselectedColor ?? Colors.black);
      });
}

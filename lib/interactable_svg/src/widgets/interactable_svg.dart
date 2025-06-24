import 'package:flutter/material.dart';
import './region_painter.dart';
import '../models/region.dart';
import '../parser.dart';
import '../size_controller.dart';

class InteractableSvg extends StatefulWidget {
  final bool _isFromWeb;
  final bool _isString;
  final double? width;
  final double? height;
  final String svgAddress;
  final String fileName;
  final Function(Region? region) onChanged;
  final ValueNotifier<List<String>> selectedRegion;
  final Color? strokeColor;
  final double? strokeWidth;
  final Color? selectedColor;
  final Color? dotColor;
  final bool? toggleEnable;
  final String? unSelectableId;
  final bool? centerDotEnable;
  final bool? centerTextEnable;
  final bool? isMultiSelectable;
  final TextStyle? centerTextStyle;

  const InteractableSvg({
    Key? key,
    required this.svgAddress,
    required this.onChanged,
    required this.selectedRegion,
    this.width,
    this.height,
    this.strokeColor,
    this.strokeWidth,
    this.selectedColor,
    this.dotColor,
    this.unSelectableId,
    this.centerDotEnable,
    this.centerTextEnable,
    this.centerTextStyle,
    this.toggleEnable,
    this.isMultiSelectable,
  })  : _isFromWeb = false,
        _isString = false,
        fileName = "",
        super(key: key);

  const InteractableSvg.network(
      {required this.fileName,
      Key? key,
      required this.svgAddress,
      required this.onChanged,
      required this.selectedRegion,
      this.width,
      this.height,
      this.strokeColor,
      this.strokeWidth,
      this.selectedColor,
      this.dotColor,
      this.unSelectableId,
      this.centerDotEnable,
      this.centerTextEnable,
      this.centerTextStyle,
      this.toggleEnable,
      this.isMultiSelectable})
      : _isFromWeb = true,
        _isString = false,
        super(key: key);

  const InteractableSvg.string(
      {Key? key,
      required this.svgAddress,
      required this.onChanged,
      required this.selectedRegion,
      this.width,
      this.height,
      this.strokeColor,
      this.strokeWidth,
      this.selectedColor,
      this.dotColor,
      this.unSelectableId,
      this.centerDotEnable,
      this.centerTextEnable,
      this.centerTextStyle,
      this.toggleEnable,
      this.isMultiSelectable})
      : _isFromWeb = false,
        _isString = true,
        fileName = "",
        super(key: key);

  @override
  InteractableSvgState createState() => InteractableSvgState();
}

class InteractableSvgState extends State<InteractableSvg> {
  final List<Region> _regionList = [];

  late ValueNotifier<List<String>> selectedRegion;
  final _sizeController = SizeController.instance;
  Size? mapSize;

  @override
  void initState() {
    super.initState();
    selectedRegion = widget.selectedRegion;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRegionList();
    });
  }

  _loadRegionList() async {
    late final List<Region> list;
    if (widget._isFromWeb) {
      list = await Parser.instance
          .svgToRegionListNetwork(widget.svgAddress, widget.fileName);
    } else if (widget._isString) {
      list = await Parser.instance.svgToRegionListString(widget.svgAddress);
    } else {
      list = await Parser.instance.svgToRegionList(widget.svgAddress);
    }

    _regionList.clear();
    setState(() {
      _regionList.addAll(list);
      mapSize = _sizeController.mapSize;
    });

    for(var reg in selectedRegion.value){
      if(_regionList.where((element) => element.id == reg).isEmpty){
        selectedRegion.value.removeWhere((element) => element == reg);
      }
    }
    
    selectedRegion.notifyListeners();
  }

  void clearSelect() {
    selectedRegion.value.clear();
    selectedRegion.notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (var region in _regionList) _buildStackItem(region),
      ],
    );
  }

  Widget _buildStackItem(Region region) {
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTap: () => (widget.toggleEnable ?? false)
          ? toggleButton(region)
          : holdButton(region),
      child: ValueListenableBuilder(
        valueListenable: selectedRegion,
        builder: (ctx, selected, child) => CustomPaint(
          isComplex: true,
          foregroundPainter: RegionPainter(
              region: region,
              selectedRegion: selected,
              dotColor: widget.dotColor,
              selectedColor: widget.selectedColor,
              strokeColor: widget.strokeColor,
              centerDotEnable: widget.centerDotEnable,
              centerTextEnable: widget.centerTextEnable,
              centerTextStyle: widget.centerTextStyle,
              strokeWidth: widget.strokeWidth,
              unSelectableId: widget.unSelectableId),
          child: Container(
            width: widget.width ?? double.infinity,
            height: widget.height ?? double.infinity,
            constraints: BoxConstraints(
                maxWidth: mapSize?.width ?? 0, maxHeight: mapSize?.height ?? 0),
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }

  void toggleButton(Region region) {
    if (region.id != widget.unSelectableId) {
      if (selectedRegion.value.where((element) => element == region.id).isNotEmpty) {
        selectedRegion.value.removeWhere((element) => element == region.id);
      } else {
        if (widget.isMultiSelectable ?? false) {
          selectedRegion.value.add(region.id);
        } else {
          selectedRegion.value.clear();
          selectedRegion.value.add(region.id);
        }
      }
      selectedRegion.notifyListeners();
      widget.onChanged.call(region);
    }
  }

  void holdButton(Region region) {
    if (region.id != widget.unSelectableId) {
      if (widget.isMultiSelectable ?? false) {
        selectedRegion.value.add(region.id);
      } else {
        selectedRegion.value.clear();
        selectedRegion.value.add(region.id);
      }
      selectedRegion.notifyListeners();
      widget.onChanged.call(region);
    }
  }
}

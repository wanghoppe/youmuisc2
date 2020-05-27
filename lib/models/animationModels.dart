import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/scheduler/ticker.dart';

class TabControllerProvider extends TickerProvider{

  Ticker _ticker;
  TabController _tabController;

  TabControllerProvider(){
    _tabController = TabController(vsync: this, length: 3, initialIndex: 0);
  }

  get tabController => _tabController;

  @override
  Ticker createTicker(onTick) {
    _ticker = Ticker(onTick, debugLabel: kDebugMode ? 'created by $this' : null);
    return _ticker;
  }
}

class AnimationTestModel extends ChangeNotifier{
  var titles = ['1 This is 1', '2 This is 2'];
  var curIdx = 0;

  get curTitle => titles[curIdx];

  void changeTitle(){
    curIdx = 1 - curIdx;
    notifyListeners();
  }
}


class BottomSheetControllerProvider extends TickerProvider{

  static const s1 = 0.2;
  static const s2 = 0.6;

  Ticker _ticker;
  AnimationController _controller;
  bool canBeDragged = false;

  get controller => _controller;

  BottomSheetControllerProvider(){
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
  }


  @override
  Ticker createTicker(onTick) {
    _ticker = Ticker(onTick, debugLabel: kDebugMode ? 'created by $this' : null);
    return _ticker;
  }
  
}
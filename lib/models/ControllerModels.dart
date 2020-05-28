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

  static const s1 = 0.3;
  static const s2 = 0.7;
  static const durationMill = 900;

  Ticker _ticker;
  AnimationController _controller;
  bool canBeDragged = false;

  get controller => _controller;

  BottomSheetControllerProvider(){
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: durationMill));
  }


  @override
  Ticker createTicker(onTick) {
    _ticker = Ticker(onTick, debugLabel: kDebugMode ? 'created by $this' : null);
    return _ticker;
  }

  void _curvedAnimateTo(double val){
    _controller.animateTo(val, curve: Curves.easeOutCubic);
  }

  bool nextDown(){
    if (_controller.value > s2){
      _curvedAnimateTo(s2);
    }else if (_controller.value > s1) {
      _curvedAnimateTo(s1);
    }else{
      return false;
    }
    return true;
  }

  void nextUp(){
    if (_controller.value < s2){
      _curvedAnimateTo(s2);
    }else{
      _curvedAnimateTo(1.0);
    }
  }

  void onZeroDrop(){
    final mid1 = (s1 + s2)/2;
    final mid2 = (s2 + 1.0)/2;

    if (_controller.value < mid1) _curvedAnimateTo(s1);
    else if (_controller.value > mid2) _curvedAnimateTo(1.0);
    else _curvedAnimateTo(s2);
  }

  void onDropDownClick(){
    if (_controller.value == 1.0){
      quickToS1();
    }else if (_controller.value == s2){
      _curvedAnimateTo(s1);
    }
  }

  void onClosedTap(){
    if (_controller.value == s1) {
      _curvedAnimateTo(s2);
    }
  }

  void onCloseClick() => _controller.animateTo(0.0);

  void quickToS1(){
//    _curvedAnimateTo(s1,
//        duration: Duration(milliseconds: (durationMill*(s2-s1)).round()));
    _controller.value = s2;
    _curvedAnimateTo(s1);
  }
}

class HomeNavigatorController{
  GlobalKey<NavigatorState> homeNavigator = GlobalKey<NavigatorState>();
  final BottomSheetControllerProvider bottomController;

  HomeNavigatorController(this.bottomController);

  Future<bool> handleAndroidBack() async{
    if (!bottomController.nextDown()){
      if (homeNavigator.currentState.canPop()){
        homeNavigator.currentState.pop();
      }else{
        return true;
      }
    }
    return false;
  }
}
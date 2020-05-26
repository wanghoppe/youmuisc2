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

class BottomSheetControllerProvider extends TickerProvider{
  static const double maxSlide = 800;
  static const double minDragStartEdge = 60;
  static const double maxDragStartEdge = maxSlide - 16;

  Ticker _ticker;
  AnimationController _controller;
  bool _canBeDragged = false;

  get controller => _controller;

  void onTap() {
    if (_controller.isDismissed) {
//      _controller.forward();
      _controller.animateTo(0.5);
    } else if (_controller.isCompleted) {
      _controller.reverse();
    }
  }

  void onDragStart(DragStartDetails details) {
    bool isDragOpenFromLeft = _controller.isDismissed &&
        details.globalPosition.dx < minDragStartEdge;
    bool isDragCloseFromRight = _controller.isCompleted &&
        details.globalPosition.dx > maxDragStartEdge;

    _canBeDragged = isDragOpenFromLeft || isDragCloseFromRight;
    _canBeDragged = true;

  }

  void onDragUpdate(DragUpdateDetails details) {
    if (_canBeDragged) {
      double delta = details.primaryDelta / maxSlide;
      _controller.value += delta;
    }
  }

  void onDragEnd(DragEndDetails details) {
    //I have no idea what it means, copied from Drawer
    if (_controller.value < 0.5) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }


  BottomSheetControllerProvider(){
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 300));
  }

  @override
  Ticker createTicker(onTick) {
    _ticker = Ticker(onTick, debugLabel: kDebugMode ? 'created by $this' : null);
    return _ticker;
  }
  
}
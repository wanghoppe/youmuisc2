

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
  @override
  Ticker createTicker(onTick) {
    // TODO: implement createTicker
    throw UnimplementedError();
  }
  
}
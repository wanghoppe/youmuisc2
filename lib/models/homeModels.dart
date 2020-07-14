import 'package:flutter/cupertino.dart';
import 'package:youmusic2/client/client.dart';
import 'package:youmusic2/client/homeUtils.dart';
import 'package:youmusic2/views/homeView.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class LoadModel extends ChangeNotifier{
  var finished = false;

  void finish(){
    if (!finished){
      finished = true;
      notifyListeners();
    }
  }
  void start(){
    if (finished){
      finished = false;
      notifyListeners();
    }
  }
}

class AnimatedListModel{

  var _list = <Widget>[];
  final listKey = GlobalKey<SliverAnimatedListState>();
  final loadModel;
  var _subscription;

  AnimatedListModel({@required this.loadModel});

  void consume(){
    if (!loadModel.finished){
      _subscription?.cancel();
      _removeAnimatedAll();
    }
    loadModel.start();

    final rowStream = HomePageStream(client: getIt<ApiClient>()).stream;
    _subscription = rowStream.listen(
      (json) => _insert(json),
      onDone: () => loadModel.finish()
    );
  }

  void _insert(Map<String, dynamic> json) {
    _list.add(HomeRow(json: json, index: _list.length));
    listKey.currentState
        .insertItem(_list.length-1, duration:const Duration(milliseconds: 600));
  }

  void resetList(){
    _removeAnimatedAll();
    consume();
  }

  void _removeAnimatedAll(){
    for (var i = _list.length-1; i>=0; i--){
      listKey.currentState.removeItem(i, (context, animation) => Container());
    }
    _list = <Widget>[];
  }
  int get length => _list.length;

  Widget operator [](int index) => _list[index];

  int indexOf(Widget item) => _list.indexOf(item);
}
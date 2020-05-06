import 'package:flutter/cupertino.dart';

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
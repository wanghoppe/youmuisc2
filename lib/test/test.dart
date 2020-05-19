

import 'dart:io';
import 'dart:async';




class Test{
  var num = 1;
  Future<bool> finished;

  Test(){finished = myTest();}

  Future<bool> myTest() async{
    await Future.delayed(Duration(seconds: 1));
    num = 2;
    return Future.error('Error from return');
  }
}

void main() async{
  var t1 = Test();
  try {
    await t1.finished;
  }catch(e){
    print(e);
  }
  var x = await t1.finished;
  print(t1.num);
  print(t1.finished.toString());
}
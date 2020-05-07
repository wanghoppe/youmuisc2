

import 'dart:io';

void main(){
  print('This is just a test');
  var f =  File('output/local.txt');
  f.writeAsStringSync('contents');
}
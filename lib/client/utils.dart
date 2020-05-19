import 'dart:convert';
import 'dart:io';

void prettyWrite(File file, Map m){
  final encoder = JsonEncoder.withIndent('  ');
  final prettyPrint = encoder.convert(m);
  file.writeAsStringSync(prettyPrint);
}
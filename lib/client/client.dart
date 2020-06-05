import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:youmusic2/client/utils.dart';
import 'dart:convert';
import 'requestConst.dart' as c;


class ApiClient{
  final _visitorReg = RegExp(r'"VISITOR_DATA":"(.*?)"');
  final _pageLabelReg = RegExp(r'"PAGE_BUILD_LABEL":"(.*?)"');
  final _deviceReg = RegExp(r'"DEVICE":"(.*?)"');
  static const URL = 'music.youtube.com';
  static const BROWSE = '/youtubei/v1/browse';
  static const NEXT = '/youtubei/v1/next';
  var partialHeader;

  Future isReady;

  ApiClient(){
    isReady = getPartialHeader();
  }

  Future<void> getPartialHeader() async{
    var response = await http.get(
      'https://music.youtube.com',
      headers: c.getHeaderMap,
    );
    assert(response.statusCode == 200);
    var html = response.body;
    partialHeader = <String, String>{
      'X-YouTube-Device': _deviceReg.firstMatch(html)?.group(1)
          ?.replaceAll('\\u0026', '\u0026'),
      'X-YouTube-Page-Label': _pageLabelReg.firstMatch(html)?.group(1),
      'X-Goog-Visitor-Id': _visitorReg.firstMatch(html)?.group(1),
//      ...c.headerTest //todo
    };
  }

  Future<String> getFirstResponse() async{
    await isReady;
    assert(partialHeader != null);
    var response = await http.post(
        Uri.https(URL, BROWSE, c.queryParaBase),
        headers: {...c.headerMapBase, ...partialHeader},
        body: jsonEncode(c.firstBodyMap)
    );
//    assert(response.statusCode == 200);
    if(response.statusCode != 200){
      print(response.body);
      throw(Error);
    }
    return response.body;
  }

  Future<String> getContinueResponse(String continuation, String itct) async{
    await isReady;
    assert(partialHeader != null);
    final para = {
      'ctoken': continuation,
      'continuation': continuation,
      'itct': itct,
      ...c.queryParaBase
    };
    var response = await http.post(
        Uri.https(URL, BROWSE, para),
        headers: {...c.headerMapBase, ...partialHeader},
        body: jsonEncode(c.bodyMap)
    );
    assert(response.statusCode == 200);
    return response.body;
  }

  Future<String> getPlaylistResponse(Map navigationEndpoint) async{
    await isReady;
//    print(navigationEndpoint);
    final requestBody = {
      'context': {
        ...c.bodyMap['context'],
        'clickTracking': {
          'clickTrackingParams': navigationEndpoint['clickTrackingParams']
        }
      },
      ...navigationEndpoint['browseEndpoint']
    };
    var response = await http.post(
        Uri.https(URL, BROWSE, c.queryParaBase),
        headers: {...c.headerMapBase, ...partialHeader},
        body: jsonEncode(requestBody)
    );
//    prettyWrite(File('output/playlist/album_raw.json'),jsonDecode(response.body));
//    print(response.statusCode);
    assert(response.statusCode == 200);
    return response.body;
  }

  Future<String> getWatchResponse(Map testBody) async{
    await isReady;
    final requestBody = {
      ...c.bodyMap,
      ...testBody
    };
    final response = await http.post(
        Uri.https(URL, NEXT, c.queryParaBase),
        headers: {...c.headerMapBase, ...partialHeader},
        body: jsonEncode(requestBody)
    );
    assert(response.statusCode == 200);
    return response.body;
  }
}

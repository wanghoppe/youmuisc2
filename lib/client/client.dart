import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'requestConst.dart' as c;


class ApiClient{
  final _visitorReg = RegExp(r'"VISITOR_DATA":"(.*?)"');
  final _pageLabelReg = RegExp(r'"PAGE_BUILD_LABEL":"(.*?)"');
  final _deviceReg = RegExp(r'"DEVICE":"(.*?)"');
  static const URL = 'music.youtube.com';
  static const BROWSE = '/youtubei/v1/browse';
  var partialHeader;

  ApiClient();

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
      'X-Goog-Visitor-Id': _visitorReg.firstMatch(html)?.group(1)
    };
  }

  Future<String> getFirstResponse() async{
    assert(partialHeader != null);
    var response = await http.post(
        Uri.https(URL, BROWSE, c.queryParaBase),
        headers: {...c.headerMapBase, ...partialHeader},
        body: jsonEncode(c.firstBodyMap)
    );
    assert(response.statusCode == 200);
    return response.body;
  }

  Future<String> getContinueResponse(String continuation, String itct) async{
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
        body: jsonEncode(c.continueBodyMap)
    );
    // print(response.statusCode);
    assert(response.statusCode == 200);
    return response.body;
  }
}

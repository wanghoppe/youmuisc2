import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'requestConst.dart' as c;


//void main() async{
//  final mystream = HomePageStream().stream;
//  var i = 1;
//  final sub = mystream.listen((data){
//    var f = File('data/sample/nb${i.toString()}.json');
//    prettyWrite(f, data);
//    i ++;
//  });
//}


void prettyWrite(File file, Map m){
  final encoder = JsonEncoder.withIndent('  ');
  final prettyprint = encoder.convert(m);
  file.writeAsStringSync(prettyprint);
}

class HomePageStream{
  final _controller = StreamController<Map>();

  HomePageStream(){
    _init();
  }

  void _init() async{
    final client = ApiClient();
    await client.getPartialHeader();

    var resString = await client.getFirstResponse();
    var resMap = getFirstInfoFromStr(resString);
    for (var row in resMap['list']){
      _controller.sink.add(row);
    }

    while (resMap['hasContinue']){
      resString = await client.getContiResponse(
          resMap['continuation'], resMap['itct']
      );
      resMap = getContinueInfoFromStr(resString);
      for (var row in resMap['list']){
        _controller.sink.add(row);
      }
    }
    await _controller.close();
  }

  Stream<Map> get stream => _controller.stream;

  Map<String, dynamic> getContinueInfoFromStr(String str){
    final infoMap = <String, dynamic>{};
    var infoList = <Map>[];
    final json = jsonDecode(str);
    final sectionListContinuation = json['continuationContents']
    ['sectionListContinuation'];
    for (final content in sectionListContinuation['contents']){
      if (content.containsKey('musicCarouselShelfRenderer')){
        infoList.add(_parseRow(content));
      }
    }
    infoMap['list'] = infoList;
    if (sectionListContinuation.containsKey('continuations')){
      final contiData = sectionListContinuation['continuations'][0]
      ['nextContinuationData'];

      infoMap['hasContinue'] = true;
      infoMap['continuation'] = contiData['continuation'];
      infoMap['itct'] = contiData['clickTrackingParams'];
    }else{
      infoMap['hasContinue'] = false;
    }
    return infoMap;
  }


  Map<String, dynamic> getFirstInfoFromStr(String str){
    final infoMap = <String, dynamic>{};
    var infoList = <Map>[];
    final json = jsonDecode(str);
    final sectionListRenderer = json['contents']['singleColumnBrowseResultsRenderer']
    ['tabs'][0]['tabRenderer']['content']['sectionListRenderer'];
    for (final content in sectionListRenderer['contents']){
      if (content.containsKey('musicCarouselShelfRenderer')){
        infoList.add(_parseRow(content));
      }
    }
    infoMap['list'] = infoList;
    if (sectionListRenderer.containsKey('continuations')){
      final contiData = sectionListRenderer['continuations'][0]
      ['nextContinuationData'];

      infoMap['hasContinue'] = true;
      infoMap['continuation'] = contiData['continuation'];
      infoMap['itct'] = contiData['clickTrackingParams'];
    }else{
      infoMap['hasContinue'] = false;
    }
    return infoMap;
  }

  Map<String, dynamic> _parseRow(row){
    final rowMap = <String, dynamic>{};
    rowMap['title'] = row['musicCarouselShelfRenderer']['header']
    ['musicCarouselShelfBasicHeaderRenderer']['title']['runs'][0]['text'];
    final items = row['musicCarouselShelfRenderer']['contents'];
    rowMap['itemList'] = [];
    for (final item in items){
      rowMap['itemList'].add(_parseItem(item));
    }
    return rowMap;
  }

  Map<String, dynamic> _parseItem(item){
    final itemMap = <String, dynamic>{};
    final content =  item['musicTwoRowItemRenderer'];
    itemMap['thumbnails'] = content['thumbnailRenderer']['musicThumbnailRenderer']
    ['thumbnail']['thumbnails'];
    itemMap['aspectRatio'] = content['aspectRatio'];
    itemMap['title'] = content['title']['runs'][0]['text'];
    itemMap['subtitleList'] = content['subtitle']['runs']?.map((it) => it['text'])?.toList();
    itemMap['navigationEndpoint'] = content['navigationEndpoint'];
    return itemMap;
  }
}


class ApiClient{
  final _visitorReg = RegExp(r'"VISITOR_DATA":"(.*?)"');
  final _pageLabelReg = RegExp(r'"PAGE_BUILD_LABEL":"(.*?)"');
  final _deviceReg = RegExp(r'"DEVICE":"(.*?)"');
  final URL = 'music.youtube.com';
  final BROWSE = '/youtubei/v1/browse';
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
      'X-YouTube-Device': _deviceReg.firstMatch(html)?.group(1)?.replaceAll('\\u0026', '\u0026'),
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

  Future<String> getContiResponse(String continuation, String itct) async{
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
        body: jsonEncode(c.contiBodyMap)
    );
    // print(response.statusCode);
    assert(response.statusCode == 200);
    return response.body;
  }
}

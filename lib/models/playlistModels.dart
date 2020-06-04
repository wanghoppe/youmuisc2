
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:youmusic2/client/client.dart';
import 'package:youmusic2/client/playlistUtils.dart';

import '../main.dart';


class InfolistModel{
  final client = getIt<ApiClient>();
  final Map navigationEndPoint;
  Future<List> futureList;
  final bool isAlbum;

  InfolistModel(this.navigationEndPoint):
      isAlbum = navigationEndPoint['browseEndpoint']
      ['browseEndpointContextSupportedConfigs']
      ['browseEndpointContextMusicConfig']
      ['pageType'] == 'MUSIC_PAGE_TYPE_ALBUM'
  {
    futureList = getPlaylist();
  }

  Future<List> getPlaylist() async{
    final str = await client.getPlaylistResponse(navigationEndPoint);
    List infoList;
    if (isAlbum) infoList = await compute(getAlbumFromStr, str);
    else infoList = await compute(getInfoListFromStr, str);
    return infoList;
  }
}

class DisableButtonModel extends ChangeNotifier{
  bool isDisable = true;
  bool _disposed = false;
  Future finished;

  DisableButtonModel(this.finished){
    enable();
  }

  void enable() async{
    await finished;
    isDisable = false;
    if (! _disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _disposed = true;
  }

}

class OpacityController{

  final appBar = OpacityModel(0.0);
  final header = OpacityModel(1.0);
  double scrollPos = 0.0;

  void changeScrollPos(double value){
    scrollPos = value;
    var op1 = min(max(scrollPos - 180, 0.0), 20)/20;
    var op2 = max(min(1 - scrollPos/200, 1.0), 0.0);
    appBar.changeOpacity(op1);
    header.changeOpacity(op2);
  }
}


class OpacityModel extends ChangeNotifier{

  double opacity;

  OpacityModel(this.opacity);

  void changeOpacity(double newOpacity){
    if (opacity != newOpacity) {
      opacity = newOpacity;
      notifyListeners();
    };
  }
}

import 'dart:io' show Directory, Platform;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youmusic2/main.dart';
import 'package:youmusic2/playerClient/playerClient.dart';

class MusicDownloader{
  final dio = Dio();

  Future<Directory> getMusicDirectory() async {
    final basePath = await getApplicationDocumentsDirectory();
    var dir = Directory('${basePath.path}/music');
    final exist = await dir.exists();
    if (! exist){
      await dir.create();
    }
    return dir;
  }

  Future<Directory> getImgDirectory() async {
    final basePath = await getApplicationDocumentsDirectory();
    var dir = Directory('${basePath.path}/img');
    final exist = await dir.exists();
    if (! exist){
      await dir.create();
    }
    return dir;
  }

  String _getExtension(){
    if (Platform.isIOS){
      return 'mp4';
    }
    return 'webm';
  }

  Future<void> tempDownload({@required videoId, @required String title,
    @required String subtitle, @required imgUrl}
  ) async {
    print('download for $title is started');
    final musicDir = await getMusicDirectory();
    final imgDir = await getImgDirectory();
    final extension = _getExtension();

    final playerClient = getIt<PlayerClient>();
    final downloadUrl = await playerClient.getStreamingUrl(videoId);
//    print(downloadUrl);
    dio.download(imgUrl, '${imgDir.path}/$videoId');
    await dio.download(downloadUrl, '${musicDir.path}/$title:::$subtitle:::$videoId.$extension');
    print('download finished');
  }

  Future<void> deleteAll() async {
    final musicDir = await getMusicDirectory();
    final imgDir = await getImgDirectory();
    await musicDir.delete(recursive: true);
    await imgDir.delete(recursive: true);
    print('deleted all music and image');
  }

}
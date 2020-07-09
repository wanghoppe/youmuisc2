
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:youmusic2/models/controllerModels.dart';
import 'package:youmusic2/models/downloadModels.dart';
import 'package:youmusic2/main.dart';
import 'package:youmusic2/models/playerModels.dart';
import 'package:youmusic2/views/homeView.dart';
import 'package:youmusic2/views/utilsView.dart';

class LocalUnderTab extends StatefulWidget{
  @override
  _LocalUnderTabState createState() => _LocalUnderTabState();
}

class _LocalUnderTabState extends State<LocalUnderTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('local'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.refresh), onPressed: (){
            setState(() {});
          })
        ],
      ),
      body: LocalListView(),
    );
  }
}

class LocalListView extends StatelessWidget{

  Future<List<File>> getFutureList() async {

    final downloader = getIt<MusicDownloader>();
    final musicDir = await downloader.getMusicDirectory();
//    print(musicDir);
    final ret = <File>[];
    await for (File music in musicDir.list()){
      ret.add(music);
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<File>>(
      future: getFutureList(),
      builder: (context, snapshot) {
        print('[$this]');
        if (snapshot.hasData){
          final fileList = snapshot.data;
          return ListView.builder(
            itemCount: fileList.length,
            itemBuilder: (context, index){
              return LocalItem(fileList[index], index);
            },
          );
        }else{
          return GeneralActivityIndicatorContainer();
        }
      },
    );
  }
}

class LocalItem extends StatelessWidget{

  final File _file;
  final int _idx;
  String title;
  String subtitle;
  String imgUrl;
  String videoId;

  LocalItem(this._file, this._idx){
    final fileName = _file.path.split('/').last;
    final fileNameLst = fileName.split(':::');
    title = fileNameLst[0];
    subtitle = fileNameLst[1];
    videoId = fileNameLst[2].substring(0, 11);
    imgUrl = _file.parent.parent.path + '/img/$videoId';
  }

  void _onItemTap(BuildContext context){
    final audioPlayer = Provider.of<AudioPlayerProvider>(context, listen: false);
    final infoProvider = Provider.of<PlayerInfoProvider>(context, listen: false);
    final animationController = getIt<BottomSheetControllerProvider>();

    infoProvider.setValue(
        Future.value(videoId),
        Future.value(imgUrl),
        Future.value(title),
        Future.value(subtitle.split(' • ')[0]),
        networkImg: false
    );
    animationController.animatedToS2();
    audioPlayer.playFromMediaItem(
      MediaItem(
        id: _file.path,
        album: subtitle,
        title: title,
        artUri: imgUrl,
      )
    );
  }

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: (){_onItemTap(context);},
      child: CustomListTile(
        title: title,
        subtitle: subtitle,
        imgUrl: imgUrl,
        morePressed: (){},
        cropCircle: false,
        heroIdx: 'null',
      ),
    );
  }

}

List<File> getDirList(Directory dir) {
  return dir.listSync();
}

class ThirdTab extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Baby')),
      body: Center(
        child: IconButton(
          icon: Icon(Icons.delete),
          onPressed: (){
            final downloader = getIt<MusicDownloader>();
            downloader.deleteAll();
          },
        ),
      ),
    );
  }

}
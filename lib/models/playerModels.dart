


import 'package:just_audio/just_audio.dart';

class PlayerTestProvider{
  final state = PlayerStateProvider();
}

class PlayerStateProvider{
  static const testUrl = 'https://r4---sn-ni5f-t8gz.googlevideo.com/videoplayback?expire=1591161500&ei=O97WXuH9OoWSkgadh5vADw&ip=24.87.163.50&id=o-AJqm69DmKVYVmuEAMTN_Dw_-nkGNAn8rjbOxZ_hBqU2S&itag=251&source=youtube&requiressl=yes&mh=AH&mm=31%2C26&mn=sn-ni5f-t8gz%2Csn-vgqs7ns7&ms=au%2Conr&mv=m&mvi=3&pl=14&gcr=ca&initcwndbps=1672500&vprv=1&mime=audio%2Fwebm&gir=yes&clen=3082997&dur=183.321&lmt=1581546926082766&mt=1591139795&fvip=4&keepalive=yes&c=WEB&txp=5531432&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cgcr%2Cvprv%2Cmime%2Cgir%2Cclen%2Cdur%2Clmt&lsparams=mh%2Cmm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpl%2Cinitcwndbps&lsig=AG3C_xAwRQIhAME3xZftOI_qcXSYOTbtiCwv052gg9QrXddAUjUaGcg4AiARCFvIglYQOxS2m0KZ_tFHb7LDvc5FALRLJml3gNexmw%3D%3D&sig=AOq0QJ8wRQIhAP1xhldHC_oGQvnOEzLn2ZdtoDw4ASntKhNosi_5486vAiAJ7zltIR7wx0QABf5_ze86yHXaPvoP2ExFF30QPJgHdQ%3D%3D';
  final _audioPlayer = AudioPlayer();
  Future<void> finishSet;


  PlayerStateProvider(){
    print('here1');
    finishSet = setUrl();
  }

  Future<void> setUrl({String url: testUrl}) async{
    print('here2');
    await _audioPlayer.setUrl(url);
    print('setUrl finished');
  }
  
  void play() async{
    await finishSet;
    await _audioPlayer.play();
  }

  void pause() async{
    await finishSet;
    await _audioPlayer.pause();
  }
}
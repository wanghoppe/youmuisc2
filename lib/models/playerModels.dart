import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:youmusic2/main.dart';
import 'package:youmusic2/playerClient/playerClient.dart';

import 'controllerModels.dart';

class AudioPlayerProvider {
  static const testUrl =
      'https://r6---sn-ni5f-t8gs.googlevideo.com/videoplayback?expire=1591320751&ei=T0zZXsK0Hcz_kga8upi4Aw&ip=24.87.163.50&id=o-AFXmubMFvoo9KhLduUKZ2hROoKtHFaIe5TCPbBYXCk4E&itag=251&source=youtube&requiressl=yes&mh=3A&mm=31%2C26&mn=sn-ni5f-t8gs%2Csn-vgqsrnek&ms=au%2Conr&mv=m&mvi=5&pcm2cms=yes&pl=14&initcwndbps=1766250&vprv=1&mime=audio%2Fwebm&gir=yes&clen=4377575&dur=267.261&lmt=1540664086012589&mt=1591299045&fvip=2&keepalive=yes&c=WEB&txp=5411222&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cvprv%2Cmime%2Cgir%2Cclen%2Cdur%2Clmt&lsparams=mh%2Cmm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpcm2cms%2Cpl%2Cinitcwndbps&lsig=AG3C_xAwRgIhALecGzvSO6wqZK7rpXdFjScUTbJMF3SnOlOIyKstdHjJAiEAxBt31SagKvtiTB-cntlF-vcl9czQOu_1JMCVXewWAiQ%3D&sig=AOq0QJ8wRQIhAKkEpIGrQaWM4kYcPFLcW-VPHmua109TwmFQA4Zt7HXJAiBnQCSxNKoNvHej5vAAyvkCDkX4CKqcSbkV72-0JTTf_g%3D%3D';

  static const testUrl2 =
      'https://r6---sn-ni5f-t8gs.googlevideo.com/videoplayback?expire=1591418827&ei=a8vaXsjiJseqkgbeq7HABg&ip=24.87.163.50&id=o-ALFUivFcV5Ac4P_pjxWt6IFgQJM1YxAYE2cT1AYxoeHP&itag=251&source=youtube&requiressl=yes&mh=3A&mm=31%2C26&mn=sn-ni5f-t8gs%2Csn-vgqsrnek&ms=au%2Conr&mv=m&mvi=5&pl=14&initcwndbps=1770000&vprv=1&mime=audio%2Fwebm&gir=yes&clen=4377575&dur=267.261&lmt=1540664086012589&mt=1591397198&fvip=2&keepalive=yes&fexp=23882513&c=WEB&txp=5411222&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cvprv%2Cmime%2Cgir%2Cclen%2Cdur%2Clmt&lsparams=mh%2Cmm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpl%2Cinitcwndbps&lsig=AG3C_xAwRQIgTAdCPZk-GNQkVVqkLKCIJZJrLprGonO-9rIttUWEYDkCIQDy4UO7M-q7CTNM-s3nz8iE76oTspDN1XleYqC3FO7QjA%3D%3D&sig=AOq0QJ8wRAIgHfXDC0dPYqGPV2zU7uu45u6tsOSwp24N1dh61L3gWPoCICroutv9YRuL7z5a3npbOtqgMRogrcKZwvU-FQIDc_lP';

  final _audioPlayer = AudioPlayer();

  final _playerClient = getIt<PlayerClient>();

  Future<void> finishSet;

  final _playingSubject = BehaviorSubject<bool>();
  final _bufferingSubject = BehaviorSubject<bool>();
  final _durationSubject = BehaviorSubject<Duration>();

  AudioPlayerProvider() {
    _playingSubject.addStream(
        _audioPlayer.playbackEventStream
            .map((event) => event.state == AudioPlaybackState.playing)
            .distinct(),
        cancelOnError: false);

    _audioPlayer.bufferingStream.listen((event) {
      _bufferingSubject.add(event);
    });

    _audioPlayer.durationStream.listen((event) {
      _durationSubject.add(event);
    });

//    finishSet = setUrl(testUrl2); //todo
  }

  Stream<Duration> get durationStream => _durationSubject.stream;

  Stream<Duration> get positionStream => _audioPlayer.getPositionStream();

  Stream<Duration> get bufferStream => _audioPlayer.bufferedPositionStream;

  Stream<bool> get playingStream => _playingSubject.stream;

  Stream<bool> get bufferingStream => _bufferingSubject.stream;

  Future<void> playFromVideoId(String videoId) async{
    _bufferingSubject.add(true);
    _durationSubject.add(null);
    if (_audioPlayer.playbackState == AudioPlaybackState.playing){
      await _audioPlayer.stop();
    }
    final url = await _playerClient.getStreamingUrl(videoId);

    await _audioPlayer.setUrl(url);
    await _audioPlayer.play(); //todo
    _bufferingSubject.add(false);
  }

  void play() async {
    await finishSet;
    await _audioPlayer.play();
  }

  void pause() async {
    await finishSet;
    await _audioPlayer.pause();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }
}

class PlayerInfoProvider extends ChangeNotifier {
  Future<String> futureUrl;

  Future<String> futureTitle;

  Future<String> futureSubtitle;

  void setValue(
      Future<String> url, Future<String> title, Future<String> subtitle) {
    futureUrl = url;
    futureTitle = title;
    futureSubtitle = subtitle;
    notifyListeners();
  }
}

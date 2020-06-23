import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:youmusic2/main.dart';
import 'package:youmusic2/playerClient/playerClient.dart';

class AudioPlayerProvider {

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

  Stream<Duration> get positionStream => _audioPlayer.getPositionStream(
    Duration(milliseconds: 500)
  );

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

    if (! _audioPlayer.playbackEvent.buffering) _bufferingSubject.add(false);
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

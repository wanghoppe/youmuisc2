import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:youmusic2/main.dart';
import 'package:youmusic2/playerClient/playerClient.dart';

MediaControl playControl = MediaControl(
  androidIcon: 'drawable/ic_action_play_arrow',
  label: 'Play',
  action: MediaAction.play,
);
MediaControl pauseControl = MediaControl(
  androidIcon: 'drawable/ic_action_pause',
  label: 'Pause',
  action: MediaAction.pause,
);
MediaControl skipToNextControl = MediaControl(
  androidIcon: 'drawable/ic_action_skip_next',
  label: 'Next',
  action: MediaAction.skipToNext,
);
MediaControl skipToPreviousControl = MediaControl(
  androidIcon: 'drawable/ic_action_skip_previous',
  label: 'Previous',
  action: MediaAction.skipToPrevious,
);
MediaControl stopControl = MediaControl(
  androidIcon: 'drawable/ic_action_stop',
  label: 'Stop',
  action: MediaAction.stop,
);

class AudioPlayerProvider {

  final _playerClient = getIt<PlayerClient>();

  final _playingSubject = BehaviorSubject<bool>();
  final _bufferingSubject = BehaviorSubject<bool>();
  final _durationSubject = BehaviorSubject<Duration>();
  final _positionSubject = BehaviorSubject<Duration>();
  final _bufferSubject = BehaviorSubject<Duration>();

  PlaybackState _playbackState;

  AudioPlayerProvider() {
    AudioService.start(backgroundTaskEntrypoint: _audioPlayerTaskEntryPoint);

    AudioService.playbackStateStream.listen((PlaybackState state) {
//      print('receive here');
//      print(state.processingState);
      if (state.processingState == AudioProcessingState.buffering){
        _bufferingSubject.add(true);
      }else{
        _bufferingSubject.add(false);
      }

      _playbackState = state;
      _playingSubject.add(state.playing);
      _positionSubject.add(state.position);
      _bufferSubject.add(state.bufferedPosition);
    });

    AudioService.currentMediaItemStream.listen((event) {
      if (event != null) {
        _durationSubject.add(event.duration);
      }
    });


    Stream.periodic(Duration(milliseconds: 500)).listen((event) {
      if (_playbackState != null){
        _positionSubject.add(_playbackState.currentPosition);
      }
    });
  }

  Stream<Duration> get durationStream => _durationSubject.distinct();

  Stream<Duration> get positionStream => _positionSubject.distinct();

  Stream<Duration> get bufferStream => _bufferSubject.distinct();

  Stream<bool> get playingStream => _playingSubject.distinct();

  Stream<bool> get bufferingStream => _bufferingSubject.distinct();

  Future<void> playFromVideoId(String videoId) async{
    _bufferingSubject.add(true);
    _durationSubject.add(null);
    
    AudioService.pause();
    final url = await _playerClient.getStreamingUrl(videoId);
    await AudioService.playFromMediaId(url);
  }

  void play() {
    AudioService.play();
  }

  void pause() async {
    AudioService.pause();
  }

  Future<void> seekTo(Duration position) async{
    return await AudioService.seekTo(position);
  }
}

void _audioPlayerTaskEntryPoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

class CustomBackEvent{
  final String key;
  final dynamic value;

  CustomBackEvent(this.key, this.value);
}

class AudioPlayerTask extends BackgroundAudioTask {

  final _audioPlayer = AudioPlayer();

  MediaItem _mediaItem;

  StreamSubscription<Duration> _durationSubscription;
  StreamSubscription<AudioPlaybackEvent> _eventSubscription;

  @override
  Future<void> onUpdateMediaItem(MediaItem mediaItem) {
    _mediaItem = mediaItem;
    return null;
  }

  @override
  onStart(Map<String, dynamic> params) {

    _durationSubscription = _audioPlayer.durationStream.listen(_sendDuration);

    _eventSubscription = _audioPlayer.playbackEventStream.listen((event) {
      final bufferingState = (event.buffering || event.state == AudioPlaybackState.connecting) ? AudioProcessingState.buffering
          : AudioProcessingState.ready;
      _setState(processingState: bufferingState);
    });

  }

  @override
  void onPlayFromMediaId(String mediaId) async{
    if (_audioPlayer.playbackState == AudioPlaybackState.playing){
      await _audioPlayer.stop();
    }
    await _audioPlayer.setUrl(mediaId);
    await _audioPlayer.play();
  }

  @override
  void onPlay() {
    _audioPlayer.play();
  }

  @override
  void onPause() {
    _audioPlayer.pause();
  }

  @override
  void onSeekTo(Duration position) {
    _audioPlayer.seek(position);
  }

  @override
  Future<void> onStop() async{
    await _audioPlayer.stop();
    await _audioPlayer.dispose();
    _durationSubscription.cancel();
    _eventSubscription.cancel();

    // Shut down this task
    await super.onStop();
  }

  List<MediaControl> getControls() {
    if (_audioPlayer.playbackState == AudioPlaybackState.playing) {
      return [
        skipToPreviousControl,
        pauseControl,
//        stopControl,
        skipToNextControl
      ];
    } else {
      return [
        skipToPreviousControl,
        playControl,
//        stopControl,
        skipToNextControl
      ];
    }
  }

  Future<void> _setState ({
    bool playing,
    AudioProcessingState processingState
  }) async {

    await AudioServiceBackground.setState(
      controls: getControls(),
      systemActions: [MediaAction.seekTo],
      processingState: processingState ?? AudioServiceBackground.state.processingState,
      playing: playing ?? _audioPlayer.playbackState == AudioPlaybackState.playing,
      position: _audioPlayer.playbackEvent.position,
      bufferedPosition: _audioPlayer.playbackEvent.bufferedPosition
    );
  }

  void _sendDuration(Duration value){
    AudioServiceBackground.setMediaItem(
      _mediaItem.copyWith(duration: value)
    );
  }
}

class PlayerInfoProvider extends ChangeNotifier {

  Future<String> futureVideoId;
  Future<String> futureImgUrl;
  Future<String> futureTitle;
  Future<String> futureSubtitle;

  Future<void> setValue(
      Future<String> futureVideoId,
      Future<String> futureImgUrl,
      Future<String> futureTitle,
      Future<String> futureSubtitle) async
  {
    this.futureVideoId = futureVideoId;
    this.futureImgUrl = futureImgUrl;
    this.futureTitle = futureTitle;
    this.futureSubtitle = futureSubtitle;
    notifyListeners();

    final videoId = await futureVideoId;
    final imgUrl = await futureImgUrl;
    final title = await futureTitle;
    final subtitle = await futureSubtitle;

    AudioService.updateMediaItem(
      MediaItem(
        id: videoId,
        album: subtitle,
        title: title,
        artUri: imgUrl
      )
    );
  }
}

class CustomAudioServiceWidget extends StatefulWidget{

  final Widget child;

  CustomAudioServiceWidget({@required this.child});

  @override
  _CustomAudioServiceWidgetState createState() => _CustomAudioServiceWidgetState();
}

class _CustomAudioServiceWidgetState extends State<CustomAudioServiceWidget> {

  @override
  void initState() {
    super.initState();
    AudioService.connect();
  }

  @override
  void dispose() {
    AudioService.disconnect();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

const queryParaBase = {
  'alt': 'json',
  'key': 'AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30'
};


const bodyClientMap = {
  'clientName': 'WEB_REMIX',
  'clientVersion': '0.1',
  'hl': 'en',
  'gl': 'US',
  'experimentIds': [],
  'experimentsToken': '',
//      'utcOffsetMinutes': 480,
  'locationInfo': {
    'locationPermissionAuthorizationStatus': 'LOCATION_PERMISSION_AUTHORIZATION_STATUS_UNSUPPORTED'
  },
  'musicAppInfo': {
    'musicActivityMasterSwitch': 'MUSIC_ACTIVITY_MASTER_SWITCH_INDETERMINATE',
    'musicLocationMasterSwitch': 'MUSIC_LOCATION_MASTER_SWITCH_INDETERMINATE',
    'pwaInstallabilityStatus': 'PWA_INSTALLABILITY_STATUS_CAN_BE_INSTALLED'
  }
};


const bodyMap = {
  'context': {
    'client': bodyClientMap,
    'capabilities': {},
    'request': {
      'internalExperimentFlags': [
        {
          'key': 'force_music_enable_outertube_tastebuilder_browse',
          'value': 'true'
        },
        {
          'key': 'force_music_enable_outertube_playlist_detail_browse',
          'value': 'true'
        },
        {
          'key': 'force_music_enable_outertube_search_suggestions',
          'value': 'true'
        }
      ],
      'sessionIndex': 0
    },
    'activePlayers': {},
    'user': {
      'enableSafetyMode': false
    }
  }
};

const headerMapBase = <String, String>{
  'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36',
  'Content-Type': 'application/json',
  'Accept': '*/*',
  'Referer': 'music.youtube.com',
};

const getHeaderMap = <String, String>{
  'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36',
};


const firstBodyMap = <String, dynamic>{
  'context': {
    'client': bodyClientMap,
    'capabilities': {},
    'request': {
      'internalExperimentFlags': [
        {
          'key': 'force_music_enable_outertube_tastebuilder_browse',
          'value': 'true'
        },
        {
          'key': 'force_music_enable_outertube_playlist_detail_browse',
          'value': 'true'
        },
        {
          'key': 'force_music_enable_outertube_search_suggestions',
          'value': 'true'
        }
      ],
      'sessionIndex': 0
    },
    'clickTracking': {
      'clickTrackingParams': 'IhMI2KSO4YWc6QIV0ojECh14-g9tMghleHRlcm5hbA=='
    },
    'activePlayers': {},
    'user': {
      'enableSafetyMode': false
    }
  },
  'browseId': 'FEmusic_home'
};

const watchEndpointBody = {
  "enablePersistentPlaylistPanel": true,
  "tunerSettingValue": "AUTOMIX_SETTING_NORMAL",
  "videoId": "vaknSDdG6xs",
  "playlistId": "RDAMVMvaknSDdG6xs",
  "params": "wAEB",
  "isAudioOnly": true
};

const watchEndpointBody2 = {
  "enablePersistentPlaylistPanel": true,
  "tunerSettingValue": "AUTOMIX_SETTING_NORMAL",
  "playlistId": "RDMM",
  "params": "wAEB",
  "isAudioOnly": true
};

const watchEndpointBody20 = {
  "enablePersistentPlaylistPanel": true,
  "tunerSettingValue": "AUTOMIX_SETTING_NORMAL",
  'videoId': "AoAm4om0wTs",
  'playlistId': "PLp12xt0S4J0VNJC-eGFd77RLRuQawkaZn",
  "params": "wAEB",
  "isAudioOnly": true
};
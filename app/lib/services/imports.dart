export 'package:flutter/material.dart';
export 'package:flutter/gestures.dart';
export 'package:app/main.dart';
export 'package:app/const.dart';

/// #DART# ///
export 'dart:io';
export 'dart:math';
export 'dart:async';
export 'dart:convert';
export 'dart:typed_data';
export 'package:flutter/foundation.dart';
export 'package:flutter/services.dart';

/// #PACKAGES# ///
/// Database Service
export 'firebase_options.dart';
export 'package:firebase_core/firebase_core.dart';
export 'package:firebase_auth/firebase_auth.dart';
export 'package:cloud_firestore/cloud_firestore.dart';
export 'package:cloud_functions/cloud_functions.dart';
export 'package:firebase_app_check/firebase_app_check.dart';
//export 'package:firebase_messaging/firebase_messaging.dart';
//export 'package:firebase_storage/firebase_storage.dart';
export 'package:firebase_crashlytics/firebase_crashlytics.dart';

///Basic
export 'package:provider/provider.dart';
export 'package:path_provider/path_provider.dart';
export 'package:uuid/uuid.dart';
export 'package:syncfusion_flutter_maps/maps.dart';
export 'package:file_picker/file_picker.dart';
export 'package:http/http.dart';
export 'package:libserialport/libserialport.dart'
    if (dart.library.html) 'package:app/services/web_serialport.dart'
    if (dart.library.io) 'package:libserialport/libserialport.dart';
export 'package:geolocator/geolocator.dart';
export 'package:battery_plus/battery_plus.dart';
export 'package:flutter_blue_plus/flutter_blue_plus.dart';
export 'package:sensors_plus/sensors_plus.dart';
export 'package:multiple_stream_builder/multiple_stream_builder.dart';
export 'package:shared_preferences/shared_preferences.dart';

///Design
export 'package:font_awesome_flutter/font_awesome_flutter.dart';
export 'package:battery_indicator/battery_indicator.dart';
export 'package:flutter_easyloading/flutter_easyloading.dart';
export 'package:graphic/graphic.dart';
export 'package:badges/badges.dart';
export 'package:cupertino_onboarding/cupertino_onboarding.dart';

///INTERFACE
///##Pages
export 'package:app/interfaces/pages/sessions.dart';
export 'package:app/interfaces/pages/devices.dart';
export 'package:app/interfaces/pages/track.dart';

///##Screens
export 'package:app/interfaces/screens/session_map.dart';
export 'package:app/interfaces/screens/ble_find_device.dart';
export 'package:app/interfaces/screens/ble_device_screen.dart';

///##Widgets
export 'package:app/interfaces/widgets/add_edit_session.dart';
export 'package:app/interfaces/widgets/card_info.dart';
export 'package:app/interfaces/widgets/card_session.dart';
export 'package:app/interfaces/widgets/profile.dart';
export 'package:app/interfaces/widgets/list_logs.dart';
export 'package:app/interfaces/widgets/card_log.dart';
export 'package:app/interfaces/widgets/card_device.dart';
export 'package:app/interfaces/widgets/add_edit_device.dart';
export 'package:app/interfaces/widgets/data_visualization.dart';
export 'package:app/interfaces/widgets/track_map.dart';
export 'package:app/interfaces/widgets/position_device_configurator.dart';
export 'package:app/interfaces/widgets/track_telemetries.dart';
export 'package:app/interfaces/widgets/upload_session_dialog.dart';

///MODELS
export 'package:app/models/device.dart';
export 'package:app/models/session.dart';
export 'package:app/models/user.dart';
export 'package:app/models/telemetry_analytics.dart';
export 'package:app/models/ble_characteristic.dart';
export 'package:app/models/ble_service.dart';
export 'package:app/models/mpu.dart';
export 'package:app/models/gps.dart';
export 'package:app/models/system.dart';
export 'package:app/models/telemetry_analytics.dart';

///SERVICES
export 'package:app/services/database_session.dart';
export '../../services/session/database_gps.dart';
export 'package:app/services/session/database_mpu.dart';
export 'package:app/services/session/database_system.dart';
export 'package:app/services/database_user.dart';
export 'package:app/services/database_device.dart';
export 'package:app/services/auth.dart';
export 'package:app/services/calculation.dart';
export 'package:app/services/style.dart';
export 'package:app/services/map.dart';
export 'package:app/services/bluetooth_helper.dart';
export 'package:app/services/units.dart';

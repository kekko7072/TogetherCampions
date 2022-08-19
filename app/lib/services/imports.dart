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
export 'package:firebase_messaging/firebase_messaging.dart';
export 'package:firebase_storage/firebase_storage.dart';
export 'package:firebase_crashlytics/firebase_crashlytics.dart';

///Basic
export 'package:provider/provider.dart';
export 'package:uuid/uuid.dart';
export 'package:google_maps_flutter/google_maps_flutter.dart';

///Design
export 'package:flutter_svg/flutter_svg.dart';
export 'package:battery_indicator/battery_indicator.dart';
export 'package:flutter_easyloading/flutter_easyloading.dart';
export 'package:graphic/graphic.dart';

///INTERFACE
///##Pages
export 'package:app/interfaces/pages/sessions.dart';
export 'package:app/interfaces/pages/devices.dart';
export 'package:app/interfaces/pages/live.dart';

///##Screens
export 'package:app/interfaces/screens/session_map.dart';

///##Widgets
export 'package:app/interfaces/widgets/card_telemetry.dart';
export 'package:app/interfaces/widgets/add_edit_session.dart';
export 'package:app/interfaces/widgets/card_info.dart';
export 'package:app/interfaces/widgets/card_session.dart';
export 'package:app/interfaces/widgets/add_edit_profile.dart';
export 'package:app/interfaces/widgets/list_logs.dart';
export 'package:app/interfaces/widgets/card_log.dart';
export 'package:app/interfaces/widgets/card_device.dart';
export 'package:app/interfaces/widgets/add_edit_device.dart';

///MODELS
export 'package:app/models/device.dart';
export 'package:app/models/log.dart';
export 'package:app/models/user.dart';
export 'package:app/models/telemetry.dart';

///SERVICES
export 'package:app/services/database_log.dart';
export 'package:app/services/database_user.dart';
export 'package:app/services/database_device.dart';
export 'package:app/services/auth.dart';
export 'package:app/services/calculation.dart';
export 'package:app/services/style.dart';

import 'imports.dart';

class DatabaseSession {
  DatabaseSession({required this.deviceID});
  final String deviceID;

  ///COLLECTIONS & DOCS
  late CollectionReference<Map<String, dynamic>> sessionCollection =
      FirebaseFirestore.instance
          .collection('devices')
          .doc(deviceID)
          .collection('sessions');

  ///CRUD
  Future add({required Session session}) async {
    return await sessionCollection.doc(session.id).set({
      'info': {
        'name': session.info.name,
        'start': session.info.start,
        'end': session.info.end,
      },
      'devicePosition': {
        'x': session.devicePosition.x,
        'y': session.devicePosition.y,
        'z': session.devicePosition.z,
      }
    });
  }

  Future edit({required Session session}) async {
    return await sessionCollection.doc(session.id).update({
      'info': {
        'name': session.info.name,
        'start': session.info.start,
        'end': session.info.end,
      },
      'devicePosition': {
        'x': session.devicePosition.x,
        'y': session.devicePosition.y,
        'z': session.devicePosition.z,
      }
    });
  }

  Future delete({required String id}) async {
    final islandRef =
        FirebaseStorage.instance.ref().child("devices/$deviceID/$id.json");

    await islandRef.delete();

    return await sessionCollection.doc(id).delete();
  }

  Future<String> downloadFile({required String sessionID}) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file =
        File('${directory.path}/devices/$deviceID/$sessionID.json');
    if (await file.exists()) {
      return await file.readAsString();
    } else {
      final islandRef = FirebaseStorage.instance
          .ref()
          .child("devices/$deviceID/$sessionID.json");

      final downloadTask = islandRef.writeToFile(file);

      downloadTask.snapshotEvents.listen((taskSnapshot) {
        print(taskSnapshot);
        switch (taskSnapshot.state) {
          case TaskState.running:
            // TODO: Handle this case.
            break;
          case TaskState.paused:
            // TODO: Handle this case.
            break;
          case TaskState.success:
            break;
          case TaskState.canceled:
            // TODO: Handle this case.
            break;
          case TaskState.error:
            // TODO: Handle this case.
            break;
        }
      });
      return await file.readAsString();
    }
  }

  /*Future<bool> uploadFile({required SessionFile sessionFile}) async {
    ///1. Create Session
    await DatabaseSession(deviceID: deviceID).add(
        session: Session(
            id: sessionFile.sessionId,
            info: sessionFile.info,
            devicePosition: sessionFile.devicePosition));

    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/${sessionFile.sessionId}.json');
    //TODO FIX
    // await file.writeAsString(jsonEncode(sessionFile.toJson()));

    final islandRef = FirebaseStorage.instance
        .ref()
        .child("devices/$deviceID/${sessionFile.sessionId}.json");

    try {
      final metadata = SettableMetadata(
        contentType: 'data/json',
        //customMetadata: {'picked-file-path': file.path},
      );

      if (kIsWeb) {
        await islandRef.putData(await file.readAsBytes(), metadata);
      } else {
        await islandRef.putFile(file, metadata);
      }

      return true;
    } on FirebaseException catch (e) {
      debugPrint("ERROR: $e");
      return false;
    }
  }
*/
  ///SERIALIZATION
  static Session sessionFromSnapshot(
      DocumentSnapshot<Map<String, dynamic>?> snapshot) {
    return Session(
      id: snapshot.id,
      info: SessionInfo(
        name: snapshot.data()?['info']['name'],
        start: snapshot.data()?['info']['start'].toDate(),
        end: snapshot.data()?['info']['end'].toDate(),
      ),
      devicePosition: DevicePosition(
        x: snapshot.data()?['devicePosition']?['x']?.toInt(),
        y: snapshot.data()?['devicePosition']?['y']?.toInt(),
        z: snapshot.data()?['devicePosition']?['z']?.toInt(),
      ),
    );
  }

  static List<Session> sessionsListFromSnapshot(
          QuerySnapshot<Map<String, dynamic>> snapshot) =>
      snapshot.docs.map((snapshot) => sessionFromSnapshot(snapshot)).toList();

  ///STREAMS
  Stream<Session> stream({required String id}) =>
      sessionCollection.doc(id).snapshots().map(sessionFromSnapshot);

  Stream<List<Session>> get streamList => sessionCollection
      .orderBy('info.start', descending: true)
      .snapshots()
      .map(sessionsListFromSnapshot);

  ///FUTURES
  Future<List<SessionFile>> get futureList async {
    List<SessionFile> output = [];

    //Load files url form app directory
    final Directory directory = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> values = directory.listSync();

    //Remove links of file not in the correct format
    values.removeWhere((element) => !element.path.contains(".json"));

    //Parse files
    for (var element in values) {
      try {
        String val = await File.fromUri(element.uri).readAsString();
        output.add(SessionFile.fromJson(element.uri.path, jsonDecode(val)));
      } catch (e) {
        debugPrint("ERROR PARSING FILE: $e");
      }
    }

    //Order SessionFile by date
    output.sort((a, b) {
      DateTime startA = a.info?.start ?? DateTime.now();
      DateTime startB =
          b.info?.start ?? DateTime.now().add(const Duration(days: 1));

      return startB.compareTo(startA);
    });

    return output;
  }
}

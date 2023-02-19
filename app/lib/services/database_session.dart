import 'imports.dart';

class DatabaseSession {
  DatabaseSession({required this.deviceID});
  final String deviceID;

  ///CRUD
  Future add({required Session session}) async {
    /*return await sessionCollection.doc(session.id).set({
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
    });*/
  }

  Future edit({required Session session}) async {
    /* return await sessionCollection.doc(session.id).update({
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
    });*/
  }

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

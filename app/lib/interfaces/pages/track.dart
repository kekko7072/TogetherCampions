import 'package:app/services/imports.dart';

class Track extends StatefulWidget {
  const Track({Key? key}) : super(key: key);

  @override
  State<Track> createState() => _TrackState();
}

class _TrackState extends State<Track> {
  int time = 10;
  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);

    return userData != null
        ? Scaffold(
            body: StreamBuilder<List<Log>>(
                stream: DatabaseLog(id: userData.devices.first)
                    .liveLog(addTime: time),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Text('Caricamento: ${snapshot.error}');
                  }

                  List<Log> data = snapshot.data!;

                  return Stack(
                    children: [
                      TrackMap(
                        id: userData.devices.first,
                        logs: data,
                      ),
                    ],
                  );
                }),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}

import 'package:app/services/imports.dart';
import 'package:flutter/cupertino.dart';

import '../screens/live_map.dart';

class Live extends StatefulWidget {
  const Live({Key? key}) : super(key: key);

  @override
  State<Live> createState() => _LiveState();
}

class _LiveState extends State<Live> {
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
                      LiveMap(
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

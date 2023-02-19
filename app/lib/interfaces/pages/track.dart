import 'package:app/services/imports.dart';
import 'package:flutter/cupertino.dart';

class Track extends StatefulWidget {
  const Track({Key? key}) : super(key: key);

  @override
  State<Track> createState() => _TrackState();
}

class _TrackState extends State<Track> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: /*userData.devices.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Icon(
                    CupertinoIcons.exclamationmark_triangle,
                    size: 200,
                  ),
                  Text(
                    'Registra un dispositivo prima di iniziare a tracciarlo',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  CupertinoButton.filled(
                      child: const Text('REGISTRA DISPOSITIVO'),
                      onPressed: () => showModalBottomSheet(
                            context: context,
                            shape: AppStyle.kModalBottomStyle,
                            isScrollControlled: true,
                            isDismissible: true,
                            builder: (context) =>
                                const AddEditDevice(isEdit: false),
                          )),
                ],
              ),
            )
          :*/
          Center(child: TrackScreen()),
      /*StreamBuilder<List<Log>>(
                    stream: DatabaseLog(id: userData.devices.first)
                        .liveLog(addTime: time),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Text('Caricamento: ${snapshot.error}');
                      }

                      List<Log> data = snapshot.data!;
                      if (data.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Icon(
                                CupertinoIcons.loop,
                                size: 200,
                              ),
                              Text(
                                'Dispositivo non connesso.',
                                style: Theme.of(context).textTheme.titleLarge,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Stack(
                          children: [
                            TrackMap(
                              id: userData.devices.first,
                              logs: data,
                            ),
                          ],
                        );
                      }
                    }),*/
    );
  }
}

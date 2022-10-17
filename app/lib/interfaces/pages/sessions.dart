import 'package:app/services/imports.dart';
import 'package:flutter/cupertino.dart';

class Sessions extends StatefulWidget {
  const Sessions({Key? key, required this.userData}) : super(key: key);
  final UserData userData;

  @override
  State<Sessions> createState() => _SessionsState();
}

class _SessionsState extends State<Sessions> {
  late String deviceID;
  List<Session> sessions = [];

  @override
  void initState() {
    super.initState();
    deviceID = widget.userData.devices.first;
    sessions = widget.userData.sessions.where((element) => deviceID == element.deviceID).toList();
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);

    return userData != null
        ? Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.start,
                        direction: Axis.horizontal,
                        spacing: 5,
                        runSpacing: 5,
                        children: [
                          for (String id in userData.devices) ...[
                            FilterChip(
                                backgroundColor: deviceID == id ? AppStyle.primaryColor : Colors.black12,
                                label: StreamBuilder<Device>(
                                    stream: DatabaseDevice().device(id: id),
                                    builder: (context, snapshot) {
                                      return Text(
                                        snapshot.data?.name ?? id,
                                        style: TextStyle(fontWeight: deviceID == id ? FontWeight.bold : FontWeight.normal, color: Colors.white),
                                      );
                                    }),
                                onSelected: (value) => setState(() {
                                      deviceID = id;
                                      sessions = userData.sessions.where((element) => deviceID == element.deviceID).toList();
                                    })),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Wrap(
                          direction: Axis.horizontal,
                          spacing: 5,
                          runSpacing: 5,
                          children: [
                            for (Session session in sessions) ...[
                              StreamBuilder<List<Log>>(
                                  stream: DatabaseLog(id: deviceID).sessionLogs(session: session),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Center(
                                          child: Padding(
                                        padding: EdgeInsets.all(20.0),
                                        child: CircularProgressIndicator(),
                                      ));
                                    } else if (snapshot.data!.isEmpty) {
                                      return const Center(child: Text('No data available'));
                                    }

                                    return CardSession(
                                      userData: userData,
                                      id: deviceID,
                                      session: session,
                                      logs: snapshot.data!,
                                    );
                                  }),
                            ]
                          ],
                        ),
                      ),
                      CupertinoButton(
                        child: const Text(
                          'Load more',
                        ),
                        onPressed: () => setState(() => sessions.addAll(userData.sessions.sublist(
                              widget.userData.sessions.length - sessions.length > 5 ? widget.userData.sessions.length - sessions.length - 5 : widget.userData.sessions.length - sessions.length,
                              widget.userData.sessions.length - sessions.length,
                            ))),
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButton: TextButton(
              onPressed: () async => showModalBottomSheet(
                context: context,
                shape: AppStyle.kModalBottomStyle,
                isScrollControlled: true,
                isDismissible: true,
                builder: (context) => AddEditSession(
                  userData: userData,
                  isEdit: false,
                ),
              ),
              child: Card(
                  color: Theme.of(context).primaryColor,
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 30,
                    ),
                  )),
            ),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}

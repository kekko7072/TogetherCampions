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
    sessions = widget.userData.sessions
        .where((element) => deviceID == element.deviceID)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);

    return userData != null
        ? Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (String id in userData.devices) ...[
                      Wrap(
                        alignment: WrapAlignment.start,
                        direction: Axis.horizontal,
                        children: [
                          FilterChip(
                              backgroundColor: deviceID == id
                                  ? AppStyle.primaryColor
                                  : Colors.black12,
                              label: Text(
                                id,
                                style: TextStyle(
                                    fontWeight: deviceID == id
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: Colors.white),
                              ),
                              onSelected: (value) =>
                                  setState(() => deviceID = id)),
                        ],
                      ),
                    ],
                    ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sessions.length,
                        reverse: true,
                        itemBuilder: (context, index) =>
                            StreamBuilder<List<Log>>(
                                stream: DatabaseLog(id: deviceID)
                                    .sessionLogs(session: sessions[index]),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                        child: Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: CircularProgressIndicator(),
                                    ));
                                  }

                                  return CardSession(
                                    userData: userData,
                                    id: deviceID,
                                    session: userData.sessions[index],
                                    logs: snapshot.data!,
                                  );
                                })),
                    CupertinoButton(
                      child: const Text(
                        'Load more',
                      ),
                      onPressed: () => setState(() =>
                          sessions.addAll(userData.sessions.sublist(
                            widget.userData.sessions.length - sessions.length >
                                    5
                                ? widget.userData.sessions.length -
                                    sessions.length -
                                    5
                                : widget.userData.sessions.length -
                                    sessions.length,
                            widget.userData.sessions.length - sessions.length,
                          ))),
                    ),
                    const SizedBox(height: 60),
                  ],
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

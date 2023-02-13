import 'package:app/services/imports.dart';

import '../widgets/edit_session.dart';

class Sessions extends StatefulWidget {
  const Sessions({Key? key, required this.userData}) : super(key: key);
  final UserData userData;

  @override
  State<Sessions> createState() => _SessionsState();
}

class _SessionsState extends State<Sessions> {
  late String deviceID;

  @override
  void initState() {
    super.initState();
    deviceID = widget.userData.devices.first;
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
                child: RefreshIndicator(
                  onRefresh: () async {},
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
                                  backgroundColor: deviceID == id
                                      ? AppStyle.primaryColor
                                      : Colors.black12,
                                  label: StreamBuilder<Device>(
                                      stream: DatabaseDevice().device(id: id),
                                      builder: (context, snapshot) {
                                        return Text(
                                          snapshot.data?.name ?? '',
                                          style: TextStyle(
                                              fontWeight: deviceID == id
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: Colors.white),
                                        );
                                      }),
                                  onSelected: (value) => setState(() {
                                        deviceID = id;
                                      })),
                            ],
                          ],
                        ),
                        const SizedBox(height: 10),
                        FutureBuilder<List<SessionFile>>(
                            future:
                                DatabaseSession(deviceID: deviceID).futureList,
                            builder: (context, snapshot) {
                              final List<SessionFile> sessions =
                                  snapshot.data ?? [];

                              return Center(
                                child: Wrap(
                                  direction: Axis.horizontal,
                                  spacing: 5,
                                  runSpacing: 5,
                                  children: [
                                    for (SessionFile session in sessions) ...[
                                      CardSession(
                                        userData: userData,
                                        session: session,
                                        onDelete: () async {
                                          EasyLoading.show();
                                          try {
                                            await File(session.path).delete();
                                            EasyLoading.dismiss();
                                            setState(
                                                () => sessions.remove(session));
                                          } catch (e) {
                                            EasyLoading.showError(e.toString());
                                          }
                                        },
                                        onEdit: () => showModalBottomSheet(
                                          context: context,
                                          shape: AppStyle.kModalBottomStyle,
                                          isScrollControlled: true,
                                          isDismissible: true,
                                          builder: (context) => EditSession(
                                            deviceID: deviceID,
                                            session: session.info!,
                                          ),
                                        ),
                                      )
                                    ]
                                  ],
                                ),
                              );
                            }),
                      ],
                    ),
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
                builder: (context) => AddSession(userData: userData),
              ),
              child: Card(
                  color: Theme.of(context).primaryColor,
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.add,
                      size: 30,
                      color: Colors.white,
                    ),
                  )),
            ),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}

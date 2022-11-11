import 'package:app/services/imports.dart';

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
                      StreamBuilder<List<Session>>(
                          stream:
                              DatabaseSession(deviceID: deviceID).streamList,
                          builder: (context, snapshot) {
                            final List<Session> sessions =
                                snapshot.hasData ? snapshot.data! : [];

                            return Center(
                              child: Wrap(
                                direction: Axis.horizontal,
                                spacing: 5,
                                runSpacing: 5,
                                children: [
                                  for (Session session in sessions) ...[
                                    CardSession(
                                      userData: userData,
                                      deviceID: deviceID,
                                      session: session,
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

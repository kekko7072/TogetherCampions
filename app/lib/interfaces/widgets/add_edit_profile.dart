import 'package:app/services/imports.dart';

class AddEditProfile extends StatelessWidget {
  const AddEditProfile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Profilo',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      'UID: $kDefaultUid',
                    ),
                    StreamBuilder<List<Log>>(
                        stream: DatabaseLog(uid: kDefaultUid).allLogs,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Text('No data');
                          }
                          List<Log> logs = snapshot.data!;
                          return ListView.builder(
                              shrinkWrap: true,
                              reverse: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: logs.length,
                              itemBuilder: (context, index) =>
                                  CardLog(log: logs[index]));
                        })
                  ],
                ),
              ),
            ),
          );
        });
  }
}

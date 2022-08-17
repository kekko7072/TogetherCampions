import 'package:app/services/imports.dart';

class ListLogs extends StatelessWidget {
  const ListLogs(
      {Key? key, required this.id, required this.isSession, this.session})
      : super(key: key);
  final String id;
  final bool isSession;
  final Session? session;

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
                      'Telemetria completa',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    StreamBuilder<List<Log>>(
                        stream: isSession
                            ? DatabaseLog(id: id).sessionLogs(session: session!)
                            : DatabaseLog(id: id).allLogs,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('No logs: ${snapshot.error}'),
                            );
                          } else if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          List<Log> logs = snapshot.data ?? [];

                          return ListView.builder(
                              shrinkWrap: true,
                              reverse: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data!.length,
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

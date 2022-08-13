import 'package:app/services/imports.dart';

class ListLogsSession extends StatelessWidget {
  const ListLogsSession({Key? key, required this.logs}) : super(key: key);
  final List<Log> logs;

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
                    ListView.builder(
                        shrinkWrap: true,
                        reverse: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: logs.length,
                        itemBuilder: (context, index) =>
                            CardLog(log: logs[index]))
                  ],
                ),
              ),
            ),
          );
        });
  }
}

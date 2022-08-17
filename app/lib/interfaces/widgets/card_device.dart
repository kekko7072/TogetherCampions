import 'package:app/services/imports.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'add_edit_device.dart';

class CardDevice extends StatelessWidget {
  const CardDevice({Key? key, required this.device, required this.uid})
      : super(key: key);
  final Device device;
  final String uid;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Slidable(
        key: const ValueKey(0),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (con) async => await DatabaseDevice()
                  .delete(id: device.serialNumber, uid: uid),
              backgroundColor: const Color(0xFFFE4A49),
              foregroundColor: Colors.black,
              icon: Icons.delete,
              label: 'Delete',
            ),
            SlidableAction(
              onPressed: (cons) async => showModalBottomSheet(
                context: context,
                shape: AppStyle.kModalBottomStyle,
                isScrollControlled: true,
                isDismissible: true,
                builder: (context) => AddEditDevice(
                  isEdit: true,
                  uid: uid,
                  device: device,
                ),
              ),
              backgroundColor: AppStyle.primaryColor,
              foregroundColor: Colors.black,
              icon: Icons.edit,
              label: 'Edit',
            ),
          ],
        ),
        child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                        child: Image(
                      image: AssetImage('assets/tracker_image.png'),
                      height: 150,
                    )),
                    Center(
                      child: Text(
                        device.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ID',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(device.serialNumber),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CLOCK',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          '${device.clock}',
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'FREQUENZA',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text('${device.frequency} s'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'SINCRONIZZAZIONE DATI',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                            '${CalculationService.formatTime(seconds: device.clock * device.frequency)}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ULTIMA CONNESSIONE',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        StreamBuilder<List<Log>>(
                            stream:
                                DatabaseLog(id: device.serialNumber).lastLog,
                            builder: (context, snapshot) {
                              return Text(snapshot.hasData
                                  ? CalculationService.formatDate(
                                      date: snapshot.data!.first.timestamp,
                                      seconds: true)
                                  : '....');
                            }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            onTap: () => showModalBottomSheet(
                  context: context,
                  shape: AppStyle.kModalBottomStyle,
                  isScrollControlled: true,
                  isDismissible: true,
                  builder: (context) => Dismissible(
                      key: UniqueKey(),
                      child:
                          ListLogs(id: device.serialNumber, isSession: false)),
                )),
      ),
    );
  }
}

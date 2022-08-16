import 'package:app/services/imports.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'add_edit_device.dart';

class CardDevice extends StatefulWidget {
  const CardDevice({Key? key, required this.device, required this.uid})
      : super(key: key);
  final Device device;
  final String uid;

  @override
  State<CardDevice> createState() => _CardDeviceState();
}

class _CardDeviceState extends State<CardDevice> {
  DateTime timestamp = DateTime.now();
  @override
  void initState() {
    super.initState();
    loadTimestampLastLog();
  }

  void loadTimestampLastLog() async {
    DateTime value = await DatabaseLog(id: widget.device.id).lastLogTimestamp();
    setState(() => timestamp = value);
  }

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
                  .delete(id: widget.device.id, uid: widget.uid),
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
                  uid: widget.uid,
                  device: widget.device,
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
                        widget.device.name,
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
                        Text(widget.device.id),
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
                          '${widget.device.clock}',
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
                        Text('${widget.device.frequency} s'),
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
                            '${CalculationService.formatTime(seconds: widget.device.clock * widget.device.frequency)}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ULTIMA CONNESSIONE',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(CalculationService.formatDate(
                            date: timestamp, seconds: true)),
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
                      child: ListLogs(id: widget.device.id, isSession: false)),
                )),
      ),
    );
  }
}

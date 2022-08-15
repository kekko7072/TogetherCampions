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
              onPressed: (con) async =>
                  await DatabaseDevice().delete(id: device.id, uid: uid),
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
              padding: const EdgeInsets.all(10.0),
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
                  Text('Id: ${device.id}'),
                  Text(
                      'Ciclo di sincornizzazione: ${device.clock * device.frequency} s'),
                  Text('Clock: ${device.clock}'),
                  Text('Frequency: ${device.frequency}'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

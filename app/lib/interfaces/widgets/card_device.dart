import 'package:app/interfaces/widgets/serial_monitor.dart';
import 'package:app/services/imports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CardDevice extends StatefulWidget {
  const CardDevice(
      {Key? key,
      required this.device,
      required this.serialConnected,
      this.serialPort})
      : super(key: key);
  final Device device;
  final bool serialConnected;
  final SerialPort? serialPort;

  @override
  State<CardDevice> createState() => _CardDeviceState();
}

class _CardDeviceState extends State<CardDevice> {
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
                  {} /*await DatabaseDevice()
                  .delete(id: widget.device.serialNumber, uid: widget.uid)*/
              ,
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
        child: Container(
          margin: EdgeInsets.zero,
          width: AppStyle.resizeAutomaticallyWidth(context),
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: AppStyle.primaryColor),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                width: AppStyle.resizeAutomaticallyWidth(context),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.device.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                        ),
                        if (widget.serialConnected &&
                            widget.serialPort != null) ...[
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () => showModalBottomSheet(
                              context: context,
                              shape: AppStyle.kModalBottomStyle,
                              isScrollControlled: true,
                              isDismissible: true,
                              builder: (context) => Dismissible(
                                  key: UniqueKey(),
                                  child: SerialMonitor(
                                    device: widget.device,
                                  )),
                            ),
                            child: Card(
                              margin: EdgeInsets.zero,
                              color: CupertinoColors.activeGreen,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'CONNECTED',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                ),
                              ),
                            ),
                          )
                        ] else ...[
                          GestureDetector(
                            onTap: () => showModalBottomSheet(
                              context: context,
                              shape: AppStyle.kModalBottomStyle,
                              isScrollControlled: true,
                              isDismissible: true,
                              builder: (context) => Dismissible(
                                  key: UniqueKey(),
                                  child: DraggableScrollableSheet(
                                      expand: false,
                                      builder: (BuildContext context,
                                          ScrollController scrollController) {
                                        return SafeArea(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 15.0, horizontal: 20),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Informazioni',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleLarge!
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 5),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          'Numero modello:',
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .titleMedium!
                                                              .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                        ),
                                                        Text(
                                                          widget.device
                                                              .modelNumber,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .titleMedium,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 5),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 5),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          'Numero di serie:',
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .titleMedium!
                                                              .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                        ),
                                                        Text(
                                                          widget.device
                                                              .serialNumber,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .titleMedium,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 5),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          'Software',
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .titleMedium!
                                                              .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                        ),
                                                        Text(
                                                          "${widget.device.software.version}    ${widget.device.software.name}",
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .titleMedium,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Center(
                                                    child:
                                                        CupertinoButton.filled(
                                                            child: const Text(
                                                                'Aggiorna'),
                                                            onPressed: () {}),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      })),
                            ),
                            child: Card(
                              margin: EdgeInsets.zero,
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  widget.device.modelNumber,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                ),
                              ),
                            ),
                          )
                        ]
                      ],
                    ),
                    const Center(
                        child: Image(
                      image: AssetImage(
                        'assets/TKR1A1.png',
                      ),
                      fit: BoxFit.cover,
                      height: 150,
                    )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

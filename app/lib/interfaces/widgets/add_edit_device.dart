import 'package:flutter/cupertino.dart';
import 'package:app/services/imports.dart';

class AddEditDevice extends StatefulWidget {
  const AddEditDevice({
    Key? key,
    required this.isEdit,
    this.device,
  }) : super(key: key);

  final bool isEdit;
  final Device? device;

  @override
  State<AddEditDevice> createState() => _AddEditDeviceState();
}

class _AddEditDeviceState extends State<AddEditDevice> {
  final formKey = GlobalKey<FormState>();
  bool showLoading = false;

  TextEditingController id = TextEditingController();
  TextEditingController model = TextEditingController(text: 'TKR1A1');
  TextEditingController modelName = TextEditingController(text: 'BlackStone 1');
  TextEditingController name = TextEditingController(text: 'BlackStone 1');

  List<ScanResult> devices = [];

  int x = 0;
  int y = 0;
  int z = 0;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.device != null) {
      id.text = widget.device!.serialNumber;
      name.text = widget.device!.name;
      x = widget.device!.devicePosition.x;
      y = widget.device!.devicePosition.y;
      z = widget.device!.devicePosition.z;
    } else {
      FlutterBluePlus.instance.startScan(timeout: const Duration(seconds: 4));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Text(
                widget.isEdit ? 'Modifica' : 'Aggiungi',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (!widget.isEdit) ...[
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: FilterChip(
                      backgroundColor: AppStyle.primaryColor,
                      label: const Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                      onSelected: (bool value) {
                        FlutterBluePlus.instance
                            .startScan(timeout: const Duration(seconds: 4));
                      },
                    ),
                  ),
                ),
              ]
            ],
          ),
          if (showLoading) ...[
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            )
          ] else ...[
            const SizedBox(height: 10),
            Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!widget.isEdit) ...[
                    Wrap(
                      spacing: 10,
                      children: [
                        FilterChip(
                            backgroundColor: model.text == kDeviceModelTKR1A1
                                ? AppStyle.primaryColor
                                : Colors.white,
                            label: Text(
                              kDeviceModelTKR1A1,
                              style: TextStyle(
                                  fontWeight: model.text == kDeviceModelTKR1A1
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: model.text == kDeviceModelTKR1A1
                                      ? Colors.white
                                      : AppStyle.primaryColor),
                            ),
                            onSelected: (value) => setState(
                                () => model.text = kDeviceModelTKR1A1)),
                        FilterChip(
                            backgroundColor: model.text == kDeviceModelTKR1B1
                                ? AppStyle.primaryColor
                                : Colors.white,
                            label: Text(
                              kDeviceModelTKR1B1,
                              style: TextStyle(
                                  fontWeight: model.text == kDeviceModelTKR1B1
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: model.text == kDeviceModelTKR1B1
                                      ? Colors.white
                                      : AppStyle.primaryColor),
                            ),
                            onSelected: (value) => setState(
                                () => model.text = kDeviceModelTKR1B1)),
                      ],
                    ),
                    StreamBuilder<List<ScanResult>>(
                      stream: FlutterBluePlus.instance.scanResults,
                      initialData: const [],
                      builder: (c, snapshot) {
                        devices = snapshot.hasData ? snapshot.data! : [];
                        return Column(
                          children: snapshot.data!
                              .where((element) =>
                                  element.device.name == model.text)
                              .map(
                                (r) => GestureDetector(
                                  onTap: () => setState(
                                      () => id.text = r.device.id.toString()),
                                  child: ListTile(
                                    leading: Image(
                                      image: AssetImage(
                                        'assets/${model.text}.png',
                                      ),
                                      fit: BoxFit.cover,
                                      height: 150,
                                    ),
                                    title: Text(
                                      r.device.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      r.device.id.id,
                                      overflow: TextOverflow.clip,
                                    ),
                                    trailing: TextButton(
                                      onPressed: () => setState(() =>
                                          id.text = r.device.id.toString()),
                                      child: Icon(
                                          id.text == r.device.id.toString()
                                              ? CupertinoIcons.minus_circle_fill
                                              : CupertinoIcons.add_circled),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 20),
                    child: TextFormField(
                      controller: name,
                      textAlign: TextAlign.center,
                      decoration: AppStyle().kTextFieldDecoration(
                          icon: Icons.edit, hintText: 'Enter device name'),
                    ),
                  ),
                  PositionDeviceConfigurator(
                    onChangePosition: (newX, newY, newZ) => setState(() {
                      x = newX;
                      y = newY;
                      z = newZ;
                    }),
                    initialPosition:
                        widget.isEdit ? DevicePosition(x: x, y: y, z: z) : null,
                  ),
                  const SizedBox(height: 10),
                  CupertinoButton.filled(
                    onPressed: id.text.isEmpty
                        ? null
                        : () async {
                            setState(() => showLoading = true);
                            Navigator.of(context).pop();
                            setState(() => showLoading = false);
                            /*  await DatabaseDevice()
                                .register(
                                    serialNumber: id.text,
                                    modelNumber: model.text,
                                    uid: widget.uid,
                                    name: name.text,
                                    devicePosition:
                                        DevicePosition(x: x, y: y, z: z))
                                .then((value) {


                            });*/
                          },
                    child: Text(
                      widget.isEdit ? 'Modifica' : 'Crea',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )
          ],
        ],
      ),
    );
  }
}

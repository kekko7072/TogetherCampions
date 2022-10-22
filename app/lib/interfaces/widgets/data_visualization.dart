import 'package:app/services/imports.dart';
import 'package:flutter/cupertino.dart';

import '../../services/bluetooth_helper.dart';

class DataChartVisualizationBattery extends StatefulWidget {
  const DataChartVisualizationBattery({Key? key, required this.service})
      : super(key: key);
  final BluetoothService service;

  @override
  State<DataChartVisualizationBattery> createState() =>
      _DataChartVisualizationBatteryState();
}

class _DataChartVisualizationBatteryState
    extends State<DataChartVisualizationBattery> {
  List<MonoDimensionalValueInt> batteryLevels = [];
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<int>>(
        stream: BluetoothHelper.characteristic(
                widget.service, kBLEBatteryCharacteristic)
            ?.value,
        initialData: BluetoothHelper.characteristic(
                widget.service, kBLEBatteryCharacteristic)
            ?.lastValue,
        builder: (context, snapshot) {
          final value = snapshot.data;
          if (value != null) {
            ByteBuffer buffer = Int8List.fromList(value).buffer;
            ByteData byteData = ByteData.view(buffer);
            try {
              batteryLevels.add(MonoDimensionalValueInt(
                value: byteData.getInt32(0, Endian.little),
                timestamp: byteData.getInt32(4, Endian.little),
              ));
            } catch (e) {
              debugPrint("\nERROR: $e\n");
            }
          }
          return CupertinoAlertDialog(
            title: Text(
              'Battery Level  ${batteryLevels.last.value} %',
            ),
            content: SizedBox(
              height: MediaQuery.of(context).size.height / 2,
              //https://medium.com/analytics-vidhya/the-versatility-of-the-grammar-of-graphics-d1366760424d

              child: Chart(
                data: batteryLevels,
                variables: {
                  'timestamp': Variable(
                    accessor: (MonoDimensionalValueInt log) => log.timestamp,
                    scale: LinearScale(
                        formatter: (number) =>
                            CalculationService.timestamp(number.toInt())),
                  ),
                  'battery': Variable(
                    accessor: (MonoDimensionalValueInt log) => log.value,
                    scale: LinearScale(
                        formatter: (number) => '${number.toInt()} %'),
                  ),
                },
                coord: RectCoord(),
                elements: [LineElement()],
                rebuild: true,
                axes: [
                  Defaults.horizontalAxis,
                  Defaults.verticalAxis,
                ],
              ),
            ),
            actions: [
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Chiudi'),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                //TODO create exportation of data as csv
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Esporta'),
              )
            ],
          );
        });
  }
}

class DataChartVisualizationTemperature extends StatefulWidget {
  const DataChartVisualizationTemperature({Key? key, required this.service})
      : super(key: key);
  final BluetoothService service;

  @override
  State<DataChartVisualizationTemperature> createState() =>
      _DataChartVisualizationTemperatureState();
}

class _DataChartVisualizationTemperatureState
    extends State<DataChartVisualizationTemperature> {
  List<MonoDimensionalValueDouble> temperatures = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<int>>(
        stream: BluetoothHelper.characteristic(
                widget.service, kBLETemperatureCharacteristic)
            ?.value,
        initialData: BluetoothHelper.characteristic(
                widget.service, kBLETemperatureCharacteristic)
            ?.lastValue,
        builder: (context, snapshot) {
          final value = snapshot.data;

          if (value != null) {
            ByteBuffer buffer = Int8List.fromList(value).buffer;
            ByteData byteData = ByteData.view(buffer);
            try {
              temperatures.add(MonoDimensionalValueDouble(
                value: CalculationService.temperature(
                    byteData.getInt32(0, Endian.little)),
                timestamp: byteData.getInt32(4, Endian.little),
              ));
            } catch (e) {
              debugPrint("\nERROR: $e\n");
            }
          }
          return CupertinoAlertDialog(
            title: Text(
              'Temperature ${temperatures.last.value.toStringAsFixed(2)} °',
            ),
            content: SizedBox(
              height: MediaQuery.of(context).size.height / 2,
              //https://medium.com/analytics-vidhya/the-versatility-of-the-grammar-of-graphics-d1366760424d

              child: Chart(
                data: temperatures,
                variables: {
                  'timestamp': Variable(
                    accessor: (MonoDimensionalValueDouble log) => log.timestamp,
                    scale: LinearScale(
                        formatter: (number) =>
                            CalculationService.timestamp(number.toInt())),
                  ),
                  'temperature': Variable(
                    accessor: (MonoDimensionalValueDouble log) =>
                        log.value.roundToDouble(),
                    scale: LinearScale(
                        formatter: (number) =>
                            '${number.toStringAsFixed(2)} °C'),
                  ),
                },
                coord: RectCoord(),
                elements: [LineElement()],
                rebuild: true,
                axes: [
                  Defaults.horizontalAxis,
                  Defaults.verticalAxis,
                ],
              ),
            ),
            actions: [
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Chiudi'),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                //TODO create exportation of data as csv
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Esporta'),
              )
            ],
          );
        });
  }
}

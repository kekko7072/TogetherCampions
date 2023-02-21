import 'package:app/services/imports.dart';
import 'package:flutter/cupertino.dart';

enum SystemDataVisualization { battery, temperature }

class DataChartVisualizationSystem extends StatefulWidget {
  const DataChartVisualizationSystem(
      {Key? key, required this.service, required this.systemDataVisualization})
      : super(key: key);
  final BluetoothService service;
  final SystemDataVisualization systemDataVisualization;

  @override
  State<DataChartVisualizationSystem> createState() =>
      _DataChartVisualizationSystemState();
}

class _DataChartVisualizationSystemState
    extends State<DataChartVisualizationSystem> {
  List<System> system = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<int>>(
        stream: BluetoothHelper.characteristic(
                widget.service, kBLESystemCharacteristic)
            ?.value,
        initialData: BluetoothHelper.characteristic(
                widget.service, kBLESystemCharacteristic)
            ?.lastValue,
        builder: (context, snapshot) {
          final value = snapshot.data;
          if (value != null) {
            System? sys = System.formListInt(value);

            system.add(sys);
          }
          switch (widget.systemDataVisualization) {
            case SystemDataVisualization.battery:
              return CupertinoAlertDialog(
                title: Text(
                  'Battery Level  ${system.last.battery} %',
                ),
                content: SizedBox(
                  height: MediaQuery.of(context).size.height / 2,
                  //https://medium.com/analytics-vidhya/the-versatility-of-the-grammar-of-graphics-d1366760424d

                  child: Chart(
                    data: system,
                    variables: {
                      'timestamp': Variable(
                        accessor: (System log) => log.timestamp,
                        scale: LinearScale(
                            formatter: (number) =>
                                CalculationService.timestamp(number.toInt())),
                      ),
                      'battery': Variable(
                        accessor: (System log) => log.battery,
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
            case SystemDataVisualization.temperature:
              return CupertinoAlertDialog(
                title: Text(
                  'Temperature ${system.last.temperature.toStringAsFixed(2)} °',
                ),
                content: SizedBox(
                  height: MediaQuery.of(context).size.height / 2,
                  //https://medium.com/analytics-vidhya/the-versatility-of-the-grammar-of-graphics-d1366760424d

                  child: Chart(
                    data: system,
                    variables: {
                      'timestamp': Variable(
                        accessor: (System log) => log.timestamp,
                        scale: LinearScale(
                            formatter: (number) =>
                                CalculationService.timestamp(number.toInt())),
                      ),
                      'temperature': Variable(
                        accessor: (System log) =>
                            log.temperature.roundToDouble(),
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
          }
        });
  }
}

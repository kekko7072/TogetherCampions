import 'package:app/services/imports.dart';
import 'package:flutter/cupertino.dart';

class TrackTelemetries extends StatefulWidget {
  const TrackTelemetries({Key? key, required this.gpsNavigation})
      : super(key: key);
  final List<GpsNavigation> gpsNavigation;

  @override
  State<TrackTelemetries> createState() => TrackTelemetriesState();
}

class TrackTelemetriesState extends State<TrackTelemetries> {
  TelemetryViewLive telemetryViewRange = TelemetryViewLive.altitude;
  TelemetryViewLive telemetryViewCharts = TelemetryViewLive.altitude;

  @override
  Widget build(BuildContext context) {
    TelemetryNavigation telemetry = CalculationService.telemetryNavigation(
      gpsNavigation: widget.gpsNavigation,
    );
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilterChip(
                    backgroundColor:
                        telemetryViewRange == TelemetryViewLive.altitude
                            ? AppStyle.primaryColor
                            : Colors.black12,
                    label: Text(
                      'Altitude',
                      style: TextStyle(
                          fontWeight:
                              telemetryViewRange == TelemetryViewLive.altitude
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                          color:
                              telemetryViewRange == TelemetryViewLive.altitude
                                  ? Colors.white
                                  : Colors.black),
                    ),
                    onSelected: (value) => setState(
                        () => telemetryViewRange = TelemetryViewLive.altitude)),
                FilterChip(
                    backgroundColor:
                        telemetryViewRange == TelemetryViewLive.course
                            ? AppStyle.primaryColor
                            : Colors.black12,
                    label: Text(
                      'Course',
                      style: TextStyle(
                          fontWeight:
                              telemetryViewRange == TelemetryViewLive.course
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                          color: telemetryViewRange == TelemetryViewLive.course
                              ? Colors.white
                              : Colors.black),
                    ),
                    onSelected: (value) => setState(
                        () => telemetryViewRange = TelemetryViewLive.course)),
                FilterChip(
                    backgroundColor:
                        telemetryViewRange == TelemetryViewLive.variation
                            ? AppStyle.primaryColor
                            : Colors.black12,
                    label: Text(
                      'Variation',
                      style: TextStyle(
                          fontWeight:
                              telemetryViewRange == TelemetryViewLive.variation
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                          color:
                              telemetryViewRange == TelemetryViewLive.variation
                                  ? Colors.white
                                  : Colors.black),
                    ),
                    onSelected: (value) => setState(() =>
                        telemetryViewRange = TelemetryViewLive.variation)),
              ],
            ),
            if (telemetryViewRange == TelemetryViewLive.altitude) ...[
              SizedBox(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Medium: ${telemetry.altitude.medium} m'),
                    Text('Max: ${telemetry.altitude.max} m'),
                    Text('Min: ${telemetry.altitude.min} m'),
                  ],
                ),
              ),
            ] else if (telemetryViewRange == TelemetryViewLive.course) ...[
              SizedBox(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Medium: ${telemetry.course.medium} deg'),
                    Text('Max: ${telemetry.course.max} deg'),
                    Text('Min: ${telemetry.course.min} deg'),
                  ],
                ),
              ),
            ] else if (telemetryViewRange == TelemetryViewLive.variation) ...[
              SizedBox(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Medium: ${telemetry.variation.medium} deg'),
                    Text('Max: ${telemetry.variation.max} deg'),
                    Text('Min: ${telemetry.variation.min} deg'),
                  ],
                ),
              ),
            ],
            CupertinoButton(
              child: const Icon(CupertinoIcons.chart_bar_square),
              onPressed: () => showCupertinoDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (_) => CupertinoAlertDialog(
                        content: SafeArea(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(30),
                                      topRight: Radius.circular(30))),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 5),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Wrap(
                                      spacing: 10,
                                      children: [
                                        FilterChip(
                                            backgroundColor:
                                                telemetryViewCharts ==
                                                        TelemetryViewLive
                                                            .altitude
                                                    ? AppStyle.primaryColor
                                                    : Colors.black12,
                                            label: Text(
                                              'Altitude',
                                              style: TextStyle(
                                                  fontWeight:
                                                      telemetryViewCharts ==
                                                              TelemetryViewLive
                                                                  .altitude
                                                          ? FontWeight.bold
                                                          : FontWeight.normal),
                                            ),
                                            onSelected: (value) => setState(
                                                () => telemetryViewCharts =
                                                    TelemetryViewLive
                                                        .altitude)),
                                        FilterChip(
                                            backgroundColor:
                                                telemetryViewCharts ==
                                                        TelemetryViewLive.course
                                                    ? AppStyle.primaryColor
                                                    : Colors.black12,
                                            label: Text(
                                              'Course',
                                              style: TextStyle(
                                                  fontWeight:
                                                      telemetryViewCharts ==
                                                              TelemetryViewLive
                                                                  .course
                                                          ? FontWeight.bold
                                                          : FontWeight.normal),
                                            ),
                                            onSelected: (value) => setState(
                                                () => telemetryViewCharts =
                                                    TelemetryViewLive.course)),
                                        FilterChip(
                                            backgroundColor:
                                                telemetryViewCharts ==
                                                        TelemetryViewLive
                                                            .variation
                                                    ? AppStyle.primaryColor
                                                    : Colors.black12,
                                            label: Text(
                                              'Variation',
                                              style: TextStyle(
                                                  fontWeight:
                                                      telemetryViewCharts ==
                                                              TelemetryViewLive
                                                                  .variation
                                                          ? FontWeight.bold
                                                          : FontWeight.normal),
                                            ),
                                            onSelected: (value) => setState(
                                                () => telemetryViewCharts =
                                                    TelemetryViewLive
                                                        .variation)),
                                      ],
                                    ),
                                    if (telemetryViewCharts ==
                                        TelemetryViewLive.altitude) ...[
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                4,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        //https://medium.com/analytics-vidhya/the-versatility-of-the-grammar-of-graphics-d1366760424d

                                        child: Chart(
                                          data: widget.gpsNavigation,
                                          variables: {
                                            'timestamp': Variable(
                                              accessor: (GpsNavigation log) =>
                                                  log.timestamp,
                                              scale: LinearScale(
                                                  formatter: (number) =>
                                                      CalculationService
                                                          .timestamp(
                                                              number.toInt())),
                                            ),
                                            'altitude': Variable(
                                                accessor: (GpsNavigation gps) =>
                                                    gps.altitude,
                                                scale: LinearScale(
                                                    title: 'Altitude',
                                                    formatter: (number) =>
                                                        '$number m')),
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
                                    ] else if (telemetryViewCharts ==
                                        TelemetryViewLive.course) ...[
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                4,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        //https://medium.com/analytics-vidhya/the-versatility-of-the-grammar-of-graphics-d1366760424d

                                        child: Chart(
                                          data: widget.gpsNavigation,
                                          variables: {
                                            'timestamp': Variable(
                                              accessor: (GpsNavigation log) =>
                                                  log.timestamp,
                                              scale: LinearScale(
                                                  formatter: (number) =>
                                                      CalculationService
                                                          .timestamp(
                                                              number.toInt())),
                                            ),
                                            'course': Variable(
                                                accessor: (GpsNavigation gps) =>
                                                    gps.course,
                                                scale: LinearScale(
                                                    title: 'Course',
                                                    formatter: (number) =>
                                                        '$number °')),
                                          },
                                          coord: PolarCoord(),
                                          elements: [LineElement()],
                                          rebuild: true,
                                          axes: [
                                            Defaults.horizontalAxis,
                                            Defaults.verticalAxis,
                                          ],
                                        ),
                                      ),
                                    ] else if (telemetryViewCharts ==
                                        TelemetryViewLive.variation) ...[
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                4,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        //https://medium.com/analytics-vidhya/the-versatility-of-the-grammar-of-graphics-d1366760424d

                                        child: Chart(
                                          data: widget.gpsNavigation,
                                          variables: {
                                            'timestamp': Variable(
                                              accessor: (GpsNavigation log) =>
                                                  log.timestamp,
                                              scale: LinearScale(
                                                  formatter: (number) =>
                                                      CalculationService
                                                          .timestamp(
                                                              number.toInt())),
                                            ),
                                            'speed': Variable(
                                                accessor: (GpsNavigation gps) =>
                                                    gps.variation,
                                                scale: LinearScale(
                                                    title: 'Variation',
                                                    formatter: (number) =>
                                                        '$number °')),
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
                                    ]
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )),
            )
          ],
        ),
      ],
    );
  }
}

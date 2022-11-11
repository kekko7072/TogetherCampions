import 'package:app/services/imports.dart';

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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                    Text(
                        'Now: ${widget.gpsNavigation.last.altitude.toStringAsFixed(2)} m'),
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
                    Text(
                        'Now: ${widget.gpsNavigation.last.course.toStringAsFixed(0)} deg'),
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
                    Text(
                        'Now: ${widget.gpsNavigation.last.variation.toStringAsFixed(0)} deg'),
                    Text('Medium: ${telemetry.variation.medium} deg'),
                    Text('Max: ${telemetry.variation.max} deg'),
                    Text('Min: ${telemetry.variation.min} deg'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

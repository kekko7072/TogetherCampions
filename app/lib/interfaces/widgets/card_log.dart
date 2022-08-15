import 'package:app/services/imports.dart';

class CardLog extends StatelessWidget {
  const CardLog({Key? key, required this.log}) : super(key: key);
  final Log log;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Lat: ${log.gps.latLng.latitude}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Text(
            'Lng: ${log.gps.latLng.longitude}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
      title: Text(
          CalculationService.formatDate(date: log.timestamp, seconds: true)),
      subtitle: Wrap(
        spacing: 10,
        children: [
          Text('Speed: ${log.gps.speed} km/h'),
          Text('Course: ${log.gps.course} deg'),
          Text('Altitude: ${log.gps.altitude} m'),
          Text('Satellites: ${log.gps.satellites}'),
          Text('Battery: ${log.battery} V'),
        ],
      ),
    );
  }
}

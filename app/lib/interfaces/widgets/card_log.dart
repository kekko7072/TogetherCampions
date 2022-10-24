import 'package:app/services/imports.dart';

class CardLog extends StatelessWidget {
  const CardLog({Key? key, required this.gps}) : super(key: key);
  final GpsPosition gps;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Lat: ${gps.latLng.latitude}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Text(
            'Lng: ${gps.latLng.longitude}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
      title: Text('${gps.timestamp}'),
      subtitle: Wrap(
        spacing: 10,
        children: [
          //Text('Speed: ${gps.speed} km/h'),
          //Text('Course: ${gps.course} deg'),
          //Text('Altitude: ${gps.altitude} m'),
          //Text('Satellites: ${gps.variation}'),
          //Text('Battery: ${gps.battery} V'),
        ],
      ),
    );
  }
}

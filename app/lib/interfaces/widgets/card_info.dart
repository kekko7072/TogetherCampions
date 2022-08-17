import 'package:app/services/imports.dart';

class CardInfo extends StatelessWidget {
  const CardInfo({
    Key? key,
    required this.session,
    required this.battery,
  }) : super(key: key);

  final Session session;
  final double battery;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Card(
          child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              session.name,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Inizio:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Fine:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Consumo:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(width: 25),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(CalculationService.formatDate(
                        date: session.start, year: true, seconds: true)),
                    Text(CalculationService.formatDate(
                        date: session.end, year: true, seconds: true)),
                    Text('$battery Volts'),
                  ],
                ),
              ],
            ),
          ],
        ),
      )),
    );
  }
}

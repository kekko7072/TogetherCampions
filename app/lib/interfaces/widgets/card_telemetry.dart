import 'package:app/services/imports.dart';
import 'package:flutter/cupertino.dart';

class CardTelemetry extends StatelessWidget {
  const CardTelemetry({
    Key? key,
    required this.telemetry,
    required this.id,
    required this.session,
  }) : super(key: key);

  final Telemetry telemetry;
  final String id;
  final Session session;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 1.75,
        child: Card(
            child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Velocità',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Media:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Max:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Min:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(width: 25),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${telemetry.speed.medium}   km/h',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${telemetry.speed.max}   km/h',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${telemetry.speed.min}   km/h',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Altitudine',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Media:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Max:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Min:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(width: 25),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${telemetry.altitude.medium}   m',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${telemetry.altitude.max}   m',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${telemetry.altitude.min}   m',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Distanza: ',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${telemetry.distance} km',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Text(
                    'Telemetria completa',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: AppStyle.primaryColor,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline),
                  ),
                  onPressed: () => showModalBottomSheet(
                        context: context,
                        shape: AppStyle.kModalBottomStyle,
                        isScrollControlled: true,
                        isDismissible: true,
                        builder: (context) => Dismissible(
                            key: UniqueKey(),
                            child: ListLogs(
                                id: id, isSession: true, session: session)),
                      ))
            ],
          ),
        )),
      ),
    );
  }
}

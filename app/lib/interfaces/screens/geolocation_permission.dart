import 'package:app/services/imports.dart';
import 'package:flutter/cupertino.dart';

class GeolocationPermission extends StatefulWidget {
  const GeolocationPermission({Key? key, required this.onChange})
      : super(key: key);
  final Function(LocationPermission locationPermission) onChange;

  @override
  State<GeolocationPermission> createState() => _GeolocationPermissionState();
}

class _GeolocationPermissionState extends State<GeolocationPermission> {
  bool openedSettings = false;
  void check() async {
    if (openedSettings) {
      LocationPermission permission = await Geolocator.checkPermission();
      widget.onChange(permission);
    }
  }

  @override
  Widget build(BuildContext context) {
    check();
    return Scaffold(
        body: Center(
            child: openedSettings
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.location,
                        size: 100,
                        color: AppStyle.primaryColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 40.0, horizontal: 15),
                        child: Text(
                          'Abilita la localizzazione è necessaria per far funzionare l\'applicazione.',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      CupertinoButton.filled(
                          child: const Text('Abilita'),
                          onPressed: () async {
                            try {
                              LocationPermission permission =
                                  await Geolocator.requestPermission();
                              if (permission == LocationPermission.denied ||
                                  permission ==
                                      LocationPermission.deniedForever ||
                                  permission ==
                                      LocationPermission.unableToDetermine) {
                                openedSettings =
                                    await Geolocator.openLocationSettings();
                              }

                              widget.onChange(permission);
                            } catch (e) {
                              debugPrint('$e');
                            }
                          })
                    ],
                  )));
  }
}

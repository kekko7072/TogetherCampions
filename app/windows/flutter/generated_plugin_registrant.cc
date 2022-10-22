//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <battery_plus/battery_plus_windows_plugin.h>
#include <flutter_libserialport/flutter_libserialport_plugin.h>
#include <geolocator_windows/geolocator_windows.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  BatteryPlusWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("BatteryPlusWindowsPlugin"));
  FlutterLibserialportPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterLibserialportPlugin"));
  GeolocatorWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("GeolocatorWindows"));
}

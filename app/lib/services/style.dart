import 'imports.dart';

class AppStyle {
  static int primaryColorValue = 0xFF003F7C;

  static Color primaryColor = Color(primaryColorValue);

  static MaterialColor primaryMaterialColor = MaterialColor(
    primaryColorValue,
    <int, Color>{
      50: primaryColor,
      100: primaryColor,
      200: primaryColor,
      300: primaryColor,
      400: primaryColor,
      500: primaryColor,
      600: primaryColor,
      700: primaryColor,
      800: primaryColor,
      900: primaryColor,
    },
  );

  static int backgroundColorValue = 0xFFC40001;

  static Color backgroundColor = Color(backgroundColorValue);

  ///TextStyle
  static TextStyle kHomeTitle =
      const TextStyle(fontWeight: FontWeight.bold, fontSize: 50);
  static TextStyle kSentence = const TextStyle(
      fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black);

  ///InputDecoration
  InputDecoration kTextFieldDecoration(
          {required IconData icon, required String hintText}) =>
      InputDecoration(
        prefixIcon: Icon(
          icon,
          color: AppStyle.primaryColor,
        ),
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.white60,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppStyle.primaryColor, width: 2.0),
          borderRadius: const BorderRadius.all(Radius.circular(32.0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppStyle.primaryColor, width: 2.0),
          borderRadius: const BorderRadius.all(Radius.circular(32.0)),
        ),
      );

  ///ModalBottom
  static RoundedRectangleBorder kModalBottomStyle =
      const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)));

  ///APP BAR

  ///MENU
}

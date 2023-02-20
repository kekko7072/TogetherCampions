import 'imports.dart';

class AppStyle {
  static const int primaryColorValue = 0xFF003F7C;

  static const Color primaryColor = Color(primaryColorValue);

  static MaterialColor primaryMaterialColor = const MaterialColor(
    primaryColorValue,
    <int, Color>{
      50: Color(0xFFffffff),
      100: Color(0xFFe6ecf2),
      200: Color(0xFFccd9e5),
      300: Color(0xFFb3c5d8),
      400: Color(0xFF99b2cb),
      500: Color(0xFF809fbe),
      600: Color(0xFF668cb0),
      700: Color(0xFF4d79a3),
      800: Color(0xFF336596),
      900: Color(0xFF1a5289),
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
          color: AppStyle.backgroundColor,
        ),
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.grey,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppStyle.backgroundColor, width: 2.0),
          borderRadius: const BorderRadius.all(Radius.circular(32.0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppStyle.backgroundColor, width: 2.0),
          borderRadius: const BorderRadius.all(Radius.circular(32.0)),
        ),
      );

  ///ModalBottom
  static RoundedRectangleBorder kModalBottomStyle =
      const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)));

  ///WIDTH
  static double resizeAutomaticallyWidth(BuildContext context) =>
      MediaQuery.of(context).size.width >= 400
          ? 400
          : MediaQuery.of(context).size.width;

  ///MENU
}

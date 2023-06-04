import '../../services/imports.dart';

class CardDataNavigation extends StatelessWidget {
  final String value;
  const CardDataNavigation({Key? key, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(value, style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}

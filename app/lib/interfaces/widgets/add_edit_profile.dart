import 'package:app/services/imports.dart';

class AddEditProfile extends StatelessWidget {
  const AddEditProfile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Profilo',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      'UID: ',
                    ),

                  ],
                ),
              ),
            ),
          );
        });
  }
}

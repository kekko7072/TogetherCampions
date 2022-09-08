import 'package:app/services/imports.dart';

class Devices extends StatelessWidget {
  const Devices({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);

    return userData != null
        ? Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      StreamBuilder<List<Device>>(
                          stream:
                              DatabaseDevice().allDevices(uid: userData.uid),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Text('No data');
                            }
                            List<Device> devices = snapshot.data!;
                            return ListView.builder(
                                shrinkWrap: true,
                                reverse: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: devices.length,
                                itemBuilder: (context, index) => CardDevice(
                                      device: devices[index],
                                      uid: userData.uid,
                                    ));
                          })
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButton: TextButton(
              onPressed: () async => showModalBottomSheet(
                context: context,
                shape: AppStyle.kModalBottomStyle,
                isScrollControlled: true,
                isDismissible: true,
                builder: (context) => AddEditDevice(
                  uid: userData.uid,
                  isEdit: false,
                ),
              ),
              child: Card(
                  margin: EdgeInsets.zero,
                  color: Theme.of(context).primaryColor,
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 30,
                    ),
                  )),
            ),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}

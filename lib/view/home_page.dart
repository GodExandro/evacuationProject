import 'package:evacuation_project/get_it/get_it.dart';
import 'package:evacuation_project/services/firebase_service.dart';
import 'package:evacuation_project/view/qr_view.dart';
import 'package:flutter/material.dart';

import '../domain/model/division.dart';
import '../domain/model/user.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? currentUser;
  List<Division> divisionsList = [];

  @override
  void initState() {
    super.initState();

    _getFirebaseData();
  }

  Future<void> _getFirebaseData() async {
    final newDivisionList =
        await getIt.get<FirebaseService>().getDivisionsList();

    setState(() {
      currentUser = getIt.get<FirebaseService>().currentUser;
      divisionsList = newDivisionList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(currentUser?.userName ?? ''), actions: [
          IconButton(
            color: Colors.red,
            icon: const Icon(Icons.qr_code_2),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                builder: (context) => const QRViewExample(),
              ))
                  .then((value) async {
                await getIt.get<FirebaseService>().getDivisionsList();
                setState(() {
                  divisionsList = getIt.get<FirebaseService>().divisionsList;
                });
              });
            },
          ),
        ]),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    onPressed: () async {
                      await getIt.get<FirebaseService>().getDivisionsList();
                      setState(() {
                        divisionsList =
                            getIt.get<FirebaseService>().divisionsList;
                      });
                    },
                    child: const Text(
                      'Refresh List',
                      style: TextStyle(color: Colors.red),
                    )),
                if (currentUser?.userPermission == 'admin')
                  TextButton(
                      onPressed: () async {
                        await getIt
                            .get<FirebaseService>()
                            .resetEvacuationList();
                        setState(() {
                          divisionsList =
                              getIt.get<FirebaseService>().divisionsList;
                        });
                      },
                      child: const Text(
                        'Reset List',
                        style: TextStyle(color: Colors.red),
                      ))
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: divisionsList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return DivisionTile(division: divisionsList[index]);
                  },
                ),
              ),
            ),
          ],
        ));
  }
}

class DivisionTile extends StatefulWidget {
  final Division division;

  const DivisionTile({Key? key, required this.division}) : super(key: key);

  @override
  _DivisionTileState createState() => _DivisionTileState();
}

class _DivisionTileState extends State<DivisionTile> {
  bool _isExpanded = false;

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  Widget _buildSubdivisionsList(List<Division> subdivisions) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: subdivisions
            .map((subdivision) => DivisionTile(division: subdivision))
            .toList(),
      ),
    );
  }

  Widget _buildUsersList(List<User> users) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: users
            .map((user) => Text(
                  user.userName,
                  style: TextStyle(
                      color: user.userStatus == 'evacuated'
                          ? Colors.green
                          : Colors.red),
                ))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _toggleExpansion,
          child: Row(
            children: [
              Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
              ),
              Text(widget.division.divisionName),
            ],
          ),
        ),
        if (_isExpanded) ...[
          _buildSubdivisionsList(widget.division.subDivision),
          _buildUsersList(widget.division.workers),
        ],
      ],
    );
  }
}

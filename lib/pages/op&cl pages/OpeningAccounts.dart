import 'package:cheers_flutter/design/design.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OpeningAccounts extends StatefulWidget {
  const OpeningAccounts({super.key});

  @override
  State<OpeningAccounts> createState() => _OpeningAccountsState();
}

class _OpeningAccountsState extends State<OpeningAccounts> {
  final Map<String, TextEditingController> LCountController = {};
  final Map<String, TextEditingController> LPoundsController = {};
  final Map<String, TextEditingController> LOzController = {};

  final Map<String, TextEditingController> WCountController = {};
  final Map<String, TextEditingController> WPoundsController = {};
  final Map<String, TextEditingController> WOzController = {};

  final Map<String, TextEditingController> countController = {};

  final Map<String, TextEditingController> BcountController = {};

  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> liquorList = [];
  List<Map<String, dynamic>> wineList = [];
  List<Map<String, dynamic>> beverageList = [];

  final user = FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  bool _isExpanded = false;
  @override
  void initState() {
    super.initState();
    _fetchItems();
    _fetchLiquor();
    _fetchWines();
    _fetchBeverages();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchBeverages() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('Inventory')
          .where('category', isEqualTo: 'N/A Beverages')
          .get();

      final items = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final id = doc.id;

        BcountController[id] =
            TextEditingController(text: data['open_count']?.toString() ?? '0');

        return {
          'id': id,
          'name': data['name'] ?? 'Unnamed Item',
          'category': data['category'],
          ...data,
        };
      }).toList();

      setState(() {
        beverageList = items;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching items: $e')),
      );
    }
  }

  Future<void> _fetchLiquor() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('Inventory')
          .where('category', isEqualTo: 'Liquor')
          .get();

      final items = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final id = doc.id;

        LCountController[id] =
            TextEditingController(text: data['open_count']?.toString() ?? '0');
        LOzController[id] =
            TextEditingController(text: data['open_count']?.toString() ?? '0');
        LPoundsController[id] =
            TextEditingController(text: data['open_count']?.toString() ?? '0');

        return {
          'id': id,
          'name': data['name'] ?? 'Unnamed Item',
          'category': data['category'],
          ...data,
        };
      }).toList();

      setState(() {
        liquorList = items;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching items: $e')),
      );
    }
  }

  Future<void> _fetchWines() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('Inventory')
          .where('category', isEqualTo: 'Wine')
          .get();

      final items = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final id = doc.id;

        WCountController[id] =
            TextEditingController(text: data['open_count']?.toString() ?? '0');
        WOzController[id] =
            TextEditingController(text: data['open_count']?.toString() ?? '0');
        WPoundsController[id] =
            TextEditingController(text: data['open_count']?.toString() ?? '0');

        return {
          'id': id,
          'name': data['name'] ?? 'Unnamed Item',
          'category': data['category'],
          ...data,
        };
      }).toList();

      setState(() {
        wineList = items;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching items: $e')),
      );
    }
  }

  Future<void> _fetchItems() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('Inventory')
          .where('category', isEqualTo: 'RTDs')
          .get();

      final items = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final id = doc.id;

        countController[id] =
            TextEditingController(text: data['open_count']?.toString() ?? '0');

        return {
          'id': id,
          'name': data['name'] ?? 'Unnamed Item',
          'category': data['category'],
          ...data,
        };
      }).toList();

      setState(() {
        _items = items;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching items: $e')),
      );
    }
  }

  Future<void> _setOpeningAccounts() async {
    try {
      for (var wineItems in wineList) {
        final id = wineItems['id'];
        final name = wineItems['name'];
        final ouncesPerBottle = wineItems['ouncesPerBottle'];
        await _firestore
            .collection('Cashout')
            .doc(user.email)
            .collection("Date")
            .doc(formattedDate)
            .collection("Stock")
            .doc(id)
            .set({
          'itemID': id,
          'name': name,
          'open_count': int.tryParse(WCountController[id]!.text) ?? 0,
          'open_lbs': double.tryParse(WPoundsController[id]!.text) ?? 0.0,
          'open_oz': double.tryParse(WOzController[id]!.text) ?? 0.0,
          'updatedBy': user.email,
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        await _firestore
            .collection("Accounts")
            .doc(user.email)
            .collection("stock")
            .doc(id)
            .set({
          'id': id,
          'isLiquor': true,
          'name': name,
          'ouncesPerBottle': ouncesPerBottle,
          'runningCount': int.tryParse(WCountController[id]!.text) ?? 0,
        });
      }

      for (var liquorItems in liquorList) {
        final id = liquorItems['id'];
        final name = liquorItems['name'];
        final ouncesPerBottle = liquorItems['ouncesPerBottle'];
        await _firestore
            .collection('Cashout')
            .doc(user.email)
            .collection("Date")
            .doc(formattedDate)
            .collection("Stock")
            .doc(id)
            .set({
          'itemID': id,
          'name': name,
          'open_count': int.tryParse(LCountController[id]!.text) ?? 0,
          'open_lbs': double.tryParse(LPoundsController[id]!.text) ?? 0.0,
          'open_oz': double.tryParse(LOzController[id]!.text) ?? 0.0,
          'updatedBy': user.email,
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        await _firestore
            .collection("Accounts")
            .doc(user.email)
            .collection("stock")
            .doc(id)
            .set({
          'id': id,
          'isLiquor': true,
          'name': name,
          'ouncesPerBottle': ouncesPerBottle,
          'runningCount': int.tryParse(LCountController[id]!.text) ?? 0,
        });
      }

      for (var RTDItems in _items) {
        final id = RTDItems['id'];
        final name = RTDItems['name'];
        await _firestore
            .collection('Cashout')
            .doc(user.email)
            .collection("Date")
            .doc(formattedDate)
            .collection("Stock")
            .doc(id)
            .set({
          'itemID': id,
          'name': name,
          'open_count': int.tryParse(countController[id]!.text) ?? 0,
          'updatedBy': user.email,
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        await _firestore
            .collection("Accounts")
            .doc(user.email)
            .collection("stock")
            .doc(id)
            .set({
          'id': id,
          'isLiquor': false,
          'ouncesPerBottle': 1,
          'name': name,
          'runningCount': int.tryParse(countController[id]!.text) ?? 0,
        });
      }

      for (var beverageItems in beverageList) {
        final id = beverageItems['id'];
        final name = beverageItems['name'];
        await _firestore
            .collection('Cashout')
            .doc(user.email)
            .collection("Date")
            .doc(formattedDate)
            .collection("Stock")
            .doc(id)
            .set({
          'itemID': id,
          'name': name,
          'open_count': int.tryParse(BcountController[id]!.text) ?? 0,
          'updatedBy': user.email,
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        await _firestore
            .collection("Accounts")
            .doc(user.email)
            .collection("stock")
            .doc(id)
            .set({
          'id': id,
          'isLiquor': false,
          'ouncesPerBottle': 1,
          'name': name,
          'runningCount': int.tryParse(BcountController[id]!.text) ?? 0,
        });
      }

      LCountController.forEach((key, controller) => controller.clear());
      LPoundsController.forEach((key, controller) => controller.clear());
      LOzController.forEach((key, controller) => controller.clear());

      WCountController.forEach((key, controller) => controller.clear());
      WPoundsController.forEach((key, controller) => controller.clear());
      WOzController.forEach((key, controller) => controller.clear());

      countController.forEach((key, controller) => controller.clear());
      BcountController.forEach((key, controller) => controller.clear());

      Navigator.of(context).pop();

      AlertDialog(
        title: const Text('Opening Accounts Set'),
        content:
            const Text('Opening accounts have been set for the selected date'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"))
        ],
      );
      // Close only the dialog
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        title: const Text(
          "Opening Accounts",
          style: CheersStyles.posTitleStyle,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Set the opening accounts amounts'),
              const SizedBox(height: 10),
              const SizedBox(height: 10),

              //Wine show
              ExpansionTile(
                title: const Text('Wines'),
                initiallyExpanded: _isExpanded,
                onExpansionChanged: (expanded) {
                  setState(() => _isExpanded = expanded);
                },
                children: [
                  // Only display the title once when the ExpansionTile is opened
                  const SizedBox(
                    width: 800,
                    child: Row(
                      children: [
                        Text("Name"),
                        SizedBox(
                          width: 180,
                        ),
                        Text("Full"),
                        SizedBox(
                          width: 80,
                        ),
                        Text("Pounds"),
                        SizedBox(
                          width: 60,
                        ),
                        Text("OZ")
                      ],
                    ),
                  ),

                  // Now map over your items
                  ...wineList.map((item) {
                    final id = item['id'];
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: SizedBox(
                        width: 800,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: Text(
                                    item['name'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 100,
                                  child: TextField(
                                    controller: WCountController[id],
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder()),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: TextField(
                                    controller: WPoundsController[id],
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder()),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: TextField(
                                    controller: WOzController[id],
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder()),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
              ExpansionTile(
                title: const Text('Liquor'),
                initiallyExpanded: _isExpanded,
                onExpansionChanged: (expanded) {
                  setState(() => _isExpanded = expanded);
                },
                children: [
                  // Only display the title once when the ExpansionTile is opened
                  const SizedBox(
                    width: 800,
                    child: Row(
                      children: [
                        Text("Name"),
                        SizedBox(
                          width: 180,
                        ),
                        Text("Full"),
                        SizedBox(
                          width: 80,
                        ),
                        Text("Pounds"),
                        SizedBox(
                          width: 60,
                        ),
                        Text("OZ")
                      ],
                    ),
                  ),

                  // Now map over your items
                  ...liquorList.map((item) {
                    final id = item['id'];
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: SizedBox(
                        width: 800,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: Text(
                                    item['name'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 100,
                                  child: TextField(
                                    controller: LCountController[id],
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder()),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: TextField(
                                    controller: LPoundsController[id],
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder()),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: TextField(
                                    controller: LOzController[id],
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder()),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
              ExpansionTile(
                title: const Text('RTDs'),
                initiallyExpanded: _isExpanded,
                onExpansionChanged: (expanded) {
                  setState(() => _isExpanded = expanded);
                },
                children: [
                  // Only display the title once when the ExpansionTile is opened
                  const SizedBox(
                    width: 800,
                    child: Row(
                      children: [
                        Text("Name"),
                        SizedBox(
                          width: 180,
                        ),
                        Text("Count"),
                      ],
                    ),
                  ),

                  // Now map over your items
                  ..._items.map((item) {
                    final id = item['id'];
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: SizedBox(
                        width: 800,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: Text(
                                    item['name'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 100,
                                  child: TextField(
                                    controller: countController[id],
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder()),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
              ExpansionTile(
                title: const Text('N/A Beverages'),
                initiallyExpanded: _isExpanded,
                onExpansionChanged: (expanded) {
                  setState(() => _isExpanded = expanded);
                },
                children: [
                  // Only display the title once when the ExpansionTile is opened
                  const SizedBox(
                    width: 800,
                    child: Row(
                      children: [
                        Text("Name"),
                        SizedBox(
                          width: 180,
                        ),
                        Text("Count"),
                      ],
                    ),
                  ),

                  // Now map over your items
                  ...beverageList.map((item) {
                    final id = item['id'];
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: SizedBox(
                        width: 800,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: Text(
                                    item['name'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 100,
                                  child: TextField(
                                    controller: BcountController[id],
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder()),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: CheersStyles.buttonMain,
                    onPressed: () {
                      _setOpeningAccounts();
                    },
                    child: const Text(
                      "Set",
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: CheersStyles.buttonMain,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "Close",
                      style: TextStyle(fontSize: 17),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

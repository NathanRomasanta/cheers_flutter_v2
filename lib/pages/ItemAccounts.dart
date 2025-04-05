import 'package:cheers_flutter/design/design.dart';
import 'package:cheers_flutter/pages/op&cl%20pages/OpeningAccounts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//TODO: Update stock from bartista when opening
class ItemAccounts extends StatefulWidget {
  const ItemAccounts({super.key});

  @override
  State<ItemAccounts> createState() => _ItemAccountsState();
}

class _ItemAccountsState extends State<ItemAccounts> {
  final user = FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  bool _isLoading = true;
  List<Map<String, dynamic>> _items = [];
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, TextEditingController> _controllers2 = {};
  final Map<String, TextEditingController> _controllers3 = {};
  final Map<String, TextEditingController> _controllers4 = {};
  final Map<String, TextEditingController> _controllers5 = {};
  final Map<String, TextEditingController> _controllers6 = {};

  final Map<String, TextEditingController> LCountController = {};
  final Map<String, TextEditingController> LPoundsController = {};
  final Map<String, TextEditingController> LOzController = {};

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  @override
  void dispose() {
    for (var controller in [
      ..._controllers.values,
      ..._controllers2.values,
      ..._controllers3.values
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchItems() async {
    setState(() => _isLoading = true);

    try {
      QuerySnapshot snapshot = await _firestore.collection('Items').get();

      final items = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final id = doc.id;

        _controllers[id] =
            TextEditingController(text: data['open_count']?.toString() ?? '0');
        _controllers2[id] =
            TextEditingController(text: data['open_lbs']?.toString() ?? '0');
        _controllers3[id] =
            TextEditingController(text: data['open_oz']?.toString() ?? '0');

        _controllers4[id] =
            TextEditingController(text: data['close_count']?.toString() ?? '0');
        _controllers5[id] =
            TextEditingController(text: data['close_lbs']?.toString() ?? '0');
        _controllers6[id] =
            TextEditingController(text: data['close_oz']?.toString() ?? '0');

        return {
          'id': id,
          'name': data['name'] ?? 'Unnamed Item',
          ...data,
        };
      }).toList();

      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching items: $e')),
      );
    }
  }

  Future<void> _setOpeningAccounts() async {
    try {
      for (var item in _items) {
        final id = item['id'];
        final name = item['name'];
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
          'open_count': int.tryParse(_controllers[id]!.text) ?? 0,
          'open_lbs': double.tryParse(_controllers2[id]!.text) ?? 0.0,
          'open_oz': double.tryParse(_controllers3[id]!.text) ?? 0.0,
          'updatedBy': user.email,
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      _controllers.forEach((key, controller) => controller.clear());
      _controllers2.forEach((key, controller) => controller.clear());
      _controllers3.forEach((key, controller) => controller.clear());
      _controllers4.forEach((key, controller) => controller.clear());
      _controllers5.forEach((key, controller) => controller.clear());
      _controllers6.forEach((key, controller) => controller.clear());
      // ignore: use_build_context_synchronously
      Navigator.of(context, rootNavigator: true).pop(); // Close only the dialog
    } catch (e) {}
  }

  Future<void> _setClosingAccounts() async {
    try {
      for (var item in _items) {
        final id = item['id'];
        final name = item['name'];
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
          'close_count': int.tryParse(_controllers4[id]!.text) ?? 0,
          'close_lbs': double.tryParse(_controllers5[id]!.text) ?? 0.0,
          'close_oz': double.tryParse(_controllers6[id]!.text) ?? 0.0,
          'updatedBy': user.email,
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      _controllers.forEach((key, controller) => controller.clear());
      _controllers2.forEach((key, controller) => controller.clear());
      _controllers3.forEach((key, controller) => controller.clear());
      _controllers4.forEach((key, controller) => controller.clear());
      _controllers5.forEach((key, controller) => controller.clear());
      _controllers6.forEach((key, controller) => controller.clear());
      // ignore: use_build_context_synchronously
      Navigator.of(context, rootNavigator: true).pop(); // Close only the dialog
    } catch (e) {
      print(e);
    }
  }

  Future<void> _showOpeningAccountsDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Transaction Details',
              style: CheersStyles.alertDialogHeader),
          content: SizedBox(
            height: 400,
            width: 700,
            child: Column(
              children: [
                const Text('Select the opening accounts'),
                SizedBox(
                  height: 300,
                  width: 500,
                  child: ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      final id = item['id'];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 3,
                                child: Text(item['name'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold))),
                            const SizedBox(width: 8),
                            Expanded(
                                flex: 2,
                                child: TextField(
                                    controller: _controllers[id],
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder()),
                                    keyboardType: TextInputType.number)),
                            const SizedBox(width: 8),
                            Expanded(
                                flex: 2,
                                child: TextField(
                                    controller: _controllers2[id],
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder()),
                                    keyboardType: TextInputType.number)),
                            const SizedBox(width: 8),
                            Expanded(
                                flex: 2,
                                child: TextField(
                                    controller: _controllers3[id],
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder()),
                                    keyboardType: TextInputType.number)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                    onPressed: _setOpeningAccounts, child: const Text("Set"))
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showClosingAccountsDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Closing Accounts',
              style: CheersStyles.alertDialogHeader),
          content: SizedBox(
            height: 400,
            width: 700,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Set the closing accounts amounts'),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Text(
                      "Item Name",
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(width: 130),
                    Text(
                      "Closing count",
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(width: 25),
                    Text(
                      "Closing lbs",
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(width: 30),
                    Text(
                      "Closing oz",
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 300,
                  width: 500,
                  child: ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      final id = item['id'];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 2,
                                child: Text(item['name'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold))),
                            const SizedBox(width: 8),
                            Expanded(
                                flex: 1,
                                child: TextField(
                                    controller: _controllers4[id],
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder()),
                                    keyboardType: TextInputType.number)),
                            const SizedBox(width: 8),
                            Expanded(
                                flex: 1,
                                child: TextField(
                                    controller: _controllers5[id],
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder()),
                                    keyboardType: TextInputType.number)),
                            const SizedBox(width: 8),
                            Expanded(
                                flex: 1,
                                child: TextField(
                                    controller: _controllers6[id],
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder()),
                                    keyboardType: TextInputType.number)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 300,
                    ),
                    ElevatedButton(
                        style: CheersStyles.buttonMain,
                        onPressed: _setClosingAccounts,
                        child: const Text("Set")),
                    const SizedBox(width: 10),
                    ElevatedButton(
                        style: CheersStyles.buttonMain,
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                        child: const Text("Close"))
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding:
            const EdgeInsets.only(bottom: 30.0, right: 30, left: 30, top: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Opening & Closing Accounts",
                style: CheersStyles.pageTitle),
            const Divider(
              color: Color.fromARGB(255, 228, 228, 228),
              thickness: 1.5,
            ),
            Row(children: [
              const Text("Current Barista:", style: CheersStyles.h7s),
              const SizedBox(width: 15),
              Text(user.email.toString(), style: CheersStyles.h7s),
            ]),
            const SizedBox(height: 30),
            const Text("Opening Accounts", style: CheersStyles.h2s),
            ListTile(
              subtitle: const Text(
                "Start Your Night Right",
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              title: const Text("Set opening accounts for current Barista"),
              leading: const Icon(Icons.sunny, size: 35),
              trailing: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: Colors.white,
                            content: Container(
                                color: Colors.white,
                                height: 180,
                                width: 400,
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Please Enter your Pin",
                                          style: CheersStyles.alertDialogHeader,
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        SizedBox(
                                          width: 240,
                                          child: TextField(
                                            controller: _controller,
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.center,
                                            maxLength: 6,
                                            decoration: const InputDecoration(
                                              counterText: '',
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.orange,
                                                    width: 2),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.orange,
                                                    width: 2),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.orange,
                                                    width: 2),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        ElevatedButton(
                                          style: CheersStyles.buttonMain,
                                          onPressed: () {
                                            if (_controller.text == "112369") {
                                              Navigator.pop(context);
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  pageBuilder: (context,
                                                          animation,
                                                          secondaryAnimation) =>
                                                      const OpeningAccounts(),
                                                  transitionsBuilder: (context,
                                                      animation,
                                                      secondaryAnimation,
                                                      child) {
                                                    const begin = Offset(0.0,
                                                        1.0); // Start from bottom
                                                    const end = Offset.zero;
                                                    const curve =
                                                        Curves.fastOutSlowIn;

                                                    var tween = Tween(
                                                            begin: begin,
                                                            end: end)
                                                        .chain(CurveTween(
                                                            curve: curve));
                                                    var offsetAnimation =
                                                        animation.drive(tween);

                                                    return SlideTransition(
                                                      position: offsetAnimation,
                                                      child: child,
                                                    );
                                                  },
                                                ),
                                              );
                                            } else {
                                              Navigator.pop(context);
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  backgroundColor: Colors.white,
                                                  title: const Text(
                                                      "Incorrect PIN"),
                                                  content: const Text(
                                                      "The PIN you entered is incorrect."),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      child: const Text("OK"),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text("Submit"),
                                        ),
                                      ],
                                    )),
                                  ],
                                )),
                          );
                        });
                  }),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text("Closing Accounts", style: CheersStyles.h2s),
            ListTile(
              subtitle: const Text(
                "Wrap Up Your Night",
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              title: const Text("Set closing accounts for current Barista"),
              leading: const Icon(Icons.mode_night, size: 35),
              trailing: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                  onPressed: _showClosingAccountsDialog),
            ),
          ],
        ),
      ),
    );
  }
}

class TextFields extends StatefulWidget {
  const TextFields({super.key});

  @override
  State<TextFields> createState() => _TextFieldsState();
}

class _TextFieldsState extends State<TextFields> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, TextEditingController> _controllers2 = {};
  final Map<String, TextEditingController> _controllers3 = {};
  final Map<String, TextEditingController> _controllers4 = {};
  final Map<String, TextEditingController> _controllers5 = {};
  final Map<String, TextEditingController> _controllers6 = {};

  final Map<String, TextEditingController> LCountController = {};
  final Map<String, TextEditingController> LPoundsController = {};
  final Map<String, TextEditingController> LOzController = {};

  final Map<String, TextEditingController> countController = {};

  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> liquorList = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isExpanded = false;
  @override
  void initState() {
    super.initState();
    _fetchItems();
    _fetchLiquor();
  }

  @override
  void dispose() {
    for (var controller in [
      ..._controllers.values,
      ..._controllers2.values,
      ..._controllers3.values
    ]) {
      controller.dispose();
    }
    super.dispose();
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Set the opening accounts amounts'),
            const SizedBox(height: 10),
            const SizedBox(height: 10),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: CheersStyles.buttonMain,
                  onPressed: () {},
                  child: const Text("Set"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: CheersStyles.buttonMain,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Close"),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

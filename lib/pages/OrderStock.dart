import 'package:cheers_flutter/design/design.dart';
import 'package:cheers_flutter/pages/DualStateful.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

List<Map<String, dynamic>> selectedIngredients = [];
String name = '';
String price = '';
final GlobalKey<_LeftSideState> _checkoutKey = GlobalKey<_LeftSideState>();

late List<dynamic> liquorItems;

class OrderStock extends StatefulWidget {
  const OrderStock({super.key});

  @override
  State<OrderStock> createState() => _OrderStockState();
}

Widget _buildGridItem({
  required String title,
  required String subtitle,
  required Color color,
  IconData? icon,
  VoidCallback? onTap,
}) {
  return InkWell(
    onTap: onTap, // Clickable function
    child: Container(
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Icon(icon, size: 30, color: Colors.black54), // Show icon
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
        ],
      ),
    ),
  );
}

class _OrderStockState extends State<OrderStock> {
  Future<void> fetchLiquor() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Inventory')
        .where('category', isEqualTo: 'Liquor')
        .get();
    setState(() {
      liquorItems = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name'],
              })
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchLiquor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(children: [
        Expanded(
          flex: 2,
          child: Navigator(
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (context) => LeftSide(key: _checkoutKey),
            ),
          ),
        ),
        Container(
          height: 650,
          width: 1.5,
          color: Colors.grey.shade300,
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: Navigator(
            onGenerateRoute: (settings) =>
                MaterialPageRoute(builder: (context) => RightSide()),
          ),
        ),
      ]),
    );
  }
}

class LeftSide extends StatefulWidget {
  const LeftSide({super.key});

  @override
  State<LeftSide> createState() => _LeftSideState();
}

class _LeftSideState extends State<LeftSide> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  void rebuildCheckout() {
    setState(() {});
  }

  void _selectIngredient(Map<String, dynamic> ingredient) {
    setState(() {
      selectedIngredients.add(ingredient);
    });

    _checkoutKey.currentState?.rebuildCheckout();
  }

  void deleteItem(int index) {
    setState(() {
      selectedIngredients.removeAt(index);
    });
  }

  // Handle ounces input for liquor ingredients
  void _updateQuantity(String id, int quantity) {
    setState(() {
      selectedIngredients = selectedIngredients.map((ingredient) {
        if (ingredient['id'] == id) {
          ingredient['quantity'] = quantity;
        }
        return ingredient;
      }).toList();
    });
  }

  void _submitOrder() async {
    if (selectedIngredients.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Order is Empty'),
            content: const Text('Order cannot be empty!'),
            actions: [
              TextButton(
                onPressed: () {
                  // Close the dialog
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } else {
      try {
        await _firestore.collection('Orders').add({
          'baristaUID': user.email,
          'status': "Pending",
          'ingredients': selectedIngredients,
        });
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                'Order Submitted',
                style: CheersStyles.alertDialogHeader,
              ),
              content: const Text('Order Submitted to Admin!'),
              actions: [
                TextButton(
                  onPressed: () {
                    // Close the dialog
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Close',
                    style: CheersStyles.alertTextButton,
                  ),
                ),
              ],
            );
          },
        );

        setState(() {
          selectedIngredients.clear();
        });
      } catch (error) {
        AlertDialog(
          title: const Text('Order Error'),
          content: const Text('Order not submitted'),
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Slip',
              style: CheersStyles.menuTitle,
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                const Text(
                  "Current Barista:",
                  style: CheersStyles.h7s,
                ),
                const SizedBox(
                  width: 15,
                ),
                Text(user.email.toString(), style: CheersStyles.h7s),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: const Color(0xffF8F8F8),
              ),
              child: SizedBox(
                height: 500,
                width: 650,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 400,
                        child: ListView.builder(
                          shrinkWrap: true,
                          // Prevents nested scrolling issues
                          itemCount: selectedIngredients.length,
                          itemBuilder: (context, index) {
                            var ingredient = selectedIngredients[index];
                            return Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color.fromARGB(
                                        255, 221, 221, 221), // Underline color
                                    width: 1.0, // Underline thickness
                                  ),
                                ),
                              ),
                              child: ListTile(
                                title: Row(
                                  children: [
                                    Text(
                                      '${ingredient['name']}',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                    const SizedBox(width: 15),
                                    SizedBox(
                                        width: 100,
                                        child: TextField(
                                          decoration: const InputDecoration(
                                            labelText: 'Quantity',
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.orange,
                                                  width: 2.0),
                                            ),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.orange,
                                                  width: 1.0),
                                            ),
                                          ),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          onChanged: (value) {
                                            _updateQuantity(ingredient['id'],
                                                int.tryParse(value) ?? 0);
                                          },
                                        ))
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    deleteItem(index);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
                style: CheersStyles.buttonMain,
                onPressed: () {
                  _submitOrder();
                },
                child: const Text("Submit Order")),
          ],
        ),
      ),
    );
  }
}

class RightSide extends StatefulWidget {
  const RightSide({super.key});

  @override
  State<RightSide> createState() => _RightSideState();
}

class _RightSideState extends State<RightSide> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {
        "title": "Liquor",
        "subtitle": "Straight. Strong. Classic.",
        "color": "FFD1B3",
        "icon": Icons.local_bar,
        "onTap": () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const liquorOptions(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(0.0, 1.0); // Start from bottom
                const end = Offset.zero;
                const curve = Curves.fastOutSlowIn;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          );
        }
      },
      {
        "title": "Wines",
        "subtitle": "Sip. Swirl. Relax",
        "color": "FDCFA1",
        "icon": Icons.wine_bar,
        "onTap": () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const WineOptions(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(0.0, 1.0); // Start from bottom
                const end = Offset.zero;
                const curve = Curves.fastOutSlowIn;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          );
        },
      },
      {
        "title": "RTDs",
        "subtitle": "Crack. Sip. Chill",
        "color": "FFB997",
        "icon": Icons.emoji_food_beverage,
        "onTap": () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const RTDOptions(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(0.0, 1.0); // Start from bottom
                const end = Offset.zero;
                const curve = Curves.fastOutSlowIn;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          );
        }
      },
      {
        "title": "Beverages",
        "subtitle": "Hops & Happiness",
        "color": "FBC4AB",
        "icon": Icons.liquor,
        "onTap": () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const BeverageOptions(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(0.0, 1.0); // Start from bottom
                const end = Offset.zero;
                const curve = Curves.fastOutSlowIn;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          );
        }
      },
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            "Order Stock",
            style: CheersStyles.menuTitle,
          ),
        ), // Add a title here
        // Optional: Centers the title
        // Customize as needed
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: MasonryGridView.count(
          crossAxisCount: 2, // Two columns
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildGridItem(
              title: item["title"],
              subtitle: item["subtitle"],
              color: Color(int.parse("0xFF${item['color']}")),
              icon: item["icon"],
              onTap: item["onTap"], // Pass function
            );
          },
        ),
      ),
    );
  }
}

Widget _buildItemGrid({
  required String title,
  required Color color,
  IconData? icon,
  VoidCallback? onTap,
}) {
  return InkWell(
    onTap: onTap, // Clickable function
    child: Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Icon(icon, size: 30, color: Colors.black54), // Show icon
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}

class liquorOptions extends StatefulWidget {
  const liquorOptions({super.key});

  @override
  State<liquorOptions> createState() => _liquorOptionsState();
}

class _liquorOptionsState extends State<liquorOptions> {
  List<Map<String, dynamic>> localLiquorItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLiquor();
  }

  Future<void> fetchLiquor() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Inventory')
        .where('category', isEqualTo: 'Liquor')
        .get();

    setState(() {
      localLiquorItems = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name'],
              })
          .toList();
      isLoading = false;
    });
  }

  void _selectIngredient(Map<String, dynamic> ingredient) {
    setState(() {
      selectedIngredients.add(ingredient);
    });

    _checkoutKey.currentState?.rebuildCheckout();
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
          "Liquor Options",
          style: CheersStyles.posTitleStyle,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: MasonryGridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                itemCount: localLiquorItems.length,
                itemBuilder: (context, index) {
                  final item = localLiquorItems[index];
                  return _buildItemGrid(
                    onTap: () => _selectIngredient(item),
                    title: item["name"],
                    color: const Color(0xffF19A6F),
                  );
                },
              ),
            ),
    );
  }
}

class WineOptions extends StatefulWidget {
  const WineOptions({super.key});

  @override
  State<WineOptions> createState() => _WineOptionsState();
}

class _WineOptionsState extends State<WineOptions> {
  List<Map<String, dynamic>> localWineItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWine();
  }

  Future<void> fetchWine() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Inventory')
        .where('category', isEqualTo: 'Wine')
        .get();

    setState(() {
      localWineItems = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name'],
              })
          .toList();
      isLoading = false;
    });
  }

  void _selectIngredient(Map<String, dynamic> ingredient) {
    setState(() {
      selectedIngredients.add(ingredient);
    });

    _checkoutKey.currentState?.rebuildCheckout();
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
          "Wine Options",
          style: CheersStyles.posTitleStyle,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: MasonryGridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                itemCount: localWineItems.length,
                itemBuilder: (context, index) {
                  final item = localWineItems[index];
                  return _buildItemGrid(
                    onTap: () => _selectIngredient(item),
                    title: item["name"],
                    color: const Color(0xffF19A6F),
                  );
                },
              ),
            ),
    );
  }
}

class RTDOptions extends StatefulWidget {
  const RTDOptions({super.key});

  @override
  State<RTDOptions> createState() => _RTDOptionsState();
}

class _RTDOptionsState extends State<RTDOptions> {
  List<Map<String, dynamic>> localRTDItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRTD();
  }

  Future<void> fetchRTD() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Inventory')
        .where('category', isEqualTo: 'RTDs')
        .get();

    setState(() {
      localRTDItems = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name'],
              })
          .toList();
      isLoading = false;
    });
  }

  void _selectIngredient(Map<String, dynamic> ingredient) {
    setState(() {
      selectedIngredients.add(ingredient);
    });

    _checkoutKey.currentState?.rebuildCheckout();
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
          "RTD Options",
          style: CheersStyles.posTitleStyle,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: MasonryGridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                itemCount: localRTDItems.length,
                itemBuilder: (context, index) {
                  final item = localRTDItems[index];
                  return _buildItemGrid(
                    onTap: () => _selectIngredient(item),
                    title: item["name"],
                    color: const Color(0xffF19A6F),
                  );
                },
              ),
            ),
    );
  }
}

class BeverageOptions extends StatefulWidget {
  const BeverageOptions({super.key});

  @override
  State<BeverageOptions> createState() => _BeverageOptionsState();
}

class _BeverageOptionsState extends State<BeverageOptions> {
  List<Map<String, dynamic>> localBeverageItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBeverage();
  }

  Future<void> fetchBeverage() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Inventory')
        .where('category', isEqualTo: 'N/A Beverages')
        .get();

    setState(() {
      localBeverageItems = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name'],
              })
          .toList();
      isLoading = false;
    });
  }

  void _selectIngredient(Map<String, dynamic> ingredient) {
    setState(() {
      selectedIngredients.add(ingredient);
    });

    _checkoutKey.currentState?.rebuildCheckout();
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
          "Beverage Options",
          style: CheersStyles.posTitleStyle,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: MasonryGridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                itemCount: localBeverageItems.length,
                itemBuilder: (context, index) {
                  final item = localBeverageItems[index];
                  return _buildItemGrid(
                    onTap: () => _selectIngredient(item),
                    title: item["name"],
                    color: const Color(0xffF19A6F),
                  );
                },
              ),
            ),
    );
  }
}

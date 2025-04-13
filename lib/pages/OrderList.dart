import 'package:cheers_flutter/design/design.dart';
import 'package:cheers_flutter/services/FirestoreService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderList extends StatefulWidget {
  const OrderList({super.key});

  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  List<String> dropdownItems = ["Pending", "Rejected", "Fulfilled"];
  String? selectedValue;
  final user = FirebaseAuth.instance.currentUser!;
  List<String> collectionNames = [];
  final TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  final FirebaseService firebaseService = FirebaseService();

  List<Map<String, dynamic>> ingredients = [];
  List<Map<String, dynamic>> selectedIngredients = [];
  String name = '';
  String price = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0.0),
                color: const Color(0xffFfffff),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 30.0, right: 20, left: 20, bottom: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Recent Orders",
                          style: CheersStyles.pageTitle,
                        ),
                        const SizedBox(
                          width: 25,
                        ),
                        Container(
                          height: 30,
                          width: 200,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedValue,
                              hint: const Text('Select date'),
                              isExpanded: true,
                              items: dropdownItems.map((item) {
                                return DropdownMenuItem(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedValue = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Row(
                      children: [
                        Text(
                          "Transaction Date/Time",
                          style: CheersStyles.tableHeaders,
                        ),
                        SizedBox(width: 145),
                        Text(
                          "Transaction ID",
                          style: CheersStyles.tableHeaders,
                        ),
                        SizedBox(width: 130),
                        Text(
                          "Transaction Total",
                          style: CheersStyles.tableHeaders,
                        ),
                        SizedBox(width: 80),
                        Text(
                          "Item Count",
                          style: CheersStyles.tableHeaders,
                        ),
                        Spacer(),
                        Text(
                          "Details",
                          style: CheersStyles.tableHeaders,
                        ),
                      ],
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 228, 228, 228),
                      thickness: 1.5,
                    ),
                    SizedBox(
                      height: 520,
                      width: 1150,
                      child: selectedValue == null
                          ? const Center(
                              child:
                                  Text("Select an option to see transactions"))
                          : SingleChildScrollView(
                              child: StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('Orders')
                                      .where(
                                        'baristaUID',
                                        isEqualTo: user.email,
                                      )
                                      .where('status', isEqualTo: selectedValue)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }

                                    if (!snapshot.hasData ||
                                        snapshot.data!.docs.isEmpty) {
                                      return const Center(
                                          child: Text("No Order found"));
                                    }
                                    if (snapshot.hasData) {
                                      var itemList =
                                          snapshot.data!.docs.toList();

                                      return ListView.builder(
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          itemCount: itemList.length,
                                          itemBuilder: (context, index) {
                                            DocumentSnapshot document =
                                                itemList[index];

                                            Map<String, dynamic> data = document
                                                .data() as Map<String, dynamic>;

                                            String transactionID = document.id;
                                            double transactionTotal =
                                                data['total'];
                                            int totalItems = data['totalItems'];

                                            String baristaUID =
                                                data['baristaUID'];

                                            Timestamp timestamp = data['time'];

                                            DateTime dateTime = timestamp
                                                .toDate(); // Convert Firestore timestamp to DateTime

                                            if (baristaUID == user.email) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10.0, top: 10),
                                                child: Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                      border: Border(
                                                        bottom: BorderSide(
                                                          color: Color.fromARGB(
                                                              255,
                                                              228,
                                                              228,
                                                              228), // Border color
                                                          width:
                                                              1.0, // Border width
                                                        ),
                                                      ),
                                                    ),
                                                    child: Row(children: [
                                                      const SizedBox(width: 60),
                                                      SizedBox(
                                                          width: 250,
                                                          child: Center(
                                                              child: Text(
                                                            transactionID,
                                                            style: CheersStyles
                                                                .tableItems,
                                                          ))),
                                                      const SizedBox(width: 50),
                                                      SizedBox(
                                                          width: 100,
                                                          child: Center(
                                                              child: Text(
                                                            "\$$transactionTotal",
                                                            style: CheersStyles
                                                                .tableItems,
                                                          ))),
                                                      const SizedBox(width: 70),
                                                      SizedBox(
                                                          width: 100,
                                                          child: Center(
                                                              child: Text(
                                                            totalItems
                                                                .toString(),
                                                            style: CheersStyles
                                                                .tableItems,
                                                          ))),
                                                      const Spacer(),
                                                      IconButton(
                                                          onPressed: () {},
                                                          icon: const Icon(
                                                              Icons.menu))
                                                    ])),
                                              );
                                            } else {
                                              return Container();
                                            }
                                          });
                                    } else {
                                      return const Text("No Orders");
                                    }
                                  }),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

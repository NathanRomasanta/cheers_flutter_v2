import 'package:cheers_flutter/design/design.dart';
import 'package:cheers_flutter/pages/op&cl%20pages/ClosingAccounts.dart';
import 'package:cheers_flutter/pages/op&cl%20pages/OpeningAccounts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemAccounts extends StatefulWidget {
  const ItemAccounts({super.key});

  @override
  State<ItemAccounts> createState() => _ItemAccountsState();
}

class _ItemAccountsState extends State<ItemAccounts> {
  final user = FirebaseAuth.instance.currentUser!;
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
                                                      const ClosingAccounts(),
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
            )
          ],
        ),
      ),
    );
  }
}

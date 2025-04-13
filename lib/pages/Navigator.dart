import 'package:cheers_flutter/pages/DualStateful.dart';
import 'package:cheers_flutter/pages/Opening&Closing.dart';
import 'package:cheers_flutter/pages/OrderList.dart';
import 'package:cheers_flutter/pages/OrderStock.dart';
import 'package:cheers_flutter/pages/Settings.dart';
import 'package:cheers_flutter/pages/Orders.dart';
import 'package:cheers_flutter/pages/SquareLanding.dart';
import 'package:cheers_flutter/pages/SquareTest.dart';
import 'package:cheers_flutter/pages/BaristaStock.dart';
import 'package:cheers_flutter/pages/Transactions.dart';
import 'package:cheers_flutter/pages/squaretest2.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;

class NavigatorGate extends StatefulWidget {
  const NavigatorGate({super.key});

  @override
  State<NavigatorGate> createState() => _NavigatorGateState();
}

class _NavigatorGateState extends State<NavigatorGate> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return FluentApp(
        color: const Color(0xffffffff),
        theme: FluentThemeData(
            mediumAnimationDuration: Durations.medium1,
            animationCurve: Curves.bounceIn,
            scaffoldBackgroundColor: CupertinoColors.systemBackground,
            navigationPaneTheme: const NavigationPaneThemeData(
              backgroundColor: CupertinoColors.systemBackground,
            ),
            accentColor: material.Colors.orange.toAccentColor()),
        home: NavigationView(
          // Longer duration
          transitionBuilder: (child, animation) {
            // Combined fade and slide animation
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeIn,
              ),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0.0, 0.2), // Slide up from slightly below
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutQuad,
                )),
                child: child,
              ),
            );
          },
          pane: NavigationPane(
              displayMode: PaneDisplayMode.open,
              toggleable: true,
              header: Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 0, left: 18),
                child: SizedBox(
                    height: 40,
                    child: Image.asset(
                      'lib/assets/images/Logo.png',
                    )),
              ),
              size: const NavigationPaneSize(openMaxWidth: 86),
              items: [
                PaneItem(
                    icon: const Padding(
                      padding: EdgeInsets.all(8.0), // Add padding to the icon
                      child: Icon(
                        Icons.point_of_sale,
                        color: Color(0xffFF6E1F),
                        size: 35,
                      ),
                    ),
                    title: const Text("Order"),
                    body: const DualStatefulPage()),
                PaneItem(
                    icon: const Padding(
                      padding: EdgeInsets.all(8.0), // Add padding to the icon
                      child: Icon(
                        Icons.corporate_fare_rounded,
                        color: Color(0xffFF6E1F),
                        size: 35,
                      ),
                    ),
                    title: const Text("Transactions"),
                    body: const TransactionScreen()),
                PaneItem(
                    icon: const Padding(
                      padding:
                          const EdgeInsets.all(8.0), // Add padding to the icon
                      child: const Icon(
                        Icons.table_chart,
                        color: Color(0xffFF6E1F),
                        size: 35,
                      ),
                    ),
                    title: const Text("Stock"),
                    body: const StocksPage()),
                PaneItem(
                    icon: const Padding(
                      padding: EdgeInsets.all(8.0), // Add padding to the icon
                      child: Icon(
                        Icons.send,
                        color: Color(0xffFF6E1F),
                        size: 35,
                      ),
                    ),
                    title: const Text("Orders"),
                    body: const OrderStock()),
                PaneItem(
                    icon: const Padding(
                      padding: EdgeInsets.all(8.0), // Add padding to the icon
                      child: Icon(
                        Icons.list_alt,
                        color: Color(0xffFF6E1F),
                        size: 35,
                      ),
                    ),
                    title: const Text("OrdersList"),
                    body: const OrderList()),
                PaneItem(
                    icon: const Padding(
                      padding: EdgeInsets.all(8.0), // Add padding to the icon
                      child: Icon(
                        Icons.sip,
                        color: Color(0xffFF6E1F),
                        size: 35,
                      ),
                    ),
                    title: const Text("Item Accounts"),
                    body: const ItemAccounts()),
                PaneItem(
                    icon: const Padding(
                      padding: EdgeInsets.all(8.0), // Add padding to the icon
                      child: Icon(
                        Icons.settings,
                        color: Color(0xffFF6E1F),
                        size: 35,
                      ),
                    ),
                    title: const Text("Settings"),
                    body: const Settings()),
              ],
              selected: currentPage,
              onChanged: (index) => setState(() {
                    currentPage = index;
                  })),
        ));
  }
}

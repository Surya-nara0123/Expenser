import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/categories.dart';
import 'package:flutter_application_1/pages/payments.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/pages/settings.dart';
import 'package:flutter_application_1/components/add_payment.dart';
import 'package:flutter_application_1/components/db_handler.dart';
import 'package:sqflite/sqflite.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _balanceController = '';
  // ignore: unused_field
  String _budgetController = '';
  // ignore: unused_field
  String? _lastUpdatedDate; // Store the last updated date
  double _moneySpent = 0;
  // get the current balance from shared preferences
  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // print(prefs.getDouble('balance')!);
    // print(prefs.getDouble('budget')!);
    double storedBalance = prefs.getDouble('balance') ?? 0.0;
    double storedBudget = prefs.getDouble('budget') ?? 0.0;
    String? storedDate =
        prefs.getString('balanceChangeDate') ?? ''; // Fetch the stored date
    // String _month = DateTime.now().month.toString();
    setState(() {
      _balanceController = storedBalance.toString();
      _budgetController = storedBudget.toString();
      _lastUpdatedDate = storedDate;
    });
    // print(_balanceController);
    // print(_budgetController);
    // print(_lastUpdatedDate);
  }

  final List<List<String>> payments = [];
  final Map<int, String> categories = {};
  late Database db;

  double perBudgetSpend = 0;
  double perMoneySpentThisMonth = 0;
  List<double> perMoneyForCategories = [];
  double avergaeSpentPerDay = 0;
  double moneyLeft = 0;

  List<List<dynamic>> finalData = [];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    initializeDB().then((value) {
      setState(() {
        db = value;
      });
      db.query("Allpayments").then((value) {
        // print(value);
        setState(() {
          for (int i = 0; i < value.length; i++) {
            payments.add([
              value[i]['title'].toString().isNotEmpty
                  ? value[i]['title'].toString()
                  : '',
              value[i]['category'].toString().isNotEmpty
                  ? value[i]['category'].toString()
                  : '',
              value[i]['reason'].toString().isNotEmpty
                  ? value[i]['reason'].toString()
                  : '',
              value[i]['date'].toString().isNotEmpty
                  ? value[i]['date'].toString()
                  : '',
              value[i]['amount'].toString().isNotEmpty
                  ? value[i]['amount'].toString()
                  : '',
            ]);
          }
          double sum = 0;
          double sum1 = 0;
          // print(payments);
          for (int i = 0; i < payments.length; i++) {
            // find the money spent in this month
            // print(payments[i][3].split(" ")[0].split("-")[1]);
            if (payments[i][3].split(" ")[0].split("-")[1] ==
                DateTime.now().month.toString()) {
              // print(payments[i][4]);
              sum += double.parse(payments[i][4]);
            }
            // print((DateTime.now().month - 1) % 12);
            // print(double.parse(payments[i][3].split(" ")[0].split("-")[1]).toInt());
            if (double.parse(payments[i][3].split(" ")[0].split("-")[1])
                    .toInt()
                    .toString() ==
                ((DateTime.now().month - 1) % 12).toString()) {
              sum1 += double.parse(payments[i][4]);
            }
          }
          _moneySpent = sum;
          avergaeSpentPerDay = sum / DateTime.now().day;
          perMoneySpentThisMonth = (sum - sum1) / sum1 * 100;
          perMoneySpentThisMonth =
              double.parse(perMoneySpentThisMonth.toStringAsFixed(3));
          moneyLeft = double.parse(_budgetController) - sum;

          // compile everything into a list
          finalData = [
            [
              "${perMoneySpentThisMonth.toStringAsFixed(2)}%",
              'Money spent this month compared to last month'
            ],
            [
              "₹${avergaeSpentPerDay.toStringAsFixed(2)}",
              'Average spent per day'
            ],
            ["₹${moneyLeft.toStringAsFixed(2)}", 'Money left from budget'],
          ];
        });
        // print(payments);
      });
      db.query("Categories").then((value) {
        setState(() {
          for (int i = 0; i < value.length; i++) {
            categories[int.parse(value[i]["id"].toString())] =
                value[i]["color"].toString();
          }
          // find the percentage of money spent on each category
          for (int i = 0; i < categories.length; i++) {
            double sum = 0;
            for (int j = 0; j < payments.length; j++) {
              if (payments[j][1] == (i + 1).toString()) {
                sum += double.parse(payments[j][4]);
              }
            }
            perMoneyForCategories.add(sum);
          }
          for (int i = 0; i < categories.length; i++) {
            finalData.add(["${perMoneyForCategories[i]}₹", value[i]["category"]]);
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        // scrolledUnderElevation: 15,
        // scrolledUnderElevation: 0.2,
        leadingWidth: 0,
        leading: Container(),
        shadowColor: Colors.white,
        surfaceTintColor: Colors.white,
        backgroundColor: const Color(0xFF333131),
        toolbarHeight: 74,
        title: const Text(
          'Expenser',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontFamily: 'IrishGrover',
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const Settings();
              }));
            },
            icon: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.settings,
                weight: 1.2,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      body: homePageBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await addNewPayment(context);
          setState(() {
            // reload the data
            payments.clear();
            // categories.clear();
            final value1 = db.query("Allpayments");
            // print(value);
            value1.then((value) {
              for (int i = 0; i < value.length; i++) {
                payments.add([
                  value[i]['title'].toString().isNotEmpty
                      ? value[i]['title'].toString()
                      : '',
                  value[i]['category'].toString().isNotEmpty
                      ? value[i]['category'].toString()
                      : '',
                  value[i]['reason'].toString().isNotEmpty
                      ? value[i]['reason'].toString()
                      : '',
                  value[i]['date'].toString().isNotEmpty
                      ? value[i]['date'].toString()
                      : '',
                  value[i]['amount'].toString().isNotEmpty
                      ? value[i]['amount'].toString()
                      : '',
                ]);
                // print(payments);
              }
              // update the balance and money spent
              double sum = 0;
              double sum1 = 0;
              for (int i = 0; i < payments.length; i++) {
                // find the money spent in this month
                // print(payments[i][3].split(" ")[0].split("-")[1]);
                if (payments[i][3].split(" ")[0].split("-")[1] ==
                    DateTime.now().month.toString()) {
                  // print(payments[i][4]);
                  sum += double.parse(payments[i][4]);
                }
                // print((DateTime.now().month - 1) % 12);
                // print(double.parse(payments[i][3].split(" ")[0].split("-")[1]).toInt());
                if (double.parse(payments[i][3].split(" ")[0].split("-")[1])
                        .toInt()
                        .toString() ==
                    ((DateTime.now().month - 1) % 12).toString()) {
                  sum1 += double.parse(payments[i][4]);
                }
              }
              // print(sum1);
              // print(sum);

              _moneySpent = sum;
              avergaeSpentPerDay = sum / DateTime.now().day;
              perMoneySpentThisMonth = (sum - sum1) / sum1 * 100;
              perMoneySpentThisMonth =
                  double.parse(perMoneySpentThisMonth.toStringAsFixed(3));
            });
          });
          // Add your onPressed code here!
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> func(BuildContext context) async {
    await Navigator.push(
        context,
        PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const Payments(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;
              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              final offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            }));
    if (!context.mounted) return;
    setState(() {
      // reload the data
      payments.clear();
      // categories.clear();
      final value1 = db.query("Allpayments");
      // print(value);
      value1.then((value) {
        for (int i = 0; i < value.length; i++) {
          payments.add([
            value[i]['title'].toString().isNotEmpty
                ? value[i]['title'].toString()
                : '',
            value[i]['category'].toString().isNotEmpty
                ? value[i]['category'].toString()
                : '',
            value[i]['reason'].toString().isNotEmpty
                ? value[i]['reason'].toString()
                : '',
            value[i]['date'].toString().isNotEmpty
                ? value[i]['date'].toString()
                : '',
            value[i]['amount'].toString().isNotEmpty
                ? value[i]['amount'].toString()
                : '',
          ]);
          // print(payments);
        }
        // update the balance and money spent
        double sum = 0;
        double sum1 = 0;
        for (int i = 0; i < payments.length; i++) {
          // find the money spent in this month
          // print(payments[i][3].split(" ")[0].split("-")[1]);
          if (payments[i][3].split(" ")[0].split("-")[1] ==
              DateTime.now().month.toString()) {
            // print(payments[i][4]);
            sum += double.parse(payments[i][4]);
          }
          // print((DateTime.now().month - 1) % 12);
          // print(double.parse(payments[i][3].split(" ")[0].split("-")[1]).toInt());
          if (double.parse(payments[i][3].split(" ")[0].split("-")[1])
                  .toInt()
                  .toString() ==
              ((DateTime.now().month - 1) % 12).toString()) {
            sum1 += double.parse(payments[i][4]);
          }
        }
        // print(sum1);
        // print(sum);

        _moneySpent = sum;
        avergaeSpentPerDay = sum / DateTime.now().day;
        perMoneySpentThisMonth = (sum - sum1) / sum1 * 100;
        perMoneySpentThisMonth =
            double.parse(perMoneySpentThisMonth.toStringAsFixed(3));
      });
    });
  }

  Widget homePageBody() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Container(
          height: MediaQuery.of(context).size.height - 100,
          decoration: const BoxDecoration(
            color: Colors.black,
          ),
          child: Column(children: [
            const SizedBox(
              height: 33,
            ),
            Padding(
              padding: const EdgeInsets.all(17.0),
              child: Center(
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                              0xFFFFFCFC), // Button background color
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10), // Rounded corners
                          ),
                          padding:
                              const EdgeInsets.all(0), // Remove default padding
                        ),
                        onPressed: () {
                          // Add your button action here
                          func(context);
                        },
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Payments',
                              style: TextStyle(
                                color: Colors.black, // Text color
                                fontSize: 24,
                                fontFamily: "IrishGrover",
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 11,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                              0xFFFFFCFC), // Button background color
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10), // Rounded corners
                          ),
                          padding:
                              const EdgeInsets.all(0), // Remove default padding
                        ),
                        onPressed: () {
                          // Add your button action here
                          Navigator.push(
                              context,
                              PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      const Categories(),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    const begin = Offset(1.0, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.ease;
                                    final tween = Tween(begin: begin, end: end)
                                        .chain(CurveTween(curve: curve));
                                    final offsetAnimation =
                                        animation.drive(tween);

                                    return SlideTransition(
                                      position: offsetAnimation,
                                      child: child,
                                    );
                                  }));
                        },
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Categories',
                              style: TextStyle(
                                color: Colors.black, // Text color
                                fontSize: 24,
                                fontFamily: "IrishGrover",
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(
              indent: 18,
              endIndent: 18,
              color: Color(0xFF665F5F),
              thickness: 1,
            ),
            const SizedBox(
              height: 19,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const Settings(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.ease;
                            final tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));
                            final offsetAnimation = animation.drive(tween);

                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          }));
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size.fromHeight(91),
                  backgroundColor: const Color(0xFFF05C5C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      // Use an Expanded widget to allow text to take up the right amount of space
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // Align text to the left
                          children: [
                            Text(
                              '₹$_balanceController',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 36,
                                fontFamily: 'IrishGrover',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                                height:
                                    2.5), // Add space between the text elements
                            const Text(
                              'Current Balance',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: 'IrishGrover',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Add an arrow icon aligned to the right
                      const Icon(
                        Icons.arrow_circle_right,
                        color: Colors.black,
                        size: 36, // Slightly larger for better visibility
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 19,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const Payments(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.ease;
                            final tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));
                            final offsetAnimation = animation.drive(tween);

                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          }));
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size.fromHeight(91),
                  backgroundColor: const Color(0xFF6DF05C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      // Use an Expanded widget to allow text to take up the right amount of space
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // Align text to the left
                          children: [
                            Text(
                              '₹$_moneySpent',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 36,
                                fontFamily: 'IrishGrover',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                                height:
                                    2.5), // Add space between the text elements
                            const Text(
                              'Money Spent this month',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: 'IrishGrover',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Add an arrow icon aligned to the right
                      const Icon(
                        Icons.arrow_circle_right,
                        color: Colors.black,
                        size: 36, // Slightly larger for better visibility
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 19,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 17.0, right: 17.0),
              child: Container(
                height: 293,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFE7E7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ListView.separated(
                      // physics: const NeverScrollableScrollPhysics(),
                      itemCount: finalData.length,
                      separatorBuilder: (context, index) => const Divider(
                            color: Color(0xFFC1B8B8),
                            thickness: 1,
                          ),
                      itemBuilder: (context, index) {
                        return Row(children: [
                          const Icon(
                            Icons.arrow_drop_down,
                            size: 36,
                            color: Color(0xFF34C759),
                          ),
                          const SizedBox(
                            width: 1,
                          ),
                          Expanded(
                            child: Text(finalData[index][0],
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontFamily: 'IrishGrover',
                                    fontWeight: FontWeight.w900)),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            width: 1,
                            height: 47,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD2CACA),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(''),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text('${finalData[index][1]}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'IrishGrover',
                                    fontWeight: FontWeight.normal)),
                          )
                        ]);
                      }),
                ),
              ),
            ),
          ])),
    );
  }
}

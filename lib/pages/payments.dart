import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/home.dart';
import 'package:flutter_application_1/components/add_payment.dart';
import 'package:flutter_application_1/pages/settings.dart';
import 'package:flutter_application_1/components/db_handler.dart';
import 'package:sqflite/sqflite.dart';

class Payments extends StatefulWidget {
  const Payments({super.key});

  @override
  State<Payments> createState() => _PaymentsState();
}

class _PaymentsState extends State<Payments> {
  final List<List<String>> payments = [];
  final Map<int, String> categories = {};
  late Database db;

  @override
  void initState() {
    super.initState();
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
        });
        print(payments);
      });
      db.query("Categories").then((value) {
        setState(() {
          for (int i = 0; i < value.length; i++) {
            categories[int.parse(value[i]["id"].toString())] = value[i]["color"].toString();
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
        shadowColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: Container(),
        leadingWidth: 0,
        backgroundColor: const Color(0xFF333131),
        toolbarHeight: 74,
        title: GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const HomePage();
            }));
          },
          child: const Text(
            'Expenser',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontFamily: 'IrishGrover',
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const Settings();
              }));
            },
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: homePageBody(),
      // persistentFooterButtons: [
      //   ElevatedButton(
      //     onPressed: () {
      //       Navigator.push(context, MaterialPageRoute(builder: (context) {
      //         return Container();
      //       }));
      //     },
      //     child: const Text('Add Payment'),
      //   ),
      // ],
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await addNewPayment(context);
          db.query("Allpayments").then((value) {
            // print(value);
            setState(() {
              // List<List<String>>payments1 = [];
              payments.clear();
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
            });
          });
        },
        child: const Icon(Icons.add),
      ),
    
    );
  }

  Widget homePageBody() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF333131),
      ),
      child: ListView.builder(
        itemCount: payments.length,
        itemBuilder: (context, index) {
          return ListTile(
            titleTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontFamily: 'IrishGrover',
                fontWeight: FontWeight.bold),
            leadingAndTrailingTextStyle: const TextStyle(
              color: Colors.white,
              fontFamily: 'IrishGrover',
            ),
            subtitleTextStyle: const TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.normal,
              fontFamily: 'IrishGrover',
            ),
            title: Text(
              payments[index][0],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "Reason: ",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(payments[index][2]),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      "Money Spent: ",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(payments[index][4]),
                  ],
                )
              ],
            ),
            leading: CircleAvatar(
              backgroundColor: Color(int.parse(categories[int.parse(payments[index][1])]!)),
              radius: 12.5,
            ),
            trailing: Text(
              payments[index][3],
            ),
          );
        },
      ),
    );
  }
}

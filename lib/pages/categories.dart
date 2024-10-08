import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/db_handler.dart';
import 'package:flutter_application_1/pages/home.dart';
import 'package:flutter_application_1/pages/settings.dart';
import 'package:flutter_application_1/components/add_payment.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  final List<List<String>> categories = [];

  @override
  void initState() {
    super.initState();
    initializeDB().then((db) async {
      final List<Map<String, dynamic>> items = await db.query('Categories');
      setState(() {
        for (int i = 0; i < items.length; i++) {
          categories.add([
            items[i]['category'],
            items[i]['description'],
            items[i]['color']
          ]);
        }
      });
      // print(categories);
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
        backgroundColor: const Color(0xFF333131),
        toolbarHeight: 74,
        leadingWidth: 0,
        leading: Container(),
        title: GestureDetector(
          onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const HomePage()), // Navigate to home.dart
              (Route<dynamic> route) =>
                  false, // This will remove all previous routes from the stack
            );
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
        onPressed: () {
          addNewPayment(context);
          // Add your onPressed code here!
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Container homePageBody() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF333131),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
              itemCount: categories.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(int.parse(categories[index][2])),
                  ),
                  margin: const EdgeInsets.all(5),
                  child: ListTile(
                    title: Text(categories[index][0],
                        style: const TextStyle(
                            fontFamily: 'IrishGrover',
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.black)), // Adjust text color
                    subtitle: Text(categories[index][1],
                        style: const TextStyle(
                          color: Colors.black,
                          fontFamily: 'IrishGrover',
                          )),
                  ),
                );
              }),
        ),
      ),
    );
  }
}

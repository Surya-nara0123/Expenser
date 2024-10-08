import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/home.dart';
import 'package:flutter_application_1/components/add_payment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // For formatting the date

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final TextEditingController _balanceController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  String? _lastUpdatedDate; // Store the last updated date

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Load values from SharedPreferences
  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? storedBalance = prefs.getDouble('balance')!;
    double? storedBudget = prefs.getDouble('budget')!;
    String? storedDate = prefs.getString('balanceChangeDate') ?? ''; // Fetch the stored date

    setState(() {
      _balanceController.text = storedBalance.toString();
      _budgetController.text = storedBudget.toString();
      _lastUpdatedDate = storedDate;
    });
  }

  // Save values to SharedPreferences
  Future<void> _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String balance = _balanceController.text;
    // dont update date if there is no change to the current balance

    if (prefs.get('balance') == balance){
      return;
    }
    await prefs.setDouble('balance', double.parse(balance));
    await prefs.setDouble('budget', double.parse(_budgetController.text));

    // Save the current date when balance is changed
    String currentDate = DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now());
    // print(currentDate);
    await prefs.setString('balanceChangeDate', currentDate);

    setState(() {
      _lastUpdatedDate = currentDate;
    });
  }

  @override
  void dispose() {
    _balanceController.dispose();
    _budgetController.dispose();
    super.dispose();
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
            onPressed: () {},
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: homePageBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addNewPayment(context);
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
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Balance',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _balanceController,
              onTapOutside: (context1) {
                FocusScope.of(context).unfocus();
              },
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                hintText: 'Enter your balance',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Monthly Budget',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _budgetController,
              onTapOutside: (context1) {
                FocusScope.of(context).unfocus();
              },
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                hintText: 'Enter your budget',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _savePreferences();
                },
                child: const Text('Update'),
              ),
            ),
            const SizedBox(height: 20),
            if (_lastUpdatedDate != null)
              Text(
                'Last Balance Change: $_lastUpdatedDate',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

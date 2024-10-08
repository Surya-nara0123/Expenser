import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/db_handler.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For formatting the date

Future<dynamic> addNewPayment(BuildContext context) async {
  DateTime selectedDate = DateTime.now();
  TextEditingController dateController = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(selectedDate),
  );

  // Create focus nodes for each TextField
  FocusNode titleFocusNode = FocusNode();
  FocusNode reasonFocusNode = FocusNode();
  FocusNode amountFocusNode = FocusNode();

  List<String> categories = [];
  Map<String, int> categories1 = {};

  final db = await initializeDB();
  final List<Map<String, dynamic>> items = await db.query('Categories');
  for (int i = 0; i < items.length; i++) {
    categories.add(items[i]['category']);
    categories1[items[i]['category']] = items[i]['id'];
  }

  // Function to show the date picker and update the date field
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
    }
  }

  return showDialog(
    // ignore: use_build_context_synchronously
    context: context,
    builder: (context) {
      TextEditingController titleController = TextEditingController();
      TextEditingController reasonController = TextEditingController();
      TextEditingController amountController = TextEditingController();
      TextEditingController categoryController = TextEditingController();

      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title of the dialog
                const Center(
                  child: Text(
                    'New Payment',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(),
                const SizedBox(height: 10),

                // Payment Title
                const Text('Payment Title'),
                const SizedBox(height: 5),
                TextField(
                  controller: titleController,
                  focusNode: titleFocusNode, // Attach focus node
                  textInputAction:
                      TextInputAction.next, // Set text input action to "next"
                  decoration: const InputDecoration(
                    hintText: 'Payment Title',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (value) {
                    FocusScope.of(context).requestFocus(
                        reasonFocusNode); // Move focus to the next field
                  },
                ),
                const SizedBox(height: 10),

                // Reason
                const Text('Reason'),
                const SizedBox(height: 5),
                TextField(
                  textCapitalization: TextCapitalization.sentences,
                  controller: reasonController,
                  focusNode: reasonFocusNode, // Attach focus node
                  textInputAction:
                      TextInputAction.next, // Set text input action to "next"
                  decoration: const InputDecoration(
                    hintText: 'Reason',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) {
                    FocusScope.of(context).requestFocus(
                        amountFocusNode); // Move focus to the next field
                  },
                ),
                const SizedBox(height: 10),

                // Date Field with DatePicker
                const Text('Date'),
                const SizedBox(height: 5),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true, // Makes the field read-only
                  onTap: () {
                    selectDate(context); // Opens the date picker
                  },
                ),
                const SizedBox(height: 10),

                // Amount
                const Text('Amount'),
                const SizedBox(height: 5),
                TextField(
                  controller: amountController,
                  focusNode: amountFocusNode, // Attach focus node
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    hintText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction
                      .done, // Set the last input action to "done"
                ),
                const SizedBox(height: 10),

                // Category (Dropdown example)
                const Text('Category'),
                const SizedBox(height: 5),
                DropdownButtonFormField<String>(
                  hint: const Text("Select a Category"),
                  items: categories.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    categoryController.text = value;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                // Save Button
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      final db = await initializeDB();
                      // Insert the payment into the database
                      await insertItem(
                        db,
                        titleController.text,
                        reasonController.text,
                        categories1[categoryController.text]!,
                        dateController.text,
                        double.parse(amountController.text),
                      );
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      double balance =
                          prefs.getDouble("balance") ?? 0.0; // Get the balance
                      prefs.setDouble('balance',
                          balance - double.parse(amountController.text));
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

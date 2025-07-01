import 'package:flutter/material.dart';
import 'database.dart';

class Staff extends StatefulWidget {
  const Staff({super.key});

  @override
  State<Staff> createState() => _StaffState();
}

class _StaffState extends State<Staff> {
  TextEditingController namecontroller = TextEditingController();
  TextEditingController staffidcontroller = TextEditingController();
  TextEditingController agecontroller = TextEditingController();

  bool isFormValid = false;
  String? ageErrorText;

  void validateForm() {
    final isAgeValid = int.tryParse(agecontroller.text) != null;
    setState(() {
      isFormValid = namecontroller.text.isNotEmpty &&
          staffidcontroller.text.isNotEmpty &&
          agecontroller.text.isNotEmpty &&
          isAgeValid;

      ageErrorText = isAgeValid || agecontroller.text.isEmpty
          ? null
          : "Please enter numbers only";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Staff"),
        centerTitle: true,
      ),
      body: Container(
        margin: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const Text("Name",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            TextField(
              controller: namecontroller,
              onChanged: (_) => validateForm(),
              decoration: const InputDecoration(labelText: "Enter name"),
            ),
            const SizedBox(height: 16),
            const Text("Staff ID",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            TextField(
              controller: staffidcontroller,
              onChanged: (_) => validateForm(),
              decoration: const InputDecoration(labelText: "Enter staff ID"),
            ),
            const SizedBox(height: 16),
            const Text("Age",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            TextField(
              controller: agecontroller,
              onChanged: (_) => validateForm(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Enter age"),
            ),
            if (ageErrorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 5.0),
                child: Text(
                  ageErrorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: (!isFormValid)
                  ? null
                  : () async {
                      Map<String, dynamic> staffInfoMap = {
                        "Name": namecontroller.text,
                        "Staff ID": staffidcontroller.text,
                        "Age": agecontroller.text,
                      };
                      await DatabaseMethods()
                          .addStaffDetails(staffInfoMap)
                          .then((value) async {
                        namecontroller.clear();
                        staffidcontroller.clear();
                        agecontroller.clear();
                        setState(() {
                          isFormValid = false;
                        });
                        // Show success popup
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Success'),
                            content: const Text('Staff details added successfully!'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                        Navigator.pop(context); // Go back to staff list
                      });
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                "Submit",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}
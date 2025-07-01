import 'package:flutter/material.dart';
import 'add_staff.dart';
import 'database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StaffList extends StatefulWidget {
  const StaffList({super.key});

  @override
  State<StaffList> createState() => _StaffListState();
}

class _StaffListState extends State<StaffList> {
  TextEditingController namecontroller = TextEditingController();
  TextEditingController staffidcontroller = TextEditingController();
  TextEditingController agecontroller = TextEditingController();
  Stream? StaffStream;
  bool isEditFormValid = false;
  String? ageErrorText;

  getontheload() async {
    StaffStream = DatabaseMethods().getStaffDetails();
    setState(() {});
  }

  void validateEditForm() {
    final isAgeValid = int.tryParse(agecontroller.text) != null;

    setState(() {
      isEditFormValid = namecontroller.text.isNotEmpty &&
          staffidcontroller.text.isNotEmpty &&
          agecontroller.text.isNotEmpty &&
          isAgeValid;

      ageErrorText = (agecontroller.text.isEmpty || isAgeValid)
          ? null
          : "Please enter numbers only";
    });
  }

  @override
  void initState() {
    super.initState();
    getontheload();
  }

  Widget allStaffDetails() {
    return StreamBuilder(
      stream: StaffStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
          return const Center(child: Text("No staff found."));
        }
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20.0),
                    child: Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Row for name and icons
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  width: 100,
                                  child: Text(
                                    "Name",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    ": ${ds["Name"]}",
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 3,
                                    softWrap: true,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    namecontroller.text = ds["Name"];
                                    staffidcontroller.text = ds["Staff ID"];
                                    agecontroller.text = ds["Age"];

                                    Future.delayed(const Duration(milliseconds: 50), () {
                                      EditStaffDetail(ds["Staff ID"]);
                                    });
                                  },
                                  child: const Icon(Icons.edit, color: Colors.lightGreen),
                                ),
                                const SizedBox(width: 5.0),
                                GestureDetector(
                                  onTap: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Staff?'),
                                        content: const Text('Are you sure to delete this?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: const Text('No'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(true),
                                            child: const Text('Yes'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await DatabaseMethods().deleteStaffDetail(ds["Staff ID"]);
                                      setState(() {});
                                    }
                                  },
                                  child: const Icon(Icons.delete, color: Colors.red),
                                )
                              ],
                            ),
                            const SizedBox(height: 10),
                            buildFieldRow("Staff ID", ds["Staff ID"]),
                            buildFieldRow("Age", ds["Age"]),
                          ],
                        ),
                      ),
                    ),
                  );
                })
            : Container();
      },
    );
  }

  Widget buildFieldRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              ": $value",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
              softWrap: true,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Staff()),
          );
          getontheload();
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text("Staff List"),
        centerTitle: true,
      ),
      body: Container(
        margin: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: StaffStream,
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
                    return const Center(child: Text("No staff found."));
                  }
                  return ListView.separated(
                    itemCount: snapshot.data.docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      DocumentSnapshot ds = snapshot.data.docs[index];
                      return Card(
                        margin: EdgeInsets.zero,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          title: Text(
                            ds["Name"],
                            style: TextStyle(
                              color: Colors.lightGreen.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Staff ID: ${ds["Staff ID"]}"),
                              Text("Age: ${ds["Age"]}"),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.lightGreen.shade700),
                                onPressed: () {
                                  namecontroller.text = ds["Name"];
                                  staffidcontroller.text = ds["Staff ID"];
                                  agecontroller.text = ds["Age"];
                                  Future.delayed(const Duration(milliseconds: 50), () {
                                    EditStaffDetail(ds.id);
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Staff?'),
                                      content: const Text('Are you sure to delete this?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: const Text('No'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          child: const Text('Yes'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await DatabaseMethods().deleteStaffDetail(ds.id);
                                    setState(() {});
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Simple logo at the bottom
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                children: [
                  // Custom engineer logo as a placeholder
                  Image.network(
                    'https://i.pinimg.com/736x/14/a1/0c/14a10cf6686dfa811266f032b43a5b8c.jpg',
                    width: 60,
                    height: 60,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Yusra Sdn. Bhd.",
                    style: TextStyle(
                      color: Colors.lightGreen.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future EditStaffDetail(String id) async {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            void localValidateEditForm() {
              final isAgeValid = int.tryParse(agecontroller.text) != null;

              setStateDialog(() {
                isEditFormValid = namecontroller.text.isNotEmpty &&
                    staffidcontroller.text.isNotEmpty &&
                    agecontroller.text.isNotEmpty &&
                    isAgeValid;

                ageErrorText = (agecontroller.text.isEmpty || isAgeValid)
                    ? null
                    : "Please enter numbers only";
              });
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              localValidateEditForm();
            });

            return AlertDialog(
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(Icons.cancel),
                        ),
                        const SizedBox(width: 60.0),
                        const Text(
                          "Edit Details",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    const Text("Name",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10.0),
                    Container(
                      padding: const EdgeInsets.only(left: 10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: namecontroller,
                        onChanged: (_) => localValidateEditForm(),
                        decoration: const InputDecoration(border: InputBorder.none),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    const Text("Staff ID",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10.0),
                    Container(
                      padding: const EdgeInsets.only(left: 10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: staffidcontroller,
                        decoration: const InputDecoration(border: InputBorder.none),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    const Text("Age",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10.0),
                    Container(
                      padding: const EdgeInsets.only(left: 10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: agecontroller,
                        onChanged: (_) => localValidateEditForm(),
                        decoration: const InputDecoration(border: InputBorder.none),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    if (ageErrorText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, left: 10.0),
                        child: Text(
                          ageErrorText!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 30.0),
                    Center(
                      child: ElevatedButton(
                        onPressed: isEditFormValid
                            ? () async {
                                Map<String, dynamic> updateInfo = {
                                  "Name": namecontroller.text,
                                  "Staff ID": staffidcontroller.text,
                                  "Age": agecontroller.text,
                                };
                                await DatabaseMethods()
                                    .updateStaffDetail(id, updateInfo)
                                    .then((value) {
                                  Navigator.pop(context);
                                  setState(() {});
                                });
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Update"),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
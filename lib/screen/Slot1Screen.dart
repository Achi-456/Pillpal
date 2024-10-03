import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SlotScreen extends StatefulWidget {
  final int slotNumber;
  const SlotScreen(this.slotNumber, {Key? key}) : super(key: key);

  @override
  State<SlotScreen> createState() => _SlotScreenState();
}

class _SlotScreenState extends State<SlotScreen> {
  final TextEditingController _nameController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  int pillCount = 0;
  int tabletCount = 0;
  bool isMorning = false;
  bool isAfternoon = false;
  bool isNight = false;
  bool _isSaved = false;
  int _selectedSlot = 1;

  @override
  void initState() {
    super.initState();
    _selectedSlot = widget.slotNumber;
    fetchExistingData();
  }

  void fetchExistingData() async {
    if (user != null) {
      try {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('slot$_selectedSlot')
            .doc(user!.uid)
            .get();

        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;

          setState(() {
            _nameController.text = data['medicine_name'] ?? '';
            pillCount = data['pill_count'] ?? 0;
            tabletCount = data['tablet_count'] ?? 0;
            isMorning = data['morning_dose'] ?? false;
            isAfternoon = data['afternoon_dose'] ?? false;
            isNight = data['night_dose'] ?? false;
            _isSaved = true;
          });

          print('Fetched data: $data');
        }
      } catch (e) {
        print('Error fetching data: $e');
        setState(() {
          _isSaved = false;
          pillCount = 0;
          tabletCount = 0;
          isMorning = false;
          isAfternoon = false;
          isNight = false;
          _nameController.clear();
        });
      }
    }
  }

  Future<void> _addMedicineDetails() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

    try {
      await FirebaseFirestore.instance
          .collection('slot$_selectedSlot')
          .doc(uid)
          .set({
        'medicine_name': _nameController.text,
        'pill_count': pillCount,
        'tablet_count': tabletCount,
        'uid': uid,
        'morning_dose': isMorning,
        'afternoon_dose': isAfternoon,
        'night_dose': isNight,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Medicine details added successfully')),
      );
      setState(() {
        _isSaved = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add medicine details')),
      );
    }
  }

  void _onSlotSelected(int index) {
    setState(() {
      _selectedSlot = index + 1;
      fetchExistingData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 30, 151, 64).withOpacity(0.9),
        centerTitle: true,
        title: Text('Slot $_selectedSlot Details'),
      ),
      body: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 30, 151, 64).withOpacity(0.9),
              Color.fromARGB(255, 138, 255, 171).withOpacity(0.5),
            ],
          ),
        ),
        child: Center(
          child: Container(
            width: 350,
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                border: Border.all(color: Colors.transparent),
                borderRadius: BorderRadius.circular(25)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Center(
                      child: Container(
                        height: 100,
                        width: 300,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                          color: Colors.white.withOpacity(0.5),
                          border: Border.all(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Count',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            _buildCounter(
                                (change) => _updateCount(change), true)
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 100,
                      width: 300,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                        color: Colors.white.withOpacity(0.5),
                        border: Border.all(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Tablets per dose',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          _buildCounter(
                              (change) => _updateTabletCount(change), false)
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: 300,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                        color: Colors.white.withOpacity(0.5),
                        border: Border.all(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Dosage frequency',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildFrequencyIcon(
                                    Icons.wb_sunny, 'Morning', isMorning, () {
                                  setState(() {
                                    _isSaved = false;
                                    isMorning = !isMorning;
                                  });
                                }),
                                SizedBox(width: 40),
                                _buildFrequencyIcon(Icons.brightness_5,
                                    'Afternoon', isAfternoon, () {
                                  setState(() {
                                    _isSaved = false;
                                    isAfternoon = !isAfternoon;
                                  });
                                }),
                                SizedBox(width: 40),
                                _buildFrequencyIcon(
                                    Icons.nights_stay, 'Night', isNight, () {
                                  setState(() {
                                    _isSaved = false;
                                    isNight = !isNight;
                                  });
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextField(
                            controller: _nameController,
                            onChanged: (value) {
                              setState(() {
                                _isSaved = false;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Enter medicine name',
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (!_isSaved)
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isSaved = false;
                                fetchExistingData();
                              });
                            },
                            child: Text('Reset Changes'),
                          ),
                        ElevatedButton(
                          onPressed: _addMedicineDetails,
                          child: Text('Save Changes'),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedSlot - 1,
        onTap: (int index) {
          if (_isSaved)
            _onSlotSelected(index);
          else {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Unsaved changes'),
                content: Text(
                    'You have unsaved changes. Do you want to discard them?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _onSlotSelected(index);
                    },
                    child: Text('Discard changes'),
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _addMedicineDetails()
                            .then((value) => _onSlotSelected(index));
                      },
                      child: Text('Save changes')),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                ],
              ),
            );
          }
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.looks_one),
            label: 'Slot 1',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.looks_two),
            label: 'Slot 2',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.looks_3),
            label: 'Slot 3',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.looks_4),
            label: 'Slot 4',
          ),
        ],
        unselectedItemColor: Color.fromARGB(255, 80, 80, 80),
        selectedItemColor: Color.fromARGB(255, 60, 57, 57),
        backgroundColor: Color.fromARGB(255, 207, 255, 220),
        selectedIconTheme: IconThemeData(
          color: Color.fromARGB(255, 60, 57, 57),
        ),
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCounter(Function(int) updateFunction, bool isPillCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.remove),
          onPressed: () => updateFunction(-1),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.lightGreenAccent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            isPillCount ? "$pillCount" : "$tabletCount",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () => updateFunction(1),
        ),
      ],
    );
  }

  Widget _buildFrequencyIcon(
      IconData icon, String label, bool isSelected, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon,
              size: 36,
              color: isSelected
                  ? Color.fromARGB(255, 0, 0, 0)
                  : const Color.fromARGB(255, 174, 174, 174)),
          SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: isSelected
                      ? Color.fromARGB(255, 0, 0, 0)
                      : const Color.fromARGB(255, 174, 174, 174))),
        ],
      ),
    );
  }

  void _updateCount(int change) {
    setState(() {
      _isSaved = false;
      pillCount += change;
      if (pillCount < 0) {
        pillCount = 0;
      }
    });
  }

  void _updateTabletCount(int change) {
    setState(() {
      _isSaved = false;
      tabletCount += change;
      if (tabletCount < 0) {
        tabletCount = 0;
      }
    });
  }
}

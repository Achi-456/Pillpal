import 'package:flutter/material.dart';

class MedicineInventoryPage extends StatefulWidget {
  @override
  _MedicineInventoryPageState createState() => _MedicineInventoryPageState();
}

class _MedicineInventoryPageState extends State<MedicineInventoryPage> {
  final TextEditingController _controller = TextEditingController();
  final Map<String, Map<String, int>> _medicineInventory = {};
  String _selectedSlot = 'Slot 1';

  void _addMedicine(String medicineName) {
    setState(() {
      if (!_medicineInventory.containsKey(medicineName)) {
        _medicineInventory[medicineName] = {
          'Slot 1': 0,
          'Slot 2': 0,
          'Slot 3': 0,
        };
      }
    });
  }

  void _updateCount(String medicineName, int change) {
    setState(() {
      if (_medicineInventory[medicineName] != null) {
        _medicineInventory[medicineName]![_selectedSlot] =
            (_medicineInventory[medicineName]![_selectedSlot] ?? 0) + change;
      }
    });
  }

  void _updateTabletsPerDose(String medicineName, int change) {
    // This function can be expanded based on the requirement
    setState(() {
      if (_medicineInventory[medicineName] != null) {
        _medicineInventory[medicineName]![_selectedSlot] =
            (_medicineInventory[medicineName]![_selectedSlot] ?? 0) + change;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicine Inventory'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter medicine name',
              ),
              onSubmitted: (value) {
                _addMedicine(value);
                _controller.clear();
              },
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['Slot 1', 'Slot 2', 'Slot 3'].map((slot) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ChoiceChip(
                    label: Text(slot),
                    selected: _selectedSlot == slot,
                    onSelected: (selected) {
                      setState(() {
                        _selectedSlot = slot;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Text('Count',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildCounter((change) => _updateCount(_controller.text, change)),
            SizedBox(height: 20),
            Text('Tablets per dose',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildCounter(
                (change) => _updateTabletsPerDose(_controller.text, change)),
            SizedBox(height: 20),
            Text('Dosage frequency',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFrequencyIcon(Icons.wb_sunny, 'morning'),
                _buildFrequencyIcon(Icons.brightness_5, 'afternoon'),
                _buildFrequencyIcon(Icons.nights_stay, 'night'),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: _medicineInventory.keys.map((medicineName) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    color: Colors.lightGreenAccent,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 20.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medicineName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          ...['Slot 1', 'Slot 2', 'Slot 3'].map((slot) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$slot count',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove),
                                      onPressed: () =>
                                          _updateCount(medicineName, -1),
                                    ),
                                    Text(
                                      '${_medicineInventory[medicineName]![slot]}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: () =>
                                          _updateCount(medicineName, 1),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounter(Function(int) updateFunction) {
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
            "", // Example value
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

  Widget _buildFrequencyIcon(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Icon(icon, size: 36),
          SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}

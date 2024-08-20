import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medicine Grid',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MedicineGrid(),
    );
  }
}

class Medicine {
  final int id;
  final String name;
  final String composition;
  final String photo;
  final String usage;
  final String price;
  final String dosage;

  Medicine({
    required this.id,
    required this.name,
    required this.composition,
    required this.photo,
    required this.usage,
    required this.price,
    required this.dosage,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'],
      name: json['name'],
      composition: json['composition'],
      photo: json['photo'] ?? "",
     // photo: json['icon_url'] ?? 'https://trego.co.in/uploads/medicines/photos/64e01bf1f7dbd9099e249e9c3247fdbb9a46b4b1-1280x720-sixteen_nine.jpg',
      usage: json['usage'],
      price: json['price'],
      dosage: json['dosage'],
    );
  }
}

class MedicineGrid extends StatefulWidget {
  @override
  _MedicineGridState createState() => _MedicineGridState();
}

class _MedicineGridState extends State<MedicineGrid> {
  late Future<List<Medicine>> futureMedicines;

  @override
  void initState() {
    super.initState();
    futureMedicines = fetchMedicines();
  }

  Future<List<Medicine>> fetchMedicines() async {
    final response = await http.get(Uri.parse('https://trego.co.in/api/medicine/list'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<Medicine> medicines = data.map((json) => Medicine.fromJson(json)).toList();
      return medicines;
    } else {
      throw Exception('Failed to load medicines');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicine list'
            ''),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<Medicine>>(
        future: futureMedicines,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Medicine medicine = snapshot.data![index];
                return MedicineCard(medicine: medicine);
              },
            );
          }
        },
      ),
    );
  }
}

class MedicineCard extends StatelessWidget {
  final Medicine medicine;

  MedicineCard({required this.medicine});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
     child: Column(
       crossAxisAlignment: CrossAxisAlignment.stretch,
       children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: medicine.photo.isNotEmpty
                     ? NetworkImage(medicine.photo)
                    : AssetImage('asseset.jpg') as ImageProvider,
                 fit: BoxFit.cover,
                 ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
             ),
           ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.0),
                Text(medicine.composition),
                SizedBox(height: 4.0),
                Text('Price: \RS ${medicine.price}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.0),
                Text('Dosage: ${medicine.dosage}'),
                ElevatedButton(
                  child: const Text(
                    'Buy Now',
                  ),
                  onPressed: () {},

                ),
                SizedBox(height: 4.0)
              ],
            ),
          ),
        ],
      ),
    );
  }
}


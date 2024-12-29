import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventura App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventura'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InventoryScreen()),
                );
              },
              child: const Text('Pregled inventara'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QRScannerScreen()),
                );
              },
              child: const Text('Skeniraj i inventuriraj'),
            ),
          ],
        ),
      ),
    );
  }
}

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseReference databaseRef = FirebaseDatabase.instance.ref('inventory');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pregled inventara'),
      ),
      body: StreamBuilder(
        stream: databaseRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data != null) {
            final data = (snapshot.data! as DatabaseEvent).snapshot.value as Map?;
            if (data == null) {
              return const Center(child: Text('Inventar je prazan.'));
            }

            final items = data.entries.map((e) {
              final value = e.value as Map;
              return {
                'id': e.key,
                ...value,
              };
            }).toList();

            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item['name'] ?? 'Nepoznato'),
                  subtitle: Text(
                    'Količina: ${item['quantity']}, Lokacija: ${item['location']}, '
                    'Inventuriran: ${item['inventoried'] ? "Da" : "Ne"}',
                  ),
                  trailing: item['inventoried']
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.radio_button_unchecked, color: Colors.red),
                );
              },
            );
          }

          return const Center(child: Text('Došlo je do greške pri dohvaćanju podataka.'));
        },
      ),
    );
  }
}

class QRScannerScreen extends StatelessWidget {
  const QRScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skeniraj i inventuriraj'),
      ),
      body: const Center(
        child: Text('Dodajte QR skener funkcionalnost ovdje.'),
      ),
    );
  }
}

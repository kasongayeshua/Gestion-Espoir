import 'package:flutter/material.dart';

void main() {
  runApp(const GestionEspoirApp());
}

class GestionEspoirApp extends StatelessWidget {
  const GestionEspoirApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion Espoir',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const AccueilPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AccueilPage extends StatelessWidget {
  const AccueilPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion Espoir'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Bienvenue dans Gestion Espoir',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Votre application de gestion commerciale est prête.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () {
                // Action pour les ventes ou la gestion
              },
              icon: const Icon(Icons.store),
              label: const Text(
                'Accéder au Tableau de Bord',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

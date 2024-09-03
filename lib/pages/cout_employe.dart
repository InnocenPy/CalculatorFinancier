import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

class CoutEmployeurPage extends StatefulWidget {
  const CoutEmployeurPage({super.key});

  @override
  _CoutEmployeurPageState createState() => _CoutEmployeurPageState();
}

class _CoutEmployeurPageState extends State<CoutEmployeurPage> {
  int _selectedToggleIndex = 0;

  // Controllers for input fields
  final TextEditingController salaireBrutController = TextEditingController();
  final TextEditingController tauxAccidentTravailController =
      TextEditingController();
  final TextEditingController rubriquesNonSoumisesController =
      TextEditingController();
  final TextEditingController salaireNetController = TextEditingController();
  final TextEditingController coutEmployeurController = TextEditingController();
  final TextEditingController avantageNatureController =
      TextEditingController();

  String resultatCoutEmployeur = '';
  String resultatSalaireBrut = '';
  String resultatSalaireNet = '';

  @override
  void dispose() {
    salaireBrutController.dispose();
    tauxAccidentTravailController.dispose();
    rubriquesNonSoumisesController.dispose();
    salaireNetController.dispose();
    coutEmployeurController.dispose();
    avantageNatureController.dispose();
    super.dispose();
  }

  void _calculateFromBrut() {
    double B3 = double.tryParse(salaireBrutController.text) ?? 0;
    double B4 = double.tryParse(tauxAccidentTravailController.text) ?? 0;
    double B5 = double.tryParse(rubriquesNonSoumisesController.text) ?? 0;

    double coutEmployeur = B3 + ((B3 - B5) * (0.179 + B4)) + (B3 * 0.045);
    setState(() {
      resultatCoutEmployeur = coutEmployeur.toStringAsFixed(2);
    });
  }

  void _calculateFromNet() {
    double B12 = double.tryParse(salaireNetController.text) ?? 0;
    double B11 = double.tryParse(rubriquesNonSoumisesController.text) ?? 0;
    double B13 = double.tryParse(tauxAccidentTravailController.text) ?? 0;

    double coutEmployeur = B12 + ((B12 - B11) * (0.179 + B13)) + (B12 * 0.045);
    setState(() {
      resultatCoutEmployeur = coutEmployeur.toStringAsFixed(2);
    });
  }

  void _calculateFromCoutEmployeur() {
    double B17 = double.tryParse(coutEmployeurController.text) ?? 0;
    double B18 = double.tryParse(tauxAccidentTravailController.text) ?? 0;
    double B19 = double.tryParse(rubriquesNonSoumisesController.text) ?? 0;
    double B20 = double.tryParse(avantageNatureController.text) ?? 0;

    double salaireBrut =
        (B17 + ((0.179 + B18) * B19)) / (1 + (0.179 + B18) + 0.045);
    double salaireNet = salaireBrut - (((salaireBrut - B19) * 0.0666)) - B20;

    setState(() {
      resultatSalaireBrut = salaireBrut.toStringAsFixed(2);
      resultatSalaireNet = salaireNet.toStringAsFixed(2);
    });
  }

  void _onToggleSwitch(int index) {
    setState(() {
      _selectedToggleIndex = index;
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
      ),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calcul Salaire / Coût Employeur")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ToggleSwitch(
              initialLabelIndex: _selectedToggleIndex,
              labels: const ['Brut', 'Net', 'Coût Employeur'],
              onToggle: (index) {
                _onToggleSwitch(index!);
              },
            ),
            const SizedBox(height: 20),
            if (_selectedToggleIndex == 0) ...[
              _buildTextField(
                controller: salaireBrutController,
                label: 'Salaire Brut',
                onChanged: (value) => _calculateFromBrut(),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: tauxAccidentTravailController,
                label: 'Taux Accident du Travail',
                onChanged: (value) => _calculateFromBrut(),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: rubriquesNonSoumisesController,
                label: 'Rubriques Non Soumises',
                onChanged: (value) => _calculateFromBrut(),
              ),
              const SizedBox(height: 20),
              Text(
                'Coût Employeur (CF et TL inclus): $resultatCoutEmployeur',
                style: const TextStyle(fontSize: 18),
              ),
            ] else if (_selectedToggleIndex == 1) ...[
              _buildTextField(
                controller: salaireNetController,
                label: 'Salaire Net',
                onChanged: (value) => _calculateFromNet(),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: tauxAccidentTravailController,
                label: 'Taux Accident du Travail',
                onChanged: (value) => _calculateFromNet(),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: rubriquesNonSoumisesController,
                label: 'Rubriques Non Soumises',
                onChanged: (value) => _calculateFromNet(),
              ),
              const SizedBox(height: 20),
              Text(
                'Coût Employeur (CF et TL inclus): $resultatCoutEmployeur',
                style: const TextStyle(fontSize: 18),
              ),
            ] else if (_selectedToggleIndex == 2) ...[
              _buildTextField(
                controller: coutEmployeurController,
                label: 'Coût Employeur',
                onChanged: (value) => _calculateFromCoutEmployeur(),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: tauxAccidentTravailController,
                label: 'Taux Accident du Travail',
                onChanged: (value) => _calculateFromCoutEmployeur(),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: rubriquesNonSoumisesController,
                label: 'Rubriques Non Soumises',
                onChanged: (value) => _calculateFromCoutEmployeur(),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: avantageNatureController,
                label: 'Avantage en Nature',
                onChanged: (value) => _calculateFromCoutEmployeur(),
              ),
              const SizedBox(height: 20),
              Text(
                'Salaire Brut: $resultatSalaireBrut',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                'Salaire Net: $resultatSalaireNet',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

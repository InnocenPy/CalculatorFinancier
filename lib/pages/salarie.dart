import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

class CalculSalairePage extends StatefulWidget {
  const CalculSalairePage({super.key});

  @override
  _CalculSalairePageState createState() => _CalculSalairePageState();
}

class _CalculSalairePageState extends State<CalculSalairePage> {
  final TextEditingController salaireBrutController = TextEditingController();
  final TextEditingController avantageNatureController =
      TextEditingController();
  final TextEditingController rubriquesNonSoumisesController =
      TextEditingController();
  final TextEditingController salaireNetController = TextEditingController();

  bool isCalculFromBrut = true;

  @override
  void dispose() {
    salaireBrutController.dispose();
    avantageNatureController.dispose();
    rubriquesNonSoumisesController.dispose();
    salaireNetController.dispose();
    super.dispose();
  }

  void _calculateFromBrut() {
    double B3 = double.tryParse(salaireBrutController.text) ?? 0;
    double B4 = double.tryParse(avantageNatureController.text) ?? 0;
    double B5 = double.tryParse(rubriquesNonSoumisesController.text) ?? 0;

    double net = B3 - ((B3 - B5) * 0.0666) - B4;
    salaireNetController.text = net.toStringAsFixed(2);
  }

  void _calculateFromNet() {
    double B10 = double.tryParse(salaireNetController.text) ?? 0;
    double B11 = double.tryParse(avantageNatureController.text) ?? 0;
    double B12 = double.tryParse(rubriquesNonSoumisesController.text) ?? 0;

    double brut = (B10 + B11 + (-B12 * 0.0666)) / 0.9334;
    salaireBrutController.text = brut.toStringAsFixed(2);
  }

  void _onToggleSwitch(int index) {
    setState(() {
      isCalculFromBrut = index == 0;
      if (isCalculFromBrut) {
        _calculateFromBrut();
      } else {
        _calculateFromNet();
      }
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
        border: OutlineInputBorder(),
        labelText: label,
      ),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calcul Salaire Brut/Net")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ToggleSwitch(
              initialLabelIndex: isCalculFromBrut ? 0 : 1,
              labels: ['Brut', 'Net'],
              onToggle: (index) {
                _onToggleSwitch(index!);
              },
            ),
            const SizedBox(height: 20),
            if (isCalculFromBrut) ...[
              _buildTextField(
                controller: salaireBrutController,
                label: 'Salaire Brut',
                onChanged: (value) {
                  _calculateFromBrut();
                  setState(() {}); // Update state after calculation
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: avantageNatureController,
                label: 'Avantage en Nature',
                onChanged: (value) {
                  _calculateFromBrut();
                  setState(() {}); // Update state after calculation
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: rubriquesNonSoumisesController,
                label: 'Rubriques Non Soumises',
                onChanged: (value) {
                  _calculateFromBrut();
                  setState(() {}); // Update state after calculation
                },
              ),
              const SizedBox(height: 20),
              Text(
                "Salaire Net (avant prélèvement de l'ITS): ${salaireNetController.text}",
                style: const TextStyle(fontSize: 18),
              ),
            ] else ...[
              _buildTextField(
                controller: salaireNetController,
                label: 'Salaire Net',
                onChanged: (value) {
                  _calculateFromNet();
                  setState(() {}); // Update state after calculation
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: avantageNatureController,
                label: 'Avantage en Nature',
                onChanged: (value) {
                  _calculateFromNet();
                  setState(() {}); // Update state after calculation
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: rubriquesNonSoumisesController,
                label: 'Rubriques Non Soumises',
                onChanged: (value) {
                  _calculateFromNet();
                  setState(() {}); // Update state after calculation
                },
              ),
              const SizedBox(height: 20),
              Text(
                "Salaire Brut: ${salaireBrutController.text}",
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

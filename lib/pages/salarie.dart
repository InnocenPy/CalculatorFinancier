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
        border: const OutlineInputBorder(),
        labelText: label,
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildTextFieldReadonly({
    required TextEditingController controller,
    required String label,
  }) {
    return Column(
      children: [
        Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.brown, // Définit la couleur du texte
            ),
            textAlign: TextAlign.center, // Centre le texte horizontalement
          ),
        ),
        TextField(
          readOnly: true, // Champ en lecture seule
          controller: controller,
          style:
              const TextStyle(color: Colors.white), // Couleur du texte en blanc
          decoration: const InputDecoration(
            fillColor: Colors.brown, // Couleur de fond marron
            filled: true, // Activer le remplissage de la couleur de fond
            labelStyle: TextStyle(
              color: Colors.white, // Couleur du texte du label en blanc
              fontSize: 16, // Taille du texte du label
            ),
            floatingLabelAlignment: FloatingLabelAlignment.center,

            border: InputBorder.none, // Pas de bordure
            //labelText: label,
            alignLabelWithHint:
                true, // Pour aligner le label avec le hint et centrer
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calcul Salaires Brut/Net")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ToggleSwitch(
              initialLabelIndex: isCalculFromBrut ? 0 : 1,
              labels: ['Brut', 'Net'],
              activeBgColor: [Colors.brown],
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
              const SizedBox(height: 40),
              _buildTextFieldReadonly(
                  controller: salaireNetController,
                  label: 'Salaire Net (avant prélèvement de ITS)'),
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
              const SizedBox(height: 40),
              _buildTextFieldReadonly(
                  controller:  salaireBrutController, label: 'Salaire Brut')
            ],
          ],
        ),
      ),
    );
  }
}

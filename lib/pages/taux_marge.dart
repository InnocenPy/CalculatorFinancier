import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:number_text_input_formatter/number_text_input_formatter.dart';
import 'package:toggle_switch/toggle_switch.dart';

class TauxDeMargePage extends StatefulWidget {
  const TauxDeMargePage({super.key});

  @override
  State<TauxDeMargePage> createState() => _TauxDeMargePageState();
}

class _TauxDeMargePageState extends State<TauxDeMargePage> {
  final TextEditingController prixAchatController = TextEditingController();
  final TextEditingController tauxMargeController = TextEditingController();
  final TextEditingController prixVenteTTCController = TextEditingController();
  final TextEditingController prixVenteHTController = TextEditingController();
  final TextEditingController coefficientController = TextEditingController();
  final TextEditingController tauxTVAController = TextEditingController();

  double prixAchatHT = 0;
  double prixVenteHT = 0;
  double prixVenteTTC = 0;
  double marge = 0;
  double coefficient = 0;
  double tauxMarge = 0;

  bool isTauxMargeSelected = true;
  bool isPrixVenteSelected = false;
  bool isCoefficientSelected = false;

  @override
  void dispose() {
    prixAchatController.dispose();
    tauxMargeController.dispose();
    prixVenteTTCController.dispose();
    coefficientController.dispose();
    tauxTVAController.dispose();
    super.dispose();
  }

  /// Méthode générique pour obtenir une valeur numérique depuis un contrôleur.
  double _parseInputValue(TextEditingController controller,
      {double fallback = 0}) {
    String cleanedValue =
        controller.text.replaceAll(RegExp(r"\s+"), "").replaceAll(',', '.');
    return double.tryParse(cleanedValue) ?? fallback;
  }

  /// Calcul à partir du taux de marge.
  void _calculateFromTauxMarge() {
    if (prixAchatController.text.isNotEmpty) {
      // String cachat = prixAchatController.text
      //     .replaceAll(RegExp(r"\s+"), "")
      //     .replaceAll(',', '.');
      // double achat = double.tryParse(cachat) ?? 0;

      // print(achat);
      if (tauxMargeController.text.isNotEmpty) {
        if (tauxTVAController.text.isNotEmpty) {
          double prixAchat = _parseInputValue(prixAchatController) ?? 0;
          double tauxMarge = _parseInputValue(tauxMargeController) / 100;
          double tauxTVA = _parseInputValue(tauxTVAController) / 100;

          // Calcul des valeurs de base
          prixVenteHT = prixAchat / (1 - tauxMarge);
          prixVenteTTC = prixVenteHT * (1 + tauxTVA);
          marge = prixVenteHT - prixAchat;
          coefficient = prixVenteTTC / prixAchat;

          prixVenteTTCController.text = formatValue(prixVenteTTC, 0);
          // prixVenteHTController.text = formatValue(prixVenteHT, 0);

          // Mise à jour des autres valeurs interconnectées
          setState(() {
            this.prixVenteHT = prixVenteHT;
            this.prixVenteTTC = prixVenteTTC;
            this.marge = marge;
            this.coefficient = coefficient;
            this.tauxMarge = tauxMarge * 100; // Conversion en pourcentage
          });
        }
      }
    }
  }

  /// Calcul à partir du prix de vente TTC avec une sécurité renforcée.
  void _calculateFromPrixVenteTTC() {
    double prixAchat = _parseInputValue(prixAchatController);
    double prixVenteTTC = _parseInputValue(prixVenteTTCController);
    double tauxTVA = _parseInputValue(tauxTVAController) / 100;

    // Calcul des valeurs de base
    prixVenteHT = prixVenteTTC / (1 + tauxTVA);
    marge = prixVenteHT - prixAchat;
    coefficient = prixVenteTTC / prixAchat;
    tauxMarge = (marge / prixVenteHT) * 100;

    tauxMargeController.text = formatValue(tauxMarge, 0);
    coefficientController.text = formatValue(coefficient, 1);

    // Mise à jour des autres valeurs interconnectées
    setState(() {
      this.prixVenteTTC = prixVenteTTC;
      this.prixVenteHT = prixVenteHT;
      this.marge = marge;
      this.coefficient = coefficient;
      this.tauxMarge = tauxMarge;
    });
  }

  /// Calcul à partir du coefficient avec une sécurité renforcée.
  void _calculateFromCoefficient() {
    double prixAchat = _parseInputValue(prixAchatController);
    double coefficient = _parseInputValue(coefficientController);
    double tauxTVA = _parseInputValue(tauxTVAController) / 100;

    // Calcul des valeurs de base
    prixVenteHT = prixAchat * coefficient / (1 + tauxTVA);
    prixVenteTTC = prixAchat * coefficient;
    marge = prixVenteHT - prixAchat;
    tauxMarge = (marge / prixVenteHT) * 100;

    prixVenteTTCController.text = formatValue(prixVenteTTC, 0);
    tauxMargeController.text = formatValue(tauxMarge, 0);

    // Mise à jour des autres valeurs interconnectées
    setState(() {
      this.prixVenteHT = prixVenteHT;
      this.prixVenteTTC = prixVenteTTC;
      this.marge = marge;
      this.coefficient = coefficient;
      this.tauxMarge = tauxMarge;
    });
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

  String formatValue(double value, int decimalPlaces) {
    // Vérifier si la valeur est NaN (Not a Number) ou infinie
    if (value.isNaN || value.isInfinite) {
      return '0';
    }

    // Arrondir la valeur au nombre de décimales spécifié
    double roundedValue = double.parse(value.toStringAsFixed(decimalPlaces));

    // Formater la valeur arrondie avec le séparateur de milliers
    return NumberFormat.decimalPattern('fr').format(roundedValue);
  }

  /// Gère le changement de page et effectue le calcul approprié.
  void onPageChanged(int index) {
    isTauxMargeSelected = index == 0;
    isPrixVenteSelected = index == 1;
    isCoefficientSelected = index == 2;

    if (isTauxMargeSelected) {
      _calculateFromTauxMarge();
    } else if (isPrixVenteSelected) {
      _calculateFromPrixVenteTTC();
    } else if (isCoefficientSelected) {
      _calculateFromCoefficient();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calcul Taux de Marge")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ToggleSwitch(
                customWidths: [200, 200, 200],
                initialLabelIndex: isTauxMargeSelected
                    ? 0
                    : isPrixVenteSelected
                        ? 1
                        : 2,
                labels: const ['Taux de Marge', 'Prix de Vente', 'Coefficient'],
                activeBgColor: [Colors.brown],
                onToggle: (index) {
                  onPageChanged(index!);
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: prixAchatController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  NumberTextInputFormatter(
                    integerDigits: 10,
                    decimalDigits: 2,
                    maxValue: '10000000000.00',
                    decimalSeparator: ',',
                    groupDigits: 3,
                    groupSeparator: ' ',
                    allowNegative: false,
                    overrideDecimalPoint: false,
                    insertDecimalPoint: false,
                    insertDecimalDigits: false,
                  ),
                ],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Prix d\'achat HT',
                ),
                onChanged: (value) {
                  onPageChanged(isTauxMargeSelected
                      ? 0
                      : isPrixVenteSelected
                          ? 1
                          : 2);
                },
              ),
              const SizedBox(height: 20),
              if (isTauxMargeSelected)
                TextField(
                  controller: tauxMargeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Taux de Marge (%)',
                  ),
                  onChanged: (value) {
                    _calculateFromTauxMarge();
                  },
                ),
              if (isPrixVenteSelected)
                TextField(
                  controller: prixVenteTTCController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Prix de Vente TTC',
                  ),
                  onChanged: (value) {
                    _calculateFromPrixVenteTTC();
                  },
                ),
              if (isCoefficientSelected)
                TextField(
                  controller: coefficientController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Coefficient',
                  ),
                  onChanged: (value) {
                    _calculateFromCoefficient();
                  },
                ),
              const SizedBox(height: 20),
              TextField(
                controller: tauxTVAController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Taux de TVA (%)',
                ),
                onChanged: (value) {
                  onPageChanged(isTauxMargeSelected
                      ? 0
                      : isPrixVenteSelected
                          ? 1
                          : 2);
                },
              ),
              const SizedBox(height: 40),
              _buildTextFieldReadonly(
                  controller:
                      TextEditingController(text: formatValue(prixVenteHT, 0)),
                  label: 'Prix de vente HT'),
              // _InfoLine("Prix de Vente HT:", prixVenteHT),
              _buildTextFieldReadonly(
                  controller: TextEditingController(
                    text: formatValue(prixVenteTTC, 0),
                  ),
                  label: 'Prix de Vente TTC'),
              // _InfoLine("Prix de Vente TTC:", prixVenteTTC),
              _buildTextFieldReadonly(
                  controller: TextEditingController(
                    text: formatValue(marge, 0),
                  ),
                  label: 'Marge'),
              // _InfoLine("Marge:", marge),
              _buildTextFieldReadonly(
                  controller: TextEditingController(
                    text: formatValue(coefficient, 1),
                  ),
                  label: 'Coefficient'),
              // _InfoLine("Coefficient:", coefficient),
              _buildTextFieldReadonly(
                  controller: TextEditingController(
                    text: formatValue(tauxMarge, 0),
                  ),
                  label: 'Taux de Marge'),
              // _InfoLine("Taux de Marge:", tauxMarge),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final dynamic value;

  _InfoLine(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        Text(
          value is num
              ? NumberFormat.decimalPattern('fr').format(value)
              : value.toString(),
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}

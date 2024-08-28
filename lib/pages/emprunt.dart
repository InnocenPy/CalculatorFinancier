import 'package:flutter/material.dart';
import 'dart:math';

class SimulationEmpruntPage extends StatefulWidget {
  @override
  _SimulationEmpruntPageState createState() => _SimulationEmpruntPageState();
}

class _SimulationEmpruntPageState extends State<SimulationEmpruntPage> {
  double montantEmprunte = 0;
  double tauxAnnuel = 0;
  int dureeEmprunt = 1; // en années
  int paiementsParAn = 12;

  @override
  Widget build(BuildContext context) {
    int nombreEcheances = dureeEmprunt * paiementsParAn;
    double tauxParPeriode = tauxAnnuel / paiementsParAn;
    double remboursementParEcheance = montantEmprunte *
        (tauxParPeriode / (1 - pow(1 / (1 + tauxParPeriode), nombreEcheances)));
    // Si la valeur de remboursementParEcheance est NaN, on la remplace par 0
    remboursementParEcheance =
        remboursementParEcheance.isNaN ? 0 : remboursementParEcheance;

    double interetsTotaux =
        (remboursementParEcheance * nombreEcheances) - montantEmprunte;
    // Si la valeur de interetsTotaux est -1, on la remplace par 0
    interetsTotaux = interetsTotaux.isNaN ? 0 : interetsTotaux;

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Champ de saisie pour le montant du prêt
            TextField(
              cursorColor: Colors.blue,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Montant emprunte',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  montantEmprunte = double.tryParse(value) ?? 0;
                });
              },
            ),

            SizedBox(height: 20),

            // Champ de saisie pour le taux annuel
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Taux (%)',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  tauxAnnuel = (double.tryParse(value) ?? 0) / 100;
                });
              },
            ),

            SizedBox(height: 40),

            // Durée de l'emprunt
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Text('Durée de l\'emprunt (années) :'),
                    // const SizedBox(width: 50),
                    TextButton(
                      onPressed: () {
                        if (dureeEmprunt > 1) {
                          setState(() {
                            dureeEmprunt--;
                          });
                        }
                      },
                      child: Text('-'),
                    ),
                    Text('$dureeEmprunt an${dureeEmprunt > 1 ? 's' : ''}'),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          dureeEmprunt++;
                        });
                      },
                      child: Text('+'),
                    ),
                  ],
                ),
              ],
            ),
            // Nombre de paiements par an
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text('Nombre de paiements par an : '),
                // const SizedBox(width: 40),
                TextButton(
                  onPressed: () {
                    if (paiementsParAn > 1) {
                      setState(() {
                        paiementsParAn--;
                      });
                    }
                  },
                  child: Text('-'),
                ),
                Text('$paiementsParAn'),
                TextButton(
                  onPressed: () {
                    setState(() {
                      paiementsParAn++;
                    });
                  },
                  child: Text('+'),
                ),
              ],
            ),
            // Section des résultats
            SizedBox(height: 20),
            Text('Nombre d\'échéances : $nombreEcheances'),
            Text(
                'Remboursement par échéance : \$${remboursementParEcheance.toStringAsFixed(2)}'),
            Text('Intérêts totaux : \$${interetsTotaux.toStringAsFixed(2)}'),

            SizedBox(
              height: 40,
            ),
            // Text('INNOCENT-DEV')
          ],
        ),
      ),
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';

class SimplexSolver extends StatefulWidget {
  const SimplexSolver({super.key});

  @override
  _SimplexSolverAppState createState() => _SimplexSolverAppState();
}

class _SimplexSolverAppState extends State<SimplexSolver> {
  List<TextEditingController> cControllers = [];
  List<List<TextEditingController>> aControllers = [];
  List<TextEditingController> bControllers = [];
  String result = "";

  Map<String, dynamic> dynamicSimplex(
      List<double> c, List<List<double>> A, List<double> b) {
    c = c.map((coef) => -coef).toList();

    int numConstraints = A.length;
    int numVars = c.length;

    if (A.length != b.length) {
      throw ArgumentError("Number of rows in A must match the size of b");
    }
    if (A[0].length != c.length) {
      throw ArgumentError("Number of columns in A must match the size of c");
    }

    List<List<double>> tableau = [];
    for (int i = 0; i < numConstraints; i++) {
      tableau.add([
        ...A[i],
        ...List.generate(numConstraints, (j) => i == j ? 1.0 : 0.0),
        b[i],
      ]);
    }

    tableau.add([
      ...c.map((e) => -e),
      ...List.filled(numConstraints + 1, 0.0),
    ]);

    while (true) {
      List<double> lastRow = tableau.last.sublist(0, tableau.last.length - 1);
      if (lastRow.every((value) => value <= 0)) {
        break;
      }

      int pivotCol =
          lastRow.indexWhere((value) => value == lastRow.reduce(max));

      List<double> ratios = [];
      for (int i = 0; i < numConstraints; i++) {
        double denominator = tableau[i][pivotCol];
        if (denominator > 0) {
          ratios.add(tableau[i].last / denominator);
        } else {
          ratios.add(double.infinity);
        }
      }

      if (ratios.every((r) => r == double.infinity)) {
        throw ArgumentError("The solution is unbounded.");
      }

      int pivotRow = ratios.indexWhere((r) => r == ratios.reduce(min));

      double pivotElement = tableau[pivotRow][pivotCol];
      for (int j = 0; j < tableau[pivotRow].length; j++) {
        tableau[pivotRow][j] /= pivotElement;
      }

      for (int i = 0; i < tableau.length; i++) {
        if (i != pivotRow) {
          double factor = tableau[i][pivotCol];
          for (int j = 0; j < tableau[i].length; j++) {
            tableau[i][j] -= factor * tableau[pivotRow][j];
          }
        }
      }

      printTableau(tableau, pivotRow, pivotCol, ratios, pivotElement);
    }

    List<double> solution = List.filled(numVars, 0.0);
    for (int i = 0; i < numVars; i++) {
      List<double> col = tableau.map((row) => row[i]).toList();
      if (col.sublist(0, numConstraints).where((value) => value != 0).length ==
          1) {
        int oneRow = col.indexOf(1.0);
        if (oneRow != -1 && tableau[oneRow].last >= 0) {
          solution[i] = tableau[oneRow].last;
        }
      }
    }

    double z = tableau.last.last;

    print("Optimal Solution: $solution");
    print("Optimal Value (z): $z");
    print("Final Tableau:");
    printTableau(tableau, -1, -1, [], 0.0);

    return {
      'solution': solution,
      'z': z,
      'tableau': tableau,
    };
  }

  void printTableau(List<List<double>> tableau, int pivotRow, int pivotCol,
      List<double> ratios, double pivotElement) {
    print("Current Tableau:");
    for (int i = 0; i < tableau.length; i++) {
      print(tableau[i]);
    }
    if (pivotRow != -1 && pivotCol != -1) {
      print("Pivot Column: $pivotCol");
      print("Ratios: $ratios");
      print("Pivot Row: $pivotRow");
      print("Pivot Element: $pivotElement");
    }
    print("");
  }

  void solveSimplex() {
    try {
      List<double> c = cControllers
          .map((controller) => double.parse(controller.text))
          .toList();
      List<List<double>> A = aControllers
          .map((rowControllers) => rowControllers
              .map((controller) => double.parse(controller.text))
              .toList())
          .toList();
      List<double> b = bControllers
          .map((controller) => double.parse(controller.text))
          .toList();

      var simplexResult = dynamicSimplex(c, A, b);

      setState(() {
        result =
            "Solution: ${simplexResult['solution']}\nOptimal Value (z): ${simplexResult['z']}\nFinal Tableau: ${simplexResult['tableau']}";
      });
    } catch (e) {
      setState(() {
        result = "Error: ${e.toString()}";
      });
    }
  }

  void addObjectiveCoefficient() {
    setState(() {
      cControllers.add(TextEditingController());
    });
  }

  void removeObjectiveCoefficient() {
    setState(() {
      if (cControllers.isNotEmpty) {
        cControllers.removeLast();
        for (var row in aControllers) {
          if (row.isNotEmpty) {
            row.removeLast();
          }
        }
      }
    });
  }

  void removeConstraint() {
    setState(() {
      if (aControllers.isNotEmpty) {
        aControllers.removeLast();
        bControllers.removeLast();
      }
    });
  }

  void addConstraint() {
    setState(() {
      List<TextEditingController> newConstraint =
          List.generate(cControllers.length, (_) => TextEditingController());
      aControllers.add(newConstraint);
      bControllers.add(TextEditingController());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dynamic Simplex Solver'),
        actions: [
          TextButton(
              onPressed: () {
                cControllers = [];
                aControllers = [];
                bControllers = [];
                result = '';
                setState(() {});
              },
              child: Text('reset'))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Objective Function Coefficients:'),
              Row(
                children: List.generate(cControllers.length, (index) {
                  return Expanded(
                    child: TextField(
                      controller: cControllers[index],
                      decoration: InputDecoration(
                        labelText: 'c$index',
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: addObjectiveCoefficient,
                    child: Text('Add Coefficient'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      removeObjectiveCoefficient();
                      removeConstraint();
                    },
                    child: Text('Remove Coefficient'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text('Constraints Coefficients:'),
              Column(
                children: List.generate(aControllers.length, (i) {
                  return Row(
                    children: List.generate(cControllers.length, (j) {
                      return Expanded(
                        child: TextField(
                          controller: aControllers[i][j],
                          decoration: InputDecoration(
                            labelText: 'a$i$j',
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
              SizedBox(height: 20),
              Text('Constraints RHS:'),
              Column(
                children: List.generate(bControllers.length, (index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: bControllers[index],
                          decoration: InputDecoration(
                            labelText: 'b$index',
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (cControllers.length > bControllers.length) {
                    addConstraint();
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Error'),
                          content: Text('Cannot add more constraints'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Text('Add Constraint'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: solveSimplex,
                child: Text('Solve'),
              ),
              SizedBox(height: 20),
              Text(
                result,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

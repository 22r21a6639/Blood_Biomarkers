import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:lottie/lottie.dart';
import 'result.dart';

class DataEntryPage extends StatefulWidget {
  @override
  _DataEntryPageState createState() => _DataEntryPageState();
}

class _DataEntryPageState extends State<DataEntryPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController hemoglobinController = TextEditingController();
  final TextEditingController redBloodCellsController = TextEditingController();
  final TextEditingController whiteBloodCellsController =
      TextEditingController();
  final TextEditingController neutrophilsController = TextEditingController();
  final TextEditingController eosinophilsController = TextEditingController();
  final TextEditingController monocytesController = TextEditingController();
  final TextEditingController basophilsController = TextEditingController();
  final TextEditingController hematocritController = TextEditingController();
  final TextEditingController mcvController = TextEditingController();
  final TextEditingController mchController = TextEditingController();
  final TextEditingController mchcController = TextEditingController();
  final TextEditingController rdwController = TextEditingController();

  Interpreter? _interpreter;
  List<String> _labels = [];
  String? _predictionResult;
  late Future<void> _loadModelFuture;

  @override
  void initState() {
    super.initState();
    _loadModelFuture = loadModel();
  }

  Future<void> loadModel() async {
    try {
      // Check if the model file exists

      // Load the model
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      print('Model loaded successfully');

      // Load labels
      _labels = await loadLabels('assets/labels.txt');
      print('Labels loaded successfully');
    } catch (e) {
      print('Failed to load model or labels: $e');
    }
  }

  Future<List<String>> loadLabels(String assetPath) async {
    try {
      final rawLabels = await rootBundle.loadString(assetPath);
      return rawLabels.split('\n').map((label) => label.trim()).toList();
    } catch (e) {
      print('Failed to load labels: $e');
      return [];
    }
  }

  Future<void> predict() async {
    if (_interpreter == null) {
      print('Model not loaded');
      return;
    }

    List<double> input = [
      double.parse(hemoglobinController.text),
      double.parse(redBloodCellsController.text),
      double.parse(whiteBloodCellsController.text),
      double.parse(neutrophilsController.text),
      double.parse(eosinophilsController.text),
      double.parse(monocytesController.text),
      double.parse(basophilsController.text),
      double.parse(hematocritController.text),
      double.parse(mcvController.text),
      double.parse(mchController.text),
      double.parse(mchcController.text),
      double.parse(rdwController.text),
    ];

    var inputTensor = Float32List.fromList(input).buffer.asUint8List();

    var outputTensorShape = _interpreter!.getOutputTensor(0).shape;
    print('Output Tensor Shape: $outputTensorShape');

    var outputTensor = Float32List(outputTensorShape.reduce((a, b) => a * b))
        .buffer
        .asUint8List();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animation2.json',
                onLoaded: (composition) {
                  // Delay navigation until the animation is complete
                  Future.delayed(composition.duration, () async {
                    // Run the prediction
                    try {
                      _interpreter!.run(inputTensor, outputTensor);
                      var output = outputTensor.buffer.asFloat32List();
                      print('Output Values: $output');

                      if (output.length != _labels.length) {
                        print(
                            'Output length (${output.length}) does not match the number of labels (${_labels.length})');
                        return;
                      }

                      int predictedIndex = output.indexWhere((value) =>
                          value ==
                          output.reduce(
                              (curr, next) => curr > next ? curr : next));
                      print('Predicted Index: $predictedIndex');

                      setState(() {
                        _predictionResult = _labels[predictedIndex];
                      });

                      Navigator.pop(
                          context); // Dismiss the loading animation dialog

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultPage(
                            result: _predictionResult!,
                          ),
                        ),
                      );
                    } catch (e) {
                      print('Error running model: $e');
                      Navigator.pop(
                          context); // Dismiss the loading animation dialog
                    }
                  });
                },
              ),
              SizedBox(height: 20),
              Text(
                'Processing...',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Enter Data',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 17, 17, 17),
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<void>(
        future: _loadModelFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error loading model: ${snapshot.error}'));
          } else {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: hemoglobinController,
                        decoration: InputDecoration(
                            labelText: 'Enter Hemoglobin value'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Hemoglobin value';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: redBloodCellsController,
                        decoration: InputDecoration(
                            labelText: 'Enter Red Blood Cells value'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Red Blood Cells value';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: whiteBloodCellsController,
                        decoration: InputDecoration(
                            labelText: 'Enter White Blood Cells value'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter White Blood Cells value';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 30),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Differential Values:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: neutrophilsController,
                        decoration: InputDecoration(
                            labelText: 'Enter Neutrophils value'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Neutrophils value';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: eosinophilsController,
                        decoration: InputDecoration(
                            labelText: 'Enter Eosinophils value'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Eosinophils value';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: monocytesController,
                        decoration:
                            InputDecoration(labelText: 'Enter Monocytes value'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Monocytes value';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: basophilsController,
                        decoration:
                            InputDecoration(labelText: 'Enter Basophils value'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Basophils value';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 50),
                      TextFormField(
                        controller: hematocritController,
                        decoration: InputDecoration(
                            labelText: 'Enter Hematocrit value'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Hematocrit value';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: mcvController,
                        decoration:
                            InputDecoration(labelText: 'Enter MCV value'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter MCV value';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: mchController,
                        decoration:
                            InputDecoration(labelText: 'Enter MCH value'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter MCH value';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: mchcController,
                        decoration:
                            InputDecoration(labelText: 'Enter MCHC value'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter MCHC value';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: rdwController,
                        decoration:
                            InputDecoration(labelText: 'Enter RDW value'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter RDW value';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            predict();
                          }
                        },
                        child: Text('Submit'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

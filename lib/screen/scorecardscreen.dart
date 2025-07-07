// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/inspection_provider.dart';
import '../widget/inputscore.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ScorecardScreen extends StatefulWidget {
  const ScorecardScreen({super.key});

  @override
  State<ScorecardScreen> createState() => _ScorecardScreenState();
}

class _ScorecardScreenState extends State<ScorecardScreen> {
  final TextEditingController _stationController = TextEditingController();
  final TextEditingController _trainController = TextEditingController();
  final TextEditingController _inspectorController = TextEditingController();
  DateTime? _selectedDate;

  List<String> coaches = List.generate(13, (i) => "C${i + 1}");
  List<String> sections = ['T1', 'T2', 'T3', 'T4', 'D1', 'D2', 'B1', 'B2'];
  List<String> platform = [
    "P-Cleanliness",
    "P-Urinals",
    "P-WaterBooth",
    "P-Dustbin",
    "P-CirculatingArea"
  ];
  Future<void> _generatePdf() async {
    if (await Permission.storage.request().isGranted) {
      final document = PdfDocument();
      final page = document.pages.add();

      page.graphics.drawString(
        'Train Cleanliness Scorecard',
        PdfStandardFont(PdfFontFamily.helvetica, 18),
      );

      final StringBuffer buffer = StringBuffer()
        ..writeln("Station: ${_stationController.text}")
        ..writeln("Train No: ${_trainController.text}")
        ..writeln("Inspector: ${_inspectorController.text}")
        ..writeln(
            "Date: ${_selectedDate != null ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}" : "Not selected"}");

      page.graphics.drawString(
        buffer.toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: const Rect.fromLTWH(0, 40, 500, 400),
      );

      final bytes = await document.save();
      document.dispose();

      final dir = await getExternalStorageDirectory();
      final path = '${dir!.path}/TrainScorecard.pdf';
      final file = File(path);
      await file.writeAsBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved at: $path')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied.')),
      );
    }
  }

  Future<void> _submitForm() async {
    final provider = Provider.of<InspectionProvider>(context, listen: false);

    final data = {
      "station_name": _stationController.text.trim(),
      "train_no": _trainController.text.trim(),
      "inspection_date": _selectedDate?.toIso8601String() ?? '',
      "inspector": _inspectorController.text.trim(),
      "scores": provider.toJson(),
    };

    try {
      final response = await http.post(
        Uri.parse("https://httpbin.org/post"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Form submitted successfully!")),
        );
        print("Response: ${response.body}"); //to showcase the json object
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  XFile? _imageFile;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Select Image Source"),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            icon: const Icon(Icons.camera),
            label: const Text("Camera"),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            icon: const Icon(Icons.photo),
            label: const Text("Gallery"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Clean Train Scorecard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            tooltip: "Upload Photo",
            onPressed: () => _showImageSourceDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: "Export to PDF",
            onPressed: _generatePdf,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: width > 600 ? 600 : width,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Basic Details",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _stationController,
                            decoration: const InputDecoration(
                              labelText: "Station Name",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _trainController,
                            decoration: const InputDecoration(
                              labelText: "Train Number",
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _inspectorController,
                            decoration: const InputDecoration(
                              labelText: "Inspector Name",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.date_range, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _selectedDate == null
                                      ? "Date of Inspection: Not selected"
                                      : "Date of Inspection: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                                ),
                              ),
                              TextButton(
                                child: const Text("Pick Date"),
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                    initialDate: DateTime.now(),
                                  );
                                  if (picked != null) {
                                    setState(() => _selectedDate = picked);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(thickness: 1.5),
                  const Text("Coach-wise Inspection",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  ...coaches.map((coach) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ExpansionTile(
                        title: Text("Coach $coach"),
                        children: sections
                            .map((sec) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0, vertical: 4.0),
                                  child: ScoreInput(id: "$coach-$sec"),
                                ))
                            .toList(),
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                  const Text("Platform Parameters",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  ...platform.map((id) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 4.0),
                        child: ScoreInput(id: id),
                      )),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.send_rounded),
                      label: const Text("Submit"),
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (_imageFile != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Image.file(
                        File(_imageFile!.path),
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

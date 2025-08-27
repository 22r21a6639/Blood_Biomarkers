import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lottie/lottie.dart';
import 'result.dart'; // Import the ResultPage

class UploadCbpReportPage extends StatefulWidget {
  @override
  _UploadCbpReportPageState createState() => _UploadCbpReportPageState();
}

class _UploadCbpReportPageState extends State<UploadCbpReportPage> {
  PlatformFile? selectedFile;
  bool isUploading = false;
  double uploadProgress = 0;

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        selectedFile = result.files.first;
      });
    } else {
      // User canceled the picker
      print('File picking canceled');
    }
  }

  Future<void> _submitFile() async {
    if (selectedFile != null) {
      setState(() {
        isUploading = true;
        uploadProgress = 0;
      });

      // Simulate file upload and update progress
      for (int i = 1; i <= 10; i++) {
        await Future.delayed(Duration(milliseconds: 300));
        setState(() {
          uploadProgress = i / 10;
        });
      }

      setState(() {
        isUploading = false;
      });

      print('File submitted: ${selectedFile!.name}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File submitted: ${selectedFile!.name}')),
      );
    } else {
      print('No file selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload CBP Report'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickFile,
              child: Text('Choose Your File'),
            ),
            if (selectedFile != null) ...[
              SizedBox(
                  height: 20), // Add space between the button and the file info
              Text('Selected file: ${selectedFile!.name}'),
              SizedBox(
                  height:
                      20), // Add space between the file info and the submit button
              ElevatedButton(
                onPressed: _submitFile,
                child: Text('Submit'),
              ),
              if (isUploading) ...[
                SizedBox(height: 20),
                LinearProgressIndicator(
                  value: uploadProgress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                SizedBox(height: 10),
                Text('${(uploadProgress * 100).toInt()}% uploaded'),
              ],
            ],
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoadingScreen(),
                  ),
                );
              },
              child: Text('View Results'),
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  final Future<void> _loadDataFuture = Future<void>(() async {
    // Simulate a delay for loading
    await Future.delayed(Duration(seconds: 3));
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _loadDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the future is complete, navigate to the ResultPage
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ResultPage()),
              );
            });
            return Container(); // Return an empty container while navigating
          } else {
            // While the future is loading, show the animation
            return Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: Lottie.asset('assets/animation1.json'),
              ),
            );
          }
        },
      ),
    );
  }
}

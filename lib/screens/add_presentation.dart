import 'dart:typed_data'; // For handling bytes
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPresentationScreen extends StatefulWidget {
  const AddPresentationScreen({super.key});

  @override
  State<AddPresentationScreen> createState() => _AddPresentationScreenState();
}

class _AddPresentationScreenState extends State<AddPresentationScreen> {
  final TextEditingController _titleController = TextEditingController();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Uint8List? _selectedFileBytes;
  String? _selectedFileName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Presentation"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload PDF widget
            Card(
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Upload a Presentation",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: "Enter Title for the PDF",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _selectFile,
                          child: const Text("Select PDF"),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _uploadFile,
                          child: const Text("Upload PDF"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_selectedFileName != null)
                      Text("Selected File: $_selectedFileName"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // List of uploaded PDFs
            const Text(
              "Uploaded Presentations",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('presentations').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("No presentations uploaded yet."),
                    );
                  }

                  final presentations = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: presentations.length,
                    itemBuilder: (context, index) {
                      final presentation = presentations[index];
                      return ListTile(
                        title: Text(presentation['title']),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteFile(presentation.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true, // Required for web to get file bytes
      );

      if (result != null) {
        setState(() {
          _selectedFileBytes = result.files.single.bytes;
          _selectedFileName = result.files.single.name;
        });

        print("File selected: $_selectedFileName");
        print("Selected file size: ${_selectedFileBytes?.lengthInBytes} bytes");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("File selected successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No file selected.")),
        );
      }
    } catch (e) {
      print("Error selecting file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to select file: $e")),
      );
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFileBytes == null || _selectedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a file first.")),
      );
      return;
    }

    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide a title for the PDF.")),
      );
      return;
    }

    try {
      print("Starting upload for file: $_selectedFileName");
      final ref = _storage.ref().child('presentations/$_selectedFileName');
      print("Storage reference created.");

      final uploadTask = ref.putData(_selectedFileBytes!);

      // Track progress and errors
      uploadTask.snapshotEvents.listen(
        (event) {
          final progress = (event.bytesTransferred / event.totalBytes) * 100;
          print("Progress: $progress%");
        },
        onError: (e) {
          print("Error during upload: $e");
        },
      );

      await uploadTask.whenComplete(() {
        print("Upload task completed.");
      });

      final fileUrl = await ref.getDownloadURL();
      print("File uploaded. URL: $fileUrl");

      // Add metadata to Firestore
      await _firestore.collection('presentations').add({
        'title': _titleController.text,
        'url': fileUrl,
        'uploadedAt': Timestamp.now(),
      });
      print("File metadata added to Firestore.");

      setState(() {
        _selectedFileBytes = null;
        _selectedFileName = null;
      });

      _titleController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PDF uploaded successfully!")),
      );
    } catch (e) {
      print("Error during upload: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload PDF: $e")),
      );
    }
  }

  Future<void> _deleteFile(String docId) async {
    try {
      final doc = await _firestore.collection('presentations').doc(docId).get();
      final fileUrl = doc['url'];

      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();

      await _firestore.collection('presentations').doc(docId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PDF deleted successfully.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete PDF: $e")),
      );
    }
  }
}

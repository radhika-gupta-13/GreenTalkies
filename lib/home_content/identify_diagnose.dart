import 'dart:io';
import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:greentalkies/profile/service/gemini_service.dart';

class IdentifyDiagnosePage extends StatefulWidget {
  const IdentifyDiagnosePage({super.key});

  @override
  State<IdentifyDiagnosePage> createState() => _IdentifyDiagnosePageState();
}

class _IdentifyDiagnosePageState extends State<IdentifyDiagnosePage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  String? _resultText;
  bool _isLoading = false;
  bool _isDiagnose = false;

  late GeminiService _gemini;

  @override
  void initState() {
    super.initState();
    _initializeGemini();
  }

  /// ================= Initialize GeminiService with auto IP =================
  Future<void> _initializeGemini() async {
    if (!dotenv.isInitialized) await dotenv.load(fileName: ".env");

    _gemini = GeminiService(); // default constructor
    await _gemini.init(); // auto-detect IP or use .env
  }

  /// ================= Pick Image from Gallery and call API =================
  Future<void> _pickAndProcessImage({required bool isDiagnose}) async {
  try {
    // Pick image
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile == null) return;

    setState(() {
      _selectedImage = pickedFile; // keep as XFile
      _resultText = null;
      _isDiagnose = isDiagnose;
      _isLoading = true;
    });

    // Convert XFile -> File **only for API call**
    File fileForApi = File(pickedFile.path);

    // Call GeminiService
    String result;
    if (isDiagnose) {
      result = await _gemini.diagnosePlant(fileForApi);
    } else {
      result = await _gemini.identifyPlant(fileForApi);
    }

    setState(() {
      _resultText = result;
      _isLoading = false;
    });
  } catch (e) {
    setState(() => _isLoading = false);
    _showSnackBar('Error: $e');
  }
}

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: GTColors.lushGreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GTColors.secondaryBaseLight,
      appBar: AppBar(
        title: const Text(
          'Identify or Diagnose',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: GTColors.primaryBaseDark,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 60, 162, 65),
        elevation: 0,
        iconTheme: const IconThemeData(color: GTColors.primaryBaseDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'What can we help you identify today?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: GTColors.primaryBaseDark,
              ),
            ),
            const SizedBox(height: 30),
            _buildPhotoSubmissionSection(),
            if (_selectedImage != null) ...[
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_selectedImage!.path),
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: GTColors.lushGreen),
              )
            else if (_resultText != null) ...[
              const SizedBox(height: 20),
              _buildResultSection(_resultText!),
            ],
            const SizedBox(height: 30),
            const Divider(color: GTColors.darkText, thickness: 0.1),
            const SizedBox(height: 30),
            const Text(
              'Or, Search Manually',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: GTColors.primaryBaseDark,
              ),
            ),
            const SizedBox(height: 15),
            _buildManualSearchField(),
            const SizedBox(height: 40),
            _buildQuickTipsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSubmissionSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: GTColors.darkText.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.photo_library_outlined,
              color: GTColors.lushGreen, size: 50),
          const SizedBox(height: 10),
          const Text(
            'Select a photo of the plant or its issue',
            style: TextStyle(color: GTColors.darkText),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                'Identify',
                Icons.photo_library,
                () => _pickAndProcessImage(isDiagnose: false),
                GTColors.lushGreen,
              ),
              _buildActionButton(
                'Diagnose',
                Icons.healing_rounded,
                () => _pickAndProcessImage(isDiagnose: true),
                Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
          String label, IconData icon, VoidCallback onPressed, Color color) =>
      ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      );

  Widget _buildResultSection(String result) => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: GTColors.lushGreen, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: GTColors.darkText.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isDiagnose ? 'Diagnosis Result:' : 'Identification Result:',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: GTColors.primaryBaseDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              result,
              style: const TextStyle(
                  fontSize: 14, color: GTColors.darkText, height: 1.4),
            ),
          ],
        ),
      );

  Widget _buildManualSearchField() => TextField(
        decoration: InputDecoration(
          hintText: 'e.g. Monstera Deliciosa, Yellowing Leaves',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: GTColors.lushGreen, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: GTColors.darkText.withOpacity(0.3),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: GTColors.lushGreen, width: 2),
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.search, color: GTColors.lushGreen),
            onPressed: () => _showSnackBar('Searching manually...'),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onSubmitted: (value) => _showSnackBar('Searching for: $value'),
      );

  Widget _buildQuickTipsSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Tip for Diagnosis:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: GTColors.primaryBaseDark,
            ),
          ),
          const SizedBox(height: 10),
          _buildTipCard(
            'Take a clear, well-lit photo of the **entire plant** and a close-up of the **affected leaf** or area.',
            Icons.lightbulb_outline,
          ),
        ],
      );

  Widget _buildTipCard(String text, IconData icon) {
    final parts = text.split('**');
    final spans = <TextSpan>[];
    for (int i = 0; i < parts.length; i++) {
      spans.add(TextSpan(
        text: parts[i],
        style: TextStyle(
          fontWeight: i % 2 != 0 ? FontWeight.bold : FontWeight.normal,
          color: GTColors.darkText,
          fontSize: 14,
          height: 1.5,
        ),
      ));
    }
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: GTColors.lushGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: GTColors.lushGreen, size: 24),
          const SizedBox(width: 10),
          Expanded(child: RichText(text: TextSpan(children: spans))),
        ],
      ),
    );
  }
}

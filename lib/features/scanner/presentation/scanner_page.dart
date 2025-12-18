import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/features/scanner/presentation/receipt_edit_page.dart';
import 'package:mealtrack/features/scanner/service/text_recognition_service.dart';

class ScannerPage extends StatefulWidget {
  final ImagePicker _picker;
  final TextRecognitionService _textRecognitionService;

  ScannerPage({
    super.key,
    ImagePicker? picker,
    TextRecognitionService? textRecognitionService,
  }) : _picker = picker ?? ImagePicker(),
       _textRecognitionService =
           textRecognitionService ?? TextRecognitionService();

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  bool _isBusy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _buildBody()),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isBusy ? null : _processImageFromGallery,
              icon: const Icon(Icons.image_search),
              label: const Text('Galerie öffnen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isBusy) {
      return const Center(child: CircularProgressIndicator());
    }

    return const Center(
      child: Text(
        'Klicke auf den Button, um einen Beispielbeleg zu scannen.',
        textAlign: TextAlign.center,
      ),
    );
  }

  Future<void> _processImageFromGallery() async {
    setState(() {
      _isBusy = true;
    });

    try {
      final XFile? image = await widget._picker.pickImage(
        source: ImageSource.gallery,
      );
      if (image == null) return;

      final result = await widget._textRecognitionService.processImage(image);

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ReceiptEditPage(scannedItems: result),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Fehler bei der Texterkennung: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Fehler: ${e.toString()}')));
      }
    } finally {
      setState(() {
        _isBusy = false;
      });
    }
  }
}

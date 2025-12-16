import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/features/scanner/data/scanned_item.dart';
import 'package:mealtrack/features/scanner/service/text_recognition_service.dart';

class ScannerPage extends StatefulWidget {
  final ImagePicker _picker;
  final TextRecognitionService? _textRecognitionService;

  ScannerPage({
    super.key,
    ImagePicker? picker,
    TextRecognitionService? textRecognitionService,
  }) : _picker = picker ?? ImagePicker(),
       _textRecognitionService = textRecognitionService;

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  late final TextRecognitionService _textRecognitionService;
  bool _isBusy = false;
  List<ScannedItem> _scannedItems = [];

  @override
  void initState() {
    super.initState();
    _textRecognitionService =
        widget._textRecognitionService ?? TextRecognitionService();
  }

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
              onPressed: _isBusy ? null : _processImageFromGallary,
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

    if (_scannedItems.isNotEmpty) {
      return ListView.builder(
        itemCount: _scannedItems.length,
        itemBuilder: (context, index) {
          final item = _scannedItems[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              title: Text(item.name),
              subtitle: Text(
                'Menge: ${item.quantity} / Gewicht: ${item.weight ?? '-'}',
              ),
              trailing: Text('${item.totalPrice.toStringAsFixed(2)} €'),
            ),
          );
        },
      );
    }

    return const Center(
      child: Text(
        'Klicke auf den Button, um einen Beispielbeleg zu scannen.',
        textAlign: TextAlign.center,
      ),
    );
  }

  Future<void> _processImageFromGallary() async {
    setState(() {
      _isBusy = true;
      _scannedItems = [];
    });

    try {
      final XFile? image = await widget._picker.pickImage(
        source: ImageSource.gallery,
      );
      final result = await _textRecognitionService.processImage(image);

      setState(() {
        _scannedItems = result;
      });
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

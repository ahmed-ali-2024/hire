import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../logger/app_logger.dart';

abstract class CVParserService {
  Future<String> parseFile(PlatformFile file);
  String extractCandidateName(String text);
}

class CVParserServiceImpl implements CVParserService {
  const CVParserServiceImpl();

  @override
  Future<String> parseFile(PlatformFile file) async {
    try {
      AppLogger.instance.i('CVParserService: Parsing file ${file.name}');

      if (file.name == 'demo_cv.pdf') {
        return '''Ahmed Ali
Senior Flutter Developer
ahmed.ali@3aai.in
+966500000000

Summary:
Highly experienced Software Engineer with over 6 years of expertise in mobile application development, specializing in Flutter, Dart, and Cross-Platform Architecture. Strong background in clean architecture, state management (Bloc, Riverpod), and backend integration with Supabase, Firebase, and REST APIs. Passionate about building high-performance, fluid, and scalable user interfaces.

Experience:
- Senior Mobile Developer at TechCorp (2022 - Present)
  * Designed and built core features for enterprise Flutter applications with over 1,000,000 active users.
  * Optimized application startup time by 35% and introduced robust local caching mechanisms.
  * Mentored junior developers and established CI/CD pipelines using GitHub Actions.
- Flutter Developer at AppStudio (2020 - 2022)
  * Developed and launched 5+ cross-platform mobile applications for iOS and Android.
  * Worked closely with UI/UX designers to translate Figma designs into pixel-perfect Flutter layouts.

Skills:
Flutter, Dart, Clean Architecture, Bloc, RESTful APIs, Supabase, Git, Firebase, CI/CD, Agile.
''';
      }

      if (file.name.toLowerCase().endsWith('.pdf')) {
        final bytes = file.bytes;
        if (bytes == null) {
          AppLogger.instance.w('CVParserService: File bytes are null.');
          return '';
        }

        final PdfDocument document = PdfDocument(inputBytes: bytes);
        final PdfTextExtractor extractor = PdfTextExtractor(document);
        final String text = extractor.extractText();
        document.dispose();
        
        AppLogger.instance.i('CVParserService: Successfully parsed PDF, length: ${text.length}');
        return text;
      } else {
        // Fallback for non-pdf files or unimplemented formats (e.g. DOCX without library)
        AppLogger.instance.w('CVParserService: Unsupported file format for ${file.name}');
        return '';
      }
    } catch (e) {
      AppLogger.instance.e('CVParserService Error: $e');
      return '';
    }
  }

  @override
  String extractCandidateName(String text) {
    if (text.isEmpty) return 'Unknown Candidate';

    // Split by lines and search first few non-empty lines
    final lines = text.split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.isEmpty) return 'Unknown Candidate';

    // Take the first line as candidate name since names usually appear at the top.
    // Clean it slightly to ensure it doesn't contain email/phone symbols.
    final candidateLine = lines.first;
    if (candidateLine.contains('@') || candidateLine.length > 50 || candidateLine.contains('http')) {
      if (lines.length > 1) {
        final secondLine = lines[1];
        if (!secondLine.contains('@') && secondLine.length <= 50) {
          return secondLine;
        }
      }
      return 'Unknown Candidate';
    }

    return candidateLine;
  }
}

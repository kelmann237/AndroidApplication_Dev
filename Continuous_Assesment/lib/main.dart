import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' hide Border;

// ── Export feature imports ──
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// ══════════════════════════════════════════════════════════════════
//  LECTURER REQUIREMENT — main() DEMONSTRATION
//  Shows: lambda passed to custom higher-order function,
//         collection operations (filter, map, forEach)
// ══════════════════════════════════════════════════════════════════
void main() {
  // ── Sample data for demonstration ──
  final demoStudents = [
    Student(name: 'Alice',   registrationNumber: '21A001', courseTitle: 'Maths',   major: 'Science',  mark: 85),
    Student(name: 'Bob',     registrationNumber: '21A002', courseTitle: 'Physics', major: 'Science',  mark: 42),
    Student(name: 'Charlie', registrationNumber: '21A003', courseTitle: 'Maths',   major: 'Arts',     mark: 67),
    Student(name: 'Diana',   registrationNumber: '21A004', courseTitle: 'Biology', major: 'Medicine', mark: 91),
    Student(name: 'Eve',     registrationNumber: '21A005', courseTitle: 'Maths',   major: 'Science',  mark: 55),
  ];

  // ── 1. Validation function on data class ──
  print('=== Validation ===');
  for (final s in demoStudents) {
    final error = s.validate();
    print('${s.name}: ${error ?? "Valid"}');
  }

  // ── 2. Formatting function on data class ──
  print('\n=== Formatted Summary ===');
  for (final s in demoStudents) {
    print(s.formattedSummary());
  }

  // ── 3. Lambda passed to custom higher-order function ──
  //    applyToAll() is a custom higher-order function that
  //    accepts a lambda (Function) and applies it to each student
  print('\n=== Custom Higher-Order Function (applyToAll) ===');
  applyToAll(demoStudents, (s) => print('Processing: ${s.name} → Grade ${s.grade}'));

  // ── 4. Collection operations ──

  // filter: only students who passed
  final passed = demoStudents.where((s) => s.hasPassed()).toList();
  print('\n=== filter: passed students ===');
  passed.forEach((s) => print('  ${s.name} (${s.mark})'));

  // map: get a list of formatted grade strings
  final gradeStrings = demoStudents.map((s) => s.formattedSummary()).toList();
  print('\n=== map: formatted grade strings ===');
  gradeStrings.forEach(print);

  // forEach: print a warning for every failing student
  print('\n=== forEach: failing students warning ===');
  demoStudents
      .where((s) => !s.hasPassed())
      .forEach((s) => print('  ⚠ ${s.name} failed with ${s.mark}/100'));

  // ── 5. Collection.filter through StudentCollection class ──
  print('\n=== StudentCollection filter by major ===');
  final collection = StudentCollection(demoStudents);
  final scienceStudents = collection.filterBy((s) => s.major == 'Science');
  scienceStudents.forEach((s) => print('  ${s.name} — ${s.major}'));

  // ══════════════════════════════════════════════════════════════
  //  ★ ADDED NOTION 1 — LAMBDA FUNCTIONS
  //
  //  A lambda (anonymous function) is a nameless function
  //  defined inline and assigned to a variable or passed directly
  //  as an argument. Dart uses the  (params) => expr  or
  //  (params) { body; }  syntax.
  // ══════════════════════════════════════════════════════════════
  print('\n=== ★ Lambda Functions Demo ===');

  // Lambda stored in a variable — single-expression arrow form
  final gradeLabel = (Student s) => '${s.name} scored ${s.mark} → ${s.grade}';

  // Lambda stored in a variable — block-body form
  final printResult = (Student s) {
    final status = s.hasPassed() ? '✓ PASS' : '✗ FAIL';
    print('  $status | ${gradeLabel(s)}');
  };

  // Invoke the lambdas directly
  demoStudents.forEach(printResult);

  // Lambda passed inline to sort() — sorts ascending by mark
  final ascending = List<Student>.from(demoStudents)
    ..sort((a, b) => a.mark.compareTo(b.mark));
  print('\n  Sorted ascending by mark:');
  ascending.forEach((s) => print('    ${s.mark.toStringAsFixed(1)}  ${s.name}'));

  // ══════════════════════════════════════════════════════════════
  //  ★ ADDED NOTION 2 — HIGHER-ORDER FUNCTIONS
  //
  //  A higher-order function either:
  //    (a) accepts one or more functions as parameters, OR
  //    (b) returns a function as its result.
  //
  //  Three new standalone higher-order functions are defined
  //  below main() (see HOF section). Here we call them.
  // ══════════════════════════════════════════════════════════════
  print('\n=== ★ Higher-Order Functions Demo ===');

  // (a) transformAll — takes a list and a transform lambda,
  //     returns a new list (accepts a function, returns data)
  final names = transformAll<Student, String>(
    demoStudents,
        (s) => s.name.toUpperCase(),
  );
  print('  transformAll (names uppercased): $names');

  // (b) countWhere — takes a predicate lambda, returns an int
  final highAchievers = countWhere(demoStudents, (s) => s.mark >= 75);
  print('  countWhere mark >= 75: $highAchievers students');

  // (c) makeGreetingFor — RETURNS a lambda (function factory)
  final greetScience = makeGreetingFor('Science');
  final greetMedicine = makeGreetingFor('Medicine');
  demoStudents.forEach((s) {
    if (s.major == 'Science')  print('  ${greetScience(s)}');
    if (s.major == 'Medicine') print('  ${greetMedicine(s)}');
  });

  // ══════════════════════════════════════════════════════════════
  //  ★ ADDED NOTION 3 — OBJECT-ORIENTED PROGRAMMING (OOP)
  //
  //  Four fundamental OOP pillars demonstrated with new classes:
  //
  //  1. ENCAPSULATION — GradeBook wraps private state and exposes
  //     controlled access through getters / methods only.
  //
  //  2. INHERITANCE   — HonoursStudent extends Student, inheriting
  //     all fields and methods, and overrides grade/remark logic.
  //
  //  3. POLYMORPHISM  — A List<Student> holds both Student and
  //     HonoursStudent objects; grade/remark calls dispatch to
  //     the correct override at runtime.
  //
  //  4. ABSTRACTION   — GradeCalculator is an abstract class that
  //     defines a contract (interface); ConcreteGradeCalculator
  //     provides the implementation.
  // ══════════════════════════════════════════════════════════════
  print('\n=== ★ OOP Demo ===');

  // --- ENCAPSULATION ---
  print('\n  -- Encapsulation (GradeBook) --');
  final book = GradeBook(courseName: 'Advanced Maths');
  book.enroll(demoStudents[0]); // Alice  85
  book.enroll(demoStudents[3]); // Diana  91
  print('  Course   : ${book.courseName}');
  print('  Enrolled : ${book.studentCount} students');
  print('  Top mark : ${book.topMark}');
  // book._students is private — cannot be accessed from outside GradeBook

  // --- INHERITANCE ---
  print('\n  -- Inheritance (HonoursStudent extends Student) --');
  final honours = HonoursStudent(
    name: 'Frank',
    registrationNumber: '21H001',
    courseTitle: 'Maths',
    major: 'Science',
    mark: 88,
    thesisTitle: 'Algebraic Topology',
  );
  print('  ${honours.formattedSummary()}');
  print('  Thesis: ${honours.thesisTitle}');
  print('  Honours grade remark: ${honours.gradeRemark()}');

  // --- POLYMORPHISM ---
  print('\n  -- Polymorphism (Student list with mixed runtime types) --');
  final mixedList = <Student>[
    demoStudents[0], // plain Student
    honours,         // HonoursStudent — overrides grade/remark
  ];
  for (final s in mixedList) {
    // Same method call; Dart dispatches to the correct override
    print('  ${s.runtimeType}: ${s.name} → ${s.grade} | ${s.gradeRemark()}');
  }

  // --- ABSTRACTION ---
  print('\n  -- Abstraction (GradeCalculator interface) --');
  final GradeCalculator calc = ConcreteGradeCalculator();
  for (final s in demoStudents) {
    print('  ${s.name}: calculated grade = ${calc.calculate(s.mark)}');
  }

  // Run the Flutter app
  runApp(const GradeApp());
}

// ══════════════════════════════════════════════════════════════════
//  CUSTOM HIGHER-ORDER FUNCTION
//  Accepts a list of students and a lambda Function(Student)
// ══════════════════════════════════════════════════════════════════
void applyToAll(List<Student> students, void Function(Student) action) {
  for (final student in students) {
    action(student);
  }
}

// ══════════════════════════════════════════════════════════════════
//  ★ ADDED — HIGHER-ORDER FUNCTION DEFINITIONS
//
//  These three functions are referenced in the HOF demo above.
// ══════════════════════════════════════════════════════════════════

/// (a) transformAll — accepts a transform lambda, returns a new list.
///     Generic so it works with any input/output types.
List<R> transformAll<T, R>(List<T> items, R Function(T) transform) =>
    items.map(transform).toList();

/// (b) countWhere — accepts a predicate lambda, returns a count.
int countWhere<T>(List<T> items, bool Function(T) predicate) =>
    items.where(predicate).length;

/// (c) makeGreetingFor — RETURNS a lambda (function factory pattern).
///     Demonstrates a higher-order function that produces a function.
String Function(Student) makeGreetingFor(String major) {
  // The returned lambda closes over [major] — this is a closure
  return (Student s) => 'Hello ${s.name}, welcome to the $major department!';
}

// ══════════════════════════════════════════════════════════════════
//  ★ ADDED — OOP CLASS DEFINITIONS
// ══════════════════════════════════════════════════════════════════

// ── ENCAPSULATION ────────────────────────────────────────────────
/// GradeBook hides its internal list behind a private field.
/// External code can only interact through the public API.
class GradeBook {
  final String courseName;
  final List<Student> _students = []; // private — not accessible outside

  GradeBook({required this.courseName});

  // Controlled write access
  void enroll(Student s) => _students.add(s);

  // Controlled read access via getters — no direct field exposure
  int get studentCount => _students.length;

  double get topMark =>
      _students.isEmpty ? 0 : _students.map((s) => s.mark).reduce((a, b) => a > b ? a : b);

  List<String> get summary =>
      _students.map((s) => s.formattedSummary()).toList();
}

// ── INHERITANCE ──────────────────────────────────────────────────
/// HonoursStudent IS-A Student (extends it).
/// It inherits all fields and methods, adds thesisTitle,
/// and overrides gradeRemark() with honours-specific logic.
class HonoursStudent extends Student {
  final String thesisTitle;

  HonoursStudent({
    required super.name,
    required super.registrationNumber,
    required super.courseTitle,
    required super.major,
    required super.mark,
    required this.thesisTitle,
  });

  // Override — polymorphic dispatch will call this version
  @override
  String gradeRemark() {
    if (mark >= 80) return 'Honours — First Class';
    if (mark >= 70) return 'Honours — Upper Second';
    if (mark >= 60) return 'Honours — Lower Second';
    return 'Honours — Third Class';
  }

  // Override formattedSummary to include thesis info
  @override
  String formattedSummary() =>
      '[HONOURS] ${super.formattedSummary()} | Thesis: $thesisTitle';
}

// ── ABSTRACTION ──────────────────────────────────────────────────
/// Abstract class defines WHAT a grade calculator must do,
/// without specifying HOW. Callers depend on the abstraction,
/// not on any concrete implementation.
abstract class GradeCalculator {
  String calculate(double mark); // contract — must be implemented
}

/// ConcreteGradeCalculator provides one specific implementation.
/// A different implementation (e.g. weighted grading) could be
/// swapped in without changing any calling code.
class ConcreteGradeCalculator implements GradeCalculator {
  @override
  String calculate(double mark) => getGrade(mark); // delegates to existing helper
}

// ══════════════════════════════════════════════════════════════════
//  GRADE LOGIC
// ══════════════════════════════════════════════════════════════════
String getGrade(double mark) {
  if (mark >= 90) return 'A+';
  if (mark >= 80) return 'A';
  if (mark >= 75) return 'B+';
  if (mark >= 70) return 'B';
  if (mark >= 65) return 'C+';
  if (mark >= 60) return 'C';
  if (mark >= 55) return 'D+';
  if (mark >= 50) return 'D';
  return 'F';
}

Color gradeColor(String grade) {
  switch (grade) {
    case 'A+':
    case 'A':
      return Colors.green.shade700;
    case 'B+':
    case 'B':
      return Colors.blue.shade700;
    case 'C+':
    case 'C':
      return Colors.orange.shade700;
    case 'D+':
    case 'D':
      return Colors.deepOrange.shade700;
    default:
      return Colors.red.shade700;
  }
}

// ══════════════════════════════════════════════════════════════════
//  DATA CLASS — Student
//  Includes required functions: validate(), formattedSummary(),
//  hasPassed(), and computed property grade
// ══════════════════════════════════════════════════════════════════
class Student {
  final String name;
  final String registrationNumber;
  final String courseTitle;
  final String major;
  final double mark;

  // Computed property
  String get grade => getGrade(mark);

  Student({
    required this.name,
    required this.registrationNumber,
    required this.courseTitle,
    required this.major,
    required this.mark,
  });

  // ── FUNCTION 1: Validation ──
  // Returns null if valid, or an error message string if invalid
  String? validate() {
    if (name.trim().isEmpty) return 'Name cannot be empty';
    if (registrationNumber.trim().isEmpty) return 'Registration number cannot be empty';
    if (courseTitle.trim().isEmpty) return 'Course title cannot be empty';
    if (major.trim().isEmpty) return 'Major cannot be empty';
    if (mark < 0 || mark > 100) return 'Mark must be between 0 and 100';
    return null; // valid
  }

  // ── FUNCTION 2: Formatting ──
  // Returns a human-readable one-line summary of the student
  String formattedSummary() {
    return '[${registrationNumber}] ${name} | ${courseTitle} | '
        '${mark.toStringAsFixed(1)}/100 → Grade: ${grade}';
  }

  // ── FUNCTION 3: Pass/Fail check ──
  bool hasPassed() => mark >= 50;

  // ── FUNCTION 4: Grade remark ──
  String gradeRemark() {
    if (mark >= 90) return 'Excellent';
    if (mark >= 75) return 'Very Good';
    if (mark >= 60) return 'Good';
    if (mark >= 50) return 'Satisfactory';
    return 'Fail — Needs Improvement';
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'registrationNumber': registrationNumber,
    'courseTitle': courseTitle,
    'major': major,
    'mark': mark,
  };

  factory Student.fromMap(Map<String, dynamic> m) => Student(
    name: m['name'],
    registrationNumber: m['registrationNumber'],
    courseTitle: m['courseTitle'],
    major: m['major'],
    mark: m['mark'],
  );
}

// ══════════════════════════════════════════════════════════════════
//  COLLECTION CLASS — StudentCollection
//  Wraps a list and provides higher-order collection methods
// ══════════════════════════════════════════════════════════════════
class StudentCollection {
  final List<Student> _students;

  StudentCollection(this._students);

  // Higher-order filter: accepts a lambda predicate
  List<Student> filterBy(bool Function(Student) predicate) =>
      _students.where(predicate).toList();

  // Higher-order map: transform each student into something else
  List<T> mapTo<T>(T Function(Student) transform) =>
      _students.map(transform).toList();

  // Higher-order forEach
  void forEach(void Function(Student) action) =>
      _students.forEach(action);

  // Average mark
  double get averageMark =>
      _students.isEmpty ? 0 : _students.fold(0.0, (sum, s) => sum + s.mark) / _students.length;

  // Count passed
  int get passedCount => _students.where((s) => s.hasPassed()).length;

  // Count failed
  int get failedCount => _students.length - passedCount;

  // Sort by mark descending
  List<Student> get sortedByMark =>
      List.from(_students)..sort((a, b) => b.mark.compareTo(a.mark));

  int get length => _students.length;
}

// ══════════════════════════════════════════════════════════════════
//  GLOBAL SAVE STORE
// ══════════════════════════════════════════════════════════════════
class SavedRecord {
  final String id;
  final String title;
  final String savedAt;
  final bool isBatch;
  final List<Student> students;

  SavedRecord({
    required this.id,
    required this.title,
    required this.savedAt,
    required this.isBatch,
    required this.students,
  });
}

class SaveStore {
  static final List<SavedRecord> _records = [];

  static List<SavedRecord> get all => List.unmodifiable(_records);

  static void add(SavedRecord record) => _records.insert(0, record);

  static void delete(String id) =>
      _records.removeWhere((r) => r.id == id);

  static String _now() {
    final d = DateTime.now();
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}  '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }

  static void saveSingle(Student s) {
    add(SavedRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: s.name,
      savedAt: _now(),
      isBatch: false,
      students: [s],
    ));
  }

  static void saveBatch(List<Student> students, String fileName) {
    add(SavedRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Batch – ${students.length} students  ($fileName)',
      savedAt: _now(),
      isBatch: true,
      students: List.from(students),
    ));
  }
}

// ══════════════════════════════════════════════════════════════════
//  REPORT BUILDERS
// ══════════════════════════════════════════════════════════════════
String buildSingleReport(Student s) => '''====================================
       GRADE REPORT
====================================
Name               : ${s.name}
Registration No.   : ${s.registrationNumber}
Course Title       : ${s.courseTitle}
Major / Department : ${s.major}
Mark               : ${s.mark.toStringAsFixed(1)} / 100
Grade              : ${s.grade}
Remark             : ${s.gradeRemark()}
====================================''';

String buildBatchReport(List<Student> students) {
  final col = StudentCollection(students);
  final buf = StringBuffer();
  buf.writeln('====================================');
  buf.writeln('       BATCH GRADE REPORT');
  buf.writeln('====================================');
  buf.writeln('Total Students : ${col.length}');
  buf.writeln('Average Mark   : ${col.averageMark.toStringAsFixed(1)} / 100');
  buf.writeln('Passed         : ${col.passedCount}');
  buf.writeln('Failed         : ${col.failedCount}');
  buf.writeln('====================================\n');
  // Use higher-order forEach via StudentCollection
  col.forEach((s) {
    buf.writeln('--- ${s.name} ---');
    buf.writeln('Registration No.   : ${s.registrationNumber}');
    buf.writeln('Course Title       : ${s.courseTitle}');
    buf.writeln('Major / Department : ${s.major}');
    buf.writeln('Mark               : ${s.mark.toStringAsFixed(1)} / 100');
    buf.writeln('Grade              : ${s.grade}');
    buf.writeln('Remark             : ${s.gradeRemark()}');
    buf.writeln();
  });
  buf.writeln('====================================');
  return buf.toString();
}

// ══════════════════════════════════════════════════════════════════
//  EXPORT SERVICE
//  Generates .txt and .pdf files and shares them via share_plus.
// ══════════════════════════════════════════════════════════════════
class ExportService {
  // ── Export as plain .txt ──────────────────────────────────────
  // ── Export as plain .txt ──────────────────────────────────────
  // Uses XFile.fromData — no file system / path_provider needed
  static Future<void> exportTxt(
      BuildContext context, String reportText, String fileName) async {
    try {
      final bytes = Uint8List.fromList(reportText.codeUnits);
      final xfile = XFile.fromData(
        bytes,
        name: '$fileName.txt',
        mimeType: 'text/plain',
      );
      final result = await Share.shareXFiles(
        [xfile],
        subject: fileName,
      );
      if (context.mounted) {
        if (result.status == ShareResultStatus.success) {
          _showSnack(context, '✓ TXT exported successfully', Colors.green);
        } else if (result.status == ShareResultStatus.dismissed) {
          _showSnack(context, 'Export cancelled', Colors.orange);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showSnack(context, 'TXT export failed: $e', Colors.red);
      }
    }
  }

  // ── Export as styled .pdf ─────────────────────────────────────
  // Uses XFile.fromData — no file system / path_provider needed
  static Future<void> exportPdf(
      BuildContext context, SavedRecord record) async {
    try {
      final doc = pw.Document();
      if (record.isBatch) {
        _buildBatchPdf(doc, record);
      } else {
        _buildSinglePdf(doc, record.students.first);
      }

      final bytes = await doc.save();
      final fileName = record.isBatch
          ? 'batch_report_${record.id}'
          : '${record.students.first.name.replaceAll(' ', '_')}_report';

      final xfile = XFile.fromData(
        Uint8List.fromList(bytes),
        name: '$fileName.pdf',
        mimeType: 'application/pdf',
      );
      final result = await Share.shareXFiles(
        [xfile],
        subject: fileName,
      );
      if (context.mounted) {
        if (result.status == ShareResultStatus.success) {
          _showSnack(context, '✓ PDF exported successfully', Colors.green);
        } else if (result.status == ShareResultStatus.dismissed) {
          _showSnack(context, 'Export cancelled', Colors.orange);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showSnack(context, 'PDF export failed: $e', Colors.red);
      }
    }
  }

  static void _showSnack(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color,
          duration: const Duration(seconds: 3)),
    );
  }

  // ── PDF builder — single student ─────────────────────────────
  static void _buildSinglePdf(pw.Document doc, Student s) {
    final gradeColor = _gradeHexColor(s.grade);
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header band
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: gradeColor,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('GRADE REPORT',
                          style: pw.TextStyle(
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white)),
                      pw.SizedBox(height: 4),
                      pw.Text(s.name,
                          style: const pw.TextStyle(
                              fontSize: 14, color: PdfColors.white)),
                    ],
                  ),
                  pw.Container(
                    width: 56,
                    height: 56,
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.white,
                      shape: pw.BoxShape.circle,
                    ),
                    child: pw.Center(
                      child: pw.Text(s.grade,
                          style: pw.TextStyle(
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                              color: gradeColor)),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 24),
            _pdfInfoRow('Registration No.', s.registrationNumber),
            _pdfDivider(),
            _pdfInfoRow('Course Title', s.courseTitle),
            _pdfDivider(),
            _pdfInfoRow('Major / Department', s.major),
            _pdfDivider(),
            _pdfInfoRow('Mark', '${s.mark.toStringAsFixed(1)} / 100'),
            _pdfDivider(),
            _pdfInfoRow('Grade', s.grade, valueColor: gradeColor),
            _pdfDivider(),
            _pdfInfoRow('Remark', s.gradeRemark()),
            pw.SizedBox(height: 32),
            pw.Center(
              child: pw.Text('Generated by Grade Manager',
                  style: const pw.TextStyle(
                      fontSize: 10, color: PdfColors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  // ── PDF builder — batch ───────────────────────────────────────
  static void _buildBatchPdf(pw.Document doc, SavedRecord record) {
    final col = StudentCollection(record.students);
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: const PdfColor(0.082, 0.396, 0.753),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('BATCH GRADE REPORT',
                      style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white)),
                  pw.SizedBox(height: 6),
                  pw.Text('Saved: ${record.savedAt}',
                      style: const pw.TextStyle(
                          fontSize: 11, color: PdfColors.grey)),
                ],
              ),
            ),
            pw.SizedBox(height: 24),
            pw.Row(children: [
              _pdfStatBox('Total', '${col.length}',
                  const PdfColor(0.082, 0.396, 0.753)),
              pw.SizedBox(width: 8),
              _pdfStatBox('Average', '${col.averageMark.toStringAsFixed(1)}%',
                  const PdfColor(0.416, 0.106, 0.604)),
              pw.SizedBox(width: 8),
              _pdfStatBox('Passed', '${col.passedCount}',
                  const PdfColor(0.18, 0.49, 0.196)),
              pw.SizedBox(width: 8),
              _pdfStatBox('Failed', '${col.failedCount}',
                  const PdfColor(0.776, 0.157, 0.157)),
            ]),
            pw.SizedBox(height: 28),
            // Table header
            pw.Container(
              color: const PdfColor(0.082, 0.396, 0.753),
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: pw.Row(children: [
                pw.Expanded(flex: 3, child: _pdfTableHeader('Name')),
                pw.Expanded(flex: 2, child: _pdfTableHeader('Reg. No.')),
                pw.Expanded(flex: 2, child: _pdfTableHeader('Course')),
                pw.Expanded(flex: 1, child: _pdfTableHeader('Mark')),
                pw.Expanded(flex: 1, child: _pdfTableHeader('Grade')),
              ]),
            ),
            // Table rows
            ...col.sortedByMark.asMap().entries.map((e) {
              final i = e.key;
              final s = e.value;
              final bg = i.isOdd
                  ? const PdfColor(0.961, 0.969, 0.98)
                  : PdfColors.white;
              return pw.Container(
                color: bg,
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                child: pw.Row(children: [
                  pw.Expanded(flex: 3, child: _pdfTableCell(s.name)),
                  pw.Expanded(flex: 2, child: _pdfTableCell(s.registrationNumber)),
                  pw.Expanded(flex: 2, child: _pdfTableCell(s.courseTitle)),
                  pw.Expanded(flex: 1, child: _pdfTableCell(s.mark.toStringAsFixed(1))),
                  pw.Expanded(
                      flex: 1,
                      child: pw.Text(s.grade,
                          style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: _gradeHexColor(s.grade)))),
                ]),
              );
            }),
            pw.SizedBox(height: 32),
            pw.Center(
              child: pw.Text('Generated by Grade Manager',
                  style: const pw.TextStyle(
                      fontSize: 10, color: PdfColors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  // ── PDF helpers ───────────────────────────────────────────────
  static pw.Widget _pdfInfoRow(String label, String value,
      {PdfColor? valueColor}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(children: [
        pw.SizedBox(
          width: 160,
          child: pw.Text(label,
              style: const pw.TextStyle(color: PdfColors.grey600)),
        ),
        pw.Expanded(
          child: pw.Text(value,
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, color: valueColor)),
        ),
      ]),
    );
  }

  static pw.Widget _pdfDivider() =>
      pw.Divider(height: 1, thickness: 0.5, color: PdfColors.grey300);

  static pw.Widget _pdfStatBox(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: color, width: 1),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(children: [
          pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: color)),
          pw.Text(label,
              style: pw.TextStyle(fontSize: 10, color: color)),
        ]),
      ),
    );
  }

  static pw.Widget _pdfTableHeader(String text) => pw.Text(text,
      style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white));

  static pw.Widget _pdfTableCell(String text) => pw.Text(text,
      style: const pw.TextStyle(fontSize: 10, color: PdfColors.black));

  // Maps grade letter to PdfColor (R, G, B as 0.0–1.0)
  static PdfColor _gradeHexColor(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return const PdfColor(0.18, 0.49, 0.196);
      case 'B+':
      case 'B':
        return const PdfColor(0.082, 0.396, 0.753);
      case 'C+':
      case 'C':
        return const PdfColor(0.902, 0.318, 0.0);
      case 'D+':
      case 'D':
        return const PdfColor(0.749, 0.212, 0.047);
      default:
        return const PdfColor(0.718, 0.11, 0.11);
    }
  }
}

// ══════════════════════════════════════════════════════════════════
//  APP ROOT
// ══════════════════════════════════════════════════════════════════
class GradeApp extends StatelessWidget {
  const GradeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grade Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
          ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      home: const HomePage(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  HOME PAGE
// ══════════════════════════════════════════════════════════════════
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.school, size: 28),
            SizedBox(width: 10),
            Text('Grade Manager',
                style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const SavedRecordsPage()),
            ).then((_) => setState(() {})),
            icon: const Icon(Icons.folder_open, color: Colors.white),
            label: const Text('Saved Info',
                style: TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.person_add), text: 'Single Student'),
            Tab(icon: Icon(Icons.upload_file), text: 'Import Excel'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SingleStudentTab(onSaved: () => setState(() {})),
          ExcelImportTab(onSaved: () => setState(() {})),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  TAB 1 — SINGLE STUDENT
// ══════════════════════════════════════════════════════════════════
class SingleStudentTab extends StatefulWidget {
  final VoidCallback onSaved;
  const SingleStudentTab({super.key, required this.onSaved});

  @override
  State<SingleStudentTab> createState() => _SingleStudentTabState();
}

class _SingleStudentTabState extends State<SingleStudentTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _regCtrl = TextEditingController();
  final _courseCtrl = TextEditingController();
  final _majorCtrl = TextEditingController();
  final _markCtrl = TextEditingController();
  Student? _result;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final student = Student(
        name: _nameCtrl.text.trim(),
        registrationNumber: _regCtrl.text.trim(),
        courseTitle: _courseCtrl.text.trim(),
        major: _majorCtrl.text.trim(),
        mark: double.parse(_markCtrl.text.trim()),
      );
      // Use validate() function from data class
      final error = student.validate();
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
        return;
      }
      setState(() => _result = student);
    }
  }

  void _reset() {
    _formKey.currentState!.reset();
    _nameCtrl.clear();
    _regCtrl.clear();
    _courseCtrl.clear();
    _majorCtrl.clear();
    _markCtrl.clear();
    setState(() => _result = null);
  }

  void _save() {
    if (_result == null) return;
    SaveStore.saveSingle(_result!);
    widget.onSaved();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_result!.name}\'s result saved!'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SavedRecordsPage())),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Form card
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Student Information',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildField(_nameCtrl, 'Full Name', Icons.person, false),
                    const SizedBox(height: 12),
                    _buildField(_regCtrl, 'Registration Number', Icons.badge, false),
                    const SizedBox(height: 12),
                    _buildField(_courseCtrl, 'Course Title', Icons.book, false),
                    const SizedBox(height: 12),
                    _buildField(_majorCtrl, 'Major / Department', Icons.school, false),
                    const SizedBox(height: 12),
                    _buildField(_markCtrl, 'Mark (0 – 100)', Icons.grade, true),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _submit,
                            icon: const Icon(Icons.check_circle),
                            label: const Text('OKAY',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1565C0),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: _reset,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reset'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Result card
          if (_result != null) ...[
            const SizedBox(height: 20),
            StudentResultCard(student: _result!),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Save Result',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SavedRecordsPage()),
                ),
                icon: const Icon(Icons.folder_open,
                    color: Color(0xFF1565C0)),
                label: const Text('Show Saved Info',
                    style: TextStyle(
                        fontSize: 16, color: Color(0xFF1565C0))),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(
                      color: Color(0xFF1565C0), width: 2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label,
      IconData icon, bool isNumber) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1565C0)),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Please enter $label';
        if (isNumber) {
          final n = double.tryParse(v.trim());
          if (n == null) return 'Enter a valid number';
          if (n < 0 || n > 100) return 'Mark must be between 0 and 100';
        }
        return null;
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  RESULT CARD
// ══════════════════════════════════════════════════════════════════
class StudentResultCard extends StatelessWidget {
  final Student student;
  const StudentResultCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final color = gradeColor(student.grade);
    return Card(
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Text(student.grade,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: color)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.name,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Text(student.registrationNumber,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ),
                Text('${student.mark.toStringAsFixed(1)}/100',
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _infoRow(Icons.book, 'Course', student.courseTitle),
                const Divider(height: 20),
                _infoRow(Icons.school, 'Major', student.major),
                const Divider(height: 20),
                _infoRow(Icons.grade, 'Grade', student.grade,
                    valueColor: color),
                const Divider(height: 20),
                // gradeRemark() function displayed in UI
                _infoRow(Icons.star, 'Remark', student.gradeRemark()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1565C0), size: 20),
        const SizedBox(width: 10),
        Text('$label: ',
            style: const TextStyle(
                color: Colors.grey, fontWeight: FontWeight.w500)),
        Expanded(
          child: Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: valueColor ?? Colors.black87)),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  TAB 2 — EXCEL IMPORT
// ══════════════════════════════════════════════════════════════════
class ExcelImportTab extends StatefulWidget {
  final VoidCallback onSaved;
  const ExcelImportTab({super.key, required this.onSaved});

  @override
  State<ExcelImportTab> createState() => _ExcelImportTabState();
}

class _ExcelImportTabState extends State<ExcelImportTab> {
  List<Student> _students = [];
  String? _fileName;
  String? _error;
  bool _loading = false;

  Future<void> _pickFile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );
      if (result == null || result.files.isEmpty) {
        setState(() => _loading = false);
        return;
      }
      final file = result.files.first;
      _fileName = file.name;
      final bytes = file.bytes ?? await File(file.path!).readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      final rawStudents = <Student>[];
      for (final table in excel.tables.values) {
        for (int i = 1; i < table.rows.length; i++) {
          final row = table.rows[i];
          if (row.length < 5) continue;
          final name     = row[0]?.value?.toString().trim() ?? '';
          final reg      = row[1]?.value?.toString().trim() ?? '';
          final course   = row[2]?.value?.toString().trim() ?? '';
          final major    = row[3]?.value?.toString().trim() ?? '';
          final markRaw  = row[4]?.value?.toString().trim() ?? '';
          if (name.isEmpty) continue;
          final mark = double.tryParse(markRaw) ?? 0.0;
          rawStudents.add(Student(
            name: name,
            registrationNumber: reg,
            courseTitle: course,
            major: major,
            mark: mark.clamp(0, 100),
          ));
        }
        break;
      }

      // Use StudentCollection + filter to keep only valid students
      final collection = StudentCollection(rawStudents);
      final validStudents = collection.filterBy((s) => s.validate() == null);

      setState(() {
        _students = validStudents;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error reading file: $e';
        _loading = false;
      });
    }
  }

  void _saveBatch() {
    if (_students.isEmpty) return;
    SaveStore.saveBatch(_students, _fileName ?? 'unknown');
    widget.onSaved();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_students.length} students saved!'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SavedRecordsPage())),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use StudentCollection for computed stats
    final collection = StudentCollection(_students);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.upload_file,
                      size: 48, color: Color(0xFF1565C0)),
                  const SizedBox(height: 12),
                  const Text('Upload an Excel file with student data',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 6),
                  Text(
                      'Columns: Name | Reg. Number | Course Title | Major | Mark',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _loading ? null : _pickFile,
                        icon: _loading
                            ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.folder_open),
                        label: Text(
                            _loading ? 'Loading...' : 'Choose File'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      if (_students.isNotEmpty) ...[
                        ElevatedButton.icon(
                          onPressed: _saveBatch,
                          icon: const Icon(Icons.save),
                          label: const Text('Save Results'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SavedRecordsPage()),
                          ),
                          icon: const Icon(Icons.folder_open,
                              color: Color(0xFF1565C0)),
                          label: const Text('Show Saved Info',
                              style:
                              TextStyle(color: Color(0xFF1565C0))),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            side: const BorderSide(
                                color: Color(0xFF1565C0), width: 2),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (_fileName != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 18),
                        const SizedBox(width: 6),
                        Text(_fileName!,
                            style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(_error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          if (_students.isNotEmpty) ...[
            // Stats using StudentCollection computed properties
            _StatsRowWidget(collection: collection),
            const SizedBox(height: 12),
            Text('${collection.length} valid students imported',
                style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Expanded(
              // sortedByMark from StudentCollection
              child: ListView.separated(
                itemCount: collection.length,
                separatorBuilder: (context, index) =>
                const SizedBox(height: 10),
                itemBuilder: (context, i) => StudentListTile(
                    student: collection.sortedByMark[i], index: i + 1),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  STATS ROW WIDGET  (uses StudentCollection properties)
// ══════════════════════════════════════════════════════════════════
class _StatsRowWidget extends StatelessWidget {
  final StudentCollection collection;
  const _StatsRowWidget({required this.collection});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _chip('Average',
            '${collection.averageMark.toStringAsFixed(1)}%',
            Colors.blue.shade700),
        const SizedBox(width: 8),
        _chip('Passed', '${collection.passedCount}',
            Colors.green.shade700),
        const SizedBox(width: 8),
        _chip('Failed', '${collection.failedCount}',
            Colors.red.shade700),
      ],
    );
  }

  Widget _chip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color)),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: color.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  STUDENT LIST TILE
// ══════════════════════════════════════════════════════════════════
class StudentListTile extends StatelessWidget {
  final Student student;
  final int index;
  const StudentListTile(
      {super.key, required this.student, required this.index});

  @override
  Widget build(BuildContext context) {
    final color = gradeColor(student.grade);
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color,
          child: Text(student.grade,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ),
        title: Text(student.name,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(
          '${student.registrationNumber}  •  ${student.courseTitle}  •  ${student.major}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${student.mark.toStringAsFixed(1)}/100',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15)),
            Text('Grade: ${student.grade}',
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  SAVED RECORDS PAGE
// ══════════════════════════════════════════════════════════════════
class SavedRecordsPage extends StatefulWidget {
  const SavedRecordsPage({super.key});

  @override
  State<SavedRecordsPage> createState() => _SavedRecordsPageState();
}

class _SavedRecordsPageState extends State<SavedRecordsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  List<SavedRecord> get _singles =>
      SaveStore.all.where((r) => !r.isBatch).toList();
  List<SavedRecord> get _batches =>
      SaveStore.all.where((r) => r.isBatch).toList();

  void _delete(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text(
            'Are you sure you want to delete this saved record?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              SaveStore.delete(id);
              Navigator.pop(ctx);
              setState(() {});
            },
            style:
            ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: const Text('Saved Records',
            style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(
                icon: const Icon(Icons.person),
                text: 'Individual (${_singles.length})'),
            Tab(
                icon: const Icon(Icons.groups),
                text: 'Batch (${_batches.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _buildList(_singles),
          _buildList(_batches),
        ],
      ),
    );
  }

  Widget _buildList(List<SavedRecord> records) {
    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text('No saved records yet',
                style: TextStyle(
                    color: Colors.grey.shade500, fontSize: 16)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _SavedRecordCard(
        record: records[i],
        onDelete: _delete,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  SavedRecordDetailPage(record: records[i])),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  SAVED RECORD CARD
// ══════════════════════════════════════════════════════════════════
class _SavedRecordCard extends StatelessWidget {
  final SavedRecord record;
  final void Function(String id) onDelete;
  final VoidCallback onTap;

  const _SavedRecordCard({
    required this.record,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
    record.isBatch ? const Color(0xFF1565C0) : Colors.green.shade700;
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(
                    record.isBatch ? Icons.groups : Icons.person,
                    color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(record.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(record.savedAt,
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => onDelete(record.id),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  SAVED RECORD DETAIL PAGE
// ══════════════════════════════════════════════════════════════════
class SavedRecordDetailPage extends StatefulWidget {
  final SavedRecord record;
  const SavedRecordDetailPage({super.key, required this.record});

  @override
  State<SavedRecordDetailPage> createState() => _SavedRecordDetailPageState();
}

class _SavedRecordDetailPageState extends State<SavedRecordDetailPage> {
  bool _exporting = false;

  Future<void> _handleExport(String value) async {
    if (_exporting) return;
    setState(() => _exporting = true);

    final report = widget.record.isBatch
        ? buildBatchReport(widget.record.students)
        : buildSingleReport(widget.record.students.first);

    final fileName = widget.record.isBatch
        ? 'batch_report_${widget.record.id}'
        : '${widget.record.students.first.name.replaceAll(' ', '_')}_report';

    try {
      if (value == 'txt') {
        await ExportService.exportTxt(context, report, fileName);
      } else if (value == 'pdf') {
        await ExportService.exportPdf(context, widget.record);
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.record.isBatch
        ? buildBatchReport(widget.record.students)
        : buildSingleReport(widget.record.students.first);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: Text(
          widget.record.isBatch ? 'Batch Report' : widget.record.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // ── Copy to clipboard ──
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy to clipboard',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: report));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copied to clipboard!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          // ── Export menu (TXT / PDF) ──
          _exporting
              ? const Padding(
            padding: EdgeInsets.all(14),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            ),
          )
              : PopupMenuButton<String>(
            icon: const Icon(Icons.ios_share),
            tooltip: 'Export report',
            onSelected: _handleExport,
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'txt',
                child: Row(children: [
                  Icon(Icons.text_snippet_outlined,
                      color: Color(0xFF1565C0)),
                  SizedBox(width: 10),
                  Text('Export as .txt'),
                ]),
              ),
              const PopupMenuItem(
                value: 'pdf',
                child: Row(children: [
                  Icon(Icons.picture_as_pdf_outlined,
                      color: Colors.red),
                  SizedBox(width: 10),
                  Text('Export as .pdf'),
                ]),
              ),
            ],
          ),
        ],
      ),
      body: widget.record.isBatch
          ? _batchDetail(context, report)
          : _singleDetail(report),
    );
  }

  Widget _singleDetail(String report) {
    final s = widget.record.students.first;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          StudentResultCard(student: s),
          const SizedBox(height: 16),
          _reportBox(report),
        ],
      ),
    );
  }

  Widget _batchDetail(BuildContext context, String report) {
    final col = StudentCollection(widget.record.students);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  _statBox('Total', '${col.length}',
                      Colors.blue.shade700),
                  const SizedBox(width: 8),
                  _statBox('Average',
                      '${col.averageMark.toStringAsFixed(1)}%',
                      Colors.purple.shade700),
                  const SizedBox(width: 8),
                  _statBox('Passed', '${col.passedCount}',
                      Colors.green.shade700),
                  const SizedBox(width: 8),
                  _statBox('Failed', '${col.failedCount}',
                      Colors.red.shade700),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: report));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Report copied!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy,
                      color: Color(0xFF1565C0)),
                  label: const Text('Copy Full Report',
                      style: TextStyle(color: Color(0xFF1565C0))),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(
                        color: Color(0xFF1565C0), width: 2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 4),
            itemCount: col.length,
            separatorBuilder: (context, index) =>
            const SizedBox(height: 10),
            itemBuilder: (context, i) => StudentListTile(
                student: col.sortedByMark[i], index: i + 1),
          ),
        ),
      ],
    );
  }

  Widget _reportBox(String report) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: SelectableText(report,
          style:
          const TextStyle(fontFamily: 'monospace', fontSize: 13)),
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color)),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: color.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }
}
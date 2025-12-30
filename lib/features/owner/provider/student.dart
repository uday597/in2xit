import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../modal/students.dart';

class StudentProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<StudentModal> _students = [];
  List<StudentModal> get students => _students;

  bool isLoading = false;

  // IMAGE UPLOAD
  Future<String?> uploadStudentImage(File image) async {
    try {
      final ext = image.path.split('.').last;
      final fileName = "student_${DateTime.now().millisecondsSinceEpoch}.$ext";

      await supabase.storage.from('student').upload(fileName, image);

      return supabase.storage.from('student').getPublicUrl(fileName);
    } catch (e) {
      debugPrint("Upload Error: $e");
      return null;
    }
  }

  // ADD STUDENT + QR
  Future<bool> addStudent({
    required int collegeId,
    required String name,
    required String className,
    required String mobile,
    required String address,
    File? imageFile,
  }) async {
    try {
      String? imageUrl;

      if (imageFile != null) {
        imageUrl = await uploadStudentImage(imageFile);
      }

      final inserted = await supabase
          .from('students')
          .insert({
            'college_id': collegeId,
            'name': name,
            'class_name': className,
            'mobile': mobile,
            'address': address,
            'student_image': imageUrl,
          })
          .select()
          .single();

      final studentId = inserted['id'];

      // QR STRING
      final qr = "student|id:$studentId|college:$collegeId";

      await supabase
          .from('students')
          .update({'qr_code': qr})
          .eq('id', studentId);

      fetchStudents(collegeId);
      return true;
    } catch (e) {
      debugPrint("Add Student Error: $e");
      return false;
    }
  }

  // FETCH STUDENTS
  Future<void> fetchStudents(int collegeId) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await supabase
          .from('students')
          .select()
          .eq('college_id', collegeId)
          .order('id', ascending: false);

      _students = response.map((e) => StudentModal.fromMap(e)).toList();
    } catch (e) {
      debugPrint("Fetch Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStudent({
    required int id,
    required int collegeId,
    String? name,
    String? className,
    String? mobile,
    String? address,
    File? imageFile,
  }) async {
    String? imageUrl;

    if (imageFile != null) {
      imageUrl = await uploadStudentImage(imageFile);
    }

    await supabase
        .from('students')
        .update({
          if (name != null) 'name': name,
          if (className != null) 'class_name': className,
          if (mobile != null) 'mobile': mobile,
          if (address != null) 'address': address,
          if (imageUrl != null) 'student_image': imageUrl, // ✅ URL saved
        })
        .eq('id', id);

    fetchStudents(collegeId);
  }

  // DELETE STUDENT
  Future<void> deleteStudent(int id, int collegeId) async {
    await supabase.from('students').delete().eq('id', id);
    fetchStudents(collegeId);
  }

  // FETCH BY QR (Guard / Scanner)
  Future<StudentModal?> fetchStudentByQR(String qr) async {
    try {
      if (!qr.startsWith("student|id:")) return null;

      final id = int.parse(qr.split('|')[1].replaceAll('id:', ''));

      final data = await supabase
          .from('students')
          .select('''*,college_id(*)''')
          .eq('id', id)
          .maybeSingle();

      return data != null ? StudentModal.fromMap(data) : null;
    } catch (e) {
      debugPrint("QR Error: $e");
      return null;
    }
  }

  Future<StudentModal?> fetchStudentById(int id) async {
    try {
      final data = await supabase
          .from('students')
          .select()
          .eq('id', id)
          .maybeSingle();

      return data != null ? StudentModal.fromMap(data) : null;
    } catch (e) {
      return null;
    }
  }
}

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentAccountRepository {
  static const _storageKey = 'mdc_connect_student_accounts_v1';
  static final _random = Random.secure();

  static String normalizeSchoolId(String schoolId) =>
      schoolId.trim().toUpperCase();

  Future<void> createAccount({
    required String schoolId,
    required String password,
  }) async {
    final normalizedId = normalizeSchoolId(schoolId);
    final accounts = await _readAccounts();
    if (accounts.containsKey(normalizedId)) {
      throw const StudentAccountException(
        'An account already exists for that school ID.',
      );
    }

    final salt = List.generate(
      16,
      (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    accounts[normalizedId] = {
      'salt': salt,
      'passwordHash': _hash(password, salt),
    };
    await _writeAccounts(accounts);
  }

  Future<bool> authenticate({
    required String schoolId,
    required String password,
  }) async {
    final account = (await _readAccounts())[normalizeSchoolId(schoolId)];
    if (account == null) return false;
    return _hash(password, account['salt'] as String) ==
        account['passwordHash'];
  }

  Future<Map<String, Map<String, dynamic>>> _readAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storageKey);
    if (stored == null) return {};
    final decoded = Map<String, dynamic>.from(jsonDecode(stored) as Map);
    return decoded.map(
      (id, value) => MapEntry(id, Map<String, dynamic>.from(value as Map)),
    );
  }

  Future<void> _writeAccounts(
    Map<String, Map<String, dynamic>> accounts,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setString(_storageKey, jsonEncode(accounts));
    if (!saved) throw const StudentAccountException('Could not save account.');
  }

  String _hash(String password, String salt) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();
}

class StudentAccountException implements Exception {
  const StudentAccountException(this.message);
  final String message;
  @override
  String toString() => message;
}

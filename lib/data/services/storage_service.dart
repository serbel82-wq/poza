import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  static const String _userNameKey = 'user_name';
  static const String _completedLessonsKey = 'completed_lessons';
  static const String _currentSeasonKey = 'current_season';
  static const String _currentLessonKey = 'current_lesson';
  static const String _lastActiveKey = 'last_active_date';
  static const String _achievementsKey = 'achievements';
  static const String _onboardingCompletedKey = 'onboarding_completed';

  static SharedPreferences? _prefs;
  
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) throw Exception('StorageService not initialized');
    return _prefs!;
  }

  // --- Локальное хранилище ---

  static Future<void> setUserName(String name) async => await prefs.setString(_userNameKey, name);
  static String? getUserName() => prefs.getString(_userNameKey);

  static List<int> getCompletedLessons() {
    final data = prefs.getString(_completedLessonsKey);
    if (data == null) return [];
    try {
      return List<int>.from(jsonDecode(data));
    } catch (e) {
      return [];
    }
  }

  static Future<void> addCompletedLesson(int lessonId) async {
    final lessons = getCompletedLessons();
    if (!lessons.contains(lessonId)) {
      lessons.add(lessonId);
      await prefs.setString(_completedLessonsKey, jsonEncode(lessons));
      syncToCloud();
    }
  }

  static bool isLessonCompleted(int lessonId) => getCompletedLessons().contains(lessonId);
  static int getTotalCompletedLessons() => getCompletedLessons().length;

  static List<String> getAchievements() {
    final data = prefs.getString(_achievementsKey);
    if (data == null) return [];
    return List<String>.from(jsonDecode(data));
  }

  static Future<void> addAchievement(String id) async {
    final achs = getAchievements();
    if (!achs.contains(id)) {
      achs.add(id);
      await prefs.setString(_achievementsKey, jsonEncode(achs));
      syncToCloud();
    }
  }

  static Future<void> setLastActiveDate(DateTime date) async => 
      await prefs.setString(_lastActiveKey, date.toIso8601String());

  // --- Безопасная работа с облаком ---

  static Future<void> loadFromCloud() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!doc.exists) return;
      final data = doc.data()!;
      if (data['userName'] != null) await prefs.setString(_userNameKey, data['userName']);
      if (data['completedLessons'] != null) {
        await prefs.setString(_completedLessonsKey, jsonEncode(data['completedLessons']));
      }
    } catch (e) {
      debugPrint('StorageService: Облако недоступно (используем локальные данные)');
    }
  }

  static Future<void> syncToCloud() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final data = {
        'userName': getUserName(),
        'completedLessons': getCompletedLessons(),
        'achievements': getAchievements(),
        'lastActive': FieldValue.serverTimestamp(),
      };
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('StorageService: Синхронизация пропущена');
    }
  }
}

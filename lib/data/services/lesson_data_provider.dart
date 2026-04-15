import '../models/lesson.dart';
import '../models/task.dart';
import '../models/season.dart';

class LessonDataProvider {
  static List<Season> getSeasons() {
    return [
      const Season(id: 1, title: 'Основы ИИ', subtitle: 'Сезон 1', description: 'Как работают нейросети', lessonsCount: 8, iconName: 'rocket_launch', isUnlocked: true),
      const Season(id: 2, title: 'Медиа ИИ', subtitle: 'Сезон 2', description: 'Музыка и Видео', lessonsCount: 6, iconName: 'music_note', isUnlocked: false),
      const Season(id: 3, title: 'Кодинг', subtitle: 'Сезон 3', description: 'Программируй с ИИ', lessonsCount: 6, iconName: 'code', isUnlocked: false),
      const Season(id: 4, title: 'Творчество', subtitle: 'Сезон 4', description: 'Книги и комиксы', lessonsCount: 6, iconName: 'auto_stories', isUnlocked: false),
      const Season(id: 5, title: 'Детектив', subtitle: 'Сезон 5', description: 'Правда или ложь', lessonsCount: 6, iconName: 'search', isUnlocked: false),
      const Season(id: 6, title: 'Школа', subtitle: 'Сезон 6', description: 'Помощник в учебе', lessonsCount: 6, iconName: 'lightbulb', isUnlocked: false),
      const Season(id: 7, title: 'Будущее', subtitle: 'Сезон 7', description: 'Мир через 10 лет', lessonsCount: 6, iconName: 'rocket', isUnlocked: false),
      const Season(id: 8, title: 'Проект', subtitle: 'Сезон 8', description: 'Твой финал', lessonsCount: 8, iconName: 'build', isUnlocked: false),
    ];
  }

  static List<Lesson> getLessonsBySeason(int seasonId) {
    if (seasonId == 1) return getSeason1Lessons();
    if (seasonId == 2) return getSeason2Lessons();
    if (seasonId == 3) return getSeason3Lessons();
    if (seasonId == 8) return getSeason8Lessons();
    return _generateEmpty(seasonId);
  }

  static Lesson? getLessonById(int id) {
    for (int i = 1; i <= 8; i++) {
      final lessons = getLessonsBySeason(i);
      for (final l in lessons) { if (l.id == id) return l; }
    }
    return null;
  }

  static Lesson? getNextLesson(int currentLessonId) {
    final current = getLessonById(currentLessonId);
    if (current == null) return null;
    final lessons = getLessonsBySeason(current.seasonId);
    final idx = lessons.indexWhere((l) => l.id == currentLessonId);
    if (idx != -1 && idx < lessons.length - 1) return lessons[idx + 1];
    return null;
  }

  static List<Lesson> getSeason1Lessons() {
    return [
      _create(1, 1, 1, 'Код Машин', 'Компьютер учится на примерах.'),
      _create(2, 1, 2, 'Мозг ИИ', 'Нейросеть похожа на твой мозг.'),
      _create(3, 1, 3, 'Сила Промпта', 'Хороший запрос = результат.'),
      _create(4, 1, 4, 'ИИ-Арт', 'ИИ рисует по твоим словам.'),
      _create(5, 1, 5, 'Галлюцинации', 'ИИ может ошибаться.'),
      _create(6, 1, 6, 'Безопасность', 'Не давай личные данные.'),
      _create(7, 1, 7, 'ИИ-Тьютор', 'ИИ как личный учитель.'),
      _create(8, 1, 8, 'Твой Робот', 'Создай правила для бота.'),
    ];
  }

  static List<Lesson> getSeason2Lessons() {
    return [
      _create(101, 2, 1, 'Битмейкер', 'Музыка по настроению.'),
      _create(102, 2, 2, 'Голос-Клон', 'ИИ имитирует голоса.'),
      _create(103, 2, 3, 'Кино из текста', 'Сними видео из описания.'),
      _create(104, 2, 4, 'Подкаст-Шоу', 'ИИ пишет сценарий радио.'),
      _create(105, 2, 5, 'Аниматор', 'Оживи свои картинки.'),
      _create(106, 2, 6, 'Твой Клип', 'Соедини музыку и видео.'),
    ];
  }

  static List<Lesson> getSeason3Lessons() {
    return [
      _create(301, 3, 1, 'ИИ-Кодер', 'Пиши код вместе с ИИ.'),
      _create(302, 3, 2, 'Авто-Мастер', 'Пусть робот делает работу.'),
      _create(303, 3, 3, 'Свой Сайт', 'Собери страницу быстро.'),
      _create(304, 3, 4, 'Детектив Цифр', 'Ищи паттерны в данных.'),
      _create(305, 3, 5, 'Бот-Квест', 'Создай бота для игры.'),
      _create(306, 3, 6, 'App-Гений', 'Придумай приложение.'),
    ];
  }

  static List<Lesson> getSeason8Lessons() {
    return [
      _create(801, 8, 1, 'Идея', 'Начало твоего проекта.'),
      _create(802, 8, 2, 'Исследование', 'Поиск решений.'),
      _create(803, 8, 3, 'Прототип', 'Первая версия.'),
      _create(804, 8, 4, 'Дизайн', 'Красота и удобство.'),
      _create(805, 8, 5, 'Умный ИИ', 'Добавь интеллект.'),
      _create(806, 8, 6, 'Тест-Драйв', 'Проверка на друзьях.'),
      _create(807, 8, 7, 'Презентация', 'Расскажи о проекте.'),
      _create(808, 8, 8, 'ЗАПУСК!', 'Ты — Исследователь!'),
    ];
  }

  static List<Lesson> _generateEmpty(int sId) {
    return List.generate(6, (i) => _create(sId * 100 + i + 1, sId, i + 1, 'Миссия ${i + 1}', 'Скоро появится!'));
  }

  static Lesson _create(int id, int s, int o, String t, String theory) {
    return Lesson(
      id: id, seasonId: s, order: o, title: t, subtitle: 'Миссия $o',
      theoryText: theory, durationMinutes: 10, iconName: 'rocket_launch',
      tasks: [
        Task(title: 'Задание', description: 'Практика', type: TaskType.text, instruction: 'Напиши ответ...', totalPoints: 50),
      ],
    );
  }
}

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
    switch (seasonId) {
      case 1: return getSeason1Lessons();
      case 2: return getSeason2Lessons();
      case 3: return getSeason3Lessons();
      case 4: return _generateSeason(4, 'Творец историй', ['Герои', 'Комиксы', 'Поэзия', 'Квесты', 'Миры', 'Книга']);
      case 5: return _generateSeason(5, 'ИИ Детектив', ['Фейки', 'Следы', 'Этика', 'Баланс', 'Факты', 'Отчет']);
      case 6: return _generateSeason(6, 'Реальная жизнь', ['Приложения', 'Языки', 'Спорт', 'Наука', 'Здоровье', 'Помощник']);
      case 7: return _generateSeason(7, 'Будущее ИИ', ['Прогноз', 'Роботы', 'AGI', 'Работа', 'Законы', 'Видение']);
      case 8: return getSeason8Lessons();
      default: return [];
    }
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
    if (current.seasonId < 8) {
      final nextS = getLessonsBySeason(current.seasonId + 1);
      return nextS.isNotEmpty ? nextS[0] : null;
    }
    return null;
  }

  static List<Lesson> getSeason1Lessons() {
    return [
      _create(1, 1, 1, 'Код Машин', 'Компьютер учится на примерах.'),
      _create(2, 1, 2, 'Мозг ИИ', 'Нейросеть похожа на твой мозг.'),
      _create(3, 1, 3, 'Сила Промпта', 'Хороший запрос = крутой результат.'),
      _create(4, 1, 4, 'ИИ-Арт', 'ИИ рисует по твоим словам.'),
      _create(5, 1, 5, 'Галлюцинации', 'ИИ может уверенно ошибаться.'),
      _create(6, 1, 6, 'Безопасность', 'Не давай ИИ личные данные.'),
      _create(7, 1, 7, 'ИИ-Тьютор', 'ИИ как личный учитель.'),
      _create(8, 1, 8, 'Твой Робот', 'Создай правила для своего помощника.'),
    ];
  }

  static List<Lesson> getSeason2Lessons() {
    return [
      _create(101, 2, 1, 'Битмейкер', 'ИИ создает музыку по настроению.'),
      _create(102, 2, 2, 'Голос-Клон', 'ИИ может говорить твоим голосом.'),
      _create(103, 2, 3, 'Кино из текста', 'Сними видео из описания.'),
      _create(104, 2, 4, 'Подкаст-Шоу', 'ИИ пишет сценарий для радио.'),
      _create(105, 2, 5, 'Аниматор', 'Оживи свои картинки.'),
      _create(106, 2, 6, 'Твой Клип', 'Соедини музыку и видео.'),
    ];
  }

  static List<Lesson> getSeason3Lessons() {
    return [
      _create(301, 3, 1, 'ИИ-Кодер', 'Пиши функции вместе с ИИ.'),
      _create(302, 3, 2, 'Авто-Мастер', 'Пусть робот делает скучную работу.'),
      _create(303, 3, 3, 'Свой Сайт', 'Собери страницу за 5 минут.'),
      _create(304, 3, 4, 'Детектив Цифр', 'Ищи паттерны в данных.'),
      _create(305, 3, 5, 'Бот-Квест', 'Создай Telegram бота для игры.'),
      _create(306, 3, 6, 'App-Гений', 'Придумай свое мобильное приложение.'),
    ];
  }

  static List<Lesson> getSeason8Lessons() {
    return [
      _create(801, 8, 1, 'Идея', 'Начало большого пути.'),
      _create(802, 8, 2, 'Исследование', 'Поиск лучших решений.'),
      _create(803, 8, 3, 'Прототип', 'Первая рабочая версия.'),
      _create(804, 8, 4, 'Дизайн', 'Красота и удобство.'),
      _create(805, 8, 5, 'Интеллект', 'Добавление "магии" ИИ.'),
      _create(806, 8, 6, 'Тест-Драйв', 'Проверка на друзьях.'),
      _create(807, 8, 7, 'Презентация', 'Расскажи миру о проекте.'),
      _create(808, 8, 8, 'ЗАПУСК!', 'Ты — НейроИсследователь!'),
    ];
  }

  static List<Lesson> _generateSeason(int sId, String sTitle, List<String> names) {
    return List.generate(names.length, (i) => _create(sId * 100 + i + 1, sId, i + 1, names[i], 'Миссия про ${names[i]}!'));
  }

  static Lesson _create(int id, int s, int o, String t, String theory) {
    return Lesson(
      id: id, seasonId: s, order: o, title: t, subtitle: 'Миссия $o',
      theoryText: theory, durationMinutes: 10, iconName: 'rocket_launch',
      tasks: [
        Task(title: 'Практика', description: 'Действуй!', type: TaskType.text, instruction: 'Напиши свой ответ здесь...', totalPoints: 50),
      ],
    );
  }
}

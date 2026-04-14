import '../models/lesson.dart';
import '../models/task.dart';
import '../models/season.dart';

class LessonDataProvider {
  static List<Season> getSeasons() {
    return [
      const Season(id: 1, title: 'Первый контакт', subtitle: 'Сезон 1', description: 'Узнай, как устроены нейросети', lessonsCount: 8, iconName: 'rocket_launch', isUnlocked: true),
      const Season(id: 2, title: 'Мир звука и видео', subtitle: 'Сезон 2', description: 'Создавай музыку и видео', lessonsCount: 6, iconName: 'music_note', isUnlocked: false),
      const Season(id: 3, title: 'Код и автоматизация', subtitle: 'Сезон 3', description: 'Пиши код с ИИ', lessonsCount: 6, iconName: 'code', isUnlocked: false),
      const Season(id: 4, title: 'Творец историй', subtitle: 'Сезон 4', description: 'Создавай миры с ИИ', lessonsCount: 6, iconName: 'auto_stories', isUnlocked: false),
      const Season(id: 5, title: 'ИИ детектив', subtitle: 'Сезон 5', description: 'Найди ошибки ИИ', lessonsCount: 6, iconName: 'search', isUnlocked: false),
      const Season(id: 6, title: 'ИИ в реальной жизни', subtitle: 'Сезон 6', description: 'ИИ в учёбе и спорте', lessonsCount: 6, iconName: 'lightbulb', isUnlocked: false),
      const Season(id: 7, title: 'Будущее ИИ', subtitle: 'Сезон 7', description: 'Мир через 10 лет', lessonsCount: 6, iconName: 'rocket', isUnlocked: false),
      const Season(id: 8, title: 'Свой ИИ-проект', subtitle: 'Сезон 8', description: 'Создай свой проект', lessonsCount: 8, iconName: 'build', isUnlocked: false),
    ];
  }

  static List<Lesson> getLessonsBySeason(int seasonId) {
    switch (seasonId) {
      case 1: return getSeason1Lessons();
      case 2: return getSeason2Lessons();
      case 3: return getSeason3Lessons();
      case 4: return _createEmptySeason(4, 'Творец историй', 6);
      case 5: return _createEmptySeason(5, 'ИИ Детектив', 6);
      case 6: return _createEmptySeason(6, 'Реальная жизнь', 6);
      case 7: return _createEmptySeason(7, 'Будущее', 6);
      case 8: return _createEmptySeason(8, 'Большой Финал', 8);
      default: return [];
    }
  }

  static Lesson? getLessonById(int id) {
    for (int i = 1; i <= 8; i++) {
      final lessons = getLessonsBySeason(i);
      final lesson = lessons.where((l) => l.id == id).toList();
      if (lesson.isNotEmpty) return lesson.first;
    }
    return null;
  }

  static Lesson? getNextLesson(int currentLessonId) {
    final current = getLessonById(currentLessonId);
    if (current == null) return null;
    final seasonLessons = getLessonsBySeason(current.seasonId);
    final currentIndex = seasonLessons.indexWhere((l) => l.id == currentLessonId);
    if (currentIndex != -1 && currentIndex < seasonLessons.length - 1) return seasonLessons[currentIndex + 1];
    if (current.seasonId < 8) {
      final nextSeasonLessons = getLessonsBySeason(current.seasonId + 1);
      if (nextSeasonLessons.isNotEmpty) return nextSeasonLessons.first;
    }
    return null;
  }

  static List<Lesson> getSeason1Lessons() {
    return [
      Lesson(
        id: 1, seasonId: 1, order: 1, 
        title: 'Миссия 1: Секретный код машин', 
        subtitle: 'Как компьютер учится', 
        theoryText: 'Компьютер учится на примерах. Показываешь ему 1000 котиков — он понимает, кто такой котик.',
        durationMinutes: 10, iconName: 'rocket_launch',
        tasks: [
          const Task(
            title: 'Практика: Учитель Роботов',
            description: 'Попробуй мыслить как ИИ',
            type: TaskType.text,
            instruction: 'Представь, что тебе нужно научить ИИ отличать яблоко от банана. Напиши ОДИН самый главный признак (например, цвет или форма), который поможет ИИ не ошибиться!',
            totalPoints: 20,
          ),
          const Task(
            title: 'Блиц-опрос',
            description: 'Закрепляем знания',
            type: TaskType.quiz,
            totalPoints: 20,
            questions: [
              TaskQuestion(question: 'Откуда ИИ берет знания?', options: ['Из головы', 'Из примеров (фото, тексты)', 'Ему везет'], correctAnswer: 'Из примеров (фото, тексты)', points: 20),
            ],
          ),
        ],
      ),
      Lesson(
        id: 2, seasonId: 1, order: 2, 
        title: 'Миссия 2: Мозг робота', 
        subtitle: 'Про нейронные сети', 
        theoryText: 'Нейросеть — это паутина из "нейронов", похожая на мозг. Информация бегает по ней и находит ответы.',
        durationMinutes: 12, iconName: 'psychology',
        tasks: [
          const Task(
            title: 'Практика: Связи Нейронов',
            description: 'Творческое задание',
            type: TaskType.creative,
            instruction: 'Если бы ты мог добавить своему мозгу одну "супер-способность" нейросети (например, помнить всё-всё или переводить любой язык), что бы это было? Напиши!',
            totalPoints: 30,
          ),
        ],
      ),
      Lesson(
        id: 3, seasonId: 1, order: 3, 
        title: 'Миссия 3: Хороший Промпт', 
        subtitle: 'Искусство запроса', 
        theoryText: 'Промпт — это команда для ИИ. Чем точнее промпт, тем лучше результат. Хороший промпт: "Нарисуй кота в скафандре на Луне в стиле мультика".',
        durationMinutes: 15, iconName: 'edit_note',
        tasks: [
          const Task(
            title: 'Практика: Мастер Запросов',
            description: 'Создай свой первый промпт',
            type: TaskType.text,
            instruction: 'Напиши идеальный запрос для ИИ, чтобы он придумал историю про твоего любимого супергероя, который попал в мир динозавров. Не забудь указать, что должно произойти!',
            totalPoints: 40,
          ),
          const Task(
            title: 'Квиз: Промпт-Инженер',
            description: 'Проверь точность',
            type: TaskType.choice,
            totalPoints: 20,
            questions: [
              TaskQuestion(question: 'Какой промпт лучше?', options: ['Нарисуй что-нибудь', 'Нарисуй рыжего кота в шляпе', 'Кот'], correctAnswer: 'Нарисуй рыжего кота в шляпе', points: 20),
            ],
          ),
        ],
      ),
      Lesson(
        id: 4, seasonId: 1, order: 4, 
        title: 'Миссия 4: ИИ-Художник', 
        subtitle: 'Генерация картинок', 
        theoryText: 'ИИ-художники (как Midjourney или DALL-E) умеют рисовать что угодно. Важно описать стиль: "акварель", "3D-игра" или "фото".',
        durationMinutes: 15, iconName: 'palette',
        tasks: [
          const Task(
            title: 'Практика: Опиши Шедевр',
            description: 'Задание на воображение',
            type: TaskType.creative,
            instruction: 'Представь, что тебе нужно сгенерировать обложку для игры "Космические гонки на улитках". Опиши словами, какие цвета и предметы должны быть на этой картинке!',
            totalPoints: 50,
          ),
        ],
      ),
      _createLesson(5, 1, 5, 'Миссия 5: Детектор Лжи', 'Про галлюцинации', 'ИИ иногда врет! Проверяй факты.'),
      _createLesson(6, 1, 6, 'Миссия 6: Твои Границы', 'Безопасность', 'Не пиши личные данные.'),
      _createLesson(7, 1, 7, 'Миссия 7: ИИ-Помощник', 'Школа', 'Используй ИИ как репетитора.'),
      _createLesson(8, 1, 8, 'Миссия 8: Финал Сезона', 'Твой проект', 'Создай своего ассистента.'),
    ];
  }

  static List<Lesson> getSeason2Lessons() {
    return [
      _createLesson(101, 2, 1, 'Миссия 1: Битмейкер', 'Музыка ИИ', 'Создай трек за 1 минуту.'),
      _createLesson(102, 2, 2, 'Миссия 2: Твой Голос', 'Синтез речи', 'Как ИИ может говорить за тебя.'),
      _createLesson(103, 2, 3, 'Миссия 3: Кинорежиссер', 'Видео ИИ', 'Превращаем текст в видео.'),
      _createLesson(104, 2, 4, 'Миссия 4: Подкастер', 'Аудио шоу', 'Создай свое радио.'),
      _createLesson(105, 2, 5, 'Миссия 5: Мультипликатор', 'Анимация', 'Оживи своих героев.'),
      _createLesson(106, 2, 6, 'Миссия 6: Клип-мастер', 'Финальный клип', 'Собери видео и звук вместе.'),
    ];
  }

  static List<Lesson> getSeason3Lessons() {
    return [
      _createLesson(301, 3, 1, 'Миссия 1: Кодер-Новичок', 'Основы кода', 'Напиши первую строку кода с ИИ.'),
      _createLesson(302, 3, 2, 'Миссия 2: Авто-Робот', 'Автоматизация', 'Пусть компьютер работает за тебя.'),
      _createLesson(303, 3, 3, 'Миссия 3: Веб-Мастер', 'Создай сайт', 'Твоя личная страница в сети.'),
      _createLesson(304, 3, 4, 'Миссия 4: Детектив Цифр', 'Анализ данных', 'Ищи секреты в таблицах.'),
      _createLesson(305, 3, 5, 'Миссия 5: Бот-Друг', 'Telegram боты', 'Создай своего бота-помощника.'),
      _createLesson(306, 3, 6, 'Миссия 6: App-Профи', 'Свое приложение', 'Сделай работающее мобильное приложение.'),
    ];
  }

  static Lesson _createLesson(int id, int season, int order, String title, String sub, String theory) {
    return Lesson(
      id: id, seasonId: season, order: order, title: title, subtitle: sub,
      theoryText: theory, durationMinutes: 15, iconName: 'rocket_launch',
      tasks: [
        const Task(title: 'Практика: Исследование', description: 'Попробуй сам!', type: TaskType.text, instruction: 'Напиши, что нового ты узнал в этой миссии?', totalPoints: 20),
      ],
    );
  }

  static List<Lesson> _createEmptySeason(int seasonId, String title, int count) {
    return List.generate(count, (i) => _createLesson(seasonId * 100 + i, seasonId, i + 1, 'Миссия ${i+1}: $title', 'Загрузка...', 'Эта миссия скоро появится!'));
  }
}

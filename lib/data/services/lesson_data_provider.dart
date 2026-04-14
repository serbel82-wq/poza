import '../models/lesson.dart';
import '../models/task.dart';
import '../models/season.dart';

class LessonDataProvider {
  static List<Season> getSeasons() {
    return [
      const Season(
        id: 1,
        title: 'Первый контакт',
        subtitle: 'Сезон 1',
        description: 'Узнай, как устроены нейросети и как использовать их с пользой',
        lessonsCount: 8,
        iconName: 'rocket_launch',
        isUnlocked: true,
      ),
      const Season(
        id: 2,
        title: 'Мир звука и видео',
        subtitle: 'Сезон 2',
        description: 'Создавай музыку и видео с помощью нейросетей',
        lessonsCount: 6,
        iconName: 'music_note',
        isUnlocked: false,
      ),
      const Season(
        id: 3,
        title: 'Код и автоматизация',
        subtitle: 'Сезон 3',
        description: 'Пиши код быстрее с помощью ИИ-помощников',
        lessonsCount: 6,
        iconName: 'code',
        isUnlocked: false,
      ),
      const Season(
        id: 4,
        title: 'Творец историй',
        subtitle: 'Сезон 4',
        description: 'Создавай истории, персонажей и целые миры с ИИ',
        lessonsCount: 6,
        iconName: 'auto_stories',
        isUnlocked: false,
      ),
      const Season(
        id: 5,
        title: 'ИИ детектив',
        subtitle: 'Сезон 5',
        description: 'Научись проверять информацию и находить ошибки ИИ',
        lessonsCount: 6,
        iconName: 'search',
        isUnlocked: false,
      ),
      const Season(
        id: 6,
        title: 'ИИ в реальной жизни',
        subtitle: 'Сезон 6',
        description: 'Как нейросети помогают в учёбе, спорте и творчестве',
        lessonsCount: 6,
        iconName: 'lightbulb',
        isUnlocked: false,
      ),
      const Season(
        id: 7,
        title: 'Будущее ИИ',
        subtitle: 'Сезон 7',
        description: 'Что будет с искусственным интеллектом через 10 лет?',
        lessonsCount: 6,
        iconName: 'rocket',
        isUnlocked: false,
      ),
      const Season(
        id: 8,
        title: 'Свой ИИ-проект',
        subtitle: 'Сезон 8',
        description: 'Создай собственный проект с использованием нейросетей',
        lessonsCount: 8,
        iconName: 'build',
        isUnlocked: false,
      ),
    ];
  }

  static List<Lesson> getLessonsBySeason(int seasonId) {
    switch (seasonId) {
      case 1: return getSeason1Lessons();
      case 2: return getSeason2Lessons();
      case 3: return getSeason3Lessons();
      case 4: return getSeason4Lessons();
      case 5: return getSeason5Lessons();
      case 6: return getSeason6Lessons();
      case 7: return getSeason7Lessons();
      case 8: return getSeason8Lessons();
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
    
    if (currentIndex != -1 && currentIndex < seasonLessons.length - 1) {
      return seasonLessons[currentIndex + 1];
    }
    
    // Если это был последний урок сезона, ищем первый урок следующего сезона
    if (current.seasonId < 8) {
      final nextSeasonLessons = getLessonsBySeason(current.seasonId + 1);
      if (nextSeasonLessons.isNotEmpty) return nextSeasonLessons.first;
    }
    
    return null;
  }

  static List<Lesson> getSeason1Lessons() {
    return [
      _createLesson(1, 1, 1, 'Миссия 1: Секретный код машин', 'Как компьютер учится', 'Компьютер учится на примерах (как ты!). Показываешь ему 1000 котиков — он понимает, кто такой котик.'),
      _createLesson(2, 1, 2, 'Миссия 2: Мозг робота', 'Про нейронные сети', 'Нейросеть — это паутина из "нейронов", похожая на человеческий мозг. Информация бегает по ней и находит ответы.'),
      _createLesson(3, 1, 3, 'Миссия 3: Хороший Промпт', 'Искусство запроса', 'Чтобы ИИ тебя понял, нужно быть точным. Промпт — это твоя команда. Чем яснее команда, тем круче результат!'),
      _createLesson(4, 1, 4, 'Миссия 4: ИИ-Художник', 'Генерация картинок', 'Ты пишешь слова — ИИ рисует шедевр. Узнай, как смешивать стили Ван Гога и киберпанка.'),
      _createLesson(5, 1, 5, 'Миссия 5: Детектор Лжи', 'Про галлюцинации', 'ИИ иногда врет! Это называется галлюцинация. Научись проверять факты и не верить на слово.'),
      _createLesson(6, 1, 6, 'Миссия 6: Твои Границы', 'Безопасность данных', 'Никогда не говори ИИ свой адрес или пароли. Помни: интернет всё запоминает!'),
      _createLesson(7, 1, 7, 'Миссия 7: ИИ-Помощник', 'Школа и нейросети', 'Как использовать ИИ, чтобы он помогал учиться, а не просто делал за тебя домашку.'),
      _createLesson(8, 1, 8, 'Миссия 8: Финал Сезона', 'Твой первый проект', 'Собери всё, что узнал, и создай свой системный промпт для личного робота-друга.'),
    ];
  }

  static List<Lesson> getSeason2Lessons() {
    return [
      _createLesson(101, 2, 1, 'Музыка из космоса', 'ИИ и звук', 'Создай свой первый трек без инструментов. Как ИИ "слышит" музыку.'),
      _createLesson(102, 2, 2, 'Голос будущего', 'Синтез речи', 'Как клонировать голос и почему важно использовать это честно.'),
      _createLesson(103, 2, 3, 'Текст оживает', 'Видео по запросу', 'Превращаем описание в короткое кино. Магия Runway и Pika.'),
      _createLesson(104, 2, 4, 'Подкаст за 5 минут', 'Аудио-шоу', 'Пишем сценарий и озвучиваем его разными героями с помощью ИИ.'),
      _createLesson(105, 2, 5, 'Мультфильм с нуля', 'Анимация ИИ', 'Создаем персонажей и оживляем их. Твоя первая анимация.'),
      _createLesson(106, 2, 6, 'Клипмейкер', 'Финальный клип', 'Соединяем звук, видео и историю в один крутой проект.'),
    ];
  }

  static List<Lesson> getSeason3Lessons() {
    return [
      _createLesson(301, 3, 1, 'Код для новичка', 'Программируем с ИИ', 'ИИ — это твой напарник-кодер. Он пишет функции, ты проверяешь.'),
      _createLesson(302, 3, 2, 'Авто-Магия', 'Автоматизация', 'Пусть компьютер сам сортирует твои фото и напоминает о делах.'),
      _createLesson(303, 3, 3, 'Мой Сайт', 'Веб за минуты', 'Создаем личную страницу с помощью ИИ-конструкторов.'),
      _createLesson(304, 3, 4, 'Детектив Данных', 'Анализ цифр', 'Ищи закономерности в своих оценках или успехах в играх.'),
      _createLesson(305, 3, 5, 'Бот-Помощник', 'Telegram боты', 'Создай бота, который отвечает на вопросы твоим друзьям.'),
      _createLesson(306, 3, 6, 'App-Мастер', 'Мини-приложение', 'Создаем работающее приложение из идеи и чистого листа.'),
    ];
  }

  // Заглушки для остальных сезонов, чтобы не было пустых экранов
  static List<Lesson> getSeason4Lessons() => _createEmptySeason(4, 'Творец историй', 6);
  static List<Lesson> getSeason5Lessons() => _createEmptySeason(5, 'ИИ Детектив', 6);
  static List<Lesson> getSeason6Lessons() => _createEmptySeason(6, 'Реальная жизнь', 6);
  static List<Lesson> getSeason7Lessons() => _createEmptySeason(7, 'Будущее', 6);
  static List<Lesson> getSeason8Lessons() => _createEmptySeason(8, 'Большой Финал', 8);

  // Вспомогательные методы
  static Lesson _createLesson(int id, int season, int order, String title, String sub, String theory) {
    return Lesson(
      id: id, seasonId: season, order: order, title: title, subtitle: sub,
      theoryText: theory, durationMinutes: 15, iconName: 'rocket_launch',
      tasks: [
        Task(title: 'Квиз: $title', description: 'Проверь знания', type: TaskType.quiz, totalPoints: 20, 
          questions: [TaskQuestion(question: 'Что самое главное в этой миссии?', options: ['Скорость', 'Внимательность', 'ИИ'], correctAnswer: 'Внимательность', points: 20)]),
      ],
    );
  }

  static List<Lesson> _createEmptySeason(int seasonId, String title, int count) {
    return List.generate(count, (i) => _createLesson(seasonId * 100 + i, seasonId, i + 1, 'Миссия ${i+1}: $title', 'Загрузка...', 'Эта миссия станет доступна совсем скоро!'));
  }
}

import '../models/lesson.dart';
import '../models/task.dart';
import '../models/season.dart';

class LessonDataProvider {
  static List<Season> getSeasons() {
    return [
      const Season(id: 1, title: 'Первый контакт', subtitle: 'Сезон 1', description: 'Узнай тайны ИИ и научись ими управлять', lessonsCount: 8, iconName: 'rocket_launch', isUnlocked: true),
      const Season(id: 2, title: 'Мир звука и видео', subtitle: 'Сезон 2', description: 'Создавай музыку и кино с помощью ИИ', lessonsCount: 6, iconName: 'music_note', isUnlocked: false),
      const Season(id: 3, title: 'Код и автоматизация', subtitle: 'Сезон 3', description: 'Стань программистом будущего', lessonsCount: 6, iconName: 'code', isUnlocked: false),
      const Season(id: 4, title: 'Творец историй', subtitle: 'Сезон 4', description: 'Пиши книги и комиксы вместе с ИИ', lessonsCount: 6, iconName: 'auto_stories', isUnlocked: false),
      const Season(id: 5, title: 'ИИ детектив', subtitle: 'Сезон 5', description: 'Научись отличать правду от лжи', lessonsCount: 6, iconName: 'search', isUnlocked: false),
      const Season(id: 6, title: 'ИИ в реальной жизни', subtitle: 'Сезон 6', description: 'ИИ поможет в школе и спорте', lessonsCount: 6, iconName: 'lightbulb', isUnlocked: false),
      const Season(id: 7, title: 'Будущее ИИ', subtitle: 'Сезон 7', description: 'Узнай, каким будет мир через 10 лет', lessonsCount: 6, iconName: 'rocket', isUnlocked: false),
      const Season(id: 8, title: 'Твой Большой Проект', subtitle: 'Сезон 8', description: 'Создай свой ИИ-продукт с нуля', lessonsCount: 8, iconName: 'build', isUnlocked: false),
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
      for (final l in lessons) {
        if (l.id == id) return l;
      }
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
      final nextLessons = getLessonsBySeason(current.seasonId + 1);
      return nextLessons.isNotEmpty ? nextLessons.first : null;
    }
    return null;
  }

  static List<Lesson> getSeason1Lessons() {
    return [
      _createLesson(1, 1, 1, 'Миссия 1: Секретный код машин', 'Как ИИ учится', 'Привет! Я — робот Нейроша. Давай узнаем, как компьютер учится на примерах. Покажи ему 1000 котиков, и он поймет, кто такой котик!', 'Напиши один признак котика?'),
      _createLesson(2, 1, 2, 'Миссия 2: Мозг робота', 'Нейронные сети', 'Нейросеть — это паутина из нейронов, как в твоем мозгу. Информация бегает по ней и находит ответы на любые вопросы.', 'Что бы ты хотел, чтобы ИИ выучил первым?'),
      _createLesson(3, 1, 3, 'Миссия 3: Сила Промпта', 'Искусство запроса', 'Промпт — это твоя команда. Точный промпт дает магический результат. Не просто "кот", а "рыжий кот в шляпе"!', 'Напиши промпт для истории про робота-повара.'),
      _createLesson(4, 1, 4, 'Миссия 4: Цифровой Холст', 'Генерация картинок', 'ИИ рисует в любом стиле — от Ван Гога до Minecraft. Главное — описать детали и свет.', 'Опиши словами картинку своей мечты.'),
      _createLesson(5, 1, 5, 'Миссия 5: Детектор Галлюцинаций', 'Когда ИИ ошибается', 'ИИ может уверенно врать. Это галлюцинация. Всегда проверяй факты в поиске!', 'Найди ошибку в ответе ИИ.'),
      _createLesson(6, 1, 6, 'Миссия 6: Твоя Кибер-Крепость', 'Безопасность', 'Интернет всё помнит. Не пиши ИИ свои пароли или адрес. Будь мудрым исследователем!', 'Назови 3 правила безопасности.'),
      _createLesson(7, 1, 7, 'Миссия 7: ИИ-Напарник', 'Школа будущего', 'ИИ может объяснить физику как сказку или помочь с планом сочинения. Но учись сам!', 'Спроси ИИ про сложную тему и напиши результат.'),
      _createLesson(8, 1, 8, 'Миссия 8: Твой Первый Робот', 'Создание ассистента', 'Время создать правила для своего ИИ. Напиши его характер и его главную задачу.', 'Придумай имя своему помощнику.'),
    ];
  }

  static List<Lesson> getSeason2Lessons() {
    return [
      _createLesson(101, 2, 1, 'Миссия 1: Битмейкер ИИ', 'Музыка будущего', 'ИИ создает музыку, анализируя ритмы. Ты можешь создать трек, выбрав настроение.', 'Опиши стиль своей музыки.'),
      _createLesson(102, 2, 2, 'Миссия 2: Голоса из Машины', 'Синтез речи', 'Нейросети имитируют любой голос. Это круто для игр, но опасно для фейков. Будь осторожен!', 'Твоя идея для использования голоса ИИ.'),
      _createLesson(103, 2, 3, 'Миссия 3: Режиссер Текста', 'Видео из слов', 'Сними кино, не выходя из комнаты. Опиши действие, и ИИ создаст короткое видео.', 'Напиши сценарий на 5 секунд.'),
      _createLesson(104, 2, 4, 'Миссия 4: Радио Исследователей', 'Создание подкаста', 'ИИ пишет сценарий и озвучивает разных героев. Твое шоу готово к эфиру!', 'Тема для твоего первого подкаста.'),
      _createLesson(105, 2, 5, 'Миссия 5: Ожившие Картинки', 'Анимация ИИ', 'Превращаем фото в живую сцену. Волосы развиваются, глаза моргают — это магия ИИ!', 'Какую картинку ты оживишь первой?'),
      _createLesson(106, 2, 6, 'Миссия 6: Финал: Твой Клип', 'Творческий синтез', 'Соедини музыку, видео и голос в один проект. Ты — настоящий медиа-мастер!', 'Опиши идею своего клипа.'),
    ];
  }

  static List<Lesson> getSeason3Lessons() {
    return [
      _createLesson(301, 3, 1, 'Миссия 1: Язык Роботов', 'Основы кода', 'Код — это команды. ИИ понимает их быстрее всех и поможет тебе написать программу.', 'Напиши команду для робота.'),
      _createLesson(302, 3, 2, 'Миссия 2: Авто-Магия', 'Автоматизация', 'Пусть ИИ сам сортирует письма или напоминает о тренировках. Настрой свои правила.', 'Какое дело ты поручишь ИИ?'),
      _createLesson(303, 3, 3, 'Миссия 3: Мой Остров в Сети', 'Создание сайта', 'ИИ-конструкторы соберут сайт за минуты. Выбери дизайн и тексты.', 'Придумай название своего сайта.'),
      _createLesson(304, 3, 4, 'Миссия 4: Охотник за Данными', 'Анализ цифр', 'ИИ видит паттерны в таблицах. Он предскажет твой успех в игре или учебе.', 'Какие данные проанализировать?'),
      _createLesson(305, 3, 5, 'Миссия 5: Бот-Помощник', 'Telegram боты', 'Создай бота, который будет отвечать друзьям или играть с тобой в квесты.', 'Придумай функцию для бота.'),
      _createLesson(306, 3, 6, 'Миссия 6: Финал: App-Мастер', 'Свое приложение', 'Сделай работающий прототип приложения. Ты теперь настоящий разработчик!', 'Какую проблему решит твое приложение?'),
    ];
  }

  static List<Lesson> getSeason8Lessons() {
    return [
      _createLesson(801, 8, 1, 'Старт Проекта', 'Идея', 'Выбери тему проекта. Это начало пути!', 'Название твоего проекта.'),
      _createLesson(802, 8, 2, 'Исследование', 'Поиск', 'Изучи решения других и сделай лучше.', 'Кто будет пользователем?'),
      _createLesson(803, 8, 3, 'Прототип', 'Версия 1.0', 'Создай черновик. Главное — работающая идея.', 'Главная функция проекта.'),
      _createLesson(804, 8, 4, 'Дизайн', 'Красота', 'Сделай проект ярким и понятным.', 'Какие цвета ты выберешь?'),
      _createLesson(805, 8, 5, 'Умный ИИ', 'Интеллект', 'Интегрируй нейросеть в свой проект.', 'Как ИИ поможет людям?'),
      _createLesson(806, 8, 6, 'Тесты', 'Фикс багов', 'Проверь всё сам и исправь ошибки.', 'Какой баг ты нашел?'),
      _createLesson(807, 8, 7, 'Презентация', 'Финал', 'Подготовь крутой рассказ о проекте.', 'Заголовок для рекламы.'),
      _createLesson(808, 8, 8, 'ЗАПУСК!', 'Успех', 'Твой проект готов! Ты — НейроИсследователь!', 'Что ты чувствуешь?'),
    ];
  }

  static List<Lesson> _generateSeason(int sId, String sTitle, List<String> names) {
    return List.generate(names.length, (i) => _createLesson(sId * 100 + i + 1, sId, i + 1, 'Миссия ${i + 1}: ${names[i]}', sTitle, 'В этой миссии ты узнаешь всё про ${names[i]} и научишься применять это на практике вместе с Нейрошей!', 'Твое открытие в этой миссии?'));
  }

  static Lesson _createLesson(int id, int season, int order, String title, String sub, String theory, String practiceHint) {
    return Lesson(
      id: id, seasonId: season, order: order, title: title, subtitle: sub,
      theoryText: theory, durationMinutes: 15, iconName: 'rocket_launch',
      tasks: [
        Task(title: 'Практика: $title', description: 'Твое задание', type: TaskType.text, instruction: practiceHint, totalPoints: 30),
        Task(title: 'Блиц-проверка', description: 'Мини-квиз', type: TaskType.quiz, totalPoints: 20, 
          questions: [TaskQuestion(question: 'Готов идти дальше?', options: ['Да, я всё понял!', 'Нужно еще время'], correctAnswer: 'Да, я всё понял!', points: 20)]),
      ],
    );
  }
}

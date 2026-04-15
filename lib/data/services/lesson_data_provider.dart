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
    if (current.seasonId < 8) return getLessonsBySeason(current.seasonId + 1).isNotEmpty ? getLessonsBySeason(current.seasonId + 1)[0] : null;
    return null;
  }

  // --- НАПОЛНЕНИЕ ВСЕХ СЕЗОНОВ ---

  static List<Lesson> getSeason1Lessons() {
    return [
      _create(1, 1, 1, 'Код Машин', 'Компьютер учится на 1000 фото котиков. Попробуй найти 1 главный признак яблока?'),
      _create(2, 1, 2, 'Мозг ИИ', 'Нейросеть — это паутина связей. Если бы ты мог выучить любой язык за 1 секунду, какой выберешь?'),
      _create(3, 1, 3, 'Сила Запроса', 'Хороший промпт = Роль + Задача + Стиль. Напиши промпт: "Кот-повар готовит..."'),
      _create(4, 1, 4, 'ИИ-Арт', 'ИИ рисует по словам. Опиши обложку игры про гонки на улитках в космосе!'),
      _create(5, 1, 5, 'Галлюцинации', 'ИИ может врать уверенно. Спроси его: "Кто победил в битве за Марс в 1900 году?"'),
      _create(6, 1, 6, 'Безопасность', 'Не давай ИИ свой адрес или пароль. Напиши 3 вещи, которые нельзя говорить роботам.'),
      _create(7, 1, 7, 'ИИ-Тьютор', 'ИИ может объяснить физику как сказку. Попроси его объяснить, почему небо синее.'),
      _create(8, 1, 8, 'Твой Робот', 'Создай правила для своего бота. Как его зовут и какой у него характер?'),
    ];
  }

  static List<Lesson> getSeason2Lessons() {
    return [
      _create(101, 2, 1, 'Битмейкер', 'ИИ создает музыку по настроению. Опиши стиль своего трека (напр. "Грустный робот").'),
      _create(102, 2, 2, 'Голос-Клон', 'ИИ может говорить твоим голосом. Как это поможет в создании мультфильма?'),
      _create(103, 2, 3, 'Кино из текста', 'Напиши сценарий на 5 секунд видео: Робот танцует под дождем из конфет.'),
      _create(104, 2, 4, 'Подкаст-Шоу', 'ИИ пишет сценарий для радио. О чем будет твой первый выпуск?'),
      _create(105, 2, 5, 'Аниматор', 'Оживи картинку: что должно двигаться на фото горного озера?'),
      _create(106, 2, 6, 'Твой Клип', 'Соедини музыку и видео. Опиши главную идею своего первого ИИ-клипа.'),
    ];
  }

  static List<Lesson> getSeason3Lessons() {
    return [
      _create(301, 3, 1, 'ИИ-Кодер', 'ИИ пишет функции. Попроси его написать код для калькулятора на Python.'),
      _create(302, 3, 2, 'Авто-Мастер', 'Пусть ИИ сам сортирует файлы. Какое скучное дело ты бы отдал роботу?'),
      _create(303, 3, 3, 'Свой Сайт', 'ИИ соберет страницу за 5 минут. Придумай крутой заголовок для своего сайта.'),
      _create(304, 3, 4, 'Детектив Цифр', 'ИИ ищет паттерны. Какие данные из твоих игр можно проанализировать?'),
      _create(305, 3, 5, 'Бот-Квест', 'Создай Telegram бота для игры с друзьями. Какая будет первая команда?'),
      _create(306, 3, 6, 'App-Гений', 'Придумай идею приложения, которое решит твою проблему в школе.'),
    ];
  }

  static List<Lesson> getSeason4Lessons() {
    return [
      _create(401, 4, 1, 'Мир Героев', 'Создай персонажа с уникальной суперсилой ИИ. Как его зовут?'),
      _create(402, 4, 2, 'Комикс-Мастер', 'Опиши 3 кадра для комикса про битву роботов на кухонном столе.'),
      _create(403, 4, 3, 'Поэт-Машина', 'Попроси ИИ написать рэп про исследование нейросетей. Оцени результат.'),
      _create(404, 4, 4, 'Квест-Автор', 'Создай историю, где читатель выбирает: идти в пещеру или в портал.'),
      _create(405, 4, 5, 'Голос Книги', 'Озвучь свою историю разными голосами ИИ. Какой голос подходит злодею?'),
      _create(406, 4, 6, 'Твоя Книга', 'Собери все главы и картинки. О чем твоя первая ИИ-книга?'),
    ];
  }

  static List<Lesson> getSeason5Lessons() {
    return [
      _create(501, 5, 1, 'Ловушка Фейков', 'Как отличить фото ИИ от настоящего? Напиши 2 признака (напр. пальцы).'),
      _create(502, 5, 2, 'След в сети', 'ИИ знает всё о твоих лайках. Как защитить свою приватность?'),
      _create(503, 5, 3, 'Этика ИИ', 'Должен ли ИИ указывать, что он робот? Твоё мнение.'),
      _create(504, 5, 4, 'Баланс', 'Как пользоваться ИИ и не разучиться думать самому? Напиши правило.'),
      _create(505, 5, 5, 'Поиск Истины', 'Найди в интернете новость и проверь её с помощью ИИ. Правда или фейк?'),
      _create(506, 5, 6, 'Детектив', 'Твое финальное расследование: найди галлюцинацию в рассказе ИИ.'),
    ];
  }

  static List<Lesson> getSeason6Lessons() {
    return [
      _create(601, 6, 1, 'Smart-Учеба', 'ИИ как репетитор по математике. Попроси его объяснить дробь через пиццу.'),
      _create(602, 6, 2, 'Языковой барьер', 'Поговори с ИИ на английском про космос. Напиши, что было трудно.'),
      _create(603, 6, 3, 'Спорт и ИИ', 'ИИ анализирует твой бег. Как технологии помогают атлетам?'),
      _create(604, 6, 4, 'Научный поиск', 'Найди с ИИ ответ на вопрос: "Могут ли роботы чувствовать?"'),
      _create(605, 6, 5, 'План на день', 'Пусть ИИ составит тебе идеальное расписание. Что он туда добавил?'),
      _create(606, 6, 6, 'Помощник', 'Создай своего ассистента для школы. Его главная суперсила?'),
    ];
  }

  static List<Lesson> getSeason7Lessons() {
    return [
      _create(701, 7, 1, 'Мир 2035', 'Предскажи: какая технология будет у каждого ребенка через 10 лет?'),
      _create(702, 7, 2, 'Киборги', 'Нейроинтерфейсы — связь мозга и ПК. Ты бы хотел управлять игрой мыслью?'),
      _create(703, 7, 3, 'AGI - Сверхразум', 'Когда ИИ станет умнее всех людей вместе взятых? Твой прогноз.'),
      _create(704, 7, 4, 'Профессии', 'Кем ты будешь работать, если всё будут делать роботы? Твоя идея.'),
      _create(705, 7, 5, 'Законы Роботов', 'Напиши свой закон для ИИ, чтобы он никогда не вредил людям.'),
      _create(706, 7, 6, 'Видение', 'Опиши свой идеальный день в будущем с ИИ-другом.'),
    ];
  }

  static List<Lesson> getSeason8Lessons() {
    return [
      _create(801, 8, 1, 'Идея Проекта', 'Что ты создашь? Напиши название и главную цель.'),
      _create(802, 8, 2, 'План Миссии', 'Разбей свой проект на 5 маленьких шагов. С чего начнешь?'),
      _create(803, 8, 3, 'Черновик', 'Создай первую версию (текст или схему). Что уже работает?'),
      _create(804, 8, 4, 'Красота', 'Выбери цвета и иконки. Как твой проект привлечет детей?'),
      _create(805, 8, 5, 'Интеллект', 'Добавь промпт, который делает твой проект "умным".'),
      _create(806, 8, 6, 'Тест-Драйв', 'Дай попробовать другу. Какой главный совет ты получил?'),
      _create(807, 8, 7, 'Презентация', 'Напиши 3 предложения, которые заставят всех скачать твой проект.'),
      _create(808, 8, 8, 'ФИНАЛ!', 'Ты — Мастер Нейросетей! Твое финальное слово будущим ученикам.'),
    ];
  }

  static Lesson _create(int id, int s, int o, String t, String theory) {
    return Lesson(
      id: id, seasonId: s, order: o, title: t, subtitle: 'Миссия $o',
      theoryText: theory, durationMinutes: 10, iconName: 'rocket_launch',
      tasks: [
        Task(title: 'Твоя Практика', description: 'Действуй!', type: TaskType.text, instruction: 'Напиши свой ответ здесь...', totalPoints: 50),
      ],
    );
  }
}

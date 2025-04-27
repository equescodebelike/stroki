// List<int> suffixBorderArray(String S) {
//   int n = S.length;
//   List<int> bs = List.filled(n, 0); // Инициализация массива bs нулями

//   // Проход по строке справа налево
//   for (int i = n - 2; i >= 0; --i) {
//     int bsLeft = bs[i + 1]; // длина текущей грани

//     // переходим к предыдущей грани
//     while (bsLeft > 0 && S[i] != S[n - bsLeft - 1]) {
//       bsLeft = bs[n - bsLeft];
//     }

//     // Если символы совпадают, увеличиваем длину грани на 1
//     if (S[i] == S[n - bsLeft - 1]) {
//       // длина наибольшей грани
//       bs[i] = bsLeft + 1;
//     } else {
//       bs[i] = 0; // Иначе грань нулевой длины
//     }
//   }

//   return bs;
// }

List<int> suffixBorderArrayNaive(String S) {
  int n = S.length;
  List<int> bs = List.filled(n, 0); // Инициализация массива bs нулями

  // Проход по всем суффиксам
  for (int i = n - 1; i >= 0; --i) {
    int maxBorder = 0; // Максимальная длина грани для текущего суффикса

    // Проверяем все возможные грани
    for (int len = 1; len <= n - i; ++len) {
      // Проверяем, является ли подстрока S[i..i+len-1] гранью
      if (S.substring(i, i + len) == S.substring(n - len, n)) {
        maxBorder = len; // Обновляем максимальную длину грани
      }
    }

    bs[i] = maxBorder; // Записываем результат в массив
  }

  return bs;
}

List<int> suffixZValues(String S) {
  int n = S.length;
  List<int> zs = List.filled(n, 0);
  if (n == 0) return zs;

  int l = n - 1;
  int r = n - 1;
  zs[n - 1] = 0;
  // n - 1 раз по 1 свойству
  for (int i = n - 2; i >= 0; i--) {
    zs[i] = 0;
    // если позиция не покрыта z-блоком
    // 1
    if (i <= l) {
      zs[i] = strCompBack(S, i, n - 1);
      // вычисляем новые границы
      r = i;
      l = r - zs[i];
    } else {
      // если позиция покрыта z-блоком
      // 2a

      int j = n - (r + 1 - i);
      if (zs[j] < i - l) {
        // подстрока, оканчивающаяся в i полностью лежит внутри текущего z-блока
        // мы копируем значение
        zs[i] = zs[j];
        continue;
      } else {
        // выходим за границы текущего блока
        // 2b

        // иначе начинаем с конца текущего блока, что исключает повторную проверку символов

        // с L-ой строки начинаем сравнивать символы
        int matched = strCompBack(S, l, n - i + l);
        zs[i] = (i - l) + matched;
        r = i;
        l = r - zs[i];
      }
    }
  }
  // O(n) + O(n) = O(n)
  return zs;
}

int strCompBack(String S, int i1, int i2) {
  int eqLen = 0;
  // O(n) неудачных O(n) удачных
  // границы блока только уменьшаются, max n позиций
  while (i1 >= 0 && i2 >= 0) {
    print(S[i1] + '\n');
    print(S[i2] + '\n');
    if (S[i1] != S[i2]) break;
    eqLen++;
    i1--;
    i2--;
  }
  return eqLen;
}

void kmp(String pattern, String text) {
  if (pattern.isEmpty) {
    print("Образец пуст");
    return;
  }

  int m = pattern.length;
  int n = text.length;

  List<int> bp = _computePrefixBorder(pattern);
  List<int> bpm = _convertBPtoBPM(bp, pattern);

  int k = 0; // поддержание текущей длины совпдающего префикса
  for (int i = 0; i < n; i++) {
    // быстрые продвижения при фиксированном i
    while (k > 0 && pattern.codeUnitAt(k) != text.codeUnitAt(i)) {
      // пропускаем заведомо не совпадающие позиции
      k = bpm[k - 1]; // Каждый шаг while уменьшает k на ≥1
      // общее число уменьшений > общее число увеличений
    }

    if (pattern.codeUnitAt(k) == text.codeUnitAt(i)) {
      k++; // увеличивается на меньше или 1 раз при каждом шаге for
    }

    if (k == m) {
      print("Вхождение с позиции ${i - m + 1}");
      k = bpm[k - 1];
    }
  }
}

// построение массива граней
// O(m)
List<int> _computePrefixBorder(String pattern) {
  int m = pattern.length;
  List<int> bp = List.filled(m, 0);
  int k = 0;

  for (int i = 1; i < m; i++) {
    while (k > 0 && pattern.codeUnitAt(i) != pattern.codeUnitAt(k)) {
      k = bp[k - 1];
    }

    if (pattern.codeUnitAt(i) == pattern.codeUnitAt(k)) {
      k++;
    } else {
      k = 0;
    }

    bp[i] = k;
  }

  return bp;
}

// модифицированный массив граней
// O(m)
//Он гарантирует, что после сдвига P[bpm[k-1]] ≠ P[k].
// Если P[bp[k-1]] == P[k], то вместо bp[k-1] берётся bpm[bp[k-1] - 1] (рекурсивно ищется меньшая грань, где символы различаются).
// гарантируя, что после сдвига следующий сравниваемый символ точно не совпадёт с текущим несовпавшим символом в тексте
//В худшем случае (без bpm) КМП может деградировать до O(n×m), но с bpm остаётся строго O(n + m).
List<int> _convertBPtoBPM(List<int> bp, String pattern) {
  int m = pattern.length;
  List<int> bpm = List.from(bp);

  for (int k = 0; k < m; k++) {
    if (k < m - 1 && pattern.codeUnitAt(bpm[k]) == pattern.codeUnitAt(k + 1)) {
      if (bpm[k] > 0) {
        bpm[k] = bpm[bpm[k] - 1];
      } else {
        bpm[k] = 0;
      }
    }
  }

  return bpm;
}

void shiftAndWithAlphabet(String pattern, String text) {
  final m = pattern.length;
  final n = text.length;

  if (m == 0 || n == 0 || m > n) return;

  const chBeg = '0';
  const chEnd = 'z';
  final alphabetSize = chEnd.codeUnitAt(0) - chBeg.codeUnitAt(0) + 1;

  final B = List<int>.filled(alphabetSize, 0);
  // O(n) + alphabetSize
  for (var j = 0; j < m; j++) {
    final char = pattern[j];
    // вычитаем chBeg чтобы не хранить числа, соотв не используемым символам алфавита
    final charCode = char.codeUnitAt(0) - chBeg.codeUnitAt(0);
    // битовая карта вхождений
    if (charCode >= 0 && charCode < alphabetSize) {
      // Условие (b): Проверка совпадения текущего символа
      // тк мы нумеруем позиции слева направо, а рязряды двоичных чисел
      // младшие находятся находятся наоборот справа
      B[charCode] |= 1 << (m - 1 - j);
    }
  }
  final uHigh = 1 << (m - 1); // Константа для старшего разряда
  // массив битовых карт
  var M = 0;
  // Вычисление «строк матрицы» и фиксация вхождений
  for (var i = 0; i < n; i++) {
    final currentChar = text[i];
    final charCode = currentChar.codeUnitAt(0) - chBeg.codeUnitAt(0);
    // Условие (a): Проверка совпадения префиксов
    M = ((M >> 1) | uHigh) & B[charCode];
    // 1 в младшем разряде?
    if ((M & 1) == 1) {
      print("Найдено вхождение с позиции ${i - m + 1}");
    }
  }
}

void boyerMoore(String pattern, String text, bool strongRule) {
  int m = pattern.length;
  int n = text.length;

  // Препроцессинг для правила плохого символа
  Map<String, int> badCharShift = preprocessBadChar(pattern);

  // Препроцессинг для правила хорошего суффикса
  List<int> bs = List.filled(m, 0);
  suffixBorderArray(pattern, bs);

  List<int> br = List.filled(m, 0);
  bsToBr(bs, br, m);

  List<int> bsModified = List.from(bs);
  if (strongRule) {
    bsToBsm(bsModified, m, pattern);
  }

  // заполняем фиктивными значениями
  // не для любой позиции слева есть ближайший хороший суффикс
  List<int> ns = List.filled(m, -1);
  bsToNs(bsModified, ns, m);

  int currentTextPosition = m; // Правая граница «прикладывания» образца

  while (currentTextPosition <= n) {
    // Поиск вхождений
    int patternIndex = m - 1;
    int textIndex = currentTextPosition - 1;
    // Сравнение образца с текстом справа налево
    while (patternIndex >= 0 && pattern[patternIndex] == text[textIndex]) {
      patternIndex--;
      textIndex--;
    }
    // Результаты сравнения
    if (patternIndex < 0) {
      print("Найдено вхождение на позиции ${textIndex + 1}");
      int goodSuffixShift = m - br[0];
      currentTextPosition += goodSuffixShift;
    } else {
      // Продвижение по наиболее эффективному правилу
      int badShift =
          badCharShift.containsKey(text[textIndex]) ? patternIndex - badCharShift[text[textIndex]]! : patternIndex + 1;

      int goodSuffixShift = goodSuffixShiftFunction(ns, br, patternIndex, m);

      currentTextPosition += max(badShift, goodSuffixShift);
    }
  }
}

// Создаёт таблицу последних вхождений символов
Map<String, int> preprocessBadChar(String pattern) {
  Map<String, int> shiftMap = {};
  for (int i = 0; i < pattern.length; i++) {
    shiftMap[pattern[i]] = i;
  }
  // "ABCDABD" создаст {'A':4, 'B':5, 'C':2, 'D':6}
  return shiftMap;
}

void suffixBorderArray(String pattern, List<int> bs) {
  int m = pattern.length;
  bs[m - 1] = 0;
  int border = 0;

  for (int i = m - 2; i >= 0; i--) {
    border = bs[i + 1];
    while (border > 0 && pattern[i] != pattern[m - 1 - border]) {
      border = bs[m - border];
    }
    if (pattern[i] == pattern[m - 1 - border]) {
      border++;
    }
    bs[i] = border;
  }
}

// Создаёт массив br, где br[k] — наибольшая грань, не превышающая длину текущего суффикса m-k-1
// Используется для случаев, когда нет полной копии суффикса
// каждый элемент br[k] получает значение 1 раз
// массивы можно совместить
void bsToBr(List<int> bs, List<int> br, int m) {
  int currentBorder = bs[0];
  int k = 0;

  while (currentBorder > 0) {
    // k < m - currBorder <=> currBorder < m - k
    while (k < m - currentBorder) {
      br[k] = currentBorder; // Меньшая грань образца (k = m - currBorder)
      k++;
    }
    currentBorder = bs[m - currentBorder];
  }

  while (k < m) {
    br[k] = 0;
    k++;
  }
}

// Проверяет условие сильного правила: символ перед гранью должен отличаться
// Корректирует значения граней для соблюдения этого условия
void bsToBsm(List<int> bs, int m, String pattern) {
  for (int j = 0; j < m; j++) {
    if (bs[j] > 0) {
      int border = bs[j];
      if (j - border >= 0 && pattern[j - border] == pattern[m - 1 - border]) {
        bs[j] = bs[m - border];
      }
    }
  }
}

// Заполняет массив ns, где ns[k] хранит позицию ближайшей слева копии суффикса pattern[k+1..m-1]
// Используется для быстрого определения сдвига по правилу хорошего суффикса
void bsToNs(List<int> bs, List<int> ns, int m) {
  for (int j = 0; j < m - 1; j++) {
    if (bs[j] != 0) {
      // порядок просмотра bs гарантирует сохранение позиций самых правых копий суффиксов
      int k = m - bs[j] - 1;
      if (k >= 0 && k < m) {
        ns[k] = j;
      }
    }
  }
}

// ns массив ближайших суффиксов слева либо сильное либо слабое правило
int goodSuffixShiftFunction(List<int> ns, List<int> br, int posBad, int m) {
  if (posBad == m - 1) return 1; // Хорошего суффикса нет
  if (posBad < 0) return m - br[0]; // Образец совпал – сдвиг по наиб. грани
  int copyPos = ns[posBad]; // Вхождение левой копии суффикса
  if (copyPos >= 0) {
    return posBad - copyPos + 1;
  } else {
    return m - br[posBad]; // Cдвиг по ограниченной наибольшей грани
  }
}

int max(int a, int b) => a > b ? a : b;

int gorner2Mod(List<int> S, int m, int q) {
  int res = 0;
  for (int i = 0; i < m; i++) {
    res = (res * 2 + S[i]) % q;
  }
  return res;
}

void KR(String P, String T, int q) {
  List<int> pBinary = P.codeUnits.map((c) => c & 1).toList();
  List<int> tBinary = T.codeUnits.map((c) => c & 1).toList();
  
  int m = P.length;
  int n = T.length;
  
  int p2m = 1;
  for (int i = 0; i < m - 1; i++) {
    p2m = (p2m * 2) % q;
  }
  
  int hp = gorner2Mod(pBinary, m, q);
  int ht = gorner2Mod(tBinary, m, q);

  for (int j = 0; j <= n - m; j++) {
    if (ht == hp) {
      bool match = true;
      // только при коллизии заходим в цикл
      // 1/q
      for (int k = 0; k < m; k++) {
        if (P[k] != T[j + k]) {
          match = false;
          break;
        }
      }
      if (match) {
        print("Найдено вхождение c позиции $j");
      }
    }
    
    if (j < n - m) {
      // const
      ht = ((ht - p2m * tBinary[j]) * 2 + tBinary[j + m]) % q;
      if (ht < 0) {
        ht += q;
      }
    }
  }
}

void main() {
  String text = "ABAAABCDABCABCDABCDABDE";
  String pattern = "ABCDABD";
  KR(pattern, text, 7);
}

// void main() {
//   final pattern = "abra";
//   final text = "abracadabra";
//   shiftAndWithAlphabet(pattern, text);

// }

// void main() {
//   String text = "ABABDABACDABABCABABD";
//   String pattern = "ABABCABAB";
//   kmp(pattern, text);
// }

// void main() {
//   String S = "abacabadabacaba";
//   List<int> bs = suffixZValues(S);

//   print("Массив z-значений суффиксов: $bs");
// }

List<int> suffixBorderArray(String S) {
  int n = S.length;
  List<int> bs = List.filled(n, 0); // Инициализация массива bs нулями

  // Проход по строке справа налево
  for (int i = n - 2; i >= 0; --i) {
    int bsLeft = bs[i + 1]; // длина текущей грани

    // переходим к предыдущей грани
    while (bsLeft > 0 && S[i] != S[n - bsLeft - 1]) {
      bsLeft = bs[n - bsLeft];
    }

    // Если символы совпадают, увеличиваем длину грани на 1
    if (S[i] == S[n - bsLeft - 1]) {
      // длина наибольшей грани
      bs[i] = bsLeft + 1;
    } else {
      bs[i] = 0; // Иначе грань нулевой длины
    }
  }

  return bs;
}

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
    if (i <= l) {
      zs[i] = strCompBack(S, i, n - 1);
      // вычисляем новые границы
      r = i;
      l = r - zs[i];
    } else {
      // если позиция покрыта z-блоком

      // на сколько мы отошли от начала покрывающего z-блока
      int j = n - (r + 1 - i);
      if (zs[j] < i - l) {
        // константая сложность, если внутри текущего z-блока

        // подстрока, оканчивающаяся в i полностью лежит внутри текущего z-блока
        // мы копируем значение
        zs[i] = zs[j];
        continue;
      } else {
        // выходим за границы текущего блока

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

  int k = 0; // текущий индекс в образце
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

void main() {
  String text = "ABABDABACDABABCABABD";
  String pattern = "ABABCABAB";
  kmp(pattern, text);
}

// void main() {
//   String S = "abacabadabacaba";
//   List<int> bs = suffixZValues(S);

//   print("Массив z-значений суффиксов: $bs");
// }

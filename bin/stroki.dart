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
      int j = n - (r + 1 - i);
      if (zs[j] < i - l) {
        // константая сложность, если внутри текущего z-блока
        zs[i] = zs[j];
        continue;
      } else {
        // иначе начинаем с конца текущего блока, что исключает повторную проверку символов
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
    if (S[i1] != S[i2]) break;
    eqLen++;
    i1--;
    i2--;
  }
  return eqLen;
}

void main() {
  String S = "abacabadabacaba";
  List<int> bs = suffixZValues(S);

  print("Массив z-значений суффиксов: $bs");
}

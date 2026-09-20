#import "../../../../config.typ": *
#import "@preview/cetz:0.4.2"

#show: template-post.with(
  title: "2026 CSP-S 第一轮真题解析",
  description: "2026 年 CCF CSP-S 第一轮（提高级 C++ 语言）认证真题与详细的答案解析，含 15 道单项选择题、3 篇阅读程序与 2 篇完善程序。",
  tags: ("NOI 系列真题",),
  category: "CSP-S 真题",
  date: datetime(year: 2026, month: 9, day: 20)
)

#set enum(numbering: "A.")

= 一、单项选择题

*第 1 题*

#note(title: "题面")[
  执行下列代码后，`cnt` 的值是（ ）

  ```cpp
  int x = 2026, cnt = 0;
  while (x) {
    x &= x - 1;
    cnt++;
  }
  ```

  #choice[6][7][11][8]
]

#success(title: "答案")[
  语句 `x &= x - 1` 在树状数组的代码中就有出现，其作用是消去 $x$ 的二进制表示中最低位的一个 1，因此循环次数就是 $x$ 中 1 的个数。
  
  一种做法是将 2026 写成二进制：
  
  $ 2026 = 2^10 + 2^9 + 2^8 + 2^7 + 2^6 + 2^5 + 2^3 + 2^1 $
  
  其二进制表示共有 8 个 `1`，故 `cnt` 最终为 8。
  
  另一种更好的做法则是注意到 2026 十分靠近 $2^11 = 2048$，因此可以考虑写作 $2026 = 2047 - 21$。注意到 2047 的二进制表示是长度为 11 的全 `1` 串，而 21 的二进制表示是 `10101`，因此 2026 的二进制表示就是长度为 11 的全 `1` 串去掉了 21 的二进制表示中的 `1`，即去掉了 3 个 `1`，就剩下 $11 - 3 = 8$ 个 `1`。
  
  因此，本题的答案为 D。
]

*第 2 题*

#note(title: "题面")[
  用权值 ${1, 2, 3, 4, 5, 6, 7, 8}$ 构造哈夫曼树，其带权路径长度是（ ）

  #choice[108][96][99][102]
]

#success(title: "答案")[
  构造哈夫曼树时，每次取当前权值最小的两个结点合并，各次合并的代价依次为：

  #table(
    columns: 4,
    table.header(
      [轮次], [合并的两个权值], [合并代价], [剩余权值]
    ),
    [1], [1, 2], [3], [3, 3, 4, 5, 6, 7, 8],
    [2], [3, 3], [6], [4, 5, 6, 6, 7, 8],
    [3], [4, 5], [9], [6, 6, 7, 8, 9],
    [4], [6, 6], [12], [7, 8, 9, 12],
    [5], [7, 8], [15], [9, 12, 15],
    [6], [9, 12], [21], [15, 21],
    [7], [15, 21], [36], [36],
  )

  带权路径长度等于所有合并代价之和，即

  $ 3+6+9+12+15+21+36 = 102 $

  因此，本题的答案为 D。
]

*第 3 题*

#note(title: "题面")[
  把 1 到 1000 的所有整数按十进制写出，数字“1”总共出现了多少次（ ）

  #choice[300][271][301][320]
]

#success(title: "答案")[
  先统计 1～999 中数字“1”出现的次数，把每个数补足三位考虑：

  - 个位为 1：每 10 个数出现一次，共 100 次；
  - 十位为 1：每 100 个数中出现 10 次，共 100 次；
  - 百位为 1：仅在 100 到 199 中出现，共 100 次。

  合计 300 次。1000 的千位上还有一个 1，总计 301 次。因此，本题的答案为 C。
]

*第 4 题*

#note(title: "题面")[
  将 5 封信随机装入 5 个写好地址的信封（每封一个），恰好有 2 封装对的方案数是（ ）

  #choice[44][24][10][20]
]

#success(title: "答案")[
  恰好有 2 封装对，有 $binom(5, 2) = 10$ 种选法；剩下的 3 封要求全部装错，3 个元素的错排数为 2。因此方案总数为 $10 times 2 = 20$。因此，本题的答案为 D。
]

*第 5 题*

#note(title: "题面")[
  $3^2026 mod 100$ 的值是（ ）

  #choice[29][9][43][81]
]

#success(title: "答案")[
  可以使用快速幂的方法计算 $3^2026 mod 100$。在第 1 题中可以得到 2026 的二进制表示为 $11111101010_2$，因此：

  $
    3^(1_2) &= 3^1 equiv 3 space (mod 100) \
    3^(11_2) &= 3^3 = (3^1)^2 times 3 equiv 9 times 3 equiv 27 space (mod 100) \
    3^(111_2) &= 3^7 = (3^3)^2 times 3 equiv 27^2 times 3 equiv 29 times 3 equiv 87 space (mod 100) \
    3^(1111_2) &= 3^15 = (3^7)^2 times 3 equiv 87^2 times 3 equiv 69 times 3 equiv 7 space (mod 100) \
    3^(11111_2) &= 3^31 = (3^15)^2 times 3 equiv 7^2 times 3 equiv 49 times 3 equiv 47 space (mod 100) \
    3^(111111_2) &= 3^63 = (3^31)^2 times 3 equiv 47^2 times 3 equiv 9 times 3 equiv 27 space (mod 100) \
    3^(1111110_2) &= 3^126 = (3^63)^2 equiv 27^2 equiv 29 space (mod 100) \
    3^(11111101_2) &= 3^253 = (3^126)^2 times 3 equiv 29^2 times 3 equiv 41 times 3 equiv 23 space (mod 100) \
    3^(111111010_2) &= 3^506 = (3^253)^2 equiv 23^2 equiv 29 space (mod 100) \
    3^(1111110101_2) &= 3^1013 = (3^506)^2 times 3 equiv 29^2 times 3 equiv 41 times 3 equiv 23 space (mod 100) \
    3^(11111101010_2) &= 3^2026 = (3^1013)^2 equiv 23^2 equiv 29 space (mod 100)
  $

  另一种方法则是注意到 $3^20 = 3486784401 equiv 1 space (mod 100)$，即 3 的幂次在模 100 下以 20 为周期。由 $2026 equiv 6 space (mod 20)$，得

  $ 3^2026 equiv 3^6 = 729 equiv 29 space (mod 100) $

  因此，本题的答案为 A。
]

*第 6 题*

#note(title: "题面")[
  有 5 堆石子排成一行，重量依次为 $4, 1, 3, 2, 5$。每次只能把相邻的两堆合并成一堆，代价为这两堆重量之和。将所有石子合并成一堆的最小总代价是（ ）

  #choice[36][35][34][33]
]

#success(title: "答案")[
  与可以任意合并的哈夫曼问题不同，本题只能合并相邻两堆，使用区间 DP。设 $f_(i, j)$ 为把第 $i$ 到第 $j$ 堆合并成一堆的最小代价，则

  $ f_(i, j) = min_(i <= k < j)(f_(i, k) + f_(k+1, j)) + sum_(t=i)^j a_t $

  按区间长度从小到大计算：

  - 长度为 $1$ 的区间：$f_(i, i) = 0$，因为无需合并；
  - 长度为 $2$ 的区间：$f_(1, 2) = 4 + 1 = 5$，$f_(2, 3) = 1 + 3 = 4$，$f_(3, 4) = 3 + 2 = 5$，$f_(4, 5) = 2 + 5 = 7$。由于只需要合并一次，总代价就是两堆重量之和；
  - 长度为 $3$ 的区间：

    $ f_(1, 3) &= min(5 + 0, 0 + 4) + 8 = min(5, 4) + 8 = 12 \ 
    f_(2, 4) &= min(4 + 0, 0 + 5) + 6 = min(4, 5) + 6 = 10 \
    f_(3, 5) &= min(5 + 0, 0 + 7) + 10 = min(5, 7) + 10 = 15 $
  - 长度为 $4$ 的区间：

    $ f_(1, 4) &= min(0 + 10, 5 + 5, 12 + 0) + 10 = min(10, 10, 12) + 10 = 20 \
    f_(2, 5) &= min(0 + 15, 4 + 7, 10 + 0) + 11 = min(15, 11, 10) + 11 = 21 $

  - 长度为 $5$ 的区间：

    $ f_(1, 5) &= min(0 + 21, 5 + 15, 12 + 7, 20 + 0) + 15\
    & = min(21, 20, 19, 20) + 15 = 34 $

  因此，本题的答案为 C。
]

*第 7 题*

#note(title: "题面")[
  树状数组维护长度 $n = 16$ 的序列。查询前缀和 `sum(11)` 与单点修改 `add(3, x)` 分别需要访问树状数组中多少个下标（ ）

  #choice[3 和 4][4 和 4][3 和 5][4 和 3]
]

#success(title: "答案")[
  前缀和查询每次去掉下标的最低位 1，11 的二进制为 $1011_2$，依次访问 $1011_2 -> 1010_2 -> 1000_2$，共 3 个下标；
  
  单点修改每次加上最低位 1，3 的二进制为 $11_2$，依次访问 $11_2 -> 100_2 -> 1000_2 -> 10000_2$，共 4 个下标。
  
  因此，本题的答案为 A。
]

*第 8 题*

#note(title: "题面")[
  有向无环图 G 顶点集为 ${1, 2, 3, 4}$，边集为 ${(1, 2), (1, 3)}$，顶点 4 与任何顶点均不相邻。该图不同的拓扑序共有多少种（ ）

  #choice[12][8][4][6]
]

#success(title: "答案")[
  顶点 4 是孤立点，可以放在拓扑序的任意位置。对顶点 1、2、3，约束只要求 1 在 2 和 3 之前，合法的相对顺序有 `[1, 2, 3]` 和 `[1, 3, 2]` 两种；再把顶点 4 插入 4 个位置，共 $2 times 4 = 8$ 种拓扑序。因此，本题的答案为 B。
]

*第 9 题*

#note(title: "题面")[
  某分治算法满足 $T(n) = T(n\/3) + T(2n\/3) + Theta(n)$，$T(1) = O(1)$，则 $T(n)$ 是（ ）

  #choice[$Theta(n log n)$][$Theta(n^2)$][$Theta(n^1.5)$][$Theta(n)$]
]

#success(title: "答案")[
  画出分治树：

  #figure(
    auto-frame(
      cetz.canvas({
        let n = 2
        import cetz.draw: *
        set-style(content: (padding: 0.15))
        content((0, 0), [$T(n)$], name: "r")
        content((-2 * n, -1 * n), [$T(n\/3)$], name: "a")
        content((2 * n, -1 * n), [$T(2n\/3)$], name: "b")
        content((-3 * n, -2 * n), [$T(n\/9)$], name: "c")
        content((-1 * n, -2 * n), [$T(2n\/9)$], name: "d")
        content((1 * n, -2 * n), [$T(2n\/9)$], name: "e")
        content((3 * n, -2 * n), [$T(4n\/9)$], name: "f")
        content((0, -3.5 * n), [$dots.c$], name: "g")
        line("r", "a", stroke: blue, mark: (end: (symbol: "stealth", fill: blue)))
        line("r", "b", stroke: red, mark: (end: (symbol: "stealth", fill: red)))
        line("a", "c", stroke: blue, mark: (end: (symbol: "stealth", fill: blue)))
        line("a", "d", mark: (end: (symbol: "stealth", fill: black)))
        line("b", "e", mark: (end: (symbol: "stealth", fill: black)))
        line("b", "f", stroke: red, mark: (end: (symbol: "stealth", fill: red)))
        line("c", (-3.5 * n, -3 * n), stroke: blue, mark: (end: (symbol: "stealth", fill: blue)))
        line("c", (-2.5 * n, -3 * n), mark: (end: (symbol: "stealth", fill: black)))
        line("d", (-1.5 * n, -3 * n), mark: (end: (symbol: "stealth", fill: black)))
        line("d", (-0.5 * n, -3 * n), mark: (end: (symbol: "stealth", fill: black)))
        line("e", (0.5 * n, -3 * n), mark: (end: (symbol: "stealth", fill: black)))
        line("e", (1.5 * n, -3 * n), mark: (end: (symbol: "stealth", fill: black)))
        line("f", (2.5 * n, -3 * n), mark: (end: (symbol: "stealth", fill: black)))
        line("f", (3.5 * n, -3 * n), stroke: red, mark: (end: (symbol: "stealth", fill: red)))
      })
    ),
    caption: [分治树的示意图]
  )

  整棵分治树的最浅儿子由蓝色箭头部分决定，其深度为 $log_3 n$；最深儿子由红色箭头决定，其深度为 $log_(1.5) n$。考虑到 $T(n)$ 的额外代价与数据规模呈线性，因此全满的层对应的额外代价总和恰好为 $Theta(n)$。

  那么，前 $log_3 n$ 层应当是全满的，那么 $T(n)$ 的增长率应当不低于 $n log_(3) n$，即 $T(n) = Omega(n log_3 n) = Omega(n log n)$；而整棵树共 $log_(1.5) n$ 层，那么 $T(n)$ 的增长率应当不高于 $n log_(1.5) n$，即 $T(n) = O(n log_(1.5) n) = O(n log n)$。

  综上，$T(n)$ 的增长率不低于 $n log n$，也不高于 $n log n$，因此 $T(n) = Theta(n log n)$。
  
  因此，本题的答案为 A。
]

*第 10 题*

#note(title: "题面")[
  无根树含 9 个结点（编号为 $1 tilde 9$），边集为
  
  $ {(1, 2), (1, 3), (2, 4), (2, 5), (3, 6), (6, 7), (7, 8), (5, 9)} $
  
  该树的直径（以边数计）与重心分别是（ ）

  #choice[直径 6，重心为结点 3][直径 7，重心为结点 2][直径 8，重心为结点 1][直径 7，重心为结点 1]
]

#success(title: "答案")[
  以下为这棵树的示意图：

  #figure(
    auto-frame(
      cetz.canvas(length: 1.2cm, {
        import cetz.draw: *
        circle((0, 0), radius: 0.4, name: "n9")
        circle((1.4, 0), radius: 0.4, name: "n5")
        circle((2.8, 0), radius: 0.4, name: "n2")
        circle((4.2, 0), radius: 0.4, name: "n1")
        circle((5.6, 0), radius: 0.4, name: "n3")
        circle((7, 0), radius: 0.4, name: "n6")
        circle((8.4, 0), radius: 0.4, name: "n7")
        circle((9.8, 0), radius: 0.4, name: "n8")
        circle((2.8, -1.3), radius: 0.4, name: "n4")
        content((0, 0), $9$)
        content((1.4, 0), $5$)
        content((2.8, 0), $2$)
        content((4.2, 0), $1$)
        content((5.6, 0), $3$)
        content((7, 0), $6$)
        content((8.4, 0), $7$)
        content((9.8, 0), $8$)
        content((2.8, -1.3), $4$)
        line("n9", "n5")
        line("n5", "n2")
        line("n2", "n1")
        line("n1", "n3")
        line("n3", "n6")
        line("n6", "n7")
        line("n7", "n8")
        line("n2", "n4")
      })
    ),
    caption: [无根树的示意图]
  )

  路径 $9 -> 5 -> 2 -> 1 -> 3 -> 6 -> 7 -> 8$ 共经过 7 条边，且不存在更长的简单路径，故直径为 7。重心的判定标准是删去该点后每个连通块的大小都不超过结点总数的一半（4）：删去结点 1 后得到 ${2, 4, 5, 9}$ 和 ${3, 6, 7, 8}$ 两个大小均为 4 的连通块；而删去结点 2 或结点 3 时都存在一个大小为 5 的连通块，因此重心为结点 1。

  因此，本题的答案为 D。
]

*第 11 题*

#note(title: "题面")[
  一张有向图缩点后得到的有向无环图含 6 个顶点，其中入度为 0 的顶点有 3 个、出度为 0 的顶点有 4 个。为使原图变成强连通图，至少需要添加多少条有向边（ ）

  #choice[7][6][4][3]
]

#success(title: "答案")[
  实际上，当缩点后的 DAG 至少有两个顶点时，使整个图强连通所需添加的最少边数为 $max(a, b)$，其中 $a$、$b$ 分别是入度为 0 和出度为 0 的顶点数。以下是简单的证明：
  
  本题中 $max(3, 4) = 4$，故需要添加 4 条有向边。因此，本题的答案为 C。
]

*第 12 题*

#note(title: "题面")[
  含 6 个结点的不同形态的二叉树共有多少棵（结点不带标号，区分左右子树）（ ）

  #choice[42][429][132][720]
]

#success(title: "答案")[
  设 $n$ 个结点的二叉树形态数为 $f_n$，那么有

  $
    f_n = sum_(i=0)^(n - 1) f_i f_(n - 1 - i)
  $

  直接通过递推式可以得到：

  $
    f_0 &= 1\
    f_1 &= 1 times 1 = 1\
    f_2 &= 1 times 1 + 1 times 1 = 2\
    f_3 &= 1 times 2 + 1 times 1 + 2 times 1 = 5\
    f_4 &= 1 times 5 + 1 times 2 + 2 times 1 + 5 times 1 = 14\
    f_5 &= 1 times 14 + 1 times 5 + 2 times 2 + 5 times 1 + 14 times 1 = 42\
    f_6 &= 1 times 42 + 1 times 14 + 2 times 5 + 5 times 2 + 14 times 1 + 42 times 1 = 132
  $

  当然，如果对卡特兰数的性质比较熟悉，不难发现 $n$ 个结点的二叉树形态数就是第 $n$ 个卡特兰数，公式为

  $ C_n = 1/(n+1) binom(2n, n) $

  代入 $n=6$，得 $C_6 = 1/7 binom(12, 6) = 924/7 = 132$。因此，本题的答案为 C。
]

*第 13 题*

#note(title: "题面")[
  字符串 `S = ababaabab`，其所有既是真前缀又是真后缀的子串（非空）的长度之和是（ ）

  #choice[4][6][7][5]
]

#success(title: "答案")[
  逐一比较等长的真前缀与真后缀，只有长度为 2 的子串 `ab` 和长度为 4 的子串 `abab` 同时是 `S` 的真前缀和真后缀，其余长度均不相同，故长度之和为 $2+4=6$。因此，本题的答案为 B。
]

*第 14 题*

#note(title: "题面")[
  用归并排序统计逆序对，合并部分的核心代码为

  ```cpp
  // 归并 a[l..mid] 与 a[mid+1..r]，同时累加逆序对
  if (a[i] <= a[j]) {
    tmp[k++] = a[i++]; // 取左半段元素
  } else {
    tmp[k++] = a[j++]; // 取右半段元素
    ans += mid - i + 1;
  }
  ```

  若把判断条件中的 `a[i] <= a[j]` 改成 `a[i] < a[j]`，则 `ans` 统计出的结果是（ ）

  #choice[完全不变][变为原来的两倍][变为满足 `i < j` 且 `a[i] >= a[j]` 的数对个数][变为原来的一半]
]

#success(title: "答案")[
  原条件为 `<=` 时，两侧元素相等会取左侧元素，相等的数对不被计入，`ans` 统计的是严格逆序对，即满足 `a[i] > a[j]` 的数对。改为 `<` 后，相等时会进入 `else` 分支取右侧元素并执行 `ans += mid - i + 1`，于是相等的数对也被计入，统计结果变为满足 `a[i] >= a[j]` 的数对个数，也即非严格逆序对。因此，本题的答案为 C。
]

*第 15 题*

#note(title: "题面")[
  执行 `power(2, 100, 1000)` 调用下列函数，返回值是（ ）

  ```cpp
  long long power(long long a, long long b, long long p) {
    long long r = 1 % p;
    while (b) {
      if (b & 1)
        r = r * a % p;
      a = a * a % p;
      b >>= 1;
    }
    return r;
  }
  ```

  #choice[576][376][976][176]
]

#success(title: "答案")[
  除了使用在第 5 题中使用的快速幂方案计算之外，也可以用中国剩余定理计算 $2^100 mod 1000$：

  - 模 8：显然 $2^100 equiv 0 space (mod 8)$；
  - 模 125：除了直接计算外，注意到 $phi(125) = 100$，那么由欧拉定理，$2^100 equiv 1 space (mod 125)$。

  在 0 至 999 中同时满足这两个条件的数只有 376，故返回值为 376。因此，本题的答案为 B。
]

= 二、阅读程序

== 第一部分

#note(title: "题面")[
  阅读下列程序：

  ```cpp
  #include <iostream>
  #include <string>
  using namespace std;
  int a[100];
  string s;
  int gen[13] = {1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1};
  int main() {
    cin >> s;
    for (int i = 0; i < 32; ++i) {
      a[i] = s[i] - '0';
    }
    for (int i = 32; i < 44; ++i) {
      a[i] = 0;
    }
    for (int i = 0; i < 32; ++i) {
      if (a[i] == 0) continue;
      for (int j = 0; j < 13; ++j) {
        a[i+j] ^= gen[j];
      }
    }
    for (int i = 32; i < 44; ++i) {
      cout << a[i];
    }
    cout << endl;
    return 0;
  }
  ```

  输入保证为一个长度恰为 32 的 `'0'/'1'` 字符串。
]

#warning(title: "提示")[
  该程序实现了 CRC 校验码的计算。简单来说，CRC 校验码就是把输入的二进制串看成一个多项式，用一个固定的生成多项式对它做模 2 除法，余数就是 CRC 校验码。
  
  模 2 下加减运算都可以用异或实现。在上述代码中，程序从左到右扫描二进制字符串，如果当前位为 1，则用 `gen` 数组对其进行异或操作，相当于做了一次模 2 除法的减法操作。扫描完 32 位后，数组 `a` 的第 32 至 43 位就是余数，也就是 CRC 校验码。
]

*第 16 题*

#note(title: "题面")[
  （1 分）当输入为 32 个 `'0'` 时，程序输出 12 个 0。（ ）
]

#success(title: "答案")[
  输入全为 0 时，每个 `a[i]` 都是 0，因此所有异或操作都不会执行，`a[32]` 至 `a[43]` 保持初始化的 0，故输出 12 个 0。因此，本题的答案为 $checkmark.heavy$（正确）。
]

*第 17 题*

#note(title: "题面")[
  程序运行结束后，数组 `a` 中下标从 0 到 31 的元素一定全部为 0。（ ）
]

#success(title: "答案")[
  考虑处理某一个位置 $i$ 时：若 `a[i]` 为 1，异或 `gen` 时执行 `a[i] ^= gen[0]`，即异或 1，恰好把 `a[i]` 置 0；若 `a[i]` 为 0 则直接 `continue`。另外，处理完 $i$ 之后，后续的异或范围不会再影响 $a[i]$。因此循环结束后 `a[0]` 至 `a[31]` 全部为 0。因此，本题的答案为 $checkmark.heavy$（正确）。
]

*第 18 题*

#note(title: "题面")[
  若将第 12 至 14 行（为 `a[32]` 到 `a[43]` 补 0 的循环）删除，会改变程序输出结果。（ ）
]

#success(title: "答案")[
  数组 `a` 是全局数组，根据 C++ 标准，程序启动时已经被零初始化，因此输出不会改变。因此，本题的答案为 $crossmark.heavy$（错误）。
]

*第 19 题*

#note(title: "题面")[
  关于第 6 行定义的数组 `gen`，下列说法正确的是（ ）

  #choice[gen 共有 12 个元素，表示一个 12 位的除数][gen 共有 13 个元素，表示一个 13 位的被除数][gen 共有 13 个元素，其中 `gen[0]` 是除数的最高位][gen 共有 13 个元素，其中 `gen[12]` 是除数的最高位]
]

#success(title: "答案")[
  `gen` 有 13 个元素，对应 13 位除数 `1100000001111`。注意到输入数据储存在数组的前面，而得到的结果储存在数组的后面，和循环方向综合分析，可以确认除法顺序为从左往右。异或从当前位 `a[i]` 开始，`gen[0]` 首先与 `a[i]` 异或，对应除数最高位与被除数当前位对齐，因此 `gen[0]` 是除数的最高位。因此，本题的答案为 C。
]

*第 20 题*

#note(title: "题面")[
  该程序实现的功能，最准确的说法是（ ）

  #choice[将输入的 32 位串看成二进制数 $M$，输出 $M$ 与 13 位二进制数 `1100000001111` 按位异或的结果][将输入串视为 32 位二进制数 $M$，在其后补 12 个 0（即计算 $M times 2^12$），再对它用 `1100000001111` 作模 2 除法求余数，并输出 12 位余数][对输入的 32 位串逐位取反并输出结果][统计输入串中 1 的个数，并把该个数用 12 位二进制表示后输出]
]

#success(title: "答案")[
  根据上述分析可以确认这是标准的 CRC 长除法：把 32 位信息 $M$ 后补 12 个 0（次数加 12），用 13 位生成多项式 `1100000001111` 做模 2 除法（模 2 下加减均为异或），最终输出的 `a[32]` 至 `a[43]` 就是 12 位余数。因此，本题的答案为 B。
]

*第 21 题*

#note(title: "题面")[
  若将第 16 行 `if (a[i] == 0) continue;` 删除，说法正确的是（ ）

  #choice[程序输出的结果不会改变][可能造成程序运行错误][程序能够正常输出一个 12 位 `'0'/'1'` 串，但是输出结果与输入的 s 无关][程序运行结束后，`a[0]` 的值一定为 0]
]

#success(title: "答案")[
  删除 `continue` 后，每个位置的异或都无条件执行，操作不再依赖任何 `a[i]` 的值，相当于向固定位置异或固定值。换句话说，这个程序的作用将会变成对 `gen` 数组异或一个固定的值。
  
  最终每个位置的值都等于初值异或一个常数，而 `a[32]` 至 `a[43]` 的初值均为 0，故输出是固定的 12 位串，与输入 `s` 无关。下标最大只到 `a[43]`，不会越界，也不会造成运行错误；此外执行完 $i=0$ 的异或后 `a[0]` 会被翻转，则在输入的第一个字符为 `0` 时，`a[0]` 在结束时会变为 1。因此，本题的答案为 C。
]

== 第二部分

#note(title: "题面")[
  阅读下列程序：

  ```cpp
  #include <iostream>
  using namespace std;
  int n, m, a[100007], L, R, lg[100007], i, j, t, dp[100007][25], pw[25];
  int gcd(int x, int y) {
    if (y == 0) return x;
    return gcd(y, x % y);
  }
  int main() {
    cin >> n >> m;
    for (i = 1; i <= n; i++) cin >> a[i];
    t = 0;
    pw[0] = 1;
    for (i = 1; i <= 24; i++) pw[i] = pw[i-1] * 2;
    for (i = 1; i <= 100000; i++)
      if (pw[t + 1] >= i) lg[i] = t;
      else t++, lg[i] = t;
    for (i = 1; i <= n; i++)
      dp[i][0] = a[i];
    for (j = 1; j <= lg[n]; j++)
      for (i = 1; i + pw[j] - 1 <= n; i++) {
        dp[i][j] = gcd(dp[i][j-1], dp[i + pw[j-1]][j-1]);
      }
    for (i = 1; i <= m; i++) {
      cin >> L >> R;
      cout << gcd(dp[L][lg[R-L+1]], dp[R-pw[lg[R-L+1]]+1][lg[R-L+1]]) << endl;
    }
    return 0;
  }
  ```

  保证 $1 <= n <= 100000$，每次查询满足 $1 <= L <= R <= n$，且数组 `a` 的元素均为正整数。
]

#warning(title: "提示")[
  该程序实现了一个静态区间最大公约数查询。预处理阶段使用 ST 表进行初始化，查询阶段使用两个长度不小于一半的区间的最大公约数来得到结果。关于 ST 表的原理和实现，可以参考 #link("https://oi-wiki.org/ds/sparse-table/")[这个链接]。
]

*第 22 题*

#note(title: "题面")[
  当 $n = 5$，$a = {4, 2, 6, 3, 9}$，且仅有一次查询 $L = 2$、$R = 5$ 时，输出为 1。（ ）
]

#success(title: "答案")[
  查询区间为 `a[2..5]`，也就是 ${2, 6, 3, 9}$，而 $gcd(2, 6, 3, 9) = 1$，故输出为 1。因此，本题的答案为 $checkmark.heavy$（正确）。
]

*第 23 题*

#note(title: "题面")[
  当某次查询的区间长度为 1（即 $L = R$）时，这次查询的输出一定等于 `a[L]`。（ ）
]

#success(title: "答案")[
  区间长度为 1 时，`lg[1] = 0`，两段都取 `dp[L][0] = a[L]`，于是结果为 $gcd(a[L], a[L]) = a[L]$。因此，本题的答案为 $checkmark.heavy$（正确）。
]

*第 24 题*

#note(title: "题面")[
  任意一次查询的输出结果一定不小于该查询区间内的最小值。（ ）
]

#success(title: "答案")[
  最大公约数整除区间内的每个数，因此它一定不大于区间最小值，而不是不小于。例如，数组 ${11, 12}$ 的最大公约数为 1，小于最小值 11。因此，本题的答案为 $crossmark.heavy$（错误）。
]

*第 25 题*

#note(title: "题面")[
  对于 $j >= 1$，数组 `dp[i][j]` 保存的是（ ）

  #choice[从 `a[i]` 开始连续 $j$ 个数的最大公约数][从 `a[i]` 开始连续 $2^j$ 个数的最大公约数][`a[i]` 与 `a[j]` 的最大公约数][从 `a[1]` 到 `a[i]` 的最大公约数]
]

#success(title: "答案")[
  由转移式 `dp[i][j] = gcd(dp[i][j-1], dp[i + pw[j-1]][j-1])`，又有 `pw[j-1]` 保存的是整数 $2^(j - 1)$，可以确定被合并的两端左端点距离为 $2^(j-1)$。
  
  利用归纳法，`dp[i][0]` 保存的是 `a[i]`，即从 `a[i]` 开始连续 1 个数的最大公约数。此外，如果 `dp[i][j-1]` 保存的是从 `a[i]` 开始连续 $2^(j-1)$ 个数的最大公约数，`dp[i + pw[j-1]][j-1]` 保存的是从 `a[i + 2^(j-1)]` 开始连续 $2^(j-1)$ 个数的最大公约数，那么 `dp[i][j]` 就保存了从 `a[i]` 开始连续 $2^(j-1) + 2^(j-1) = 2^j$ 个数的最大公约数，因为被合并的两段区间恰好覆盖了从 `a[i]` 开始连续 $2^j$ 个数的区间。
  
  因此，本题的答案为 B。
]

*第 26 题*

#note(title: "题面")[
  若把一次求最大公约数的运算视为 $O(1)$，则第 17～22 行建表过程的时间复杂度为（ ）

  #choice[$Theta(n)$][$Theta(n log n)$][$Theta(n^2)$][$Theta(m n)$]
]

#success(title: "答案")[
  第 $j$ 层需要计算约 $n - 2^j + 1$ 个状态，一共有 $Theta(log n)$ 层，总状态数为

  $
    &sum_(j=0)^(log_2 n) (n - 2^j + 1) \
    =& n log_2 n - sum_(j=0)^(log_2 n) 2^j + sum_(j=0)^(log_2 n) 1\
    =& n log_2 n - (2^(log_2 n + 1) - 1) + (log_2 n + 1)\
    =& n log_2 n - 2n + log_2 n + 2 = Theta(n log n)
  $
  
  
  故状态总数为 $Theta(n log n)$，每个状态转移的时间复杂度为 $O(1)$，故建表的时间复杂度为 $Theta(n log n)$。因此，本题的答案为 B。
]

*第 27 题*

#note(title: "题面")[
  设 $x$ 为一次查询的区间长度（即 $x = R - L + 1$），则使得 `lg[x]` = 5 的 x 的取值范围是（ ）

  #choice[$[16, 31]$][$[17, 32]$][$[32, 63]$][$[33, 64]$]
]

#success(title: "答案")[
  根据 `lg[x]` 的定义，只有当 `i > pw[t+1]` 时 `t` 才会增加，因此 `lg[x]` 应当等于 $floor(log_2(x - 1))$。在这一条件下，`lg[x] = 5` 等价于 $2^5 < x <= 2^6$，即 $x in [33, 64]$（根据定义，`lg[32]` 仍为 4，而 `lg[64]` 为 5）。因此，本题的答案为 D。
]

== 第三部分

#note(title: "题面")[
  阅读下列程序：

  ```cpp
  #include <iostream>
  using namespace std;
  int n, fa[100007], f[100007], ans;
  int main() {
    cin >> n;
    for (int i = 2; i <= n; ++i) {
      cin >> fa[i];
    }
    for (int i = n; i >= 2; --i) {
      if (f[fa[i]] + f[i] + 1 > ans) {
        ans = f[fa[i]] + f[i] + 1;
      }
      if (f[i] + 1 > f[fa[i]]) {
        f[fa[i]] = f[i] + 1;
      }
    }
    cout << ans << endl;
    return 0;
  }
  ```

  输入第一行为结点个数 $n$，第二行为 $n - 1$ 个整数，依次表示结点 $2 tilde n$ 的父结点编号，满足 $2 <= n <= 100000$ 且 $1 ≤ "fa"[i] < i$，根结点为 1。
]

#warning(title: "提示")[
  该程序实现了求树的直径。`f[i]` 表示以 $i$ 为根的子树中 $i$ 到最远结点的距离。逆序处理每个结点时，先用 `f[fa[i]] + f[i] + 1` 拼出经过父亲的路径，更新全局最大值 `ans`，再更新 `f[fa[i]]` 的值。最终输出的 `ans` 就是树的直径（以边数计）。

  具体而言，在程序尝试更新 `ans` 时，`f[fa[i]]` 保存的是父结点 `fa[i]` 的子树中曾枚举过的部分对应的最大高度，而 `f[i]` 保存的是当前结点 `i` 的子树中对应的最大高度。两者相加再加 1 就是从结点 `i` 出发，经过父结点 `fa[i]`，再到达父结点的另一子树中最远结点的路径长度。程序逆序枚举所有点，保证每个点都能在所有儿子被处理后被处理，从而保证了该做法的正确性。
]

*第 28 题*

#note(title: "题面")[
  当 $n = 5$，$"fa"[2] tilde "fa"[5] = {1, 2, 3, 4}$ 时，程序输出 4。（ ）
]

#success(title: "答案")[
  此时树是一条链 $1-2-3-4-5$。通过模拟计算或观察程序功能，可以确定程序输出为 4。因此，本题的答案为 $checkmark.heavy$（正确）。
]

*第 29 题*

#note(title: "题面")[
  程序输出前，`f[1]` 的值一定等于 `ans` 的值。（ ）
]

#success(title: "答案")[
  `f[1]` 保存的是根 1 到最远叶子的距离（树高），而 `ans` 是树的直径，直径可以由位于两个不同分支上的点取得。例如，第 32 题中的树高仅为 2，直径却为 4，二者并不相等。因此，本题的答案为 $crossmark.heavy$（错误）。
]

*第 30 题*

#note(title: "题面")[
  将第 $10 tilde 12$ 行与第 $13 tilde 15$ 行两个 `if` 语句的顺序交换后，程序的输出结果不受影响。（ ）
]

#success(title: "答案")[
  原顺序先用*旧的* `f[fa[i]]` 与 `f[i]` 拼出经过父亲的路径，再更新高度，保证路径两端来自两个不同分支。交换后，`f[fa[i]]` 已被当前分支的高度更新，再计算路径时可能把同一条分支计算两次。可以通过对第 28 题给出的链进行模拟证明这一点，在枚举到 $i = 2$ 时，程序首先更新 `f[1] = 4`，随后尝试更新 `ans = max(ans, f[2] + f[1] + 1)`，此时 `f[2] + f[1] + 1 = 8`。因此，本题的答案为 $crossmark.heavy$（错误）。
]

*第 31 题*

#note(title: "题面")[
  程序输出的 `ans` 表示的是（ ）

  #choice[树中距离最远的两个结点之间路径所经过的边数][根结点 1 到最远叶子结点之间路径所经过的边数][树中叶子结点的个数][所有结点的父结点编号之和]
]

#success(title: "答案")[
  `f[i]` 表示以 $i$ 为根的子树中 $i$ 到最远结点的距离。合并 `f[fa[i]] + f[i] + 1` 是在最高点 `fa[i]` 处拼接两条向下分支，取全局最大值得到的正是树的直径，即距离最远的两个结点之间的边数。因此，本题的答案为 A。
]

*第 32 题*

#note(title: "题面")[
  当 $n = 7$，$"fa"[2] tilde "fa"[7] = {1, 1, 2, 2, 3, 3}$ 时，输出为（ ）

  #choice[2][3][4][5]
]

#success(title: "答案")[
  本题中给出的树结构如下：

  #figure(
    auto-frame(
      cetz.canvas(length: 1.5cm, {
        import cetz.draw: *
        circle((0, 0), radius: 0.4, name: "n1")
        circle((-2, -1.5), radius: 0.4, name: "n2")
        circle((2, -1.5), radius: 0.4, name: "n3")
        circle((-3, -3), radius: 0.4, name: "n4")
        circle((-1, -3), radius: 0.4, name: "n5")
        circle((1, -3), radius: 0.4, name: "n6")
        circle((3, -3), radius: 0.4, name: "n7")
        content((0, 0), $1$)
        content((-2, -1.5), $2$)
        content((2, -1.5), $3$)
        content((-3, -3), $4$)
        content((-1, -3), $5$)
        content((1, -3), $6$)
        content((3, -3), $7$)
        line("n4", "n2", stroke: 3.6pt)
        line("n2", "n1", stroke: 3.6pt)
        line("n1", "n3", stroke: 3.6pt)
        line("n3", "n6", stroke: 3.6pt)
        line("n2", "n5")
        line("n3", "n7")
      })
    ),
    caption: [有根树的结构示意图]
  )

  可以发现 $4-2-1-3-6$ 是这棵树的最长路径，共 4 条边，故输出 4。因此，本题的答案为 C。
]

*第 33 题*

#note(title: "题面")[
  当 $n = 10$，满足输出为 9 的合法输入种类数为（ ）

  #choice[0][9][256][512]
]

#success(title: "答案")[
  10 个结点的树直径为 9，当且仅当这棵树在视为无根树的前提下是一条链。下面展示了本题添加下链的构造过程：实线圆为已挂载的结点，虚线圆为当前两条链的末端（可继续挂载的位置）；结点 2 挂到根的左下侧，结点 3 继续挂到结点 2 下使左链延伸，结点 4 则挂到根的右下侧。

  #figure(
    auto-frame(
      cetz.canvas(length: 1.1cm, {
        import cetz.draw: *
        let dash-stroke = (paint: rgb("#808080"), thickness: 1pt, dash: "dashed")
        let r = 0.35
        let hx = 1.5
        let vd = 1.5

        let slot(x, y, nm) = circle((x, y), radius: r, stroke: dash-stroke, fill: none, name: nm)
        let solid(x, y, t, nm) = {
          circle((x, y), radius: r, fill: white, name: nm)
          content((x, y), t)
        }
        let dline(a, b) = line(a, b, stroke: dash-stroke)
        let sline(a, b) = line(a, b)

        let (cx, cy) = (-3, 0.5)
        solid(cx, cy, $1$, "a1")
        slot(cx - hx, cy - vd, "aL")
        slot(cx + hx, cy - vd, "aR")
        dline("a1", "aL")
        dline("a1", "aR")

        let (cx, cy) = (3, 0.5)
        solid(cx, cy, $1$, "b1")
        solid(cx - hx, cy - vd, $2$, "b2")
        slot(cx + hx, cy - vd, "bR")
        slot(cx - hx, cy - 2 * vd, "bD")
        sline("b1", "b2")
        dline("b1", "bR")
        dline("b2", "bD")

        let (cx, cy) = (-3, -4)
        solid(cx, cy, $1$, "c1")
        solid(cx - hx, cy - vd, $2$, "c2")
        solid(cx - hx, cy - 2 * vd, $3$, "c3")
        slot(cx + hx, cy - vd, "cR")
        slot(cx - hx, cy - 3 * vd, "cD")
        sline("c1", "c2")
        sline("c2", "c3")
        dline("c1", "cR")
        dline("c3", "cD")

        let (cx, cy) = (3, -4)
        solid(cx, cy, $1$, "d1")
        solid(cx - hx, cy - vd, $2$, "d2")
        solid(cx - hx, cy - 2 * vd, $3$, "d3")
        solid(cx + hx, cy - vd, $4$, "d4")
        slot(cx - hx, cy - 3 * vd, "dDL")
        slot(cx + hx, cy - 2 * vd, "dDR")
        sline("d1", "d2")
        sline("d2", "d3")
        sline("d1", "d4")
        dline("d3", "dDL")
        dline("d4", "dDR")
      })
    ),
    caption: [结点依次挂入两条链端的过程]
  )

  不难发现，除了根节点之外的 $9$ 个结点可以独立选择挂到左链或右链的末端，但结点 $2$ 的选取对 `fa` 数组而言没有区别，因此合法输入种类数为 $2^(9-1) = 256$。

  因此，本题的答案为 C。
]

= 三、完善程序

== （1）平衡路线

#note(title: "题面")[
  给定一张有 $n$ 个顶点、$m$ 条边的无向图，每条边带有符号 $+$ 或 $-$。对于一条从顶点 $s$ 到顶点 $t$ 的路线，允许重复经过顶点和边，定义一条路线的权值如下：记 $n^+$、$n^-$ 分别为经过的 $+$ 边数和经过的 $-$ 边数，则该路线的权值为 $abs(n^+ - n^-)$。

  请计算从 $s$ 到 $t$ 的路线的最小权值。若不存在从 $s$ 到 $t$ 的路线，则输出 $-1$。

  输入第一行为四个整数 $n$，$m$，$s$，$t$。接下来 $m$ 行，每行给出两个整数 $a$, $b$ 和一个字符 $+$ 或 $-$，描述一条连接 $a$ 与 $b$ 的无向边及其符号。

  数据满足 $2 <= n <= 2 times 10^5$，$1 <= m <= 4 times 10^5$，$1 <= s, t <= n$ 且 $s != t$，$1 <= a, b <= n$，可能出现重边。

  以下程序通过 BFS 求出最小权值。请补全程序。

  ```cpp
  #include <iostream>

  constexpr int N = 200005;
  constexpr int M = 400005;

  int n, m, s, t;
  int h[N], e[M << 1], ne[M << 1], w[M << 1], idx;
  int q[N], d[N], c[N];

  void add(int a, int b, int z) {
    e[idx] = b;
    w[idx] = z;
    ne[idx] = h[a];
    h[a] = idx++;
  }

  int main() {
    std::cin >> n >> m >> s >> t;
    for (int i = 1; i <= n; i++)
      h[i] = d[i] = c[i] = -1;
    for (int i = 0; i < m; i++) {
      int a, b;
      char op[2];
      std::cin >> a >> b >> op;
      int z = __①__ ;
      add(a, b, z);
      add(b, a, z);
    }
    int hh = 0, tt = 0;
    int p = 0, ng = 0, ok = 1;
    q[tt++] = s;
    d[s] = c[s] = 0;
    while ( __②__ ) {
      int x = q[hh++];
      for (int i = h[x]; i != -1; i = ne[i]) {
        int y = e[i];
        if (w[i] > 0) p = 1;
        if (w[i] < 0) ng = 1;
        if (d[y] == -1) {
          d[y] = __③__ ;
          c[y] = c[x] ^ 1;
          q[tt++] = y;
        } else if ( __④__ )
          ok = 0;
      }
    }
    if (d[t] == -1) {
      std::cout << -1;
      return 0;
    }
    if (!p || !ng) {
      std::cout << d[t];
      return 0;
    }
    if ( __⑤__ ) std::cout << 0;
    else std::cout << 1;
    return 0;
  }
  ```
]

#warning(title: "提示")[
  代码专门记录了在 BFS 过程中是否经过正边或负边（分别表示为布尔变量 `p` 和 `ng`）。这启发我们注意到如下事实：通过来回经过正边或负边，可以让正负边数之差加上或减去任意偶数，从而将最终结果控制在 0 或 1。因此，本题的关键在于判断如下事实：

  - 如果从结点 $s$ 出发无法到达结点 $t$，则输出 $-1$；
  - 如果从结点 $s$ 出发可以到达结点 $t$，但 BFS 过程中只经过了正边或只经过了负边，则本题等价于所有边权均为 1 的最短路问题，输出从 $s$ 到 $t$ 的最短路径长度即可；
  - 如果从结点 $s$ 出发可以到达结点 $t$，且 BFS 过程中既经过了正边又经过了负边，则需要判断图是否可以被黑白染色：

    - 若图可被黑白染色，则所有从 $s$ 到 $t$ 的路线长度奇偶性固定：当 `c[s] == c[t]` 时为偶数，可取得权值 0；否则只能取到权值 1；
    - 若图不可被黑白染色，则连通块内存在奇环，在路线上额外绕这个奇环可改变长度奇偶性，因此总能取得权值 0。

  据此即可确认，代码中 `d[i]` 记录结点 $i$ 到起点 $s$ 的距离，`c[i]` 记录结点 $i$ 的颜色（0 或 1），`ok` 记录图是否可被黑白染色。
]

*第 34 题*

#note(title: "题面")[
  ① 处应填（ ）

  #choice[`op[0] == '+' ? 0 : 1`][`op[0] == '+'`][`op[0] == '+' ? 1 : -1`][`op[0] == '-' ? 1 : 0`]
]

#success(title: "答案")[
  程序把每条边的符号转化为整数权值，后面需要用 `w[i] > 0` 和 `w[i] < 0` 区分两种边，因此 `+` 和 `-` 对应的边权应当为一正一负，本题中只有  `op[0] == '+' ? 1 : -1` 满足要求。因此，本题的答案为 C。
]

*第 35 题*

#note(title: "题面")[
  ② 处应填（ ）

  #choice[`hh < n`][`tt < n`][`hh <= tt`][`hh < tt`]
]

#success(title: "答案")[
  本题使用数组模拟队列，队首下标为 `hh`，队尾下标为 `tt`。初始时队列为空，而 `hh = 0`、`tt = 0`，添加元素时 `tt` 自增，删除元素时 `hh` 自增。据此分析可以确定，队列非空的条件是队首下标严格小于队尾下标，即 `hh < tt`。因此，本题的答案为 D。
]

*第 36 题*

#note(title: "题面")[
  ③ 处应填（ ）

  #choice[`d[y] + 1`][`d[x] + 1`][`d[x]`][`d[x] - 1`]
]

#success(title: "答案")[
  从队首 `x` 沿一条边首次到达 `y`，故 `y` 到起点的距离为 `d[x] + 1`。这也是无边权无向图中计算最短路的标准做法。因此，本题的答案为 B。
]

*第 37 题*

#note(title: "题面")[
  ④ 处应填（ ）

  #choice[`c[y] == c[x]`][`w[i] == 1`][`c[y] != c[x]`][`d[y] + 1 != d[x]`]
]

#success(title: "答案")[
  根据分析，`c[x]` 实际上是在尝试把图进行黑白染色时，每个点对应的颜色信息。这里在触发条件后将 `ok` 置为 0，说明程序认为这个图无法被黑白染色，而这只有在过程中发现一条边两端颜色相同（`c[y] == c[x]`）时进行。因此，本题的答案为 A。
]

*第 38 题*

#note(title: "题面")[
  ⑤ 处应填（ ）

  #choice[`ok && c[s] == c[t]`][`ok && c[s] != c[t]`][`!ok || c[s] == c[t]`][`!ok && c[s] != c[t]`]
]

#success(title: "答案")[
  路线权值 $abs(n^+ - n^-)$ 的奇偶性等于路线长度的奇偶性，因为 $+1$ 与 $-1$ 模 2 均为 1。

  - 图可被黑白染色（`ok`）时，所有从 $s$ 到 $t$ 的路线长度奇偶性固定：当 `c[s] == c[t]` 时为偶数，可取得权值 0；否则只能取到权值 1。
  - 图不可被黑白染色（`!ok`）时，连通块内存在奇环，在路线上额外绕这个奇环可改变长度奇偶性，因此总能取得权值 0。

  故输出 0 的条件为 `!ok || c[s] == c[t]`。因此，本题的答案为 C。
]

== （2）标准答案

#note(title: "题面")[
  有 $n$ 名学生参加一次考试，考试共有 $m$ 道选择题，每道题只有 A、B 两个选项。第 $i$ 名学生的作答用一个长度为 $m$ 的字符串 $a_i$ 表示。若最终公布的标准答案与该学生在某道题上的作答相同，则该学生得 1 分，否则不得分。记第 $i$ 名学生最终得到的总分为 $r_i$。

  给定每名学生的目标分数 $x_i$。现在需要构造一份标准答案，使 $sum_(i=1)^n abs(r_i - x_i)$ 尽可能大。

  数据满足 $1 <= n <= 20$，$1 <= m <= 300$，$0 <= x_i <= m$。

  以下程序从枚举符号的角度处理 $sum_(i=1)^n abs(r_i - x_i)$，把它写成更易优化的形式。

  对于非零整数 x，`__builtin_ctzll(x)` 返回 x 的二进制表示末尾连续 0 的个数。`__builtin_popcountll(x)` 返回 x 的二进制表示中 1 的个数。

  程序输出一组满足要求的标准答案。请补全程序。

  ```cpp
  #include <cstdlib>
  #include <iostream>
  #include <string>
  #include <vector>

  using namespace std;

  typedef long long ll;
  typedef unsigned long long ull;

  int main() {
    int n, m;
    cin >> n >> m;
    vector<ll> x(n), c(n);
    for (int i = 0; i < n; i++) {
      cin >> x[i];
      c[i] = __①__ ;
    }
    vector<string> a(n);
    for (int i = 0; i < n; i++)
      cin >> a[i];

    vector<int> s(n, -1);
    vector<ll> q(m, 0);
    ll C = 0, S = 0;
    for (int i = 0; i < n; i++) {
      C -= c[i];
      for (int j = 0; j < m; j++) {
        if (a[i][j] == 'A') q[j]--;
        else q[j]++;
      }
    }
    for (int j = 0; j < m; j++) S += abs(q[j]);
    ll ans = C + S;
    ull best = 0, lst = 0;

    for (ull mask = 1; mask < (1ULL << n); mask++) {
      ull g = __②__ ;
      ull d = g ^ lst;
      int k = __③__ ;
      C -= __④__ ;
      for (int j = 0; j < m; j++) {
        ll old = q[j];
        int v = (a[k][j] == 'A' ? 1 : -1);
        q[j] -= 2ll * s[k] * v;
        S += abs(q[j]) - abs(old);
      }
      s[k] = -s[k];
      if (C + S > ans) {
        ans = C + S;
        best = g;
      }
      lst = g;
    }

    for (int i = 0; i < n; i++) {
      if (best >> i & 1) s[i] = 1;
      else s[i] = -1;
    }

    string res(m, 'A');
    for (int j = 0; j < m; j++) {
      ll v = 0;
      for (int i = 0; i < n; i++) {
        if (a[i][j] == 'A') v += s[i];
        else v -= s[i];
      }
      if ( __⑤__ ) res[j] = 'A';
      else res[j] = 'B';
    }
    cout << res << endl;
    return 0;
  }
  ```
]

#let combo-yellow = rgb("#C2830A")
#let a1-red = text(fill: red)[$(x_1 - r_1)$]
#let b1-blue = text(fill: blue)[$(r_1 - x_1)$]
#let a2-yellow = text(fill: combo-yellow)[$(x_2 - r_2)$]
#let b2-green = text(fill: green)[$(r_2 - x_2)$]
#let combo-plus = $ + $
#let combo-matrix = math.mat(
  (a1-red + combo-plus + a2-yellow,),
  (a1-red + combo-plus + b2-green,),
  (b1-blue + combo-plus + a2-yellow,),
  (b1-blue + combo-plus + b2-green,),
)

#warning(title: "提示")[
  本题是 #link("https://codeforces.com/problemset/problem/1622/E")[Codeforces \#1622 E. Math Test] 的另版，具有更大的 $n$ 和更小的 $m$，同时微调了计分规则和 $x_i$ 的取值范围。

  题目指出本算法使用“枚举符号”的策略完成，实际上利用了一个性质：$abs(r_i - x_i) = max(x_i - r_i, r_i - x_i)$。因此，最终的目标函数可以写成

  $
    sum_(i=1)^n abs(r_i - x_i) = sum_(i=1)^n max(x_i - r_i, r_i - x_i)
  $

  不妨取 $n = 2$ 观察结构，将两个 $max$ 中的四个原子项分别染色，便可清晰地看到最大值是如何组合的：

  $
    max(#a1-red, #b1-blue) + max(#a2-yellow, #b2-green)\
    = max #combo-matrix
  $

  可以看到，来自两个 $max$ 内部的取值共构成了 $2^2$ 种组合，每一种组合可以通过在 $max$ 内取一项并相加得到，而矩阵每一行中出现的颜色与第一行中的原子一一对应。因此，目标函数也可以类似拆分为 $2^n$ 个部分的最大值，其中每个部分都来自于 $n$ 个学生的 $max$ 内部的原子项。

  考虑到本题要最大化目标函数，而目标函数由是若干个式子的最大值，利用类似 $max(f(x), g(x)) = max(max f(x), max g(x))$ 的性质，可以将问题转化为 $2^n$ 种组合对应的子问题，从而完全摆脱绝对值，得到易于计算的线性表达式。这也就对应了程序中对 `mask` 的枚举。

  从程序的第 44 行可以确定其使用 $+1$ 代表字符 `A`，$-1$ 代表字符 `B`，若将第 $i$ 个学生在第 $j$ 题的作答记为 $sigma_(i j) in {+1, -1}$，并假设 $R_j in {+1, -1}$ 为第 $j$ 个问题的标准答案。若答案和标准答案相同，则 $sigma_(i j) R_j = 1$，否则为 $-1$，那么可以使用 $(sigma_(i j) R_j + 1) \/ 2$ 表示第 $i$ 个学生在第 $j$ 题的得分。于是，第 $i$ 个学生的总分可以写成

  $
    r_i = sum_(j=1)^m (1 + sigma_(i j) R_j) / 2 = (m + sum_(j=1)^m sigma_(i j) R_j) / 2
  $
  
  在枚举子问题后，就可以确认每个 $r_i$ 和 $x_i$ 对结果的贡献符号是正还是负。下面，使用 $s_i in {+1, -1}$ 表示当前枚举到的组合中 $r_i$ 的贡献符号，$s_i = 1$ 表示 $r_i$ 的贡献为正（即选择 $r_i - x_i$），$s_i = -1$ 表示 $r_i$ 的贡献为负（即选择 $x_i - r_i$）。结合上面对 $r_i$ 的推导，就可以得到

  $
    sum_(i=1)^n s_i (r_i - x_i) &= sum_(i=1)^n s_i ((m + sum_(j=1)^m sigma_(i j) R_j) / 2 - x_i)\
    &= 1/2(sum_(i=1)^n s_i (sum_(j=1)^m sigma_(i j) R_j + (m - 2 x_i)))\
    &= 1/2 (underbrace(sum_(i=1)^n s_i (m - 2 x_i), C) + underbrace(sum_(j=1)^m (sum_(i=1)^n s_i sigma_(i j)) R_j, S))
  $

  在最大化问题中，常数倍率 $1/2$ 不影响结果，因此可以直接忽略。此时可以发现函数分为两部分，分别为 $C$ 和 $S$，其中

  - $C = sum_(i=1)^n s_i (m - 2 x_i)$，与标准答案无关，只需要在 $s_i$ 发生变化时更新即可；
  - $S = sum_(j=1)^m (sum_(i=1)^n s_i sigma_(i j)) R_j$，与标准答案相关，需要在 $s_i$ 发生更新时枚举所有题目进行更新。

  注意到 $R_i$ 的取值完全取决于我们的选择，为了最大化 $S$，我们可以选择每个 $R_j$ 与 $sum_(i=1)^n s_i sigma_(i j)$ 同号即可。此时总是有 $S = sum_(j=1)^m abs(sum_(i=1)^n s_i sigma_(i j))$。

  在完成上述推导后，回到代码可以发现，程序正是在使用变量维护上述公式，从而最大化 $sum_(i=1)^n abs(r_i - x_i)$。后续推导将会和答案解析一同进行。
]

*第 39 题*

#note(title: "题面")[
  ① 处应填（ ）

  #choice[`2 * x[i] - m`][`-m + 2 * x[i] + 1`][`m - 2 * x[i]`][`m + 2 * x[i]`]
]

#success(title: "答案")[
  程序使用数组 `s` 存储了第 $i$ 个学生的贡献符号 $s_i$，在初始情况下，`mask` 为 0，所有学生的贡献符号均为负，即 $s_i = -1$。观察此时对 $C$ 和 $S$ 的计算：

  ```cpp
  ll C = 0, S = 0;
  for (int i = 0; i < n; i++) {
    C -= c[i];
    for (int j = 0; j < m; j++) {
      if (a[i][j] == 'A') q[j]--;
      else q[j]++;
    }
  }
  for (int j = 0; j < m; j++) S += abs(q[j]);
  ll ans = C + S;
  ```

  观察代码可以发现，在 `a[i][j] == 'A'` 时，`q[j]--`，否则 `q[j]++`，因此 `q[j]` 的确维护了 $sum_(i=1)^n s_i sigma_(i j) = sum_(i=1)^n - sigma_(i j)$。结合这一习惯可以确定，$C$ 在初始情况下应该维护了 $sum_(i=1)^n s_i (m - 2 x_i) = sum_(i=1)^n -(m - 2 x_i)$。

  最后，$C$ 在初始情况下的计算为 `C -= c[i]`，因此 `c[i]` 应当等于 `m - 2 x_i`。因此，本题的答案为 C。
]

*第 40 题*

#note(title: "题面")[
  ② 处应填（ ）

  #choice[`mask | (mask >> 1)`][`mask ^ (mask >> 1)`][`mask & (mask >> 1)`][`mask ^ ((mask >> 1) + 1)`]
]

#success(title: "答案")[
  在使用正常的方式枚举符号位 $s_i$ 时，若直接通过二进制升序枚举所有组合，则在切换相邻两种组合时，可能需要枚举多个被变化的符号位，并调整 $C$ 和 $S$ 的值。然而，本题在枚举 `mask` 时仅处理了变量 `k` 对应的学生的符号位变化，其他学生的符号位保持不变。为了保证每次枚举时仅有一个符号位发生变化，程序使用了格雷码进行枚举。

  在按顺序枚举 `mask` 时，格雷码的生成公式为 `g = mask ^ (mask >> 1)`，该公式保证了相邻两种组合之间仅有一个符号位发生变化。因此，本题的答案为 B。
]

*第 41 题*

#note(title: "题面")[
  ③ 处应填（ ）

  #choice[`__builtin_ctzll(d) + 1`][`__builtin_popcountll(d)`][`__builtin_ctzll(g)`][`__builtin_ctzll(d)`]
]

#success(title: "答案")[
  根据前面的分析，在切换相邻两种组合时，程序使用格雷码保证仅有一个二进制位发生了变化。因此，`d = g ^ lst` 中恰有一个二进制位为 1，该位就是本次翻转的符号位。`__builtin_ctzll(d)` 返回末尾连续 0 的个数，正好是这一位从 0 开始的下标。考虑到本题的代码约定下标从 0 开始，因此直接作为学生编号 `k` 使用即可。因此，本题的答案为 D。
]

*第 42 题*

#note(title: "题面")[
  ④ 处应填（ ）

  #choice[`2ll * s[k] * c[k]`][`s[k] * c[k]`][`2ll * (s[k] - c[k])`][`2ll * c[k]`]
]

#success(title: "答案")[
  `C` 维护的是 $sum_i s_i c_i$。翻转 `s[k]` 后，该项的变化量为

  $ (- s_k c_k) - s_k c_k = -2 s_k c_k $

  因此应执行 `C -= 2ll * s[k] * c[k]`。因此，本题的答案为 A。
]

*第 43 题*

#note(title: "题面")[
  ⑤ 处应填（ ）

  #choice[`v >= (n & 1)`][`v > (n & 1)`][`v + (n & 1) >= 0`][`v * (n & 1) >= 0`]
]

#success(title: "答案")[
  $v = sum_i s_i sigma_(i j)$，为使目标值最大，标准答案第 $j$ 题应取与 `v` 同号的选项：`v` 为正选 A、为负选 B。此时 `v` 是 $n$ 个 $+1$ 或 $-1$ 之和，奇偶性与 $n$ 相同：

  - $n$ 为偶数时 `v` 为偶数，可能取 0，平局时任选，取正（含 0）的条件为 `v >= 0`；
  - $n$ 为奇数时 `v` 为奇数，正数最小为 1，条件为 `v >= 1`。

  逐个考虑四种选项：

  - 选项 A：`v >= (n & 1)`，当 `n` 为偶数时条件为 `v >= 0`，当 `n` 为奇数时条件为 `v >= 1`，正好符合要求；
  - 选项 B：`v > (n & 1)`，当 `n` 为奇数时条件为 `v > 1`，在 `v = 1` 时会错误地选择 B 作为标准答案；
  - 选项 C：`v + (n & 1) >= 0`，当 `n` 为奇数时条件为 `v + 1 >= 0`，在 `v = -1` 时会错误地选择 A 作为标准答案；
  - 选项 D：`v * (n & 1) >= 0`，当 `n` 为偶数时条件 `v * 0 >= 0` 恒成立，因此无法正确选择标准答案。

  因此，本题的答案为 A。
]

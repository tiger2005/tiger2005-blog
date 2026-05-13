#import "../../config.typ": *
#import "@preview/cetz:0.5.1"

#show: template-post.with(
  title: "后缀自动机是怎么被构造的？它的复杂度又是如何证明的？",
  description: "本文尝试以一种较为直观的角度看待后缀自动机、后缀链接树和结束位置集合，并尝试给出关于状态数、转移数和时间复杂度的证明。",
  tags: ("字符串", ),
  category: "",
  date: datetime(year: 2026, month: 5, day: 13)
)

// #set page(fill: black.lighten(10%))
// #set text(fill: white.darken(5%))

#quote[
  本文改编自#link("https://www.luogu.com.cn/article/b343ia0p")[本人在三年前编写的一篇文章]，并修复了其中的一些错误和不严谨之处。

  本文尝试以一种较为直观的角度看待后缀自动机、后缀链接树和结束位置集合。本文的名词描述尽可能贴合 #link("https://oi-wiki.org/string/sam/")[OI Wiki] 中的描述同时也会引入一些创新（确信）的名词辅助理解。另外，本文刻意绕开了反复的数学理论证明，如果你想要查看相关证明，请移步到其他博客。
]

为了方便起见，本文中字符串的下标从 1 开始。

对于一个长度为 $n$ 的字符串 $s$，使用 $s_i$ 代表第 $i$ 个字符，并扩展定义 $s_0 = s_(n + 1) = epsilon$。另外，使用 $s_[l, r]$ 代表字符串 $s$ 的第 $l$ 到 $r$ 个字符组成的子串。使用 $|s|$ 表示字符串 $s$ 的长度。最后，$epsilon$ 除了可以表示空字符之外，也会用来表示空串。

= 什么是后缀自动机？

后缀自动机本质上维护了一些状态，而这些状态的来源可以通过字符串的匹配流程来理解。对于一个文本字符串 $s$ 和一个模式字符串 $t$，我们可以通过以下流程来判断 $t$ 是否是 $s$ 的子串：

- 考虑字符串 $s$ 的每个位置 $k$，若 $s_k$ 与 $t_1$ 匹配，则将 $k$ 作为长度为 $1$ 的候选位置。此时，候选位置集合为 $P_1 = {k | s_k = t_1}$。
- 对 $P_1$ 中的每个位置 $k$，若 $s_(k + 1)$ 与 $t_2$ 匹配，则将 $k + 1$ 作为长度为 $2$ 的候选位置。此时，候选位置集合为 $P_2 = {k + 1 | k in P_1 and s_(k + 1) = t_2}$。
- 以此类推，构造出 $P_(|t|)$ 集合。若 $P_(|t|)$ 非空，则说明 $t$ 是 $s$ 的子串。

例如，在文本字符串 $s = mono("abcbaabd")$ 中，对模式字符串 $t = mono("abc")$ 的匹配流程如下图所示：

#figure(
  auto-frame(
    cetz.canvas({
      import cetz.draw: *
      let s = "abcbaabd"

      for i in range(s.len()) {
        content((i*1.2,0), text(
          20pt,
          font: "IBM Plex Mono",
          s.at(i)
        ))
        content((i*1.2,-0.8), text(
          14pt,
          font: "IBM Plex Mono",
          fill: gray,
          str(i + 1)
        ))
      }

      stroke(gray)
      line((-1, -1.5), (rel: ((s.len() - 1) * 1.2 + 2, 0)))
      line((-1, -2.5), (rel: ((s.len() - 1) * 1.2 + 2, 0)))
      line((-1, -3.5), (rel: ((s.len() - 1) * 1.2 + 2, 0)))
      
      stroke(black)
      fill(black)
      circle((0, -1.5), radius: (0.1, 0.1))

      circle((4 * 1.2, -1.5), radius: (0.1, 0.1))
      circle((5 * 1.2, -1.5), radius: (0.1, 0.1))

      line((0, -1.5), (rel: (1.2, -1)))
      line((4 * 1.2, -1.5), (rel: (0.6, -0.5)), mark: (end: "|"))
      line((5 * 1.2, -1.5), (rel: (1.2, -1)))

      circle((1 * 1.2, -2.5), radius: (0.1, 0.1))
      circle((6 * 1.2, -2.5), radius: (0.1, 0.1))

      line((1 * 1.2, -2.5), (rel: (1.2, -1)))
      line((6 * 1.2, -2.5), (rel: (0.6, -0.5)), mark: (end: "|"))

      circle((2 * 1.2, -3.5), radius: (0.1, 0.1))
    })
  ),
  caption: [匹配流程示意图]
)

从上述流程中可以得到：$P_1 = {1, 5, 6}$，$P_2 = {2, 7}$，$P_3 = {3}$。随着匹配的进行，算法会尝试将候选位置集合中的元素进行扩展，但在某些情况下，扩展会失败。这将会导致候选位置集合不断缩小，直到匹配结束。事实上，上述候选位置集合分别对应了某一个字符串对应的所有匹配中，最后一个匹配位置的集合，例如：

- $P_1$ 中的元素 $1$、$5$ 和 $6$ 分别对应了字符串 $mono("a")$ 在文本字符串中的三个匹配位置；
- $P_2$ 中的元素 $2$ 和 $7$ 分别对应了字符串 $mono("ab")$ 在文本字符串中的两个匹配位置；
- $P_3$ 中的元素 $3$ 对应了字符串 $mono("abc")$ 在文本字符串中的一个匹配位置。

这些候选位置集合就被称作字符串的结束位置集合，使用 $"endpos"(s, t)$ 表示在字符串 $s$ 中字符串 $t$ 的结束位置集合。在后续讨论中，文本字符串一般都是固定的，此时会直接使用 $"endpos"(t)$ 来表示字符串 $t$ 的结束位置集合。另外，上面的算法流程也展示了一个结束位置集合在接受一个新的字符时是如何被构造的——尝试进行扩展，并只保留扩展成功的位置。

回忆自动机的定义（注：Trie 树和 AC 自动机都可以看作自动机），每个结点（也就是状态）在接受一个输入字符后，将会转移到另一个结点。考虑到上面已经给出了结束位置集合，以及它们接受某一个字符后的构造流程，我们可以将每个结束位置集合看作一个状态，并且在接受一个输入字符后转移到另一个状态。这其实就是后缀自动机最直观的构造方式了。*在下面的讨论中，“结束位置集合”和“状态”是等价的。*

在后缀自动机上尝试匹配一个模式字符串的流程和 Trie 树类似，具体流程如下：

- 初始的状态为 $P_0 = "endpos"(epsilon) = {0, 1, 2, ..., |s|}$，这也是整个后缀自动机的初始状态。
- 对于模式字符串 $t$ 的每个字符 $t_i$，在当前状态 $P_(i - 1)$ 上，确认其是否存在一个转移边 $t_i$，如果存在，则转移到状态 $P_i$；否则，匹配失败。
- 如果最终成功转移到了状态 $P_(|t|)$，则说明 $t$ 是 $s$ 的子串，同时还得到了 $t$ 的所有匹配位置。

通过上述定义可以直接构造出后缀自动机，但是其效率低下，并且实现复杂度也较高。实际上，通过更深刻的性质，即可以 $cal(O) (n)$ 的时间复杂度构造出后缀自动机。

= 结束位置集合的种类数

后缀自动机中一个较为重要的性质是：对于一个长度为 $n$ 的字符串 $s$，其后缀自动机中的状态数不超过 $cal(O) (n)$。使用“正向匹配”，也就是在尾部追加字符的方式讨论结束位置集合的变化，并不能够很好地解释这个性质。相反，我们可以使用“反向匹配”，也就是在头部追加字符的方式来讨论结束位置集合的变化。

对于一个模式字符串 $t$，在其头部追加一个字符 $c$ 后，可以得到 $c + t$。不妨考虑 $"endpos"(c + t)$ 与 $"endpos"(t)$ 的关系。对于 $"endpos"(c + t)$ 中的一个位置 $k$，应该满足 $s_[k -|c + t|+ 1, k] = c + t$。此时 $s_[k -|c + t|+ 1, k]$ 的第一个字符应该是 $c$，剩余的部分应该与 $t$ 匹配。也就是说，$s_[k -|t|+ 1, k]$ 应该与 $t$ 匹配，那么 $k$ 就应该是 $"endpos"(t)$ 中的一个位置。据此可以确认：$"endpos"(c + t)$ 是 $"endpos"(t)$ 中的一个子集。

通过上述讨论还可以得到从 $"endpos"(t)$ 得到 $"endpos"(c + t)$ 的构造流程：对于 $"endpos"(t)$ 中的每个位置 $k$，如果 $s_(k-|c + t|+1) = c$，则将 $k$ 加入到 $"endpos"(c + t)$ 中。因此，对于 $k in "endpos"(t)$，只要 $k != |t|$，那么它恰好会出现在一个 $"endpos"(c + t)$ 之中。因此可以说：转化为 $"endpos"(c + t)$ 的过程“几乎”划分了 $"endpos"(t)$ 中的元素。

在上述讨论的基础之下，就可以讨论结束位置集合的种类数了。首先可以明确的是，所有可能的结束位置集合都可以通过 $"endpos"(epsilon)$ 开始，通过不断在头部追加字符来构造得到。考虑将某一个结束位置集合 $"endpos"(t)$ 进行划分，如果结果出现了变化，那么如下两个事情中至少有一个会发生：

- 划分后产生了至少两个非空集合；
- $|t|$ 是 $"endpos"(t)$ 中的一个元素，根据分析不会出现在划分结果中。

在划分结果发生变化时，称此时 $"endpos"(t)$ 对应状态是 $"endpos"(c + t)$ 对应状态的父状态，这样就可以构建出一棵树，称为后缀链接树。在后缀链接树上，对于一个大小为 $k$ 的结束位置集合，其对应的所有子状态的结束位置集合的大小总和要么是 $k$（此时需要包含至少两个子状态），要么是 $k - 1$。为了估计状态数的上界，可以使用如下的递归式#footnote[下面只考虑拆分为两个子状态的情况，不难证明对更多子状态也成立。]：

$
  cases(
    T(1) = 1,
    display(T(k) = max(T(k - 1) + 1, max_(i + j = k) (T(i) + T(j) + 1)))  & quad k > 1
  )
$

使用归纳法可以得到 $T(k) = 2k - 1$，这样就说明了一个长度为 $n$ 的字符串的后缀自动机中，状态数应当不超过 $cal(O) (n)$。

#note(title: "状态数上界的简单证明")[
  *命题：*对于一个长度不小于 $2$ 的字符串 $s$，其后缀自动机中的状态数不超过 $2|s| - 1$。

  *证明：*上述证明说明：从一个大小为 $|s|$ 的集合开始进行划分，最终得到的划分树状态数不超过 $2|s| - 1$。但是注意到根状态 $"endpos"(epsilon) = {0, 1, ..., |s|}$ 包含 $|s| + 1$ 个元素，因此需要额外考虑。

  - 如果根状态在划分过程中被立刻划分了，那么位置 $0$ 的存在与否并不影响划分树的结构，因此状态数不超过 $2|s| - 1$。
  - 如果根状态在划分过程中没有被立刻划分，那么根状态应当只有一个子状态 ${1, 2, ..., |s|}$。此时字符串 $s$ 应该由一个字符重复 $|s|$ 次组成，可以证明划分树是一条链，因此状态数不超过 $|s| + 1$。在 $|s| >= 2$ 时，$|s| + 1 <= 2|s| - 1$，因此状态数不超过 $2|s| - 1$。

  实际上，使用文本字符串 $s = mono("abbbb...b")$ 即可达到这个上界，这样就完成了证明。$qed$
]

通过后缀链接树，除了可以证明状态数的上界之外，还可以得到一些其他的性质，例如后缀链接树恰好对应了所有结束位置集合的包含关系。此外，在实现中还可以借助后缀链接树的树链快速构造出整个后缀自动机结构。

= 状态对应的字符串

首先需要明确的是：虽然本质不同的结束位置集合的数量不超过 $cal(O) (n)$，但是每一个结束位置集合可能对应多个字符串。考虑如下例子：文本字符串 $s = mono("dabcabcabc")$，对于结束位置集合 $P = {4, 7, 10}$，其对应的字符串可以是 $mono("abc")$、$mono("bc")$ 和 $mono("c")$。为了进一步研究这一现象，不妨考虑在构建后缀链接树的过程所发生的变化：

- $P$ 的父状态是根状态，在接受字符 $mono(c)$ 后得到 $P$，因此 $P$ 对应的字符串可以是 $mono("c" + epsilon) = mono("c")$。
- 随后，$"endpos"(mono("c"))$ 尝试通过在前面追加字符来进行扩展，然而只有在追加 $mono(b)$ 后才能扩展，且扩展得到的结果等于自身，因此 $P$ 对应的字符串还可以是 $mono("b" + "c") = mono("bc")$。
- 同样地，$"endpos"(mono("bc"))$ 只能通过在前面追加 $mono(a)$ 来进行扩展，且扩展得到的结果等于自身，因此 $P$ 对应的字符串还可以是 $mono("a" + "bc") = mono("abc")$。
- 最后，$"endpos"(mono("abc"))$ 可以通过追加 $mono(c)$ 和 $mono(d)$ 来进行扩展，但扩展得到的结果不等于自身，因此 $P$ 对应的字符串不能再增加了。

可以发现，一个结束位置集合对应的字符串是通过连续的“扩展后等于自身”的过程得到的。考虑到扩展是在前面追加字符，因此一个结束位置集合对应的所有字符串必然满足：短字符串是长字符串的后缀。这样就可以正式定义一些记号了：

- 记 $"link"(P)$ 表示 $P$ 的父状态；
- 记 $"len"(P)$ 表示 $P$ 对应的字符串的长度最大值；
- 记 $"minlen"(P)$ 表示 $P$ 对应的字符串的长度最小值；
- 记 $"str"(P)$ 表示 $P$ 对应的最长字符串。

实际上，可以发现 $"minlen"(P) = "len"("link"(P)) + 1$（因为父状态在最大长度处进行恰好一次扩展即可得到自身状态），因此在实现中无需单独维护 $"minlen"(P)$ 的值。对于一个状态 $P$，其对应的字符串的长度范围恰好为 $["minlen"(P), "len"(P)]$。

还需要注意的是，后缀链接树的祖先后代关系还代表了字符串的后缀关系。对于一个状态 $P$，其对应的字符串的所有后缀都可以通过不断地访问父状态来得到。

以下是字符串 $mono("abcbc")$ 对应的后缀自动机：

#figure(
  auto-frame(
    cetz.canvas(background: white.darken(5%), padding: 14pt, {
      import cetz.draw: *

      let unit = 0.6
      
      let draw-round-rect(x, y1, y2) = {
        x *= 5 * unit
        let diff = y2 - y1
        y1 *= 4 * unit
        y2 = y1 + diff * 4 * unit + 2 * unit
        merge-path({
          line((x - unit, y1 + unit), (x - unit, y2 - unit))
          arc(radius: unit, (x - unit, y2 - unit), start: 180deg, stop: 0deg)
          line((x + unit, y2 - unit), (x + unit, y1 + unit))
          arc(radius: unit, (x + unit, y1 + unit), start: 0deg, stop: -180deg)
        })
      }

      let put-text(x, y, s) = {
        content(((-1 + 5 * x) * unit, (1 + 4 * y) * unit), anchor: "mid-east", padding: .25, text(
          14pt,
          font: ("IBM Plex Mono"),
          fill: gray.darken(40%),
          s
        ))
      }

      let draw-arrow(x1, y1, x2, y2, ch) = {
        let centx = (5 * x1 + 5 * x2) * unit / 2
        let centy = (1 + 4 * y1 + 1 + 4 * y2) * unit / 2


        line(((5 * x1) * unit, (1 + 4 * y1) * unit), (rel: ((x2 - x1) * 5 * unit, (y2 - y1) * 4 * unit)), name: "line")
        content(
          (centx, centy),
          angle: 0deg,
          box(
            fill: white.darken(5%),
            inset: 3pt,
            text(
              14pt,
              font: ("IBM Plex Mono"),
              ch
            )
          )
        )
      }

      draw-arrow(0, 0, -1, -1, "a")
      draw-arrow(0, 0, 0, -1, "b")
      draw-arrow(0, 0, 1, -1, "c")
      draw-arrow(-1, -1, 0, -2, "b")
      draw-arrow(0, -1, 1, -2, "c")
      // draw-arrow(1, -1, 2, -2, "b")
      draw-arrow(0, -2, 1, -3, "c")
      draw-arrow(1, -2, 2, -3, "b")
      // draw-arrow(2, -2, 3, -3, "c")
      draw-arrow(1, -3, 2, -4, "b")
      // draw-arrow(2, -3, 3, -4, "c")
      draw-arrow(2, -4, 3, -5, "c")

      put-text(-1, -1, "a")
      put-text(0, -1, "b")
      put-text(1, -1, "c")
      put-text(0, -2, "ab")
      put-text(1, -2, "bc")
      put-text(2, -2, "cb")
      put-text(1, -3, "abc")
      put-text(2, -3, "bcb")
      put-text(3, -3, "cbc")
      put-text(2, -4, "abcb")
      put-text(3, -4, "bcbc")
      put-text(3, -5, "abcbc")

      fill(white)
      draw-round-rect(0, 0, 0)
      draw-round-rect(-1, -1, -1)
      draw-round-rect(0, -1, -1)
      draw-round-rect(1, -2, -1)

      draw-round-rect(0, -2, -2)
      draw-round-rect(1, -3, -3)
      draw-round-rect(2, -4, -2)
      draw-round-rect(3, -5, -3)
    })
  ),
  caption: [字符串 $mono("abcbc")$ 对应的后缀自动机]
)

在上述后缀自动机中，每一个圆角矩形代表一个状态，在状态左侧标注了其对应的所有字符串。可以发现，状态 $P$ 对应的字符串的长度范围为 $["minlen"(P), "len"(P)]$，并且这些字符串之间存在后缀关系。另外，图中也将状态之间的转移边标注了对应的输入字符。

随后是上述后缀自动机对应的结束位置集合和后缀链接树：

#figure(
  auto-frame(
    cetz.canvas(background: white.darken(5%), padding: 14pt, {
      import cetz.draw: *

      let unit = 0.6
      
      let draw-round-rect(x, y1, y2) = {
        x *= 5 * unit
        let diff = y2 - y1
        y1 *= 4 * unit
        y2 = y1 + diff * 4 * unit + 2 * unit
        merge-path({
          line((x - unit, y1 + unit), (x - unit, y2 - unit))
          arc(radius: unit, (x - unit, y2 - unit), start: 180deg, stop: 0deg)
          line((x + unit, y2 - unit), (x + unit, y1 + unit))
          arc(radius: unit, (x + unit, y1 + unit), start: 0deg, stop: -180deg)
        })
      }

      let put-text(x, y, s) = {
        content(((-1 + 5 * x) * unit, (1 + 4 * y) * unit), anchor: "mid-east", padding: .25, text(
          14pt,
          font: ("IBM Plex Mono"),
          fill: gray.darken(40%),
          s
        ))
      }

      let draw-arrow(x1, y1, x2, y2) = {
        let centx = (5 * x1 + 5 * x2) * unit / 2
        let centy = (1 + 4 * y1 + 1 + 4 * y2) * unit / 2

        stroke(red)
        line(((5 * x1) * unit, (1 + 4 * y1) * unit), (rel: ((x2 - x1) * 5 * unit, (y2 - y1) * 4 * unit)), name: "line")
        stroke(black)
      }

      draw-arrow(0, 0, -1, -1)
      draw-arrow(0, 0, 0, -1)
      draw-arrow(0, 0, 1, -1)
      draw-arrow(0, -1, 0, -2)
      draw-arrow(0, -1, 2, -2)
      draw-arrow(1, -2, 1, -3)
      draw-arrow(1, -2, 3, -3)

      put-text(0, 0, "0,1,2,3,4,5")
      put-text(-1, -1, "1")
      put-text(0, -1, "2,4")
      put-text(1, -2, "3,5")
      put-text(0, -2, "2")
      put-text(1, -3, "3")
      put-text(2, -4, "4")
      put-text(3, -5, "5")

      fill(white)
      draw-round-rect(0, 0, 0)
      draw-round-rect(-1, -1, -1)
      draw-round-rect(0, -1, -1)
      draw-round-rect(1, -2, -1)

      draw-round-rect(0, -2, -2)
      draw-round-rect(1, -3, -3)
      draw-round-rect(2, -4, -2)
      draw-round-rect(3, -5, -3)
    })
  ),
  caption: [字符串 $mono("abcbc")$ 对应的后缀链接树，其中一些树边穿过了状态]
)

其中在每个状态的左下角标注了其对应的结束位置集合，并使用红色边表示了后缀链接树的结构。可以发现，后缀链接树的祖先后代关系恰好对应了结束位置集合的包含关系。另外，根据后缀链接树的形式，在上述图中将父状态的结尾连接到子状态的开头，可以发现这些边恰好都连接了相邻的两层。

= 增量思想

后缀自动机的构建采用*增量思想*，每次向文本字符串的末尾追加一个字符，并且更新后缀自动机的结构。假设目前文本字符串 $s$ 的长度为 $n$，而现在需要将字符 $c$ 添加到文本字符串的末尾，此时文本字符串变为 $s + c$，长度变为 $n + 1$。此时考虑后缀自动机中需要修改的部分：

- *首先，后缀自动机的一些状态需要进行修改。*对于 $s + c$ 的所有后缀 $s'$，在 $"endpos"(s')$ 中都需要包含额外的元素 $n + 1$。一些较长的后缀可能并没有在 $s$ 中出现过，因此它们对应的 $"endpos"(s')$ 恰好为 ${n + 1}$；除此之外，较短的后缀可能在 $s$ 中出现过，因此它们对应的 $"endpos"(s')$ 中包含了 $n + 1$ 以及一些之前已经存在的元素。
- *其次，后缀自动机的一些转移终点也需要进行修改。*对于 $s$ 的所有后缀 $s''$，$"endpos"(s'')$ 在接受字符 $c$ 后得到的结果中也应该包含 $n + 1$。同样的，一些较长的后缀 $s''$ 满足 $s'' + c$ 在 $s$ 中没有出现过，因此需要添加转移边 $s'' attach(->, t: c) {n + 1}$；除此之外，一些较短的后缀 $s''$ 满足 $s'' + c$ 在 $s$ 中出现过，但在上一部分中已经将 $n + 1$ 加入到了 $"endpos"(s'' + c)$ 中，因此不需要额外修改已有的转移边。

为了更好的解释这个问题，不妨考虑 $s = mono("abab")$，且 $c = mono("a")$。在将 $c$ 添加到文本字符串的末尾后，文本字符串变为 $s + c = mono("ababa")$。考虑 $s$ 的所有后缀，以及对应的 $s + c$ 的后缀：

- 取 $s$ 的后缀 $mono("b")$，此时对应的 $s + c$ 的后缀为 $mono("ba")$。

  考虑到 $mono("ba")$ 在 $s$ 中出现过，那么只需要将 $n + 1$ 加入到 $"endpos"(mono("ba"))$ 中，而不需要修改任何转移边。
- 取 $s$ 的后缀 $mono("ab")$，此时对应的 $s + c$ 的后缀为 $mono("aba")$。

  考虑到 $mono("aba")$ 在 $s$ 中出现过，那么同理，需要将 $n + 1$ 加入到 $"endpos"(mono("aba"))$ 中，而不需要修改任何转移边。
- 取 $s$ 的后缀 $mono("bab")$，此时对应的 $s + c$ 的后缀为 $mono("baba")$。

  考虑到 $mono("baba")$ 在 $s$ 中没有出现过，那么 $"endpos"(mono("baba")) = {n + 1}$，并且需要添加转移边 $"endpos"(mono("bab")) attach(->, t: mono("a")) {n + 1}$。
- 取 $s$ 的后缀 $mono("abab")$，此时对应的 $s + c$ 的后缀为 $mono("ababa")$。

  考虑到 $mono("ababa")$ 在 $s$ 中没有出现过，那么 $"endpos"(mono("ababa")) = {n + 1}$，并且需要添加转移边 $"endpos"(mono("abab")) attach(->, t: mono("a")) {n + 1}$。

使用结束位置集合的语言将上述两点进行总结，可以得到如下的结论：

- 将会出现一个新的状态 ${n + 1}$，并且已经存在的状态可能会加入 $n + 1$ 作为新的元素（即使这些部分不需要显示维护）。
- 随后，需要枚举 $s$ 的所有后缀 $s''$，如果 $s'' + c$ 在 $s$ 中没有出现过，那么需要添加转移边 $"endpos"(s'') attach(->, t: c) {n + 1}$。虽然在绝大多数情况下不需要修改已有的转移边，但考虑到某个状态对应的字符串会出现“较长的部分无需添加，较短的部分需要添加”的情况，因此需要将这个状态拆分为两个状态。

= 最终的算法

假设在 $s$ 对应的后缀自动机中，字符串 $s$ 自身对应的状态为 $P = {n}$，此时需要在 $s$ 后添加一个字符 $c$，考虑到字符串 $s + c$ 显然从未出现过，因此后缀自动机中必然会出现一个新的状态 $C = {n + 1}$。根据前面的讨论，需要为新状态 $C$ 确认其父状态，并且添加一些指向 $C$ 的转移边。

不妨通过一个案例来理解最终算法的构造流程。一种可能的后缀自动机部分结构如下图所示：

#figure(
  auto-frame(
    cetz.canvas(background: white.darken(5%), padding: 14pt, {
      import cetz.draw: *

      let unit = 0.4
      
      let draw-round-rect(x, y1, y2) = {
        let y = x * 5 * unit
        let diff = y2 - y1
        let x1 = -((1 + 4 * y1) * unit)
        let x2 = -(x1 * (-1) + diff * 4 * unit + 2 * unit)
        let left = if x1 < x2 { x1 } else { x2 }
        let right = if x1 < x2 { x2 } else { x1 }
        merge-path({
          line((left + unit, y - unit), (right - unit, y - unit))
          arc(radius: unit, (right - unit, y - unit), start: -90deg, stop: 90deg)
          line((right - unit, y + unit), (left + unit, y + unit))
          arc(radius: unit, (left + unit, y + unit), start: 90deg, stop: 270deg)
        })
      }

      let put-text(x, y, s) = {
        content((-(1 + 4 * y) * unit, (-1 + 5 * x) * unit), anchor: "mid", padding: .25, s)
      }

      let draw-link(x1, y1, x2, y2) = {
        y1 += 0.25
        y2 += 0.25
        let centx = -((1 + 4 * y1 + 1 + 4 * y2) * unit / 2)
        let centy = (5 * x1 + 5 * x2) * unit / 2

        stroke(red)
        line((-(1 + 4 * y1) * unit, (5 * x1) * unit), (rel: (-(y2 - y1) * 4 * unit, (x2 - x1) * 5 * unit)), name: "line")
        stroke(black)
      }

      let draw-arrow(x1, y1, x2, y2, ch) = {
        y1 += 0.25
        y2 += 0.25

        let centx = -((1 + 4 * y1 + 1 + 4 * y2) * unit / 2)
        let centy = (5 * x1 + 5 * x2) * unit / 2

        line((-(1 + 4 * y1) * unit, (5 * x1) * unit), (rel: (-(y2 - y1) * 4 * unit, (x2 - x1) * 5 * unit)), name: "line")
        content(
          (centx, centy),
          angle: 0deg,
          box(
            fill: white.darken(5%),
            inset: 3pt,
            text(
              14pt,
              font: ("IBM Plex Mono"),
              ch
            )
          )
        )
      }

      draw-link(-1, 1, -1, -10)
      draw-link(-2, 0, -2, -7)

      draw-arrow(-1, 0, -2, -1, "c")
      draw-arrow(-1, -2, -2, -3, "c")
      draw-arrow(-1, -4, -2, -5, "c")
      draw-arrow(-1, -5, -2, -6, "c")
      draw-arrow(-3, -7, -2, -8, "c")
      draw-arrow(-3, -6, -2, -7, "c")
      
      content((-7 * unit, -5 * unit), $dots.c$)
      content((-3 * unit, -10 * unit), $dots.c$)
      content((38 * unit, -3 * unit), $P$)

      fill(red.lighten(50%))
      draw-round-rect(-1, 0, 0)
      draw-round-rect(-1, -2, -1)
      draw-round-rect(-1, -4, -3)
      draw-round-rect(-1, -5, -5)
      draw-round-rect(-1, -7, -6)
      draw-round-rect(-1, -9, -8)
      draw-round-rect(-1, -10, -10)

      fill(white)
      draw-round-rect(-2, -3, -1)
      draw-round-rect(-2, -8, -4)

      fill(white.darken(20%))
      draw-round-rect(-3, -7, -7)
      draw-round-rect(-3, -6, -6)
    })
  ),
  caption: [一种可能的后缀自动机部分结构，其中从左向右代表字符串长度的增加，红色的状态代表 $s$ 的后缀，剩余的状态为红色状态通过字符 $c$ 转移到达的状态]
)

需要注意，中间的状态不仅存在来自红色状态的转移边，还存在一些来自其他状态的转移边（图中表示为灰色状态的转移边）。算法的第一步是添加一个新的状态 $C$ 来表示结束位置集合 ${n + 1}$。此时，$"len"(C) = n + 1$，而 $"minlen"(C)$ 是未知的，因此我们暂时无法确认 $C$ 的父状态。

#figure(
  auto-frame(
    cetz.canvas(background: white.darken(5%), padding: 14pt, {
      import cetz.draw: *

      let unit = 0.4
      
      let draw-round-rect(x, y1, y2, special: false) = {
        let y = x * 5 * unit
        let diff = y2 - y1
        let x1 = -((1 + 4 * y1) * unit)
        let x2 = -(x1 * (-1) + diff * 4 * unit + 2 * unit)
        let left = if x1 < x2 { x1 } else { x2 }
        let right = if x1 < x2 { x2 } else { x1 }
        if (special) {
          fill(gradient.linear(
            rgb("#97ea6000"), rgb("#97ea6000"), green.lighten(50%)
          ))
          stroke(gradient.linear(
            rgb("#00000000"), rgb("#00000000"), black
          ))
        }
        merge-path({
          line((left + unit, y - unit), (right - unit, y - unit))
          arc(radius: unit, (right - unit, y - unit), start: -90deg, stop: 90deg)
          line((right - unit, y + unit), (left + unit, y + unit))
          arc(radius: unit, (left + unit, y + unit), start: 90deg, stop: 270deg)
        })
      }

      let put-text(x, y, s) = {
        content((-(1 + 4 * y) * unit, (-1 + 5 * x) * unit), anchor: "mid", padding: .25, s)
      }

      let draw-link(x1, y1, x2, y2) = {
        y1 += 0.25
        y2 += 0.25
        let centx = -((1 + 4 * y1 + 1 + 4 * y2) * unit / 2)
        let centy = (5 * x1 + 5 * x2) * unit / 2

        stroke(red)
        line((-(1 + 4 * y1) * unit, (5 * x1) * unit), (rel: (-(y2 - y1) * 4 * unit, (x2 - x1) * 5 * unit)), name: "line")
        stroke(black)
      }

      let draw-arrow(x1, y1, x2, y2, ch) = {
        y1 += 0.25
        y2 += 0.25

        let centx = -((1 + 4 * y1 + 1 + 4 * y2) * unit / 2)
        let centy = (5 * x1 + 5 * x2) * unit / 2

        line((-(1 + 4 * y1) * unit, (5 * x1) * unit), (rel: (-(y2 - y1) * 4 * unit, (x2 - x1) * 5 * unit)), name: "line")
        content(
          (centx, centy),
          angle: 0deg,
          box(
            fill: white.darken(5%),
            inset: 3pt,
            text(
              14pt,
              font: ("IBM Plex Mono"),
              ch
            )
          )
        )
      }

      draw-link(-1, 1, -1, -10)
      draw-link(-2, 0, -2, -7)

      draw-arrow(-1, 0, -2, -1, "c")
      draw-arrow(-1, -2, -2, -3, "c")
      draw-arrow(-1, -4, -2, -5, "c")
      draw-arrow(-1, -5, -2, -6, "c")
      draw-arrow(-3, -7, -2, -8, "c")
      draw-arrow(-3, -6, -2, -7, "c")
      
      content((-7 * unit, -5 * unit), $dots.c$)
      content((-3 * unit, -10 * unit), $dots.c$)
      content((38 * unit, -3 * unit), $P$)
      content((42 * unit, -12 * unit), $C$)

      fill(red.lighten(50%))
      draw-round-rect(-1, 0, 0)
      draw-round-rect(-1, -2, -1)
      draw-round-rect(-1, -4, -3)
      draw-round-rect(-1, -5, -5)
      draw-round-rect(-1, -7, -6)
      draw-round-rect(-1, -9, -8)
      draw-round-rect(-1, -10, -10)

      fill(white)
      draw-round-rect(-2, -3, -1)
      draw-round-rect(-2, -8, -4)

      fill(green.lighten(50%))
      draw-round-rect(-2, -11, -6, special: true)

      fill(white.darken(20%))
      stroke(black)
      draw-round-rect(-3, -7, -7)
      draw-round-rect(-3, -6, -6)
    })
  ),
  caption: [添加新状态 $C$ 来表示结束位置集合 ${n + 1}$，用绿色状态表示，此时 $C$ 的左端点未知，也无法确认 $C$ 的父状态]
)

随后，定义一个指针 $P'$，从 $P$ 开始不断访问其父状态，直到 $P'$ 存在一个转移边 $c$ 为止。在上述图例中，$P'$ 将会停在倒数第四个红色状态上，而其右侧三个红色状态都不存在转移边 $c$。根据前面的讨论，可以确认 $"minlen"(C) = "len"(P') + 2$。定义 $P'$ 转移边 $c$ 的终点为 $Q$。

#figure(
  auto-frame(
    cetz.canvas(background: white.darken(5%), padding: 14pt, {
      import cetz.draw: *

      let unit = 0.4
      
      let draw-round-rect(x, y1, y2, special: false) = {
        let y = x * 5 * unit
        let diff = y2 - y1
        let x1 = -((1 + 4 * y1) * unit)
        let x2 = -(x1 * (-1) + diff * 4 * unit + 2 * unit)
        let left = if x1 < x2 { x1 } else { x2 }
        let right = if x1 < x2 { x2 } else { x1 }
        if (special) {
          fill(gradient.linear(
            rgb("#97ea6000"), rgb("#97ea6000"), green.lighten(50%)
          ))
          stroke(gradient.linear(
            rgb("#00000000"), rgb("#00000000"), black
          ))
        }
        merge-path({
          line((left + unit, y - unit), (right - unit, y - unit))
          arc(radius: unit, (right - unit, y - unit), start: -90deg, stop: 90deg)
          line((right - unit, y + unit), (left + unit, y + unit))
          arc(radius: unit, (left + unit, y + unit), start: 90deg, stop: 270deg)
        })
      }

      let put-text(x, y, s) = {
        content((-(1 + 4 * y) * unit, (-1 + 5 * x) * unit), anchor: "mid", padding: .25, s)
      }

      let draw-link(x1, y1, x2, y2) = {
        y1 += 0.25
        y2 += 0.25
        let centx = -((1 + 4 * y1 + 1 + 4 * y2) * unit / 2)
        let centy = (5 * x1 + 5 * x2) * unit / 2

        stroke(red)
        line((-(1 + 4 * y1) * unit, (5 * x1) * unit), (rel: (-(y2 - y1) * 4 * unit, (x2 - x1) * 5 * unit)), name: "line")
        stroke(black)
      }

      let draw-arrow(x1, y1, x2, y2, ch) = {
        y1 += 0.25
        y2 += 0.25

        let centx = -((1 + 4 * y1 + 1 + 4 * y2) * unit / 2)
        let centy = (5 * x1 + 5 * x2) * unit / 2

        line((-(1 + 4 * y1) * unit, (5 * x1) * unit), (rel: (-(y2 - y1) * 4 * unit, (x2 - x1) * 5 * unit)), name: "line")
        content(
          (centx, centy),
          angle: 0deg,
          box(
            fill: white.darken(5%),
            inset: 3pt,
            text(
              14pt,
              font: ("IBM Plex Mono"),
              ch
            )
          )
        )
      }

      draw-link(-1, 1, -1, -10)
      draw-link(-2, 0, -2, -7)

      draw-arrow(-1, 0, -2, -1, "c")
      draw-arrow(-1, -2, -2, -3, "c")
      draw-arrow(-1, -4, -2, -5, "c")
      draw-arrow(-1, -5, -2, -6, "c")
      draw-arrow(-1, -7, -2, -8, "c")
      draw-arrow(-1, -9, -2, -10, "c")
      draw-arrow(-1, -10, -2, -11, "c")
      draw-arrow(-3, -7, -2, -8, "c")
      draw-arrow(-3, -6, -2, -7, "c")
      
      content((-7 * unit, -5 * unit), $dots.c$)
      content((-3 * unit, -10 * unit), $dots.c$)
      content((38 * unit, -3 * unit), $P$)
      content((18 * unit, -3 * unit), $P'$)
      content((42 * unit, -12 * unit), $C$)
      content((22 * unit, -12 * unit), $Q$)

      fill(red.lighten(50%))
      draw-round-rect(-1, 0, 0)
      draw-round-rect(-1, -2, -1)
      draw-round-rect(-1, -4, -3)
      draw-round-rect(-1, -5, -5)
      draw-round-rect(-1, -7, -6)
      draw-round-rect(-1, -9, -8)
      draw-round-rect(-1, -10, -10)

      fill(white)
      draw-round-rect(-2, -3, -1)
      draw-round-rect(-2, -8, -4)

      fill(green.lighten(50%))
      draw-round-rect(-2, -11, -7)

      fill(white.darken(20%))
      stroke(black)
      draw-round-rect(-3, -7, -7)
      draw-round-rect(-3, -6, -6)
    })
  ),
  caption: [指针完成移动后，添加了三条转移边，并且确认了 $C$ 的左端点]
)

随后可以发现，$C$ 和 $Q$ 在长度上存在重叠。为了解决这个问题，只需要将 $Q$ 拆分为两个状态 $Q_0$ 和 $Q_1$，其中 $"len"(Q_0)$ 和 $"minlen"(C)$ 相邻。随后适当调整 $Q_0$ 和 $Q_1$ 的转移边以及父状态即可完成算法的构造。

#figure(
  auto-frame(
    cetz.canvas(background: white.darken(5%), padding: 14pt, {
      import cetz.draw: *

      let unit = 0.4
      
      let draw-round-rect(x, y1, y2, special: false) = {
        let y = x * 5 * unit
        let diff = y2 - y1
        let x1 = -((1 + 4 * y1) * unit)
        let x2 = -(x1 * (-1) + diff * 4 * unit + 2 * unit)
        let left = if x1 < x2 { x1 } else { x2 }
        let right = if x1 < x2 { x2 } else { x1 }
        if (special) {
          fill(gradient.linear(
            rgb("#97ea6000"), rgb("#97ea6000"), green.lighten(50%)
          ))
          stroke(gradient.linear(
            rgb("#00000000"), rgb("#00000000"), black
          ))
        }
        merge-path({
          line((left + unit, y - unit), (right - unit, y - unit))
          arc(radius: unit, (right - unit, y - unit), start: -90deg, stop: 90deg)
          line((right - unit, y + unit), (left + unit, y + unit))
          arc(radius: unit, (left + unit, y + unit), start: 90deg, stop: 270deg)
        })
      }

      let put-text(x, y, s) = {
        content((-(1 + 4 * y) * unit, (-1 + 5 * x) * unit), anchor: "mid", padding: .25, s)
      }

      let draw-link(x1, y1, x2, y2) = {
        y1 += 0.25
        y2 += 0.25

        let centx = -((1 + 4 * y1 + 1 + 4 * y2) * unit / 2)
        let centy = (5 * x1 + 5 * x2) * unit / 2

        stroke(red)
        line((-(1 + 4 * y1) * unit, (5 * x1) * unit), (rel: (-(y2 - y1) * 4 * unit, (x2 - x1) * 5 * unit)), name: "line")
        stroke(black)
      }

      let draw-arrow(x1, y1, x2, y2, ch) = {
        y1 += 0.25
        y2 += 0.25

        let centx = -((1 + 4 * y1 + 1 + 4 * y2) * unit / 2)
        let centy = (5 * x1 + 5 * x2) * unit / 2

        line((-(1 + 4 * y1) * unit, (5 * x1) * unit), (rel: (-(y2 - y1) * 4 * unit, (x2 - x1) * 5 * unit)), name: "line")
        content(
          (centx, centy),
          angle: 0deg,
          box(
            fill: white.darken(5%),
            inset: 3pt,
            text(
              14pt,
              font: ("IBM Plex Mono"),
              ch
            )
          )
        )
      }

      draw-link(-1, 1, -1, -10)
      draw-link(-2, -6, -3, -7)
      draw-link(-2, 0, -2, -7)

      draw-arrow(-1, 0, -2, -1, "c")
      draw-arrow(-1, -2, -2, -3, "c")
      draw-arrow(-1, -4, -2, -5, "c")
      draw-arrow(-1, -5, -2, -6, "c")
      draw-arrow(-1, -7, -2, -8, "c")
      draw-arrow(-1, -9, -2, -10, "c")
      draw-arrow(-1, -10, -2, -11, "c")
      draw-arrow(-4, -7, -3, -8, "c")
      draw-arrow(-4, -6, -3, -7, "c")
      
      content((-7 * unit, -5 * unit), $dots.c$)
      content((-3 * unit, -10 * unit), $dots.c$)
      content((38 * unit, -3 * unit), $P$)
      content((18 * unit, -3 * unit), $P'$)
      content((42 * unit, -12 * unit), $C$)
      content((22 * unit, -12 * unit), $Q_0$)
      content((31 * unit, -17 * unit), $Q_1$)

      fill(red.lighten(50%))
      draw-round-rect(-1, 0, 0)
      draw-round-rect(-1, -2, -1)
      draw-round-rect(-1, -4, -3)
      draw-round-rect(-1, -5, -5)
      draw-round-rect(-1, -7, -6)
      draw-round-rect(-1, -9, -8)
      draw-round-rect(-1, -10, -10)

      fill(green.lighten(50%))
      draw-round-rect(-2, -3, -1)
      draw-round-rect(-2, -6, -4)

      fill(white)
      draw-round-rect(-3, -8, -7)

      fill(green.lighten(50%))
      draw-round-rect(-2, -11, -7)

      fill(white.darken(20%))
      stroke(black)
      draw-round-rect(-4, -7, -7)
      draw-round-rect(-4, -6, -6)
    })
  ),
  caption: [将 $Q$ 拆分为 $Q_0$ 和 $Q_1$，并重新建立转移边以及父状态关系，绿色状态表示 $s + c$ 的所有后缀，对应下一次增量时的红色状态]
)<i>

这样就得到了完整的算法：

+ 从 $P$ 开始不断访问其父状态，直到访问到一个状态 $P'$ 满足 $P'$ 存在一个转移边 $c$，或者访问到虚拟的“根状态的父状态”为止。在访问中途将会经过所有不存在转移边 $c$ 的状态，此时需要将它们的转移边 $c$ 都指向新状态 $C$。
+ 如果访问到的状态 $P'$ 是“根状态的父状态”，那么将 $C$ 的父状态设置为根状态即可。
+ 否则，根据前面的讨论可以立马得到：$"str"(P')$ 就是 $s$ 中满足“追加字符 $c$ 后仍然在 $s$ 中出现”的最长后缀。考虑 $P'$ 的转移边 $c$ 的终点状态 $Q$：
  - 如果 $"len"(Q) = "len"(P') + 1$，则 $Q$ 就是 $P'$ 在接受字符 $c$ 后转移到的状态，此时将 $C$ 的父状态设置为 $Q$ 即可。
  - 否则，应该有 $"len"(Q) > "len"(P') + 1$，此时考虑 $Q$ 对应的字符串，其中长度超出 $"len"(P') + 1$ 的部分都不是 $s + c$ 的后缀，从而无需修改，而未超出 $"len"(P') + 1$ 的部分都是 $s + c$ 的后缀，从而需要将 $n + 1$ 加入到结束位置集合中。此时，需要将 $Q$ 拆分为两个状态 $Q_0$ 和 $Q_1$，其中：

    - $Q_0$ 表示 $Q$ 对应的字符串中长度在 $["minlen"(Q), "len"(P') + 1]$ 范围内的部分；
    - $Q_1$ 表示 $Q$ 对应的字符串中长度在 $["len"(P') + 2, "len"(Q)]$ 范围内的部分。

    在拆分完成后，$Q_0$ 就是 $P'$ 在接受字符 $c$ 后转移到的状态，此时将 $C$ 的父状态设置为 $Q_0$，通过根据后缀关系，还需要将 $Q_1$ 的父状态设置为 $Q_0$。
    
    此外，还需要将所有指向 $Q$ 的转移边重新指向 $Q_0$ 或者 $Q_1$。考虑指向 $Q$ 的状态（此时的转移字符必然为 $c$），如果它们的转移结果包含 $n + 1$，则需要将它们的转移边重新指向 $Q_0$；否则，需要将它们的转移边重新指向 $Q_1$。注意到转移结果包含位置 $n+1$ 要求自身包含位置 $n$，那么这些位置必然是 $P'$ 及其若干个连续的祖先状态，因此可以通过访问 $P'$ 及其祖先状态来完成上述修改。

    在代码实现中，应该将 $Q_0$ 视为 $Q$ 的克隆状态，此时只需要将 $Q$ 的转移边和父状态复制给 $Q_0$，再根据上述讨论将一些原本指向 $Q$（在克隆完毕后为 $Q_1$）的边重新指向 $Q_0$ 即可。

这样就得到了最为经典的 SAM 增量算法的实现#footnote[这个实现来自 #link("https://oi-wiki.org/string/sam/")[OI Wiki]。]：

```cpp
void sam_extend(char c) {
  // 创建 {n + 1} 对应的状态 C
  int cur = sz++;
  st[cur].len = st[last].len + 1;

  // 从状态 P 开始不断访问其父状态，直到访问到一个状态 P' 满足 P' 存在一个转移边 c，或者访问到“根状态的父状态”为止。
  int p = last;
  while (p != -1 && !st[p].next.count(c)) {
    // 在访问中途将会经过所有不存在转移边 c 的状态，此时需要将它们的转移边 c 都指向新状态 C。
    st[p].next[c] = cur;
    p = st[p].link;
  }
  // 如果访问到的状态 P' 是“根状态的父状态”，那么将 C 的父状态设置为根状态即可。
  if (p == -1) {
    st[cur].link = 0;
  } else {
    // 否则，需要讨论 len(Q) 与 len(P') + 1 的关系。
    int q = st[p].next[c];
    if (st[p].len + 1 == st[q].len) {
      // 如果 len(Q) = len(P') + 1，则 Q 就是 P' 在接受字符 c 后转移到的状态，此时将 C 的父状态设置为 Q 即可。
      st[cur].link = q;
    } else {
      // 否则，应该有 len(Q) > len(P') + 1，此时考虑从 Q 克隆出一个状态 Q0。
      int clone = sz++;
      st[clone].len = st[p].len + 1;
      st[clone].next = st[q].next;
      st[clone].link = st[q].link;
      // 枚举 P' 及其祖先状态，如果它们的转移边 c 的终点是 Q，则将它们的转移边 c 的终点改为 Q0。
      while (p != -1 && st[p].next[c] == q) {
        st[p].next[c] = clone;
        p = st[p].link;
      }
      // 最后，维护后缀链接关系。
      st[q].link = st[cur].link = clone;
    }
  }
  last = cur;
}
```

= 后缀自动机的转移数

在前面的部分提到，对于一个长度为 $n space (n >= 2)$ 的字符串 $s$，其后缀自动机中的状态数不超过 $2n - 1$。在这一部分中，将会进一步证明其转移数不超过 $3 n - 4$。

#note(title: "转移数上界的简单证明")[
  *命题：*对于一个长度不小于 $3$ 的字符串 $s$，其后缀自动机中的转移数不超过 $3|s| - 4$。

  *证明：*首先需要明确的是，后缀自动机中的转移边分为两类：

  - *连续边*：对于一个状态 $P$，如果存在一个转移边 $c$，其终点状态 $Q$ 满足 $"len"(Q) = "len"(P) + 1$，则称此时的转移边 $c$ 是连续边。
  - *非连续边*：对于一个状态 $P$，如果存在一个转移边 $c$，其终点状态 $Q$ 满足 $"len"(Q) > "len"(P) + 1$，则称此时的转移边 $c$ 是非连续边。

  更具体地说，如果将 $"len"(P)$ 视为状态 $P$ 的深度，那么连续边就是连接相邻两层的边，而非连续边就是跨越两层以上的边。在图例中，则可以认为连续边是“尾连尾”的边，而非连续边则是其他的边。

  #figure(
    auto-frame(
      cetz.canvas(background: white.darken(5%), padding: 14pt, {
        import cetz.draw: *

        let unit = 0.6
        
        let draw-round-rect(x, y1, y2) = {
          x *= 5 * unit
          let diff = y2 - y1
          y1 *= 4 * unit
          y2 = y1 + diff * 4 * unit + 2 * unit
          merge-path({
            line((x - unit, y1 + unit), (x - unit, y2 - unit))
            arc(radius: unit, (x - unit, y2 - unit), start: 180deg, stop: 0deg)
            line((x + unit, y2 - unit), (x + unit, y1 + unit))
            arc(radius: unit, (x + unit, y1 + unit), start: 0deg, stop: -180deg)
          })
        }

        let put-text(x, y, s) = {
          content(((-1 + 5 * x) * unit, (1 + 4 * y) * unit), anchor: "mid-east", padding: .25, text(
            14pt,
            font: ("IBM Plex Mono"),
            fill: gray.darken(40%),
            s
          ))
        }

        let draw-arrow(x1, y1, x2, y2, ch) = {
          let centx = (5 * x1 + 5 * x2) * unit / 2
          let centy = (1 + 4 * y1 + 1 + 4 * y2) * unit / 2


          line(((5 * x1) * unit, (1 + 4 * y1) * unit), (rel: ((x2 - x1) * 5 * unit, (y2 - y1) * 4 * unit)), name: "line")
          content(
            (centx, centy),
            angle: 0deg,
            box(
              fill: white.darken(5%),
              inset: 3pt,
              text(
                14pt,
                font: ("IBM Plex Mono"),
                ch
              )
            )
          )
        }

        stroke(2pt)
        stroke(red)
        stroke((dash: "solid"))
        draw-arrow(0, 0, -1, -1, "a")
        draw-arrow(0, 0, 0, -1, "b")
        stroke(blue)
        stroke((dash: "dashed"))
        draw-arrow(0, 0, 1, -1, "c")
        stroke(red)
        stroke((dash: "solid"))
        draw-arrow(-1, -1, 0, -2, "b")
        draw-arrow(0, -1, 1, -2, "c")
        draw-arrow(0, -2, 1, -3, "c")
        stroke(blue)
        stroke((dash: "dashed"))
        draw-arrow(1, -2, 2, -3, "b")
        stroke(red)
        stroke((dash: "solid"))
        draw-arrow(1, -3, 2, -4, "b")
        draw-arrow(2, -4, 3, -5, "c")

        put-text(-1, -1, "a")
        put-text(0, -1, "b")
        put-text(1, -1, "c")
        put-text(0, -2, "ab")
        put-text(1, -2, "bc")
        put-text(2, -2, "cb")
        put-text(1, -3, "abc")
        put-text(2, -3, "bcb")
        put-text(3, -3, "cbc")
        put-text(2, -4, "abcb")
        put-text(3, -4, "bcbc")
        put-text(3, -5, "abcbc")

        stroke(1pt)
        stroke(black)

        fill(white)
        draw-round-rect(0, 0, 0)
        draw-round-rect(-1, -1, -1)
        draw-round-rect(0, -1, -1)
        draw-round-rect(1, -2, -1)

        draw-round-rect(0, -2, -2)
        draw-round-rect(1, -3, -3)
        draw-round-rect(2, -4, -2)
        draw-round-rect(3, -5, -3)
      })
    ),
    caption: [字符串 $mono("abcbc")$ 的后缀自动机中连续边和非连续边的示例，其中红色实线表示连续边，蓝色虚线表示非连续边]
  )

  首先考虑连续边的数量。在这一条件下，应当有 $"str"(Q) = "str"(P) + c$，因此对于所有非根的状态 $Q$，会有至多一条连续边指向 $Q$，对应为将 $"str"(Q)$ 去除最后一个字符后得到的字符串所在的状态。因此，连续边的数量小于状态数，即不超过 $2|s| - 2$。

  另外，所有连续边可以构成一棵树。观察增量函数的行为（或者前面给出的图例），可以注意到：状态 $C$ 总是会从状态 $P$ 通过连续边到达，而克隆状态 $Q_0$ 总是会从状态 $P'$ 通过连续边到达。又因为所有连续边不会消失，因此所有点总是会通过连续边连接。在连续边形成的树上，从根状态到达任意状态 $P$ 的路径总是会形成字符串 $"str"(P)$，只需要注意到状态 $P$ 在树上的深度恰好等于 $"len"(P)$ 即可。

  接下来考虑非连续边的数量。对于一个状态 $P$，如果存在一个转移边 $c$，其终点状态 $Q$ 满足 $"len"(Q) > "len"(P) + 1$。通过这个非连续边，可以读出一个字符串：

  - 令 $u$ 为从根节点出发，沿着连续边到达状态 $P$ 的路径上所形成的字符串，也就是 $"str"(P)$；
  - 令 $v$ 为从状态 $Q$ 到达某个包含 $n$ 的状态的路径上所形成的字符串。此时不要求 $v$ 中的边必须为连续边，并且这总是能够做到的，因为在后缀自动机中，从任意状态出发总是能够通过某条路径到达包含 $n$ 的状态。#footnote[提示：任意取出 $Q$ 中的一个结束位置 $k$，并考虑沿着路径 $s_[k+1, |s| ]$ 前进。]

  则 $u + c + v$ 就是通过这个非连续边所读出的字符串，对应一种从根状态依次到达 $P$、$Q$ 后，到达某一个包含 $n$ 的状态的路径。需要注意到，当前讨论的非连续边是这条路径经过的*第一条非连续边*。同时根据结束状态集合的定义，不难发现 $u + c + v$ 必然是 $s$ 的一个后缀。又因为每一条非连续边读出的字符串两两不同#footnote[提示：利用反证法，此时会存在 $s$ 的一个后缀，在后缀自动机上转移时会产生两条路径，它们经过的第一条非连续边不同。然而，任意字符串在后缀自动机上转移时产生的路径是唯一的，得到矛盾。]，并且读出的字符串不可能是原串#footnote[提示：利用反证法，此时 $s$ 在后缀自动机上转移时会产生一条长度为 $|s|$ 且不完全经过连续边的路径，可以证明路径的终点 $X$ 应该满足 $"len"(X) > |s|$，得到矛盾。]，因此读出的字符串数量不超过 $|s| - 1$，对应的非连续边数量不超过 $|s| - 1$。

  最后，连续边和非连续边的数量之和不超过 $2|s| - 2 + |s| - 1 = 3|s| - 3$。而实际上，上述两个上界无法同时达到（为了让连续边数量恰好等于 $2 |s| - 2$，字符串的形式应该为 $mono("abb...b")$，然而这一形式下非连续边的数量小于 $|s| - 1$），因此转移边的数量不超过 $3|s| - 4$。实际上，使用字符串 $s = mono("abb...bc")$ 即可达到这个上界，这样就完成了证明。$qed$
]

在已知转移数上界的基础之下，就可以开始推导后缀自动机的构建算法的时间复杂度上界了。

#note(title: "后缀自动机的构建算法是线性的")[
  *命题：*若将字符集大小视为常数，则对于一个长度为 $n$ 的字符串 $s$，使用上述算法构造出 $s$ 的后缀自动机的时间复杂度为 $cal(O) (n)$。

  *证明：*在上述代码中，每次扩展一个字符，使用势能分析可以确认除了 29 至 32 行的循环之外，其他部分的时间复杂度为均摊 $cal(O) (1)$。因此，算法的时间复杂度主要取决于 29 至 32 行的循环。

  设进入这个循环时，当前状态为 $P$，注意到 $P$ 包含 $n$，因此 $"str"(P)$ 是 $s$ 的一个后缀。每执行一次循环，$P$ 都会变为 $"link"(P)$，于是 $"str"(P)$ 会变成一个更短的后缀。换句话说，$"str"(P)$ 作为 $s$ 的后缀，其起始位置会不断向右移动。因此，可以使用循环前后 $"str"(P)$ 的长度差作为循环次数的渐进上界。

  这里可以使用 $E(P) = "len"("link"("link"(P)))$ 作为势能函数，不难发现循环在执行不超过两次之后，对应的 $"len"(P')$ 就会小于这个势能函数的值。随后考虑循环的终点，此时 $P'$ 通过 $c$ 可以转移到 $"link"(Q_0) = "link"("link"(C)))$，简单分析可以得到 $"len"(P') = "len"("link"("link"(C))) - 1$。因此，这一次循环的执行次数不超过 $E(P) - E(C) + cal(O)(1)$，而 $C$ 又会作为下一个扩展的 $P$，那么将上限进行累加后就可以得到算法的时间复杂度为 $cal(O) (n)$。#footnote[实际上，这里还需要证明 $E(P) - E(C)$ 不会过小。从@i 中可以看到，一个绿色状态可以对应一个或者多个红色状态，对极端情况（一个绿色状态对应一个红色状态）进行考虑可以得到 $E(C) <= E(P) + 1$。]上述证明中一些边界情况在此略去。$qed$
]

= 一些应用

在完成了后缀自动机的构造之后，就可以使用它来解决一些字符串问题了。

== 基础应用

#success(title: "识别后缀")[
  *问题：*给定一个字符串 $s$ 和若干模式字符串 $t_i$，判断 $t_i$ 是否是 $s$ 的后缀。

  *解法：*这实际上是后缀自动机在本质上需要解决的问题。回忆 AC 自动机中，需要将每个字符串的结尾状态标记为终止状态，这样在匹配过程中就能够知道是否匹配到了某个字符串的结尾状态。对于后缀自动机来说，应该将每个包含位置 $n$ 的状态标记为终止状态，这样在匹配过程中就能够知道是否恰好匹配到了某个字符串的后缀。

  因此，对字符串 $s$ 构造出后缀自动机后，对于每个模式字符串 $t_i$，在后缀自动机上进行匹配，如果最终停在一个包含位置 $n$ 的状态，那么说明 $t_i$ 是 $s$ 的后缀；否则，说明 $t_i$ 不是 $s$ 的后缀。时间复杂度为 $cal(O) (|s| + sum |t_i|)$。
]

#success(title: "识别子串")[
  *问题：*给定一个字符串 $s$ 和若干模式字符串 $t_i$，判断 $t_i$ 是否是 $s$ 的子串。

  *解法：*这也是后缀自动机在本质上需要解决的问题。对字符串 $s$ 构造出后缀自动机后，对于每个模式字符串 $t_i$，在后缀自动机上进行匹配，如果过程中没有出现失配，则说明 $t_i$ 是 $s$ 的子串；否则，说明 $t_i$ 不是 $s$ 的子串。时间复杂度为 $cal(O) (|s| + sum |t_i|)$。
]

#success(title: "本质不同的子串数量")[
  *问题：*给定一个字符串 $s$，求 $s$ 的本质不同的子串数量。

  *解法：*对于一个状态 $P$，其对应的字符串的长度范围为 $["minlen"(P), "len"(P)]$，因此其对应的字符串数量为 $"len"(P) - "minlen"(P) + 1$。因此，后缀自动机中所有状态对应的字符串数量之和即为 $s$ 的本质不同的子串数量。时间复杂度为 $cal(O) (|s|)$。
]

#success(title: "字符串的第 k 小子串")[
  *问题：*给定一个字符串 $s$ 和一个整数 $k$，求 $s$ 的第 $k$ 小子串。

  *解法：*首先对字符串 $s$ 构造出后缀自动机，对于其中的一个状态 $P$，可以计算 $f_P$ 表示从 $P$ 开始能够读出的字符串数量。对于一个状态 $P$，可以使用如下的递归式来计算 $f_P$：

  $
    f_P = 1 + sum_(P attach(->, t: c) Q) f_Q
  $

  随后，从根状态开始，贪心地选择转移边来构造第 $k$ 小子串即可。对于当前状态 $P$，首先需要检查 $k = 1$ 是否成立，随后按照转移字符的字典序依次枚举其转移边 $c$，如果 $f_Q < k$，则说明第 $k$ 小子串不在 $Q$ 的子树中，此时需要将 $k$ 减去 $f_Q$；否则，说明第 $k$ 小子串在 $Q$ 的子树中，此时需要将 $c$ 添加到答案中，并且转移到状态 $Q$ 继续进行选择。时间复杂度为 $cal(O) (|s|)$。
]

== 进阶应用

#success(title: "字符串的出现次数")[
  *问题：*给定一个字符串 $s$ 和若干模式字符串 $t_i$，求每个 $t_i$ 在 $s$ 中的出现次数。

  *解法：*首先对字符串 $s$ 构造出后缀自动机，然后在后缀自动机上匹配每个模式字符串 $t_i$，假设匹配完毕后停在状态 $P_i$。考虑令 $V_j$ 为在加入字符串的 $s$ 的第 $j$ 个字符时，后缀自动机中 ${j}$ 对应的状态，那么对于所有 $V_j$，如果 $P_i$ 是 $V_j$ 的祖先状态，那么 $t_i$ 就出现在了位置 $j - |t_i| + 1$。

  因此设置 $V_j$ 所在的位置存在 $1$ 的贡献，并计算子树和即可。时间复杂度为 $cal(O) (|s| + sum |t_i|)$。
]

#success(title: "字符串的所有出现位置")[
  *问题：*给定一个字符串 $s$ 和若干模式字符串 $t_i$，求每个 $t_i$ 在 $s$ 中的所有出现位置。

  *解法：*沿用上一个部分对 $P_i$ 的定义。在实际实现中，可以使用上述性质通过启发式合并、线段树合并等方式维护 $"endpos"$ 集合，从而得到每个模式字符串的所有出现位置。然而，利用前面对状态数上界的证明（假设字符串 $t_i$ 的出现次数为 $k_i$，那么 $"endpos"(P_i)$ 的大小为 $k_i$，使用前面的递归式可以证明其子树大小不超过 $2k_i - 1$），可以直接枚举后缀链接树上 $P_i$ 的所有后代，并根据标记确认其是否为某一个 $V_j$。时间复杂度为 $cal(O) (|s| + sum |t_i| + sum k_i)$。

  （注：如果需要实际维护每个状态的结束位置集合，一般需要结合可合并的数据结构。）
]

== 公共子串相关

#success(title: "两个字符串的最长公共子串")[
  *问题：*给定两个字符串 $s$ 和 $t$，求它们的最长公共子串。

  *解法：*首先对字符串 $s$ 构造出后缀自动机，然后在后缀自动机上匹配字符串 $t$。在过程中可以使用类似双指针的思想：不断尝试向区间末尾添加 $t$ 的每个字符，在失配时则需要通过访问父状态来进行回退（同时调整靠左的指针），直到能够继续添加字符或者访问到根状态为止。由于“存在某个字符的转移边”在某一条祖先链上存在“单调性”#footnote[可以证明，如果一个状态存在某个字符的转移边，那么其父状态也存在该字符的转移边。]，因此暴力回退得到的结果是正确的。稍微借助一些势能分析即可证明上述匹配过程的时间复杂度为 $cal(O) (|s| + |t|)$。

  另外，这个做法实际上对 $t$ 的每个前缀得到其在 $s$ 中的最长匹配后缀。
]

#success(title: "多个字符串的最长公共子串")[
  *问题：*给定若干字符串 $s_i$，求它们的最长公共子串。

  *解法：*首先对其中最短的一个字符串 $s$ 构造出后缀自动机，然后在后缀自动机上匹配每个字符串 $t_i$。对于每个字符串 $t_i$，通过上述方法可以得到其每个前缀在 $s$ 中的最长匹配后缀，并得到对应的状态。考虑到匹配某一个状态中不超过固定长度的字符串的同时，也匹配了它的所有祖先状态中不超过固定长度的字符串，因此还需要枚举整个后缀自动机，并将最大长度的标记上传。最后，寻找被所有字符串标记的状态，计算出对应字符串的长度范围，得到最长的公共子串。时间复杂度为 $cal(O) (sum |s_i|)$，由于选取了最短的字符串构造后缀自动机，因此上传标记部分并没有形成瓶颈。
]

== 例题

#success(title: "【NOI2018】你的名字")[
  *问题：*给定一个字符串 $s$，需要支持 $q$ 次询问，每次询问给出一个字符串 $t$ 和两个整数 $1 <= l <= r <= |s|$，计算出现在 $t$ 而没有出现在 $s_[l, r]$ 中的字符串数量。

  *解法：*对问题进行容斥，转化为计算 $t$ 的本质不同子串数量，减去同时出现在 $t$ 和 $s_[l, r]$ 中的字符串数量。
  
  首先解决 $l = 1, r = |s|$ 的情况。对于字符串 $s$ 构造出后缀自动机，对于询问字符串 $t$，可以计算出其每个前缀在 $s$ 中的最长匹配后缀。随后，对于字符串 $t$ 也构造出后缀自动机，并计算出 $t$ 的本质不同子串数量。对于 $t$ 中长度为 $k$ 的前缀，已知其在 $s$ 中的最长匹配后缀的长度为 $L_k$，考虑在 $t$ 的后缀自动机中添加完前 $k$ 个字符后，结束状态集合 ${k}$ 对应的状态为 $V_k$，则 $V_k$ 及其所有祖先状态对应的字符串，只要长度不超过 $L_k$，就一定同时出现在 $t$ 和 $s$ 中。将长度限制放在 $V_k$ 上，随后遍历 $t$ 的后缀自动机将限制上传，最后计算出同时出现在 $t$ 和 $s$ 中的字符串数量，得到答案。

  随后解决 $l, r$ 任意的情况。在 $s$ 的后缀自动机中，使用可持久化线段树合并的方式维护每个状态的结束位置集合。沿用前面计算公共子串的思想，使用双指针的思想处理字符串 $t$ 的匹配过程，在失配时通过访问父状态来进行回退，直到能够继续添加字符或者访问到根状态为止。
  
  假设当前在 $t$ 中通过双指针确定的子串为 $t_[i, j]$，且在 $s$ 的后缀自动机中停在状态 $P$，那么在扩展右端点时，除了确认转移边 $t_(j + 1)$ 是否存在之外，还需要确认 $t_[i, j+1]$ 是否出现在转移边 $t_(j + 1)$ 的终点状态 $Q$ 中。不过需要注意的是，即使完整的 $t_[i, j+1]$ 没有出现在 $s_[l, r]$ 中，$t_[i, j+1]$ 的某个较短后缀仍然可能出现在 $s_[l, r]$ 中，因此需要正确处理左端点的移动。

  状态 $Q$ 所代表的字符串长度范围为 $["minlen"(Q), "len"(Q)]$，那么此时需要尝试将计算出满足如下条件的最大长度 $x$：
  
  - $t_[(j + 1) - x + 1, j + 1]$ 出现在 $s_[l, r]$ 中；
  - $x$ 在 $"minlen"(Q)$ 和 $min((j + 1) - i + 1, "len"(Q))$ 之间。
  
  在 $Q$ 的结束位置集合中查询不超过 $r$ 的最大位置 $k$，可以得到 $x$ 应该是 $"len"(Q)$、$(j + 1) - i + 1$ 和 $k - l + 1$ 的最小值。如果 $x >= "minlen"(Q)$，则说明 $t_[i, j+1]$ 的后缀 $t_[(j + 1) - x + 1, j + 1]$ 出现在了 $s_[l, r]$ 中，此时可以将 $i$ 移动到 $(j + 1) - x + 1$，并且将当前状态移动到 $Q$；否则，需要将 $P$ 移动到其父状态（同时缩短当前的匹配长度），并且继续进行上述的判断，直到能够继续添加字符或者访问到根状态为止。

  时间复杂度为 $cal(O) ((|s| + sum |t_i|) log |s|)$。
]

= 扩展：为什么说后缀自动机是最小化的 DFA？

一个 DFA 包含了一些状态，以及连接这些状态的转移边。除此之外，DFA 还需要拥有一个初始状态，以及一些接受状态。对于一个字符串，DFA 从初始状态出发，根据字符串中的每个字符沿着转移边进行转移，如果最终停在一个接受状态，那么说明这个字符串被 DFA 接受了；否则，说明这个字符串没有被 DFA 接受。

将 DFA 接受的所有字符串放在一个集合中，这个集合被称为这个 DFA 的*语言*。对于一个给定的语言，可能存在多个 DFA 接受这个语言，但是其中状态数最少的那个 DFA 是唯一的，这个 DFA 就被称为这个语言的*最小化 DFA*。为了最小化 DFA，可以使用 Myhill-Nerode 定理来进行状态合并。

#note(title: "Myhill-Nerode 定理")[
  *定理：*对于一个语言 $L$，如果存在一个 DFA 接受 $L$，那么对于任意两个字符串 $x$ 和 $y$，如果对于任意字符串 $z$，$x + z$ 在 $L$ 中当且仅当 $y + z$ 在 $L$ 中，则称 $x$ 和 $y$ 是 Myhill-Nerode 等价的。Myhill-Nerode 定理表明，语言 $L$ 的最小化 DFA 的状态数等于字符串集合被 Myhill-Nerode 等价关系划分成的等价类数量。下面将会给出一个简单的证明。

  *证明：*首先证明最小化 DFA 的状态数不超过 Myhill-Nerode 的等价类数量。为此，只需要构造一个状态数等于 Myhill-Nerode 的等价类数量的 DFA，并且证明这个 DFA 接受的语言就是 $L$ 即可（因为最小化 DFA 的状态数肯定不会超过当前构造的 DFA）。为此，只需要将每一个 Myhill-Nerode 等价类对应一个状态，并且对于每个状态 $P$ 和每个字符 $c$，如果存在一个字符串 $x$ 属于 $P$，使得 $x + c$ 属于某个 Myhill-Nerode 等价类 $Q$，则在当前状态 $P$ 上添加一条转移边 $c$，其终点状态为 $Q$。

  可以证明，通过上述方式构造的 DFA 是符合要求的。这里仅讨论转移的二义性。利用反证法，对于一个状态 $P$ 和一个字符 $c$，假设存在两个字符串 $x_1$ 和 $x_2$ 属于 $P$，使得 $x_1 + c$ 属于 Myhill-Nerode 等价类 $Q_1$，而 $x_2 + c$ 属于 Myhill-Nerode 等价类 $Q_2$，且 $Q_1$ 和 $Q_2$ 不同。根据等价类的需求，此时必然存在一个字符串 $z$，使得 $x_1 + c + z$ 和 $x_2 + c + z$ 恰有一个在 $L$ 中。考虑 $z' = c + z$，则 $x_1 + z'$ 和 $x_2 + z'$ 恰有一个在 $L$ 中，可以得到 $x_1$ 和 $x_2$ 不是 Myhill-Nerode 等价的，得到矛盾。

  接下来证明最小化 DFA 的状态数不小于 Myhill-Nerode 的等价类数量。利用反证法，假设存在一个状态数小于 Myhill-Nerode 的等价类数量的 DFA 接受 $L$，则根据鸽巢原理，必然存在一个状态 $P$，使得 $P$ 包含了两个 Myhill-Nerode 不等价的字符串 $x_1$ 和 $x_2$。根据 Myhill-Nerode 定义，此时必然存在一个字符串 $z$，使得 $x_1 + z$ 和 $x_2 + z$ 恰有一个在 $L$ 中。考虑 DFA 从状态 $P$ 出发，按照字符串 $z$ 进行转移的过程，由于 $x_1$ 和 $x_2$ 都在状态 $P$ 中，因此无论 DFA 从状态 $P$ 出发按照字符串 $z$ 进行转移时停在什么状态，都无法区分出 $x_1 + z$ 和 $x_2 + z$ 是否在 $L$ 中，得到矛盾。$qed$
]

在后缀自动机中，需要考虑的语言就是字符串 $s$ 的所有后缀组成的集合。对于这个语言，后缀自动机就是它的最小化 DFA。不难发现，这个语言总是存在一个对应的 DFA（只需要建立这些字符串的 Trie 树即可），因此使用 Myhill-Nerode 定理，只需要证明后缀自动机中包含的状态数等于 Myhill-Nerode 的等价类数量即可。

为了证明这一点，不妨证明“两个字符串不是 Myhill-Nerode 等价的”和“两个字符串的结束位置集合不同”是等价的。为了让结束位置集合扩展到所有字符串，需要适当扩展其定义：对于一个字符串 $s'$，如果 $s'$ 没有在 $s$ 中出现，则 $"endpos"(s') = emptyset$。

- *充分性：*对于两个字符串 $s_1, s_2$，如果它们是 Myhill-Nerode 不等价的，那么必然存在一个字符串 $t$，使得 $s_1 + t$ 和 $s_2 + t$ 中恰有一个是 $s$ 的后缀。不失一般性的，假设 $s_1 + t$ 是 $s$ 的后缀，而 $s_2 + t$ 不是 $s$ 的后缀。不难发现 $t$ 也是 $s$ 的后缀，并且此时 $s_1$ 是 $s_[1,|s|-|t| ]$ 的一个后缀，而 $s_2$ 不是 $s_[1, |s|-|t| ]$ 的一个后缀。根据结束状态集合的定义，$|s|-|t|$ 是 $"endpos"(s_1)$ 的元素，而不是 $"endpos"(s_2)$ 的元素。
- *必要性：*对于两个字符串 $s_1, s_2$，如果它们的结束位置集合不同，则存在一个位置 $i$，使得 $i$ 在 $"endpos"(s_1)$ 和 $"endpos"(s_2)$ 中恰好一个集合存在。不失一般性的，假设 $i$ 在 $"endpos"(s_1)$ 中，而不在 $"endpos"(s_2)$ 中。构造字符串 $z = s_[i + 1, |s| ]$，则 $s_1 + z$ 是 $s$ 的后缀，而 $s_2 + z$ 不是 $s$ 的后缀，因此 $s_1$ 和 $s_2$ 不是 Myhill-Nerode 等价的。

后缀自动机中的每个状态，正是由具有相同 $"endpos"$ 集合的字符串合并而来。也就是说，SAM 的状态与非空 $"endpos"$ 等价类几乎一一对应。对于 $"endpos"$ 集合为空的字符串，可以在后缀自动机中添加一个特殊的状态来表示它们，并将所有失配的转移边指向这个特殊状态，这样就可以保证后缀自动机中的状态数等于 Myhill-Nerode 的等价类数量了。因此，可以认为后缀自动机中的状态数等于 Myhill-Nerode 的等价类数量，那么后缀自动机就是字符串 $s$ 的所有后缀组成的语言的最小化 DFA。
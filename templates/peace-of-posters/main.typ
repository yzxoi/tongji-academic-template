#import "../../../../lib.typ" as pop
#import "@preview/xarrow:0.3.0": xarrow
#import "@preview/codly:1.0.0":*

#set page("a1", margin: 2cm)
#pop.set-poster-layout(pop.layout-a1)
#pop.set-theme(pop.psi-ch)
#let Heiti = ("Times New Roman", "Heiti SC", "Heiti TC", "SimHei")
#let Songti = ("Times New Roman", "Songti SC", "Songti TC", "SimSun")
#let Zhongsong = ("Times New Roman", "STZhongsong", "SimSun")
#let Xbs = ("Times New Roman", "FZXiaoBiaoSong-B05", "FZXiaoBiaoSong-B05S")
#set text(font: Heiti, size: pop.layout-a1.at("body-size"))
#let box-spacing = 1.2em
#set columns(gutter: box-spacing)
#set block(spacing: box-spacing)
#show raw: set text(font: ("Jetbrains Mono NL","PingFang SC","Iosevka", "Fira Mono"))
#show: codly-init.with()
#codly(
	display-icon: true,
	// default-color: rgb("#283593"),
	fill: rgb("ffffff").transparentize(100%),
	stroke: 1pt + luma(200),
	// fill:none,
	zebra-fill: luma(0).transparentize(96%),
	breakable: true,
	// number-format: none,
	languages: (
		rust: (
			name: "Rust",
			icon: text(font: "tabler-icons", "\u{fa53}"),
			color: rgb("#CE412B")
		),
	)
)
#let fakebold(base-weight: none, s, ..params) = {
  set text(weight: base-weight) if base-weight != none
  set text(..params) if params != ()
  context {
    set text(stroke: 0.02857em + text.fill)
    s
  }
}
#let regex-fakebold(reg-exp: ".", base-weight: none, s, ..params) = {
  show regex(reg-exp): it => {
    fakebold(base-weight: base-weight, it, ..params)
  }
  s
}
#let show-fakebold(reg-exp: ".", base-weight: none, s, ..params) = {
  show text.where(weight: "bold").or(strong): it => {
    regex-fakebold(reg-exp: reg-exp, base-weight: base-weight, it, ..params)
  }
  s
}
#let cn-fakebold(s, ..params) = {
  regex-fakebold(reg-exp: "[\p{script=Han}！-･〇-〰—]", base-weight: "regular", s, ..params)
}
#let show-cn-fakebold(s, ..params) = {
  show-fakebold(reg-exp: "[\p{script=Han}！-･〇-〰—]", base-weight: "regular", s, ..params)
}
#show :show-cn-fakebold

#pop.update-poster-layout(spacing: box-spacing, heading-size: 30pt)

#pop.title-box(
    [
        #set text(fill: white)
        #image("guohao.png", width: 40%)
        高级语言程序设计（基础）\
				孔明棋（Peg Solitaire）
    ],
    authors: [
    ],
    institutes: [
    ],
  background: box(image("pink-yellow.png", height: 16cm, width: 100%), inset: -2cm, outset: 0pt),
  authors-size: 27pt,
  institutes-size: 19pt,
)

#set text(font: Songti, size: pop.layout-a1.at("body-size"))
#columns(2,[
  #pop.column-box(heading: "项目简介")[
    孔明棋（Peg Solitaire）是一种经典智力游戏，棋盘由33个孔组成，初始32颗棋子，每次通过跳跃相邻棋子消去棋子，目标最终仅剩棋盘中央一颗棋子。
		
		本项目实现了孔明棋的人机交互系统，提供直观图形界面与AI提示功能，允许实时撤销并配有交互动画，增强游戏体验。
  ]

  #pop.column-box(heading: "1. 设计思路")[
		- 用户交互：使用EasyX实现直观、交互友好的图形界面。
		- 游戏逻辑：采用模块化设计（棋盘、界面、主控模块）。
		- 智能提示：集成IDA\*启发式搜索算法。
		- 界面设计：采用径向渐变、高光效果增强视觉效果。
		#align(center)[
   	#figure(
			image("../../../../../report-flow-ustc/pic/system.png", width: 64%),
			caption: [系统架构图]
    )]
	]
  #pop.column-box(heading: "2. 实现难点与解决方法")[
		*（1）图形界面的径向渐变与镜面高光效果*
    #grid(
      columns: 3,
      gutter: 0.2em,
      image("../../../../../../pic/demo_homepage.png"),
			image("../../../../../../pic/demo_computing.png"),
      image("../../../../../../pic/demo_win.png"),
    )
		手动计算像素颜色，通过putpixel逐像素绘制与非线性三通道插值，实现精准径向渐变。

		仿照径向渐变的实现方式，计算棋子左上角周围一定范围内的像素点，并对这些像素点的颜色调整向白色偏移以模拟镜面反射效果。提升用户体验。
	]
	#pop.column-box()[
		*（2）多线程与界面实时刷新同步*

		相比互斥锁，原子变量具有无锁高性能、低延迟、无死锁风险等优点，适合简单同步场景。

		```cpp
std::atomic<bool> done(false), cancel(false);
std::thread solver([&]() {
    result = pegBoard.GetBestMove(cancel);
    done = true;
});// 新建线程执行求解器计算
		```
	]
	#pop.column-box()[
		*（3）高效的求解算法（启发式设计与对称约化）*
	#align(center)[
			#grid(
				columns: 2,
				gutter: 1.5em,
				figure(
					image("../../../../../../pic/demo_select_small.png"),
					caption: [用户选中提示]
				)
				,
				figure(
				image("../../../../../../pic/demo_hint_small.png"),
					caption: [AI 提示]
				)
			)]
		- 使用位板编码压缩状态空间；
		- $D_4$ 对称性约化有效减少搜索空间；
		- 三路Pattern Database启发式提高搜索效率；
		- 多项一致启发式（角孔 / Peg-Type / Merson 区域）。
  ]

  #pop.column-box(heading: "3. 我与我的智慧助手")[
    本项目开发过程中，使用ChatGPT进行前期算法调研，探索求解器设计思路与优化方向。实际编程过程则使用Copilot完成高效代码补全与风格统一，大幅提高了开发效率和代码质量。
		#align(center)[
			#grid(
				columns: 2,
				gutter: 2em,
				figure(
					image("chatgpt-logo2.png", height: 70pt),
				)
				,
				figure(
				image("Github-Copilot-Logo_Transperent.png", height: 70pt),
				)
			)]
  ]

  // #colbreak()

  #pop.column-box(heading: "4. 实现项目的心得")[
    通过此项目，深入理解了C++与EasyX图形编程、复杂算法设计及基础多线程管理，掌握了图形绘制技巧及高效算法实现方法，强化了项目模块化、功能封装与交互设计的实践能力。
  ]
  #v(1cm)

  #pop.column-box(heading: "关于作者")[
  #grid(
		columns: 2,
		gutter: 0.7em,
		image("IMG_0112.JPG"),
		[
			#v(0.3cm)
			#set text(size: 30pt)
			*余政希 2452633*\
			#set text(font: Heiti, size: pop.layout-a1.at("body-size"))
			同济大学 国豪书院\
			人工智能（精英班）\
			2452633\@tongji.edu.cn
		]
	)
  ]
])

#v(-1em)

#pop.bottom-box(
    heading-box-args: (inset: 1cm, fill: rgb("#dc005a")),
		logo: image("QRcode.png", height: 2em),
)[
    #box(height: 2em)[#set text(font: "Arial",size: 27pt, fill: white, weight: "bold")
    #align(horizon)[For more details, see https://github.com/yzxoi/APB2025/tree/main/Game
		]]
]
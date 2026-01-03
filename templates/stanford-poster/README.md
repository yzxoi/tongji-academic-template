# 学术海报 Beamer 模板（Stanford 风格）

基于 [Stanford LaTeX Poster Template](https://github.com/RylanSchaeffer/Stanford-LaTeX-Poster-Template) 改编，已替换为同济大学标识和配色方案。

## 修改说明

1. **Logo 替换**：已将 Stanford logo 替换为同济大学 logo
2. **配色方案**：使用同济大学主色 #005baa 替代原 Stanford 红色
3. **机构信息**：已更新为同济大学相关信息

## 使用说明

### 获取同济大学 Logo

本模板需要同济大学 logo 文件。请从 [TJ-CSCCG/tongji-visual](https://github.com/TJ-CSCCG/tongji-visual) 获取：

1. 访问 https://github.com/TJ-CSCCG/tongji-visual
2. 下载所需的 logo 文件（推荐使用 SVG 或 PDF 格式）
3. 将文件放置在 `logos/` 目录下
4. 在 `main.tex` 中更新 logo 路径

### 编译

使用 XeLaTeX 编译：

```bash
xelatex main.tex
```

### 自定义

- 修改 `main.tex` 中的标题、作者等信息
- 调整 `beamercolorthemestanford.sty` 中的颜色配置
- 根据需要调整海报尺寸（在 `main.tex` 中修改 `beamerposter` 参数）

## 注意事项

- 本模板使用的同济大学标识来自 tongji-visual 项目
- 所有标识的版权归同济大学所有
- 仅用于学术和非商业用途

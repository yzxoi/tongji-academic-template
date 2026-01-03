# 同济大学学术模板库

收集整理各类学术文档模板（LaTeX、Typst、Word等），供同济大学同学使用。

## 功能特性

- 📚 多种格式支持：LaTeX、Typst、Word
- 🏷️ 分类标签：毕业论文、实验报告、作业报告、实验论文
- 🔍 搜索和筛选功能
- 📱 响应式设计，支持移动端
- 🎨 同济大学视觉识别系统

## 如何贡献模板

我们欢迎所有同学贡献学术模板！以下是添加新模板的步骤：

### 1. Fork 本仓库

点击 GitHub 页面右上角的 "Fork" 按钮，将仓库 fork 到你的账户。

### 2. 准备模板文件

在你的 fork 中，按照以下结构组织模板文件：

```
templates/
└── {template-id}/
    ├── files/              # 模板源文件目录
    │   ├── main.tex        # 或其他源文件
    │   └── ...
    ├── thumbnail.png       # 缩略图（推荐尺寸：600x800px）
    └── preview.pdf         # 预览文件（可选）
```

**模板 ID 命名规则**：
- 使用小写字母、数字和连字符
- 例如：`latex-thesis-undergraduate`、`typst-lab-report`

### 3. 添加模板元数据

在 `data/templates.yaml` 文件中添加新模板的元数据。格式如下：

```yaml
templates:
  - id: template-001
    title: "本科毕业论文 LaTeX 模板"
    description: "基于 XXX 项目改编的同济大学本科毕业论文模板"
    format: "latex"  # latex | typst | word
    type: "thesis"   # thesis | lab-report | homework | experiment
    tags: ["毕业论文", "LaTeX", "本科"]
    thumbnail: "/templates/template-001/thumbnail.png"
    originalRepo: "https://github.com/original/repo"
    originalLicense: "MIT"
    downloadUrl: "/templates/template-001/files.zip"
    previewUrl: "/templates/template-001/preview.pdf"  # 可选
    author: "你的名字"
    addedDate: "2024-01-01"  # YYYY-MM-DD 格式
```

**字段说明**：

- `id`: 唯一标识符，与模板目录名一致
- `title`: 模板标题
- `description`: 模板描述
- `format`: 模板格式（`latex`、`typst` 或 `word`）
- `type`: 模板类型（`thesis`、`lab-report`、`homework` 或 `experiment`）
- `tags`: 标签数组，用于搜索和分类
- `thumbnail`: 缩略图路径（相对于 public 目录）
- `originalRepo`: 原开源项目的 GitHub 地址（或 Overleaf 链接）
- `originalLicense`: 原项目的许可证（可选）
- `downloadUrl`: 下载链接（可以是 zip 文件或目录路径）
- `previewUrl`: 预览文件路径（可选，支持 PDF 或图片）
- `author`: 贡献者名称
- `addedDate`: 添加日期

### 4. 准备缩略图

- 推荐尺寸：600x800px（3:4 比例）
- 格式：PNG 或 JPG
- 内容：展示模板的典型页面或封面

### 5. 创建 Pull Request

1. 将你的更改提交到你的 fork
2. 创建一个 Pull Request 到主仓库
3. 在 PR 描述中说明：
   - 模板的来源和用途
   - 已完成的修改（如将 logo 改为同济大学标识）
   - 原项目的许可证信息

### 6. PR 审核

维护者会审核你的 PR，可能会提出修改建议。请及时响应并更新。

## 模板要求

### 必须修改的内容

所有贡献的模板必须：

1. **替换 logo 和标识**：将原模板中的 logo、学校标识等替换为同济大学的标识
2. **更新视觉元素**：使用同济大学的配色方案（主色：#005baa）
3. **保留原项目信息**：在模板元数据中正确标注原项目地址和许可证

### 文件组织

- 模板源文件放在 `templates/{template-id}/files/` 目录下
- 如果模板文件较多，建议打包为 zip 文件
- 确保所有路径使用相对路径

## 开发指南

### 本地开发

```bash
# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 验证模板数据（添加模板后必须运行）
npm run validate

# 构建生产版本
npm run build

# 预览生产构建（标准模式）
npm run preview

# 预览生产构建（模拟 GitHub Pages 环境）
npm run preview:prod

# 完整检查（验证 + lint + 构建）
npm run check
```

### 本地验证功能

在添加或修改模板后，**强烈建议**运行验证脚本：

```bash
npm run validate
```

验证脚本会检查：
- ✅ YAML 文件格式是否正确
- ✅ 所有必需字段是否存在
- ✅ 格式和类型值是否有效
- ✅ 日期格式是否正确
- ✅ 模板目录和文件是否存在
- ✅ ID 是否唯一
- ✅ 文件路径是否正确

详细的本地开发和调试指南请查看 [docs/LOCAL_DEVELOPMENT.md](docs/LOCAL_DEVELOPMENT.md)

### 项目结构

```
tongji-academic-template/
├── templates/          # 模板文件存储目录
├── data/              # 模板元数据（YAML）
├── src/
│   ├── components/    # React 组件
│   ├── pages/         # 页面组件
│   └── utils/         # 工具函数
└── public/            # 静态资源
```

## 许可证

本项目采用 MIT 许可证。各模板的原始许可证信息在模板元数据中标注。

## 致谢

### 视觉标识

本项目使用的同济大学视觉形象标识（校徽、校名等）来自 [TJ-CSCCG/tongji-visual](https://github.com/TJ-CSCCG/tongji-visual) 项目。感谢该项目提供的矢量图资源，使得模板能够正确使用同济大学的官方视觉元素。

> 注意：tongji-visual 项目中的素材均为非官方制作，仅供学习和研究使用。所有图案、标识、文字及其组合的版权均归同济大学（或实际所有人）所有。

### 贡献者

感谢所有为本项目做出贡献的同学！

## 联系方式

如有问题或建议，请通过 GitHub Issues 联系我们。

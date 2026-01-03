# 本地开发和调试指南

本指南将帮助你设置本地开发环境，验证模板数据，并模拟 GitHub Pages 部署环境。

## 快速开始

### 1. 安装依赖

```bash
npm install
```

### 2. 启动开发服务器

```bash
npm run dev
```

开发服务器将在 `http://localhost:5173` 启动。

## 验证功能

### 验证模板数据

在添加或修改模板后，运行验证脚本检查数据格式和文件完整性：

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

### 完整检查

运行完整的检查（验证 + 代码检查 + 构建）：

```bash
npm run check
```

这将依次执行：
1. 模板数据验证
2. 代码 lint 检查
3. 生产构建测试

## 本地预览生产构建

### 模拟 GitHub Pages 环境

要模拟 GitHub Pages 的部署环境（使用 `/tongji-academic-template/` 作为 base 路径），运行：

```bash
npm run preview:prod
```

这将会：
1. 构建生产版本
2. 使用 GitHub Pages 的 base 路径启动预览服务器
3. 在 `http://localhost:4173/tongji-academic-template/` 提供服务

### 标准预览

使用默认配置预览生产构建：

```bash
npm run build
npm run preview
```

## 开发工作流

### 添加新模板时的检查清单

1. **准备模板文件**
   ```bash
   # 创建模板目录
   mkdir -p templates/your-template-id/files
   # 添加模板文件
   # 添加缩略图 thumbnail.png
   # 添加预览文件 preview.pdf (可选)
   ```

2. **更新 YAML 数据**
   ```bash
   # 编辑 data/templates.yaml
   # 添加新模板的元数据
   ```

3. **验证数据**
   ```bash
   npm run validate
   ```

4. **测试本地开发**
   ```bash
   npm run dev
   # 在浏览器中检查新模板是否正常显示
   ```

5. **测试生产构建**
   ```bash
   npm run preview:prod
   # 确保在 GitHub Pages 路径下正常工作
   ```

6. **提交前检查**
   ```bash
   npm run check
   # 确保所有检查都通过
   ```

## 常见问题

### 验证失败：文件不存在

如果验证脚本报告文件不存在，请检查：

1. **路径是否正确**
   - 缩略图路径应该相对于 `public/` 目录
   - 例如：`/templates/template-id/thumbnail.png` 对应 `public/templates/template-id/thumbnail.png`

2. **文件是否已创建**
   - 确保文件已添加到正确的位置
   - 检查文件名和扩展名是否正确

### 预览时路由不工作

如果使用 `preview:prod` 时路由不工作：

1. 确保使用正确的 URL：`http://localhost:4173/tongji-academic-template/`
2. 检查 `vite.config.ts` 中的 base 配置
3. 确保 `App.tsx` 中使用了正确的 basename

### 开发服务器中数据加载失败

如果开发时无法加载 YAML 数据：

1. 确保 `data/templates.yaml` 文件存在
2. 检查 YAML 格式是否正确（运行 `npm run validate`）
3. 检查浏览器控制台的错误信息

## 调试技巧

### 查看构建输出

```bash
npm run build
# 检查 dist/ 目录中的输出
```

### 检查网络请求

在浏览器开发者工具中：
1. 打开 Network 标签
2. 刷新页面
3. 检查 `/data/templates.yaml` 请求是否成功

### 验证 YAML 格式

如果 YAML 文件有语法错误，验证脚本会显示具体错误信息。

## 环境变量

可以通过环境变量配置：

- `NODE_ENV`: 设置为 `production` 时使用生产配置
- `BASE_URL`: 覆盖默认的 base 路径（在 vite.config.ts 中）

## 下一步

完成本地验证后：
1. 提交代码到 GitHub
2. GitHub Actions 会自动构建和部署
3. 在 GitHub 仓库设置中启用 GitHub Pages
4. 访问 `https://your-username.github.io/tongji-academic-template/`


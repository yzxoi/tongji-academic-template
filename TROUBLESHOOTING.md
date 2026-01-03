# 故障排除指南

## 模板不显示的问题

如果部署到 GitHub Pages 后模板不显示，请检查以下几点：

### 1. YAML 文件路径

确保 `data/templates.yaml` 文件已复制到 `public/data/templates.yaml`。

**解决方法**：
- 运行 `npm run build` 会自动执行 `prebuild` 脚本复制文件
- 或者手动执行：`mkdir -p public/data && cp data/templates.yaml public/data/templates.yaml`

### 2. Base 路径配置

GitHub Pages 使用 `/tongji-academic-template/` 作为 base 路径。

**检查项**：
- `vite.config.ts` 中的 `base` 配置是否正确
- `src/utils/yamlLoader.ts` 是否使用了 `import.meta.env.BASE_URL`

### 3. 浏览器控制台错误

打开浏览器开发者工具（F12），查看 Console 标签页：

- 如果看到 404 错误，说明 YAML 文件路径不正确
- 如果看到 CORS 错误，说明文件未正确部署
- 如果看到解析错误，检查 YAML 文件格式

### 4. 验证部署文件

在 GitHub Pages 上，访问：
```
https://your-username.github.io/tongji-academic-template/data/templates.yaml
```

如果能看到 YAML 内容，说明文件已正确部署。

### 5. 常见问题

**问题**：页面显示但模板列表为空

**可能原因**：
1. YAML 文件格式错误
2. 路径不正确（缺少 base 路径）
3. 浏览器缓存问题

**解决方法**：
1. 运行 `npm run validate` 检查 YAML 格式
2. 清除浏览器缓存或使用无痕模式
3. 检查网络请求（F12 -> Network）查看 YAML 文件是否成功加载

**问题**：本地正常但 GitHub Pages 不显示

**可能原因**：
- Base 路径配置问题
- 文件未正确复制到 public 目录

**解决方法**：
1. 确保 `public/data/templates.yaml` 存在
2. 检查 `vite.config.ts` 中的 base 配置
3. 重新构建并部署

## 调试步骤

1. **本地测试**：
   ```bash
   npm run preview:prod
   ```
   访问 `http://localhost:4173/tongji-academic-template/` 检查是否正常

2. **检查构建输出**：
   ```bash
   npm run build
   ls -la dist/data/
   ```
   确认 `dist/data/templates.yaml` 存在

3. **验证 YAML 格式**：
   ```bash
   npm run validate
   ```

4. **检查 GitHub Actions**：
   - 查看 Actions 标签页
   - 确认构建和部署步骤都成功
   - 检查是否有错误日志

## 联系支持

如果以上方法都无法解决问题，请：
1. 检查浏览器控制台的完整错误信息
2. 查看 GitHub Actions 的构建日志
3. 在 GitHub Issues 中提交问题，附上错误信息


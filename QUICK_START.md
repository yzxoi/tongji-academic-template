# 快速开始指南

## 本地验证和调试

### 1. 验证模板数据

在添加新模板后，运行验证：

```bash
npm run validate
```

### 2. 本地开发

启动开发服务器：

```bash
npm run dev
```

访问 `http://localhost:5173`

### 3. 预览生产构建

模拟 GitHub Pages 环境：

```bash
npm run preview:prod
```

访问 `http://localhost:4173/tongji-academic-template/`

### 4. 完整检查

提交前运行完整检查：

```bash
npm run check
```

## 常用命令

| 命令 | 说明 |
|------|------|
| `npm run dev` | 启动开发服务器 |
| `npm run validate` | 验证模板数据 |
| `npm run build` | 构建生产版本 |
| `npm run preview` | 预览生产构建（标准） |
| `npm run preview:prod` | 预览生产构建（GitHub Pages 模式） |
| `npm run check` | 完整检查（验证 + lint + 构建） |

## 添加模板后的检查清单

- [ ] 运行 `npm run validate` 验证数据
- [ ] 运行 `npm run dev` 测试显示效果
- [ ] 运行 `npm run preview:prod` 测试生产环境
- [ ] 检查所有链接和图片是否正常显示


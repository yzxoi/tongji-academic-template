import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import yaml from 'js-yaml';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');

// 必需的字段
const REQUIRED_FIELDS = [
  'id',
  'title',
  'description',
  'format',
  'type',
  'tags',
  'thumbnail',
  'originalRepo',
  'downloadUrl',
  'author',
  'addedDate',
];

// 有效的格式和类型
const VALID_FORMATS = ['latex', 'typst', 'word'];
const VALID_TYPES = ['thesis', 'lab-report', 'homework', 'experiment'];

// 日期格式正则
const DATE_REGEX = /^\d{4}-\d{2}-\d{2}$/;

let hasErrors = false;
let hasWarnings = false;

function logError(message) {
  console.error(`❌ 错误: ${message}`);
  hasErrors = true;
}

function logWarning(message) {
  console.warn(`⚠️  警告: ${message}`);
  hasWarnings = true;
}

function logSuccess(message) {
  console.log(`✅ ${message}`);
}

function checkFileExists(filePath, description) {
  // 移除开头的斜杠
  const cleanPath = filePath.startsWith('/') ? filePath.slice(1) : filePath;
  const fullPath = path.join(rootDir, 'public', cleanPath);
  
  if (!fs.existsSync(fullPath)) {
    logWarning(`${description} 不存在: ${filePath} (查找路径: ${fullPath})`);
    return false;
  }
  return true;
}

function validateTemplate(template, index) {
  const prefix = `模板 #${index + 1} (id: ${template.id || '未知'})`;
  let isValid = true;

  // 检查必需字段
  for (const field of REQUIRED_FIELDS) {
    if (!(field in template) || template[field] === null || template[field] === undefined) {
      logError(`${prefix}: 缺少必需字段 "${field}"`);
      isValid = false;
    }
  }

  if (!isValid) {
    return false;
  }

  // 验证格式
  if (!VALID_FORMATS.includes(template.format)) {
    logError(`${prefix}: 无效的格式 "${template.format}"，应为: ${VALID_FORMATS.join(', ')}`);
    isValid = false;
  }

  // 验证类型
  if (!VALID_TYPES.includes(template.type)) {
    logError(`${prefix}: 无效的类型 "${template.type}"，应为: ${VALID_TYPES.join(', ')}`);
    isValid = false;
  }

  // 验证标签
  if (!Array.isArray(template.tags) || template.tags.length === 0) {
    logError(`${prefix}: tags 必须是非空数组`);
    isValid = false;
  }

  // 验证日期格式
  if (!DATE_REGEX.test(template.addedDate)) {
    logError(`${prefix}: addedDate 格式错误，应为 YYYY-MM-DD`);
    isValid = false;
  }

  // 验证 URL 格式
  if (template.originalRepo && !template.originalRepo.startsWith('http')) {
    logWarning(`${prefix}: originalRepo 可能不是有效的 URL: ${template.originalRepo}`);
  }

  // 检查缩略图是否存在
  if (template.thumbnail) {
    checkFileExists(template.thumbnail, `${prefix}: 缩略图`);
  }

  // 检查预览文件（如果提供）
  if (template.previewUrl) {
    checkFileExists(template.previewUrl, `${prefix}: 预览文件`);
  }

  // 检查模板目录是否存在
  const templateDir = path.join(rootDir, 'templates', template.id);
  if (!fs.existsSync(templateDir)) {
    logWarning(`${prefix}: 模板目录不存在: templates/${template.id}`);
  } else {
    // 检查 files 目录
    const filesDir = path.join(templateDir, 'files');
    if (!fs.existsSync(filesDir)) {
      logWarning(`${prefix}: 模板 files 目录不存在: templates/${template.id}/files`);
    } else {
      // 检查 files 目录是否为空
      const files = fs.readdirSync(filesDir);
      if (files.length === 0) {
        logWarning(`${prefix}: 模板 files 目录为空`);
      }
    }
  }

  return isValid;
}

function validateYamlFile() {
  const yamlPath = path.join(rootDir, 'data', 'templates.yaml');
  
  if (!fs.existsSync(yamlPath)) {
    logError(`YAML 文件不存在: ${yamlPath}`);
    return false;
  }

  try {
    const yamlContent = fs.readFileSync(yamlPath, 'utf-8');
    const data = yaml.load(yamlContent);

    if (!data || !data.templates) {
      logError('YAML 文件格式错误: 缺少 "templates" 字段');
      return false;
    }

    if (!Array.isArray(data.templates)) {
      logError('YAML 文件格式错误: "templates" 必须是数组');
      return false;
    }

    logSuccess(`找到 ${data.templates.length} 个模板`);

    // 检查 ID 唯一性
    const ids = new Set();
    data.templates.forEach((template, index) => {
      if (template.id) {
        if (ids.has(template.id)) {
          logError(`模板 #${index + 1}: ID "${template.id}" 重复`);
        } else {
          ids.add(template.id);
        }
      }
    });

    // 验证每个模板
    let validCount = 0;
    data.templates.forEach((template, index) => {
      if (validateTemplate(template, index)) {
        validCount++;
      }
    });

    logSuccess(`验证通过: ${validCount}/${data.templates.length} 个模板`);

    return validCount === data.templates.length && !hasErrors;
  } catch (error) {
    logError(`YAML 解析错误: ${error.message}`);
    return false;
  }
}

// 主函数
console.log('开始验证模板数据...\n');

const isValid = validateYamlFile();

console.log('\n验证完成！');

if (hasErrors) {
  console.error('\n❌ 发现错误，请修复后重试');
  process.exit(1);
} else if (hasWarnings) {
  console.warn('\n⚠️  发现警告，请检查');
  process.exit(0);
} else {
  console.log('\n✅ 所有验证通过！');
  process.exit(0);
}


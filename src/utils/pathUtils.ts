/**
 * 工具函数：处理资源路径，确保在 GitHub Pages base 路径下正常工作
 */
export function getAssetPath(path: string): string {
  // 如果路径已经是绝对路径（以 http 开头），直接返回
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return path;
  }
  
  // 获取 base URL（在 GitHub Pages 上会是 /tongji-academic-template/）
  const baseUrl = import.meta.env.BASE_URL || '/';
  
  // 确保路径以 / 开头
  const normalizedPath = path.startsWith('/') ? path : `/${path}`;
  
  // 移除 base URL 末尾的 /，避免双斜杠
  const cleanBase = baseUrl.endsWith('/') ? baseUrl.slice(0, -1) : baseUrl;
  
  // 组合路径
  return `${cleanBase}${normalizedPath}`;
}


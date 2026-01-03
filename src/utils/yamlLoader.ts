import yaml from 'js-yaml';
import type { TemplatesData, Template } from '../types/template';

let cachedData: TemplatesData | null = null;

export async function loadTemplates(): Promise<TemplatesData> {
  if (cachedData) {
    return cachedData;
  }

  try {
    const response = await fetch('/data/templates.yaml');
    const yamlText = await response.text();
    const data = yaml.load(yamlText) as TemplatesData;
    cachedData = data;
    return data;
  } catch (error) {
    console.error('Failed to load templates:', error);
    return { templates: [] };
  }
}

export function getTemplateById(templates: Template[], id: string): Template | undefined {
  return templates.find(t => t.id === id);
}

export function filterTemplates(
  templates: Template[],
  searchQuery: string,
  formatFilter?: string,
  typeFilter?: string
): Template[] {
  let filtered = templates;

  // 搜索过滤
  if (searchQuery) {
    const query = searchQuery.toLowerCase();
    filtered = filtered.filter(template =>
      template.title.toLowerCase().includes(query) ||
      template.description.toLowerCase().includes(query) ||
      template.tags.some(tag => tag.toLowerCase().includes(query))
    );
  }

  // 格式过滤
  if (formatFilter) {
    filtered = filtered.filter(template => template.format === formatFilter);
  }

  // 类型过滤
  if (typeFilter) {
    filtered = filtered.filter(template => template.type === typeFilter);
  }

  return filtered;
}


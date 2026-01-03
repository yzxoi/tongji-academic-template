export type TemplateFormat = 'latex' | 'typst' | 'word';
export type TemplateType = 'thesis' | 'lab-report' | 'homework' | 'experiment';

export interface Template {
  id: string;
  title: string;
  description: string;
  format: TemplateFormat;
  type: TemplateType;
  tags: string[];
  thumbnail: string;
  originalRepo: string;
  originalLicense?: string;
  downloadUrl: string;
  previewUrl?: string;
  author: string;
  addedDate: string;
}

export interface TemplatesData {
  templates: Template[];
}


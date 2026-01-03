import { Link } from 'react-router-dom';
import type { Template } from '../types/template';
import { getAssetPath } from '../utils/pathUtils';
import './TemplateCard.css';

interface TemplateCardProps {
  template: Template;
}

const formatLabels: Record<string, string> = {
  latex: 'LaTeX',
  typst: 'Typst',
  word: 'Word',
};

const typeLabels: Record<string, string> = {
  thesis: '毕业论文',
  'lab-report': '实验报告',
  homework: '作业报告',
  experiment: '实验论文',
};

export default function TemplateCard({ template }: TemplateCardProps) {
  return (
    <div className="template-card">
      <Link to={`/template/${template.id}`} className="template-card-link">
        <div className="template-card-thumbnail">
          <img
            src={getAssetPath(template.thumbnail)}
            alt={template.title}
            onError={(e) => {
              const baseUrl = import.meta.env.BASE_URL || '/';
              (e.target as HTMLImageElement).src = `${baseUrl}vite.svg`;
            }}
          />
        </div>
        <div className="template-card-content">
          <h3 className="template-card-title">{template.title}</h3>
          <p className="template-card-description">{template.description}</p>
          <div className="template-card-meta">
            <span className="template-card-format">{formatLabels[template.format] || template.format}</span>
            <span className="template-card-type">{typeLabels[template.type] || template.type}</span>
          </div>
          <div className="template-card-tags">
            {template.tags.slice(0, 3).map((tag, index) => (
              <span key={index} className="template-card-tag">
                {tag}
              </span>
            ))}
          </div>
        </div>
      </Link>
    </div>
  );
}


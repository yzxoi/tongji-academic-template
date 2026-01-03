import { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { loadTemplates, filterTemplates } from '../utils/yamlLoader';
import type { Template } from '../types/template';
import TemplateCard from '../components/TemplateCard';
import './Category.css';

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

export default function Category() {
  const { category, value } = useParams<{ category: string; value: string }>();
  const [templates, setTemplates] = useState<Template[]>([]);
  const [filteredTemplates, setFilteredTemplates] = useState<Template[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadTemplates().then((data) => {
      setTemplates(data.templates);
      setLoading(false);
    });
  }, []);

  useEffect(() => {
    if (category === 'format' && value) {
      const filtered = filterTemplates(templates, '', value, undefined);
      setFilteredTemplates(filtered);
    } else if (category === 'type' && value) {
      const filtered = filterTemplates(templates, '', undefined, value);
      setFilteredTemplates(filtered);
    } else {
      setFilteredTemplates(templates);
    }
  }, [templates, category, value]);

  const getCategoryTitle = () => {
    if (category === 'format' && value) {
      return formatLabels[value] || value;
    }
    if (category === 'type' && value) {
      return typeLabels[value] || value;
    }
    return '所有模板';
  };

  if (loading) {
    return (
      <div className="category-container">
        <div className="loading">加载中...</div>
      </div>
    );
  }

  return (
    <div className="category-container">
      <div className="category-header">
        <Link to="/" className="back-link">← 返回首页</Link>
        <h1>{getCategoryTitle()}</h1>
        <p className="category-count">共 {filteredTemplates.length} 个模板</p>
      </div>

      {filteredTemplates.length === 0 ? (
        <div className="no-results">
          <p>该分类下暂无模板</p>
        </div>
      ) : (
        <div className="templates-grid">
          {filteredTemplates.map((template) => (
            <TemplateCard key={template.id} template={template} />
          ))}
        </div>
      )}
    </div>
  );
}


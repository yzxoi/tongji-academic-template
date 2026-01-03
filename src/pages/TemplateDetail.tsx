import { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { loadTemplates, getTemplateById } from '../utils/yamlLoader';
import type { Template } from '../types/template';
import { getAssetPath } from '../utils/pathUtils';
import PreviewModal from '../components/PreviewModal';
import './TemplateDetail.css';

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

export default function TemplateDetail() {
  const { id } = useParams<{ id: string }>();
  const [template, setTemplate] = useState<Template | null>(null);
  const [loading, setLoading] = useState(true);
  const [showPreview, setShowPreview] = useState(false);

  useEffect(() => {
    loadTemplates().then((data) => {
      if (id) {
        const found = getTemplateById(data.templates, id);
        if (found) {
          setTemplate(found);
        }
      }
      setLoading(false);
    });
  }, [id]);

  if (loading) {
    return (
      <div className="template-detail-container">
        <div className="loading">加载中...</div>
      </div>
    );
  }

  if (!template) {
    return (
      <div className="template-detail-container">
        <div className="not-found">
          <h2>模板未找到</h2>
          <Link to="/" className="back-button">返回首页</Link>
        </div>
      </div>
    );
  }

  return (
    <div className="template-detail-container">
      <Link to="/" className="back-link">← 返回首页</Link>

      <div className="template-detail-header">
        <div className="template-detail-thumbnail">
          <img
            src={getAssetPath(template.thumbnail)}
            alt={template.title}
            onError={(e) => {
              const baseUrl = import.meta.env.BASE_URL || '/';
              (e.target as HTMLImageElement).src = `${baseUrl}vite.svg`;
            }}
          />
        </div>
        <div className="template-detail-info">
          <h1>{template.title}</h1>
          <p className="template-detail-description">{template.description}</p>
          <div className="template-detail-meta">
            <span className="meta-badge format">{formatLabels[template.format] || template.format}</span>
            <span className="meta-badge type">{typeLabels[template.type] || template.type}</span>
          </div>
          <div className="template-detail-tags">
            {template.tags.map((tag, index) => (
              <span key={index} className="tag">{tag}</span>
            ))}
          </div>
        </div>
      </div>

      <div className="template-detail-content">
        <div className="template-detail-actions">
          <a
            href={getAssetPath(template.downloadUrl)}
            download
            className="action-button primary"
          >
            下载模板
          </a>
          {template.previewUrl && (
            <button
              className="action-button secondary"
              onClick={() => setShowPreview(true)}
            >
              预览模板
            </button>
          )}
          <a
            href={template.originalRepo}
            target="_blank"
            rel="noopener noreferrer"
            className="action-button secondary"
          >
            查看原项目
          </a>
        </div>

        <div className="template-detail-info-section">
          <h2>模板信息</h2>
          <dl className="info-list">
            <dt>格式</dt>
            <dd>{formatLabels[template.format] || template.format}</dd>
            <dt>类型</dt>
            <dd>{typeLabels[template.type] || template.type}</dd>
            <dt>贡献者</dt>
            <dd>{template.author}</dd>
            <dt>添加日期</dt>
            <dd>{template.addedDate}</dd>
            {template.originalLicense && (
              <>
                <dt>原项目许可</dt>
                <dd>{template.originalLicense}</dd>
              </>
            )}
          </dl>
        </div>

        {template.originalRepo && (
          <div className="template-detail-info-section">
            <h2>原项目信息</h2>
            <p>
              本模板基于以下开源项目改编：
              <a
                href={template.originalRepo}
                target="_blank"
                rel="noopener noreferrer"
                className="external-link"
              >
                {template.originalRepo}
              </a>
            </p>
          </div>
        )}
      </div>

      {showPreview && template.previewUrl && (
        <PreviewModal
          url={getAssetPath(template.previewUrl)}
          onClose={() => setShowPreview(false)}
        />
      )}
    </div>
  );
}


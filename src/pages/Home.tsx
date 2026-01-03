import { useState, useEffect } from 'react';
import { useSearchParams } from 'react-router-dom';
import { loadTemplates, filterTemplates } from '../utils/yamlLoader';
import type { Template } from '../types/template';
import TemplateCard from '../components/TemplateCard';
import SearchBar from '../components/SearchBar';
import FilterTags from '../components/FilterTags';
import './Home.css';

export default function Home() {
  const [searchParams, setSearchParams] = useSearchParams();
  const [templates, setTemplates] = useState<Template[]>([]);
  const [filteredTemplates, setFilteredTemplates] = useState<Template[]>([]);
  const [loading, setLoading] = useState(true);

  const searchQuery = searchParams.get('q') || '';
  const formatFilter = searchParams.get('format') || undefined;
  const typeFilter = searchParams.get('type') || undefined;

  useEffect(() => {
    loadTemplates().then((data) => {
      setTemplates(data.templates);
      setLoading(false);
    });
  }, []);

  useEffect(() => {
    const filtered = filterTemplates(templates, searchQuery, formatFilter, typeFilter);
    setFilteredTemplates(filtered);
  }, [templates, searchQuery, formatFilter, typeFilter]);

  const handleSearchChange = (value: string) => {
    const newParams = new URLSearchParams(searchParams);
    if (value) {
      newParams.set('q', value);
    } else {
      newParams.delete('q');
    }
    setSearchParams(newParams);
  };

  const handleFormatChange = (format?: string) => {
    const newParams = new URLSearchParams(searchParams);
    if (format) {
      newParams.set('format', format);
    } else {
      newParams.delete('format');
    }
    setSearchParams(newParams);
  };

  const handleTypeChange = (type?: string) => {
    const newParams = new URLSearchParams(searchParams);
    if (type) {
      newParams.set('type', type);
    } else {
      newParams.delete('type');
    }
    setSearchParams(newParams);
  };

  if (loading) {
    return (
      <div className="home-container">
        <div className="loading">加载中...</div>
      </div>
    );
  }

  return (
    <div className="home-container">
      <div className="home-header">
        <h1>同济大学学术模板库</h1>
        <p className="home-subtitle">收集整理各类学术文档模板，供同济同学使用</p>
      </div>

      <div className="home-filters">
        <SearchBar value={searchQuery} onChange={handleSearchChange} />
        <FilterTags
          formatFilter={formatFilter}
          typeFilter={typeFilter}
          onFormatChange={handleFormatChange}
          onTypeChange={handleTypeChange}
        />
      </div>

      <div className="home-results">
        <div className="results-header">
          <span className="results-count">
            找到 {filteredTemplates.length} 个模板
          </span>
        </div>
        {filteredTemplates.length === 0 ? (
          <div className="no-results">
            <p>没有找到匹配的模板</p>
            <p className="no-results-hint">尝试调整搜索条件或筛选器</p>
          </div>
        ) : (
          <div className="templates-grid">
            {filteredTemplates.map((template) => (
              <TemplateCard key={template.id} template={template} />
            ))}
          </div>
        )}
      </div>
    </div>
  );
}


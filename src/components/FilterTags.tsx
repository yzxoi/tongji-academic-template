import './FilterTags.css';

interface FilterTagsProps {
  formatFilter?: string;
  typeFilter?: string;
  onFormatChange: (format?: string) => void;
  onTypeChange: (type?: string) => void;
}

const formatOptions = [
  { value: 'latex', label: 'LaTeX' },
  { value: 'typst', label: 'Typst' },
  { value: 'word', label: 'Word' },
];

const typeOptions = [
  { value: 'thesis', label: '毕业论文' },
  { value: 'lab-report', label: '实验报告' },
  { value: 'homework', label: '作业报告' },
  { value: 'experiment', label: '实验论文' },
];

export default function FilterTags({
  formatFilter,
  typeFilter,
  onFormatChange,
  onTypeChange,
}: FilterTagsProps) {
  return (
    <div className="filter-tags">
      <div className="filter-group">
        <span className="filter-label">格式：</span>
        <div className="filter-options">
          <button
            className={`filter-option ${!formatFilter ? 'active' : ''}`}
            onClick={() => onFormatChange(undefined)}
          >
            全部
          </button>
          {formatOptions.map((option) => (
            <button
              key={option.value}
              className={`filter-option ${formatFilter === option.value ? 'active' : ''}`}
              onClick={() => onFormatChange(option.value)}
            >
              {option.label}
            </button>
          ))}
        </div>
      </div>
      <div className="filter-group">
        <span className="filter-label">类型：</span>
        <div className="filter-options">
          <button
            className={`filter-option ${!typeFilter ? 'active' : ''}`}
            onClick={() => onTypeChange(undefined)}
          >
            全部
          </button>
          {typeOptions.map((option) => (
            <button
              key={option.value}
              className={`filter-option ${typeFilter === option.value ? 'active' : ''}`}
              onClick={() => onTypeChange(option.value)}
            >
              {option.label}
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}


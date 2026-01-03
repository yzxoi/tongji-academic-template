import { useEffect } from 'react';
import { getAssetPath } from '../utils/pathUtils';
import './PreviewModal.css';

interface PreviewModalProps {
  url: string;
  onClose: () => void;
}

export default function PreviewModal({ url, onClose }: PreviewModalProps) {
  useEffect(() => {
    const handleEscape = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        onClose();
      }
    };
    document.addEventListener('keydown', handleEscape);
    document.body.style.overflow = 'hidden';

    return () => {
      document.removeEventListener('keydown', handleEscape);
      document.body.style.overflow = '';
    };
  }, [onClose]);

  const isPdf = url.toLowerCase().endsWith('.pdf');
  const isImage = /\.(jpg|jpeg|png|gif|webp)$/i.test(url);

  return (
    <div className="preview-modal-overlay" onClick={onClose}>
      <div className="preview-modal-content" onClick={(e) => e.stopPropagation()}>
        <button className="preview-modal-close" onClick={onClose} aria-label="关闭">
          ×
        </button>
        <div className="preview-modal-body">
          {isPdf ? (
            <iframe src={getAssetPath(url)} className="preview-iframe" title="PDF 预览" />
          ) : isImage ? (
            <img src={getAssetPath(url)} alt="预览" className="preview-image" />
          ) : (
            <div className="preview-unsupported">
              <p>不支持预览此文件类型</p>
              <a href={getAssetPath(url)} target="_blank" rel="noopener noreferrer" className="preview-download-link">
                下载查看
              </a>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}


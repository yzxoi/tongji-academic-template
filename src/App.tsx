import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Home from './pages/Home';
import Category from './pages/Category';
import TemplateDetail from './pages/TemplateDetail';
import './App.css';

// GitHub Pages base path
const basePath = import.meta.env.BASE_URL || '/';

function App() {
  return (
    <BrowserRouter basename={basePath}>
      <div className="app">
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/category/:category/:value" element={<Category />} />
          <Route path="/template/:id" element={<TemplateDetail />} />
        </Routes>
      </div>
    </BrowserRouter>
  );
}

export default App;

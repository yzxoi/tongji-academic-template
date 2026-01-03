#!/bin/bash
# 复制模板文件到 public 目录

mkdir -p public/data
cp data/templates.yaml public/data/templates.yaml

# 复制每个模板的文件
for dir in templates/*/; do
  if [ -d "$dir" ]; then
    template_id=$(basename "$dir")
    mkdir -p "public/templates/$template_id"
    
    # 复制缩略图
    if [ -f "$dir/demo.png" ]; then
      cp "$dir/demo.png" "public/templates/$template_id/"
    fi
    
    # 复制下载文件
    if [ -f "$dir/files.zip" ]; then
      cp "$dir/files.zip" "public/templates/$template_id/"
    fi
    
    # 复制预览文件（main.pdf 或 poster.pdf）
    if [ -f "$dir/main.pdf" ]; then
      cp "$dir/main.pdf" "public/templates/$template_id/"
    elif [ -f "$dir/poster.pdf" ]; then
      cp "$dir/poster.pdf" "public/templates/$template_id/"
    fi
  fi
done

echo "模板文件已复制到 public 目录"


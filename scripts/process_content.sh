#!/bin/bash
set -e

echo "🧹 Cleaning old Hugo content..."
rm -rf content/post
mkdir -p content/post

echo "📖 Loading credits..."

declare -A credits

if [[ -f content-source/img/credit.csv ]]; then
    while IFS=, read -r filename credit; do
        filename=$(echo "$filename" | sed 's/^"//;s/"$//')
        credit=$(echo "$credit" | sed 's/^"//;s/"$//')
        credits["$filename"]="$credit"
    done < <(tail -n +2 content-source/img/credit.csv)
else
    echo "⚠️ No credit.csv found."
fi

echo "📝 Processing posts..."

cd content-source/post

for file in *.md; do
    filename=$(basename "$file")
    name="${filename%.md}"

    image=$(grep -E '^image:' "$file" | sed -E 's/image:\s*//')

    if [[ -n "$image" && -f "../img/$image" ]]; then
        mkdir -p "../../content/post/$name"
        cp "$file" "../../content/post/$name/index.md"
        cp "../img/$image" "../../content/post/$name/$image"

        credit="${credits[$image]}"
        if [[ -n "$credit" ]]; then
            echo -e "\n\n---\n$credit" >> "../../content/post/$name/index.md"
        fi
    else
        cp "$file" "../../content/post/$filename"
    fi
done

cd ../..

echo "✅ Content processing complete."


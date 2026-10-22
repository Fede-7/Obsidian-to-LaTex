#!/usr/bin/env bash
set -euo pipefail

# La cartella può essere passata come primo argomento, altrimenti usa ./Images
images_dir="${1:-./Images}"

if [ ! -d "$images_dir" ]; then
    echo "❌ Directory $images_dir non trovata!"
    exit 1
fi

echo "🔄 Conversione WebP -> PNG con ffmpeg..."
echo "=========================================="
echo "Cartella target: $images_dir (incluso sottocartelle)"
echo ""

converted=0
failed=0

# 1. Converti tutti i file .webp (ricorsivamente)
while IFS= read -r -d '' file; do
    base=$(basename "$file" .webp)
    dir=$(dirname "$file")
    output="$dir/$base.png"
    
    echo "⏳ Conversione: $file..."
    if ffmpeg -i "$file" -c:v png "$output" -y -loglevel error 2>/dev/null; then
        echo "✅ $file → $base.png"
        rm "$file"
        converted=$((converted + 1))
    else
        echo "❌ Errore con $file"
        failed=$((failed + 1))
    fi
done < <(find "$images_dir" -type f -name "*.webp" -print0)

# 2. Converti i file .png che sono effettivamente WebP (ricorsivamente)
while IFS= read -r -d '' file; do
    # Controlla se è effettivamente un WebP
    if file "$file" 2>/dev/null | grep -q "WebP"; then
        base=$(basename "$file" .png)
        dir=$(dirname "$file")
        temp_file="$dir/${base}_temp.png"
        
        echo "⏳ Conversione: $file (WebP mascherato)..."
        if ffmpeg -i "$file" -c:v png "$temp_file" -y -loglevel error 2>/dev/null; then
            mv "$temp_file" "$file"
            echo "✅ $file (WebP) → PNG vero"
            converted=$((converted + 1))
        else
            echo "❌ Errore con $file"
            rm -f "$temp_file"
            failed=$((failed + 1))
        fi
    fi
done < <(find "$images_dir" -type f -name "*.png" -print0)

echo ""
echo "=========================================="
echo "✅ Conversione completata!"
echo "   File convertiti: $converted"
if [ "$failed" -gt 0 ]; then
    echo "   ⚠️  File falliti: $failed"
else
    echo "   Nessun file fallito! 🎉"
fi

# Verifica finale (ricorsiva)
echo ""
echo "🔍 Verifica finale..."
# Uso tr -d ' ' per rimuovere gli spazi extra che wc -l aggiunge su macOS
png_count=$(find "$images_dir" -type f -name "*.png" | wc -l | tr -d ' ')
webp_count=$(find "$images_dir" -type f -name "*.webp" | wc -l | tr -d ' ')
jpg_count=$(find "$images_dir" -type f \( -name "*.jpg" -o -name "*.jpeg" \) | wc -l | tr -d ' ')

echo "   File PNG: $png_count"
echo "   File WebP rimasti: $webp_count"
echo "   File JPG/JPEG rimasti: $jpg_count"

# Ulteriore verifica sui contenuti
echo ""
echo "🔎 Verifica contenuto:"
fake_png=$(find "$images_dir" -type f -name "*.png" -exec file {} \; 2>/dev/null | grep -c "WebP" || true)
if [ "$fake_png" -gt 0 ]; then
    echo "   ⚠️  Ancora $fake_png file .png sono in realtà WebP!"
else
    echo "   ✅ Tutti i .png sono PNG veri!"
fi
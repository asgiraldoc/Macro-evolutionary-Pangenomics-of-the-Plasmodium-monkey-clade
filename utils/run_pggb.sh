for i in *.fasta; do
  base=$(basename "$i" .fasta)
  echo "Processing $base..."
  
  pggb \
    -i "$i" \
    -o "${base}_p85_s5kb" \
    -n 10 \
    -t 30 \
    -p 85 \
    -s 5000 \
    -S

  echo "✓ Done: $base"
done

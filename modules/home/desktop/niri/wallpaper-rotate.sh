WALLPAPER_DIR="$HOME/Pictures/wallpapers"
TRANSITIONS=(left right top bottom wipe grow outer)
while true; do
  wallpaper=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" \) | shuf -n 1)
  transition=${TRANSITIONS[$RANDOM % ${#TRANSITIONS[@]}]}
  swww img "$wallpaper" --transition-type "$transition"
  sleep 900
done

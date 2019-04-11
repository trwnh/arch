fdate=$(date +'%a %Y/%m/%d %H:%M:%S')
battery=$(cat /sys/class/power_supply/BAT0/capacity)

echo $fdate 🔋 $battery%

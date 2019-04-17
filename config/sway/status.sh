fdate=$(date +'%A, %Y %B %d - %H:%M:%S')
bcap=$(cat /sys/class/power_supply/BAT0/capacity)
bstate=$(cat /sys/class/power_supply/BAT0/status)
acstate=$(cat /sys/class/power_supply/AC0/online)
vol=$(pamixer --get-volume-human)
monbright=$(light)
sep="⠀⠀"

if [ $acstate -eq 1 ]; then
  bsym=⚡
else
  bsym=🔋
fi

if [ $vol == "muted" ]; then
  vicon=🔇
else
  vicon=🔊
fi

echo $sep🕒 $fdate $sep$bsym $bcap% - $bstate $sep$vicon $vol 💡$monbright% $sep

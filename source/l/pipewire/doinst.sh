# Toss redundant sample files:
for file in pipewire.desktop pipewire-media-session.desktop pipewire-pulse.desktop ; do
  cmp etc/xdg/autostart/${file} etc/xdg/autostart/${file}.sample 2> /dev/null && rm etc/xdg/autostart/${file}.sample
done

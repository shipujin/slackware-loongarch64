config() {
  NEW="$1"
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  # If there's no config file by that name, mv it over:
  if [ ! -r $OLD ]; then
    mv $NEW $OLD
  elif [ "$(cat $OLD | md5sum)" = "$(cat $NEW | md5sum)" ]; then
    # toss the redundant copy
    rm $NEW
  fi
  # Otherwise, we leave the .new copy for the admin to consider...
}

preserve_perms() {
  NEW="$1"
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  if [ -e $OLD ]; then
    cp -a $OLD ${NEW}.incoming
    cat $NEW > ${NEW}.incoming
    # Also preserve timestamp:
    touch -r $NEW ${NEW}.incoming
    mv ${NEW}.incoming $NEW
  fi
  config $NEW
}

# Process config files in etc/grub.d/:
for file in etc/grub.d/*.new ; do
  preserve_perms $file
  # Move it into place. These are not intended to be edited locally - make new custom scripts!
  # We'll skip moving 40_custom.new, though.
  if [ -r $file -a ! "$file" = "etc/grub.d/40_custom.new" ]; then
    mv $file $(dirname $file)/$(basename $file .new)
  fi
done
config etc/default/grub.new

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

config etc/gconf/2/path.new
config etc/gconf/2/evoldap.conf.new

if [ -x /usr/bin/gio-querymodules ]; then
  chroot . /usr/bin/gio-querymodules @LIBDIR@/gio/modules/ >/dev/null 2>&1
fi


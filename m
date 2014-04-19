From: Andrey Borzenkov <arvidjaar@gmail.com>
Date: Sat, 19 Apr 2014 10:08:17 +0400
Subject: 2.02.98: lvmetad activation fails when no VG is defined: Internal error: Handler needs existing VG.
Message-ID: <20140419100817.758aea28@opensuse.site>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

openSUSE 13.1 running in pure lvmetad activation mode with root on
non-LVM. Several PVs without any VG defined. During boot I get

Apr 19 09:27:29 linux-qqqf systemd-udevd[247]: '/sbin/lvm pvscan --cache --activate ay --major 8 --minor 33' [870] terminated by signal 6 (Aborted)
Apr 19 09:27:29 linux-qqqf systemd-udevd[249]: '/sbin/lvm pvscan --cache --activate ay --major 8 --minor 17' [874] terminated by signal 6 (Aborted)
Apr 19 09:27:29 linux-qqqf systemd-udevd[248]: '/sbin/lvm pvscan --cache --activate ay --major 8 --minor 49' [871] terminated by signal 6 (Aborted)

and running with debug enabled

Apr 19 09:42:36 linux-qqqf lvm[784]: VG  not found on /dev/sdc1
Apr 19 09:42:36 linux-qqqf lvm[778]: /dev/sdd1: block size is 4096 bytes
Apr 19 09:42:36 linux-qqqf lvm[784]: Closed /dev/sdc1
Apr 19 09:42:36 linux-qqqf lvm[778]: VG  not found on /dev/sdd1
Apr 19 09:42:36 linux-qqqf lvm[784]: Internal error: Handler needs existing VG.
Apr 19 09:42:36 linux-qqqf lvm[778]: Closed /dev/sdd1
Apr 19 09:42:36 linux-qqqf lvm[778]: Internal error: Handler needs existing VG.
Apr 19 09:42:36 linux-qqqf systemd-udevd[251]: '/sbin/lvm pvscan -dddddd --cache --activate ay --major 8 --minor 17' [783] terminated by signal 11 (Segmentation fault)
Apr 19 09:42:36 linux-qqqf systemd-udevd[249]: '/sbin/lvm pvscan -dddddd --cache --activate ay --major 8 --minor 33' [784] terminated by signal 11 (Segmentation fault)
Apr 19 09:42:36 linux-qqqf systemd-udevd[250]: '/sbin/lvm pvscan -dddddd --cache --activate ay --major 8 --minor 49' [778] terminated by signal 11 (Segmentation fault)

As version is rather old it is probably fixed already; could someone
point me to commit that fixes it, I could not find obvious match. Thank
you!



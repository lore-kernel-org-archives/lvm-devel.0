From: Oliver Rath <rath@mglug.de>
Date: Thu, 29 Aug 2013 11:54:39 +0200
Subject: lvrename changes link to direct /dev/dm-X
Message-ID: <521F1A5F.9040805@mglug.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi list,

I was able to reproduze the renaming issue on a gentoo-machine with lvm-git:

heimserver ~ # lvcreate --name myoriginal -V 10M -T dmivg/winthinpool
  Rounding up size to full physical extent 12,00 MiB
  Logical volume "myoriginal" created
heimserver ~ # ls -l /dev/dmivg/myoriginal
lrwxrwxrwx 1 root root 28 29. Aug 11:46 /dev/dmivg/myoriginal ->
/dev/mapper/dmivg-myoriginal
heimserver ~ # lvrename /dev/dmivg/myoriginal myrenamedoriginal
  Renamed "myoriginal" to "myrenamedoriginal" in volume group "dmivg"
heimserver ~ # ls -l /dev/dmivg/myrenamedoriginal
lrwxrwxrwx 1 root root 8 29. Aug 11:47 /dev/dmivg/myrenamedoriginal ->
../dm-13
heimserver ~ # ls -l /dev/mapper/dmivg-myrenamedoriginal
lrwxrwxrwx 1 root root 8 29. Aug 11:47
/dev/mapper/dmivg-myrenamedoriginal -> ../dm-13


It seems, that after renaming the link points directly to the /dev/dm-X
device, before that he linked to the link in /dev/mapper/..

In Ubuntu additionally there came an error-message "unable to rename ..."

The same in Ubuntu 12.04.03 with lvm-git:

root at asterisk:~# heimserver ~ # lvcreate --name myoriginal -V 10M -T
dmivg/winthinpool
heimserver: Befehl nicht gefunden.
root at asterisk:~# lvcreate --name myoriginal -V 10M -T dmivg/winthinpool
  Rounding up size to full physical extent 12,00 MiB
  Logical volume "myoriginal" created
root at asterisk:~# ls -l /dev/dmivg/myoriginal
lrwxrwxrwx 1 root root 28 Aug 29 11:50 /dev/dmivg/myoriginal ->
/dev/mapper/dmivg-myoriginal
root at asterisk:~# ls -l /dev/mapper/dmivg-myoriginal
lrwxrwxrwx 1 root root 8 Aug 29 11:50 /dev/mapper/dmivg-myoriginal ->
../dm-55
root at asterisk:~# lvrename /dev/dmivg/myoriginal myrenamedoriginal
  Renamed "myoriginal" to "myrenamedoriginal" in volume group "dmivg"
  Unable to rename device node from 'dmivg-myoriginal' to
'dmivg-myrenamedoriginal'
root at asterisk:~# ls -l /dev/dmivg/myrenamedoriginal
lrwxrwxrwx 1 root root 35 Aug 29 11:51 /dev/dmivg/myrenamedoriginal ->
/dev/mapper/dmivg-myrenamedoriginal
root at asterisk:~# ls -l /dev/mapper/dmivg-myrenamedoriginal
brw------- 1 root root 252, 55 Aug 29 11:51
/dev/mapper/dmivg-myrenamedoriginal
root at asterisk:~#

Here the device twice: in /dev/dm-55 _and_ in
/dev/mapper/dmivg-myrenamedoriginal

@Zdenek: if you need a -vvvv log, please tell me.

Tfh!
Oliver



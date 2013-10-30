From: Oliver Rath <rath@mglug.de>
Date: Wed, 30 Oct 2013 01:03:00 +0100
Subject: indirection level for links for thinpools and thin volumes differ in ubuntu 12.04.3
Message-ID: <52704CB4.7050604@mglug.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi list,

Im not sure, if this is wanted:

If I create a thinpool-device, it is a link from /dev/<vg>/thinpoolname
to /dev/mapper/<vg>-thinpoolname, which is a link to /dev/dm-XX. .

But if I create a thinpool-volume from this device, the link to
/dev/dmi-XX is created directly:

Furthermore, the udev-rule for the thinpool-device creation seems to be
broken:

root at dmicrash:lvm2# lvcreate  --size 20G --thinpool dmivg/testpoollink
  Logical volume "testpoollink" created
  The link /dev/dmivg/testpoollink should have been created by udev but
it was not found. Falling back to direct link creation.
root at dmicrash:lvm2# ls -l /dev/dmivg/testpoollink
lrwxrwxrwx 1 root root 30 Okt 30 00:53 /dev/dmivg/testpoollink ->
/dev/mapper/dmivg-testpoollink
root at dmicrash:lvm2# ls -l /dev/mapper/dmivg-testpoollink
lrwxrwxrwx 1 root root 7 Okt 30 00:53 /dev/mapper/dmivg-testpoollink ->
../dm-7
root at dmicrash:lvm2# lvcreate  -V 2G --name testthinlink --thinpool
dmivg/testpoollink
  Logical volume "testthinlink" created
root at dmicrash:lvm2# ls -l /dev/dmivg/testthinlink
lrwxrwxrwx 1 root root 8 Okt 30 00:54 /dev/dmivg/testthinlink -> ../dm-11

This is tested on a Ubuntu 12.04.3 with the lvm-sources from today,
compiled with

./configure --with-thin=internal --with-replicators=internal
--enable-udev_sync --enable-udev_rules

Regards,
Oliver



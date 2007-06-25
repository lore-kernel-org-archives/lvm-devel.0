From: Bryn M. Reeves <breeves@redhat.com>
Date: Mon, 25 Jun 2007 13:45:13 +0100
Subject: fix lvmdiskscan volume reporting when using lvm shell
Message-ID: <467FB8D9.5090004@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Currently lvmdiskscan uses four global counters to track the number of
disks, partitions & PVs located. These are statically initialised to
zero but are never reset between runs.

This is fine for the standalone command but causes mis-reporting when
the tool is repeatedly run in the lvm shell:

# lvm
lvm> lvmdiskscan
  /dev/ramdisk               [       16.00 MB]
  /dev/loop0                 [      500.00 MB] LVM physical volume
[...]
  7 disks
  14 partitions
  0 LVM physical volume whole disks
  1 LVM physical volume
lvm> lvmdiskscan
  /dev/ramdisk               [       16.00 MB]
  /dev/loop0                 [      500.00 MB] LVM physical volume
[...]
  14 disks
  28 partitions
  0 LVM physical volume whole disks
  2 LVM physical volumes

etc.

Patch just moves the initialisation into the lvmdiskscan function.

Regards,
Bryn.
	
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFGf7jZ6YSQoMYUY94RAjUEAJ9LMqyi8bZdRqNrynK6CefPnIau2ACfVv4I
km8ZqH2XpwTPdxhWhSx37og=
=ce90
-----END PGP SIGNATURE-----
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvmdiskscan.patch
Type: text/x-patch
Size: 910 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070625/964e7574/attachment.bin>

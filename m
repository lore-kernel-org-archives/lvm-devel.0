From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 2 Mar 2011 13:49:30 -0000
Subject: LVM2/test t-snapshot-autoumount-dmeventd.sh
Message-ID: <20110302134930.546.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-03-02 13:49:30

Modified files:
	test           : t-snapshot-autoumount-dmeventd.sh 

Log message:
	Fix test to use explicit /dev/mapper/ node, /proc/mounts should not change this...
	(failed on RHEL5)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-snapshot-autoumount-dmeventd.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/t-snapshot-autoumount-dmeventd.sh	2011/01/05 00:16:20	1.2
+++ LVM2/test/t-snapshot-autoumount-dmeventd.sh	2011/03/02 13:49:29	1.3
@@ -28,7 +28,7 @@
 lvchange --monitor y $vg/snap
 
 mkdir mnt
-mount $DM_DEV_DIR/$vg/snap mnt
+mount $DM_DEV_DIR/mapper/$vg-snap mnt
 mount
 cat /proc/mounts | grep $vg-snap
 



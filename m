From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 26 Oct 2010 12:53:08 -0000
Subject: LVM2/test t-lvconvert-repair-dmeventd.sh
Message-ID: <20101026125308.11780.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-10-26 12:53:07

Modified files:
	test           : t-lvconvert-repair-dmeventd.sh 

Log message:
	Use a more generous timeout for dmeventd in t-lvconvert-repair-dmeventd.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair-dmeventd.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/t-lvconvert-repair-dmeventd.sh	2010/05/12 11:23:16	1.2
+++ LVM2/test/t-lvconvert-repair-dmeventd.sh	2010/10/26 12:53:07	1.3
@@ -20,7 +20,7 @@
 lvchange --monitor y $vg/4way
 disable_dev $dev2 $dev4
 mkfs.ext2 $DM_DEV_DIR/$vg/4way
-sleep 3 # FIXME: need a "poll" utility, akin to "check"
+sleep 10 # FIXME: need a "poll" utility, akin to "check"
 enable_dev $dev2 $dev4
 check mirror $vg 4way
 check mirror_legs $vg 4way 2



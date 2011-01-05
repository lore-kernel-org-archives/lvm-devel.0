From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 5 Jan 2011 14:15:02 -0000
Subject: LVM2/test t-lvconvert-repair-transient.sh
Message-ID: <20110105141502.31030.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-01-05 14:15:01

Modified files:
	test           : t-lvconvert-repair-transient.sh 

Log message:
	Re-enable t-lvconvert-repair-transient, avoiding the deadlock by running mkfs
	asynchronously.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair-transient.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/test/t-lvconvert-repair-transient.sh	2011/01/05 00:16:20	1.3
+++ LVM2/test/t-lvconvert-repair-transient.sh	2011/01/05 14:15:01	1.4
@@ -11,18 +11,16 @@
 
 . lib/test
 
-exit 200 # this breaks upstream .33 and RHEL6 kernel :(
-
 aux prepare_vg 5
 
-# fail multiple devices
-
 lvcreate -m 3 --ig -L 1 -n 4way $vg
 aux disable_dev $dev2 $dev4
-mkfs.ext3 $DM_DEV_DIR/$vg/4way
+mkfs.ext3 $DM_DEV_DIR/$vg/4way &
+sleep 1
 aux enable_dev $dev2 $dev4
 echo n | lvconvert --repair $vg/4way 2>&1 | tee 4way.out
 lvs -a -o +devices | not grep unknown
 vgreduce --removemissing $vg
 check mirror $vg 4way
 lvchange -a n $vg/4way
+wait



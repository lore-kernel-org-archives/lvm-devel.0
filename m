From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 1 May 2012 19:21:26 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c test/ ...
Message-ID: <20120501192126.8834.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2012-05-01 19:21:25

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 
	test/shell     : lvconvert-repair-snapshot.sh 
	                 snapshots-of-mirrors.sh 
	                 vgreduce-removemissing-snapshot.sh 

Log message:
	Disallow snapshots of mirror segment types.
	
	Snapshots of RAID logical volumes are allowed (including "raid1").  However,
	snapshots of "mirror" logical volumes has been disallowed due to unsolvable
	issues inherent to the design.  The fact that mirroring (dm-raid1.c) must
	stop all I/O as the result of a failure and wait for userspace intervention
	can lead to a circular dependency if userspace is simultaneously waiting for
	snapshots (on mirrors) to make an I/O update before proceeding.
	
	Various snapshot on mirror tests have been removed as a result.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2395&r2=1.2396
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.372&r2=1.373
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-repair-snapshot.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/snapshots-of-mirrors.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgreduce-removemissing-snapshot.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/WHATS_NEW	2012/04/26 17:30:49	1.2395
+++ LVM2/WHATS_NEW	2012/05/01 19:21:24	1.2396
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Disallow snapshots of mirror segment type.
   Fix bug in cmirror that caused incorrect status info to print on some nodes.
   Remove statement that snapshots cannot be tagged from lvm man page.
   Disallow changing cluster attribute of VG while RAID LVs are active.
--- LVM2/lib/metadata/lv_manip.c	2012/03/05 15:05:25	1.372
+++ LVM2/lib/metadata/lv_manip.c	2012/05/01 19:21:24	1.373
@@ -4208,12 +4208,10 @@
 				return NULL;
 			}
 
-			if ((org->status & MIRROR_IMAGE) ||
-			    (org->status & MIRROR_LOG)) {
-				log_error("Snapshots of mirror %ss "
-					  "are not supported",
-					  (org->status & MIRROR_LOG) ?
-					  "log" : "image");
+			if (lv_is_mirror_type(org) &&
+			    !seg_is_raid(first_seg(org))) {
+				log_error("Snapshots of \"mirror\" segment types"
+					  " are not supported");
 				return NULL;
 			}
 
--- LVM2/test/shell/lvconvert-repair-snapshot.sh	2012/03/16 13:00:06	1.2
+++ LVM2/test/shell/lvconvert-repair-snapshot.sh	2012/05/01 19:21:25	1.3
@@ -11,6 +11,13 @@
 
 . lib/test
 
+exit 0
+#
+# Snapshots of 'mirrors' are not supported.  They can no longer be created.
+# This file could be used to test some aspect of lvconvert, snapshot, and
+# RAID at some point though...
+#
+
 aux prepare_vg 5
 aux lvmconf 'allocation/maximise_cling = 0'
 aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
--- LVM2/test/shell/snapshots-of-mirrors.sh	2012/03/16 13:00:06	1.2
+++ LVM2/test/shell/snapshots-of-mirrors.sh	2012/05/01 19:21:25	1.3
@@ -13,9 +13,15 @@
 
 aux prepare_vg 4
 
-# Create snapshot of a mirror origin
+# Attempt to create snapshot of a mirror origin - should fail
 lvcreate -m 1 -L 10M -n lv $vg
-lvcreate -s $vg/lv -L 10M -n snap
+not lvcreate -s $vg/lv -L 10M -n snap
+
+exit 0
+
+#
+# Snapshots of mirrors are no longer allowed.
+#
 
 # Down-convert (mirror -> linear) under a snapshot
 lvconvert -m0 $vg/lv
--- LVM2/test/shell/vgreduce-removemissing-snapshot.sh	2012/03/16 13:00:06	1.2
+++ LVM2/test/shell/vgreduce-removemissing-snapshot.sh	2012/05/01 19:21:25	1.3
@@ -11,6 +11,14 @@
 
 . lib/test
 
+exit 0
+
+#
+# Snapshots of 'mirrors' are not supported.  They can no longer be created.
+# This file could be used to test some aspect of vgreduce, snapshot, and
+# RAID at some point though...
+#
+
 aux prepare_vg 5
 
 lvcreate -m 3 --ig -L 2M -n 4way $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5":0



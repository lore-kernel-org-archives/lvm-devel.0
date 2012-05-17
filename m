From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 17 May 2012 08:04:13 -0000
Subject: LVM2/test/shell lvconvert-repair-snapshot.sh s ...
Message-ID: <20120517080413.25296.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-05-17 08:04:11

Modified files:
	test/shell     : lvconvert-repair-snapshot.sh 
	                 snapshots-of-mirrors.sh 

Log message:
	Re-enable tests for snapshots of mirrors.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-repair-snapshot.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/snapshots-of-mirrors.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/test/shell/lvconvert-repair-snapshot.sh	2012/05/01 19:21:25	1.3
+++ LVM2/test/shell/lvconvert-repair-snapshot.sh	2012/05/17 08:04:11	1.4
@@ -11,13 +11,6 @@
 
 . lib/test
 
-exit 0
-#
-# Snapshots of 'mirrors' are not supported.  They can no longer be created.
-# This file could be used to test some aspect of lvconvert, snapshot, and
-# RAID at some point though...
-#
-
 aux prepare_vg 5
 aux lvmconf 'allocation/maximise_cling = 0'
 aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
--- LVM2/test/shell/snapshots-of-mirrors.sh	2012/05/16 15:01:06	1.4
+++ LVM2/test/shell/snapshots-of-mirrors.sh	2012/05/17 08:04:11	1.5
@@ -18,12 +18,6 @@
 
 lvcreate -s $vg/lv -L 10M -n snap
 
-exit 0
-
-#
-# Snapshots of mirrors are no longer allowed.
-#
-
 # Down-convert (mirror -> linear) under a snapshot
 lvconvert -m0 $vg/lv
 



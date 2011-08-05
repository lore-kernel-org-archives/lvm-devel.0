From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 5 Aug 2011 09:21:14 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20110805092114.14694.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-08-05 09:21:13

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Remove unused 'origin' variable in lv_remove_single function.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.269&r2=1.270

--- LVM2/lib/metadata/lv_manip.c	2011/08/02 22:07:22	1.269
+++ LVM2/lib/metadata/lv_manip.c	2011/08/05 09:21:13	1.270
@@ -2923,7 +2923,6 @@
 {
 	struct volume_group *vg;
 	struct lvinfo info;
-	struct logical_volume *origin = NULL;
 
 	vg = lv->vg;
 
@@ -2983,7 +2982,6 @@
 		return 0;
 
 	if (lv_is_cow(lv)) {
-		origin = origin_from_cow(lv);
 		log_verbose("Removing snapshot %s", lv->name);
 		/* vg_remove_snapshot() will preload origin/former snapshots */
 		if (!vg_remove_snapshot(lv))



From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 17 Feb 2010 23:36:45 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20100217233645.21290.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-02-17 23:36:45

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Do not reload origin again in lv_remove_single() if it had a merging
	snapshot.  vg_remove_snapshot() will have already performed the required
	reload.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.208&r2=1.209

--- LVM2/lib/metadata/lv_manip.c	2010/02/17 22:59:46	1.208
+++ LVM2/lib/metadata/lv_manip.c	2010/02/17 23:36:45	1.209
@@ -2064,6 +2064,7 @@
 	struct volume_group *vg;
 	struct lvinfo info;
 	struct logical_volume *origin = NULL;
+	int was_merging = 0;
 
 	vg = lv->vg;
 
@@ -2118,6 +2119,7 @@
 
 	if (lv_is_cow(lv)) {
 		origin = origin_from_cow(lv);
+		was_merging = lv_is_merging_origin(origin);
 		log_verbose("Removing snapshot %s", lv->name);
 		/* vg_remove_snapshot() will preload origin if it was merging */
 		if (!vg_remove_snapshot(lv))
@@ -2140,8 +2142,8 @@
 	if (!vg_write(vg) || !vg_commit(vg))
 		return_0;
 
-	/* If no snapshots left, reload without -real. */
-	if (origin && (!lv_is_origin(origin))) {
+	/* If no snapshots left, and was not merging, reload without -real. */
+	if (origin && (!lv_is_origin(origin) && !was_merging)) {
 		if (!suspend_lv(cmd, origin)) {
 			log_error("Failed to refresh %s without snapshot.", origin->name);
 			return 0;



From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 13 Jan 2010 01:51:46 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20100113015146.4273.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-13 01:51:45

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Reload origin if merging has stopped.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.198&r2=1.199

--- LVM2/lib/metadata/lv_manip.c	2010/01/13 01:35:49	1.198
+++ LVM2/lib/metadata/lv_manip.c	2010/01/13 01:51:45	1.199
@@ -2065,6 +2065,7 @@
 	struct volume_group *vg;
 	struct lvinfo info;
 	struct logical_volume *origin = NULL;
+	int was_merging = 0;
 
 	vg = lv->vg;
 
@@ -2126,6 +2127,7 @@
 
 	if (lv_is_cow(lv)) {
 		origin = origin_from_cow(lv);
+		was_merging = !!origin->merging_snapshot;
 		log_verbose("Removing snapshot %s", lv->name);
 		if (!vg_remove_snapshot(lv))
 			return_0;
@@ -2143,8 +2145,8 @@
 
 	backup(vg);
 
-	/* If no snapshots left, reload without -real. */
-	if (origin && !lv_is_origin(origin)) {
+	/* If no snapshots left or if we stopped merging, reload */
+	if (origin && (!lv_is_origin(origin) || was_merging)) {
 		if (!suspend_lv(cmd, origin))
 			log_error("Failed to refresh %s without snapshot.", origin->name);
 		else if (!resume_lv(cmd, origin))



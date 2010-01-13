From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 13 Jan 2010 01:47:18 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20100113014718.9030.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-13 01:47:18

Modified files:
	tools          : lvconvert.c 

Log message:
	Do not allow merging over mounted logical volumes.
	When preserving origin, check that the snapshot is not mounted.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.110&r2=1.111

--- LVM2/tools/lvconvert.c	2010/01/13 01:45:16	1.110
+++ LVM2/tools/lvconvert.c	2010/01/13 01:47:18	1.111
@@ -1058,6 +1058,7 @@
 	int r = 0;
 	struct logical_volume *origin = origin_from_cow(lv);
 	struct lv_segment *cow_seg = find_cow(lv);
+	struct lvinfo info;
 
 	/* Check if merge is possible */
 	if (cow_seg->status & SNAPSHOT_MERGE) {
@@ -1070,6 +1071,27 @@
 		return 0;
 	}
 
+	/*
+	 * Prevent merge with open device(s) as it would likely lead
+	 * to application/filesystem failure.
+	 *
+	 * FIXME testing open_count is racey; snapshot-merge target's
+	 * constructor and DM should prevent appropriate devices from
+	 * being open.
+	 */
+	if (lv_info(cmd, origin, &info, 1, 0)) {
+		if (info.open_count) {
+			log_error("Can't merge over open origin volume");
+			return 0;
+		}
+	}
+	if (lv_info(cmd, lv, &info, 1, 0)) {
+		if (info.open_count) {
+			log_error("Can't merge when snapshot is open");
+			return 0;
+		}
+	}
+
 	init_snapshot_merge(cow_seg, origin);
 
 	/* store vg on disk(s) */



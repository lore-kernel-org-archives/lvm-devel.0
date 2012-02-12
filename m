From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Feb 2012 21:37:03 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20120212213703.18027.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-02-12 21:37:03

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	missing error mesg

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.359&r2=1.360

--- LVM2/lib/metadata/lv_manip.c	2012/02/09 15:13:42	1.359
+++ LVM2/lib/metadata/lv_manip.c	2012/02/12 21:37:03	1.360
@@ -3316,8 +3316,11 @@
 		if (lv_is_merging_cow(lv) && !level) {
 			if (lv_info(lv->vg->cmd, lv, 0, &info, 1, 0) &&
 			    info.exists && info.live_table) {
-				if (!lv_snapshot_percent(lv, &snap_percent))
-					return_0;
+				if (!lv_snapshot_percent(lv, &snap_percent)) {
+					log_error("Failed to obtain merging snapshot progress percentage for logical volume %s.",
+						  lv->name);
+					return 0;
+				}
 				if ((snap_percent != PERCENT_INVALID) &&
 				     (snap_percent != PERCENT_MERGE_FAILED)) {
 					log_error("Can't remove merging snapshot logical volume \"%s\"",



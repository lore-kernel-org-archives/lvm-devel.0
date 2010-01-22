From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 22 Jan 2010 13:28:55 -0000
Subject: LVM2/lib/activate dev_manager.c
Message-ID: <20100122132855.12940.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-22 13:28:55

Modified files:
	lib/activate   : dev_manager.c 

Log message:
	Removed inactive_table check from _lv_has_target_type.  This check
	doesn't offer any benefit (that I can recall) and testing validates
	that.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.175&r2=1.176

--- LVM2/lib/activate/dev_manager.c	2010/01/15 22:58:25	1.175
+++ LVM2/lib/activate/dev_manager.c	2010/01/22 13:28:54	1.176
@@ -327,7 +327,6 @@
 	return 0;
 }
 
-/* FIXME Is there anything simpler to check for instead? */
 static int _lv_has_target_type(struct dev_manager *dm,
 			       struct logical_volume *lv,
 			       const char *layer,
@@ -363,8 +362,7 @@
 					  &type, &params);
 		if (type && strncmp(type, target_type,
 				    strlen(target_type)) == 0) {
-			/* FIXME Why the inactive test? */
-			if (info.live_table && !info.inactive_table)
+			if (info.live_table)
 				r = 1;
 			break;
 		}
@@ -1141,6 +1139,7 @@
 				      0, 1, 0, &dinfo, NULL) && dinfo.open_count) ||
 		    (dev_manager_info(dm->mem, NULL, find_merging_cow(lv)->cow,
 				      0, 1, 0, &dinfo, NULL) && dinfo.open_count)) {
+			/* FIXME Is there anything simpler to check for instead? */
 			if (!_lv_has_target_type(dm, lv, NULL, "snapshot-merge"))
 				clear_snapshot_merge(lv);
 		}



From: agk@sourceware.org <agk@sourceware.org>
Date: 17 Aug 2010 01:51:13 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c
Message-ID: <20100817015113.5363.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-08-17 01:51:12

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 

Log message:
	Fix dev_manager_transient to access -real device not snapshot-origin. (brassow)
	
	Another reminder why cloning functions impedes maintenance.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1706&r2=1.1707
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.198&r2=1.199

--- LVM2/WHATS_NEW	2010/08/17 01:16:41	1.1706
+++ LVM2/WHATS_NEW	2010/08/17 01:51:12	1.1707
@@ -1,5 +1,6 @@
 Version 2.02.73 - 
 ================================
+  Fix dev_manager_transient to access -real device not snapshot-origin.
   Monitor origin -real device below snapshot instead of overlay device.
   Don't really change monitoring status when in test mode.
   Fix some exit statuses when starting/stopping monitoring fails.
--- LVM2/lib/activate/dev_manager.c	2010/08/09 14:05:16	1.198
+++ LVM2/lib/activate/dev_manager.c	2010/08/17 01:51:12	1.199
@@ -548,6 +548,7 @@
 	return 0;
 }
 
+/* FIXME Merge with the percent function */
 int dev_manager_transient(struct dev_manager *dm, struct logical_volume *lv)
 {
 	int r = 0;
@@ -558,10 +559,11 @@
 	char *type = NULL;
 	char *params = NULL;
 	char *dlid = NULL;
+	char *suffix = lv_is_origin(lv) ? "real" : NULL;
 	const struct dm_list *segh = &lv->segments;
 	struct lv_segment *seg = NULL;
 
-	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, NULL)))
+	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, suffix)))
 		return_0;
 
 	if (!(dmt = _setup_task(0, dlid, NULL, DM_DEVICE_STATUS, 0, 0)))



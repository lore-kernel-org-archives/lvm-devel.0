From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 May 2010 12:45:23 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20100521124523.17360.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-05-21 12:45:19

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Replicator: extend _lv_each_dependency() with dependencies for Replicator devices

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1581&r2=1.1582
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.343&r2=1.344

--- LVM2/WHATS_NEW	2010/05/21 12:43:02	1.1581
+++ LVM2/WHATS_NEW	2010/05/21 12:45:18	1.1582
@@ -1,6 +1,7 @@
 Version 2.02.67 -
 ===============================
-  Add check_replicator_segment() for catching internal replicator errors.
+  Extend _lv_each_dependency() with Replicator dependencies.
+  Add check_replicator_segment() for catching internal Replicator errors.
   Initial lvm2 support for Replicator metadata handling.
   Checking open_count in all parents of presuspend_node.
   Added dm_tree_node_set_presuspend_node() to presuspend child in deactivate.
--- LVM2/lib/metadata/metadata.c	2010/05/19 11:52:37	1.343
+++ LVM2/lib/metadata/metadata.c	2010/05/21 12:45:19	1.344
@@ -2001,6 +2001,8 @@
 	struct lv_segment *lvseg;
 
 	struct logical_volume *deps[] = {
+		(lv->rdevice && lv != lv->rdevice->lv) ? lv->rdevice->lv : 0,
+		(lv->rdevice && lv != lv->rdevice->slog) ? lv->rdevice->slog : 0,
 		lv->snapshot ? lv->snapshot->origin : 0,
 		lv->snapshot ? lv->snapshot->cow : 0 };
 	for (i = 0; i < sizeof(deps) / sizeof(*deps); ++i) {
@@ -2011,6 +2013,8 @@
 	dm_list_iterate_items(lvseg, &lv->segments) {
 		if (lvseg->log_lv && !fn(lvseg->log_lv, data))
 			return_0;
+		if (lvseg->rlog_lv && !fn(lvseg->rlog_lv, data))
+			return_0;
 		for (s = 0; s < lvseg->area_count; ++s) {
 			if (seg_type(lvseg, s) == AREA_LV && !fn(seg_lv(lvseg,s), data))
 				return_0;



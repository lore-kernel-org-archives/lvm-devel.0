From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Jul 2009 12:45:58 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-deptree.c
Message-ID: <20090703124558.27572.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-03 12:45:56

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-deptree.c 

Log message:
	Add device number to more log messages during activation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.282&r2=1.283
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52

--- LVM2/WHATS_NEW_DM	2009/07/01 09:31:46	1.282
+++ LVM2/WHATS_NEW_DM	2009/07/03 12:45:55	1.283
@@ -1,5 +1,6 @@
 Version 1.02.34 - 
 ================================
+  Add device number to more log messages during activation.
 
 Version 1.02.33 - 30th June 2009
 ================================
--- LVM2/libdm/libdm-deptree.c	2009/06/09 16:10:25	1.51
+++ LVM2/libdm/libdm-deptree.c	2009/07/03 12:45:56	1.52
@@ -1263,7 +1263,10 @@
 	return 1;
 }
 
-static int _emit_segment_line(struct dm_task *dmt, struct load_segment *seg, uint64_t *seg_start, char *params, size_t paramsize)
+static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
+			      uint32_t minor, struct load_segment *seg,
+			      uint64_t *seg_start, char *params,
+			      size_t paramsize)
 {
 	unsigned log_parm_count;
 	int pos = 0;
@@ -1362,7 +1365,8 @@
 		break;
 	}
 
-	log_debug("Adding target: %" PRIu64 " %" PRIu64 " %s %s",
+	log_debug("Adding target to (%" PRIu32 ":%" PRIu32 "): %" PRIu64
+		  " %" PRIu64 " %s %s", major, minor,
 		  *seg_start, seg->size, dm_segtypes[seg->type].target, params);
 
 	if (!dm_task_add_target(dmt, *seg_start, seg->size, dm_segtypes[seg->type].target, params))
@@ -1375,8 +1379,8 @@
 
 #undef EMIT_PARAMS
 
-static int _emit_segment(struct dm_task *dmt, struct load_segment *seg,
-			 uint64_t *seg_start)
+static int _emit_segment(struct dm_task *dmt, uint32_t major, uint32_t minor,
+			 struct load_segment *seg, uint64_t *seg_start)
 {
 	char *params;
 	size_t paramsize = 4096;
@@ -1389,7 +1393,8 @@
 		}
 
 		params[0] = '\0';
-		ret = _emit_segment_line(dmt, seg, seg_start, params, paramsize);
+		ret = _emit_segment_line(dmt, major, minor, seg, seg_start,
+					 params, paramsize);
 		dm_free(params);
 
 		if (!ret)
@@ -1415,7 +1420,8 @@
 	struct load_segment *seg;
 	uint64_t seg_start = 0;
 
-	log_verbose("Loading %s table", dnode->name);
+	log_verbose("Loading %s table (%" PRIu32 ":%" PRIu32 ")", dnode->name,
+		    dnode->info.major, dnode->info.minor);
 
 	if (!(dmt = dm_task_create(DM_DEVICE_RELOAD))) {
 		log_error("Reload dm_task creation failed for %s", dnode->name);
@@ -1437,7 +1443,8 @@
 		log_error("Failed to disable open_count");
 
 	dm_list_iterate_items(seg, &dnode->props.segs)
-		if (!_emit_segment(dmt, seg, &seg_start))
+		if (!_emit_segment(dmt, dnode->info.major, dnode->info.minor,
+				   seg, &seg_start))
 			goto_out;
 
 	if (!dm_task_suppress_identical_reload(dmt))



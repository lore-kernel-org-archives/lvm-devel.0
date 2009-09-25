From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Sep 2009 18:30:28 -0000
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM libdm/libdm-de ...
Message-ID: <20090925183028.8618.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-09-25 18:30:27

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM 
	libdm          : libdm-deptree.c 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1270&r2=1.1271
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.301&r2=1.302
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58

--- LVM2/WHATS_NEW	2009/09/17 10:37:23	1.1270
+++ LVM2/WHATS_NEW	2009/09/25 18:30:26	1.1271
@@ -1,6 +1,5 @@
-Version 2.02.53 - 
+Version 2.02.53 - 25th September 2009
 =====================================
-  Fix dmeventd _temporary_log_fn parameters. (2.02.50)
   Enable dmeventd monitoring section of config file by default.
   Update lvm2 monitoring script to lvm2_monitoring_init_red_hat.in.
   Fix lvm2app test to run under test/api subdirectory only when configured.
--- LVM2/WHATS_NEW_DM	2009/09/25 18:08:04	1.301
+++ LVM2/WHATS_NEW_DM	2009/09/25 18:30:26	1.302
@@ -1,6 +1,10 @@
-Version 1.02.38 - 
+Version 1.02.38 - 25th September 2009
 =====================================
-  Handle any path supplied to dm_task_set_name() by looking up in /dev/mapper.
+  Handle any path supplied to dm_task_set_name by looking up in /dev/mapper.
+  Add several examples to 12-dm-permissions.rules.
+  Add splitname and --yes to dmsetup man page.
+  Fix _mirror_emit_segment_line return code.
+  Fix dmeventd _temporary_log_fn parameters. (2.02.50)
 
 Version 1.02.37 - 15th September 2009
 =====================================
--- LVM2/libdm/libdm-deptree.c	2009/09/22 16:26:59	1.57
+++ LVM2/libdm/libdm-deptree.c	2009/09/25 18:30:27	1.58
@@ -1285,14 +1285,12 @@
 }
 
 /*
- * mirror_emit_segment_line
- *
  * Returns: 1 on success, 0 on failure
  */
-static int mirror_emit_segment_line(struct dm_task *dmt, uint32_t major,
-				    uint32_t minor, struct load_segment *seg,
-				    uint64_t *seg_start, char *params,
-				    size_t paramsize)
+static int _mirror_emit_segment_line(struct dm_task *dmt, uint32_t major,
+				     uint32_t minor, struct load_segment *seg,
+				     uint64_t *seg_start, char *params,
+				     size_t paramsize)
 {
 	int r;
 	int block_on_error = 0;
@@ -1421,8 +1419,8 @@
 		break;
 	case SEG_MIRRORED:
 		/* Mirrors are pretty complicated - now in separate function */
-		r = mirror_emit_segment_line(dmt, major, minor, seg, seg_start,
-					     params, paramsize);
+		r = _mirror_emit_segment_line(dmt, major, minor, seg, seg_start,
+					      params, paramsize);
 		if (!r)
 			return_0;
 		break;



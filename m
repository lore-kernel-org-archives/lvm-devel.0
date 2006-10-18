From: agk@sourceware.org <agk@sourceware.org>
Date: 18 Oct 2006 18:01:54 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c li ...
Message-ID: <20061018180154.14726.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-10-18 18:01:53

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 
	lib/error      : errseg.c 
	lib/metadata   : mirror.c segtype.h 
	lib/mirror     : mirrored.c 
	lib/snapshot   : snapshot.c 
	lib/striped    : striped.c 
	lib/zero       : zero.c 
	tools          : lvconvert.c lvcreate.c 

Log message:
	Add segment parameter to target_present functions.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.473&r2=1.474
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.114&r2=1.115
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/error/errseg.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/segtype.h.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/striped/striped.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/zero/zero.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.127&r2=1.128

--- LVM2/WHATS_NEW	2006/10/16 17:17:54	1.473
+++ LVM2/WHATS_NEW	2006/10/18 18:01:51	1.474
@@ -1,5 +1,6 @@
 Version 2.02.13 -
 ===================================
+  Add segment parameter to target_present functions.
 
 Version 2.02.12 - 16th October 2006
 ===================================
--- LVM2/lib/activate/dev_manager.c	2006/08/21 12:04:55	1.114
+++ LVM2/lib/activate/dev_manager.c	2006/10/18 18:01:51	1.115
@@ -785,7 +785,7 @@
 
 	/* Ensure required device-mapper targets are loaded */
 	if (seg->segtype->ops->target_present &&
-	    !seg->segtype->ops->target_present()) {
+	    !seg->segtype->ops->target_present(seg)) {
 		log_error("Can't expand LV %s: %s target support missing "
 			  "from kernel?", seg->lv->name, seg->segtype->name);
 		return 0;
--- LVM2/lib/error/errseg.c	2006/10/03 17:55:19	1.11
+++ LVM2/lib/error/errseg.c	2006/10/18 18:01:51	1.12
@@ -50,7 +50,7 @@
 	return dm_tree_node_add_error_target(node, len);
 }
 
-static int _errseg_target_present(void)
+static int _errseg_target_present(const struct lv_segment *seg __attribute((unused)))
 {
 	static int _errseg_checked = 0;
 	static int _errseg_present = 0;
--- LVM2/lib/metadata/mirror.c	2006/09/19 19:13:41	1.33
+++ LVM2/lib/metadata/mirror.c	2006/10/18 18:01:52	1.34
@@ -562,7 +562,7 @@
 	}
 
         if (activation() && segtype->ops->target_present &&
-            !segtype->ops->target_present()) {
+            !segtype->ops->target_present(NULL)) {
                 log_error("%s: Required device-mapper target(s) not "
                           "detected in your kernel", segtype->name);
                 return 0;
--- LVM2/lib/metadata/segtype.h	2006/10/03 17:55:19	1.13
+++ LVM2/lib/metadata/segtype.h	2006/10/18 18:01:52	1.14
@@ -76,7 +76,7 @@
 			       struct lv_segment *seg, char *params,
 			       uint64_t *total_numerator,
 			       uint64_t *total_denominator, float *percent);
-	int (*target_present) (void);
+	int (*target_present) (const struct lv_segment *seg);
 	int (*modules_needed) (struct dm_pool *mem,
 			       const struct lv_segment *seg,
 			       struct list *modules);
--- LVM2/lib/mirror/mirrored.c	2006/10/03 17:55:19	1.36
+++ LVM2/lib/mirror/mirrored.c	2006/10/18 18:01:52	1.37
@@ -336,7 +336,7 @@
 	return add_areas_line(dm, seg, node, start_area, area_count);
 }
 
-static int _mirrored_target_present(void)
+static int _mirrored_target_present(const struct lv_segment *seg __attribute((unused)))
 {
 	static int _mirrored_checked = 0;
 	static int _mirrored_present = 0;
--- LVM2/lib/snapshot/snapshot.c	2006/10/03 17:55:20	1.18
+++ LVM2/lib/snapshot/snapshot.c	2006/10/18 18:01:52	1.19
@@ -112,7 +112,7 @@
 	return 1;
 }
 
-static int _snap_target_present(void)
+static int _snap_target_present(const struct lv_segment *seg __attribute((unused)))
 {
 	static int _snap_checked = 0;
 	static int _snap_present = 0;
--- LVM2/lib/striped/striped.c	2006/10/03 18:02:06	1.19
+++ LVM2/lib/striped/striped.c	2006/10/18 18:01:52	1.20
@@ -174,7 +174,7 @@
 	return add_areas_line(dm, seg, node, 0u, seg->area_count);
 }
 
-static int _striped_target_present(void)
+static int _striped_target_present(const struct lv_segment *seg __attribute((unused)))
 {
 	static int _striped_checked = 0;
 	static int _striped_present = 0;
--- LVM2/lib/zero/zero.c	2006/10/03 17:55:20	1.10
+++ LVM2/lib/zero/zero.c	2006/10/18 18:01:52	1.11
@@ -49,7 +49,7 @@
 	return dm_tree_node_add_zero_target(node, len);
 }
 
-static int _zero_target_present(void)
+static int _zero_target_present(const struct lv_segment *seg __attribute((unused)))
 {
 	static int _zero_checked = 0;
 	static int _zero_present = 0;
--- LVM2/tools/lvconvert.c	2006/09/19 19:13:41	1.21
+++ LVM2/tools/lvconvert.c	2006/10/18 18:01:53	1.22
@@ -212,7 +212,7 @@
 	}
 
 	if (activation() && lp->segtype->ops->target_present &&
-	    !lp->segtype->ops->target_present()) {
+	    !lp->segtype->ops->target_present(NULL)) {
 		log_error("%s: Required device-mapper target(s) not "
 			  "detected in your kernel", lp->segtype->name);
 		return 0;
--- LVM2/tools/lvcreate.c	2006/10/16 16:47:56	1.127
+++ LVM2/tools/lvcreate.c	2006/10/18 18:01:53	1.128
@@ -386,7 +386,7 @@
 	}
 
 	if (activation() && lp->segtype->ops->target_present &&
-	    !lp->segtype->ops->target_present()) {
+	    !lp->segtype->ops->target_present(NULL)) {
 		log_error("%s: Required device-mapper target(s) not "
 			  "detected in your kernel", lp->segtype->name);
 		return 0;



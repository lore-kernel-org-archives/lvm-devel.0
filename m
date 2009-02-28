From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Feb 2009 20:04:27 -0000
Subject: LVM2 lib/activate/dev_manager.c lib/error/errs ...
Message-ID: <20090228200427.2480.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-02-28 20:04:26

Modified files:
	lib/activate   : dev_manager.c 
	lib/error      : errseg.c 
	lib/metadata   : mirror.c segtype.h 
	lib/mirror     : mirrored.c 
	lib/snapshot   : snapshot.c 
	lib/striped    : striped.c 
	lib/zero       : zero.c 
	tools          : lvconvert.c lvcreate.c pvmove.c 

Log message:
	Fix last check-ins: seg can be NULL.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.145&r2=1.146
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/error/errseg.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.80&r2=1.81
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/segtype.h.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/striped/striped.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/zero/zero.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.67&r2=1.68
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.178&r2=1.179
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55

--- LVM2/lib/activate/dev_manager.c	2009/02/12 20:42:07	1.145
+++ LVM2/lib/activate/dev_manager.c	2009/02/28 20:04:24	1.146
@@ -908,7 +908,8 @@
 		  layer ? "-" : "", layer ? : "");
 
 	if (seg_present->segtype->ops->target_present &&
-	    !seg_present->segtype->ops->target_present(seg_present, NULL)) {
+	    !seg_present->segtype->ops->target_present(seg_present->lv->vg->cmd,
+						       seg_present, NULL)) {
 		log_error("Can't expand LV %s: %s target support missing "
 			  "from kernel?", seg->lv->name, seg_present->segtype->name);
 		return 0;
--- LVM2/lib/error/errseg.c	2009/02/28 00:54:06	1.19
+++ LVM2/lib/error/errseg.c	2009/02/28 20:04:24	1.20
@@ -51,7 +51,8 @@
 	return dm_tree_node_add_error_target(node, len);
 }
 
-static int _errseg_target_present(const struct lv_segment *seg,
+static int _errseg_target_present(struct cmd_context *cmd,
+				  const struct lv_segment *seg __attribute((unused)),
 				  unsigned *attributes __attribute((unused)))
 {
 	static int _errseg_checked = 0;
@@ -59,8 +60,8 @@
 
 	/* Reported truncated in older kernels */
 	if (!_errseg_checked &&
-	    (target_present(seg->lv->vg->cmd, "error", 0) ||
-	     target_present(seg->lv->vg->cmd, "erro", 0)))
+	    (target_present(cmd, "error", 0) ||
+	     target_present(cmd, "erro", 0)))
 		_errseg_present = 1;
 
 	_errseg_checked = 1;
--- LVM2/lib/metadata/mirror.c	2008/12/19 15:24:53	1.80
+++ LVM2/lib/metadata/mirror.c	2009/02/28 20:04:24	1.81
@@ -1380,7 +1380,7 @@
 		return_0;
 
 	if (activation() && segtype->ops->target_present &&
-	    !segtype->ops->target_present(NULL, NULL)) {
+	    !segtype->ops->target_present(cmd, NULL, NULL)) {
 		log_error("%s: Required device-mapper target(s) not "
 			  "detected in your kernel", segtype->name);
 		return 0;
--- LVM2/lib/metadata/segtype.h	2008/11/03 22:14:29	1.22
+++ LVM2/lib/metadata/segtype.h	2009/02/28 20:04:25	1.23
@@ -78,7 +78,8 @@
 			       struct lv_segment *seg, char *params,
 			       uint64_t *total_numerator,
 			       uint64_t *total_denominator);
-	int (*target_present) (const struct lv_segment *seg,
+	int (*target_present) (struct cmd_context *cmd,
+			       const struct lv_segment *seg,
 			       unsigned *attributes);
 	int (*modules_needed) (struct dm_pool *mem,
 			       const struct lv_segment *seg,
--- LVM2/lib/mirror/mirrored.c	2009/02/28 00:54:06	1.60
+++ LVM2/lib/mirror/mirrored.c	2009/02/28 20:04:25	1.61
@@ -343,7 +343,8 @@
 	return add_areas_line(dm, seg, node, start_area, area_count);
 }
 
-static int _mirrored_target_present(const struct lv_segment *seg,
+static int _mirrored_target_present(struct cmd_context *cmd,
+				    const struct lv_segment *seg,
 				    unsigned *attributes)
 {
 	static int _mirrored_checked = 0;
@@ -353,7 +354,7 @@
 	char vsn[80];
 
 	if (!_mirrored_checked) {
-		_mirrored_present = target_present(seg->lv->vg->cmd, "mirror", 1);
+		_mirrored_present = target_present(cmd, "mirror", 1);
 
 		/*
 		 * block_on_error available with mirror target >= 1.1 and <= 1.11
@@ -375,8 +376,7 @@
 	 * FIXME: Fails incorrectly if cmirror was built into kernel.
 	 */
 	if (attributes) {
-		if (!_mirror_attributes && module_present(seg->lv->vg->cmd,
-		    "log-clustered"))
+		if (!_mirror_attributes && module_present(cmd, "log-clustered"))
 			_mirror_attributes |= MIRROR_LOG_CLUSTERED;
 		*attributes = _mirror_attributes;
 	}
--- LVM2/lib/snapshot/snapshot.c	2009/02/28 00:54:07	1.34
+++ LVM2/lib/snapshot/snapshot.c	2009/02/28 20:04:25	1.35
@@ -108,15 +108,16 @@
 	return 1;
 }
 
-static int _snap_target_present(const struct lv_segment *seg,
+static int _snap_target_present(struct cmd_context *cmd,
+				const struct lv_segment *seg __attribute((unused)),
 				unsigned *attributes __attribute((unused)))
 {
 	static int _snap_checked = 0;
 	static int _snap_present = 0;
 
 	if (!_snap_checked)
-		_snap_present = target_present(seg->lv->vg->cmd, "snapshot", 1) &&
-		    target_present(seg->lv->vg->cmd, "snapshot-origin", 0);
+		_snap_present = target_present(cmd, "snapshot", 1) &&
+		    target_present(cmd, "snapshot-origin", 0);
 
 	_snap_checked = 1;
 
--- LVM2/lib/striped/striped.c	2009/02/28 00:54:07	1.26
+++ LVM2/lib/striped/striped.c	2009/02/28 20:04:25	1.27
@@ -175,15 +175,16 @@
 	return add_areas_line(dm, seg, node, 0u, seg->area_count);
 }
 
-static int _striped_target_present(const struct lv_segment *seg,
+static int _striped_target_present(struct cmd_context *cmd,
+				   const struct lv_segment *seg __attribute((unused)),
 				   unsigned *attributes __attribute((unused)))
 {
 	static int _striped_checked = 0;
 	static int _striped_present = 0;
 
 	if (!_striped_checked)
-		_striped_present = target_present(seg->lv->vg->cmd, "linear", 0) &&
-			  target_present(seg->lv->vg->cmd, "striped", 0);
+		_striped_present = target_present(cmd, "linear", 0) &&
+			  target_present(cmd, "striped", 0);
 
 	_striped_checked = 1;
 
--- LVM2/lib/zero/zero.c	2009/02/28 00:54:07	1.19
+++ LVM2/lib/zero/zero.c	2009/02/28 20:04:25	1.20
@@ -50,14 +50,15 @@
 	return dm_tree_node_add_zero_target(node, len);
 }
 
-static int _zero_target_present(const struct lv_segment *seg,
+static int _zero_target_present(struct cmd_context *cmd,
+				const struct lv_segment *seg __attribute((unused)),
 				unsigned *attributes __attribute((unused)))
 {
 	static int _zero_checked = 0;
 	static int _zero_present = 0;
 
 	if (!_zero_checked)
-		_zero_present = target_present(seg->lv->vg->cmd, "zero", 0);
+		_zero_present = target_present(cmd, "zero", 0);
 
 	_zero_checked = 1;
 
--- LVM2/tools/lvconvert.c	2008/11/03 22:14:30	1.67
+++ LVM2/tools/lvconvert.c	2009/02/28 20:04:25	1.68
@@ -219,7 +219,7 @@
 	}
 
 	if (activation() && lp->segtype->ops->target_present &&
-	    !lp->segtype->ops->target_present(NULL, NULL)) {
+	    !lp->segtype->ops->target_present(cmd, NULL, NULL)) {
 		log_error("%s: Required device-mapper target(s) not "
 			  "detected in your kernel", lp->segtype->name);
 		return 0;
--- LVM2/tools/lvcreate.c	2008/11/03 22:14:30	1.178
+++ LVM2/tools/lvcreate.c	2009/02/28 20:04:25	1.179
@@ -420,7 +420,7 @@
 	}
 
 	if (activation() && lp->segtype->ops->target_present &&
-	    !lp->segtype->ops->target_present(NULL, NULL)) {
+	    !lp->segtype->ops->target_present(cmd, NULL, NULL)) {
 		log_error("%s: Required device-mapper target(s) not "
 			  "detected in your kernel", lp->segtype->name);
 		return 0;
--- LVM2/tools/pvmove.c	2008/11/03 22:14:30	1.54
+++ LVM2/tools/pvmove.c	2009/02/28 20:04:25	1.55
@@ -33,7 +33,7 @@
 		return_0;
 
 	if (activation() && segtype->ops->target_present &&
-	    !segtype->ops->target_present(NULL, clustered ? &attr : NULL))
+	    !segtype->ops->target_present(cmd, NULL, clustered ? &attr : NULL))
 		found = 0;
 
 	if (activation() && clustered) {



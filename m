From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 7 Apr 2008 10:23:49 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/a ...
Message-ID: <20080407102349.18643.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-04-07 10:23:47

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c activate.h dev_manager.c 
	lib/error      : errseg.c 
	lib/metadata   : mirror.c segtype.h 
	lib/mirror     : mirrored.c 
	lib/snapshot   : snapshot.c 
	lib/striped    : striped.c 
	lib/zero       : zero.c 
	tools          : lvconvert.c lvcreate.c pvmove.c 

Log message:
	Add detection of clustered mirror log capability.
	Currently only check for kernel module presence.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.825&r2=1.826
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.133&r2=1.134
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.59&r2=1.60
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.134&r2=1.135
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/error/errseg.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.70&r2=1.71
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/segtype.h.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/striped/striped.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/zero/zero.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.172&r2=1.173
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50

--- LVM2/WHATS_NEW	2008/04/04 15:41:20	1.825
+++ LVM2/WHATS_NEW	2008/04/07 10:23:46	1.826
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Add detection of clustered mirror log capability.
   Add check to vg_commit() ensuring VG lock held before writing new VG metadata.
   Add validation of LV name to pvmove -n.
   Make clvmd refresh the context correctly when lvm.conf is updated.
--- LVM2/lib/activate/activate.c	2008/01/31 12:19:35	1.133
+++ LVM2/lib/activate/activate.c	2008/04/07 10:23:46	1.134
@@ -391,12 +391,26 @@
 	return r;
 }
 
-int target_present(const char *target_name, int use_modprobe)
+int module_present(const char *target_name)
 {
-	uint32_t maj, min, patchlevel;
+	int ret = 0;
 #ifdef MODPROBE_CMD
 	char module[128];
+
+	if (dm_snprintf(module, sizeof(module), "dm-%s", target_name) < 0) {
+		log_error("module_present module name too long: %s",
+			  target_name);
+		return 0;
+	}
+
+	ret = exec_cmd(MODPROBE_CMD, module, "", "");
 #endif
+	return ret;
+}
+
+int target_present(const char *target_name, int use_modprobe)
+{
+	uint32_t maj, min, patchlevel;
 
 	if (!activation())
 		return 0;
@@ -406,14 +420,7 @@
 		if (target_version(target_name, &maj, &min, &patchlevel))
 			return 1;
 
-		if (dm_snprintf(module, sizeof(module), "dm-%s", target_name)
-		    < 0) {
-			log_error("target_present module name too long: %s",
-				  target_name);
-			return 0;
-		}
-
-		if (!exec_cmd(MODPROBE_CMD, module, "", ""))
+		if (!module_present(target_name))
 			return_0;
 	}
 #endif
--- LVM2/lib/activate/activate.h	2007/11/12 20:51:53	1.59
+++ LVM2/lib/activate/activate.h	2008/04/07 10:23:46	1.60
@@ -30,6 +30,9 @@
 	uint32_t read_ahead;
 };
 
+/* target attribute flags */
+#define MIRROR_LOG_CLUSTERED	0x00000001U
+
 void set_activation(int activation);
 int activation(void);
 
@@ -37,6 +40,7 @@
 int library_version(char *version, size_t size);
 int lvm1_present(struct cmd_context *cmd);
 
+int module_present(const char *target_name);
 int target_present(const char *target_name, int use_modprobe);
 int target_version(const char *target_name, uint32_t *maj,
                    uint32_t *min, uint32_t *patchlevel);
--- LVM2/lib/activate/dev_manager.c	2008/01/30 13:59:57	1.134
+++ LVM2/lib/activate/dev_manager.c	2008/04/07 10:23:46	1.135
@@ -823,7 +823,7 @@
 		  layer ? "-" : "", layer ? : "");
 
 	if (seg_present->segtype->ops->target_present &&
-	    !seg_present->segtype->ops->target_present(seg_present)) {
+	    !seg_present->segtype->ops->target_present(seg_present, NULL)) {
 		log_error("Can't expand LV %s: %s target support missing "
 			  "from kernel?", seg->lv->name, seg_present->segtype->name);
 		return 0;
--- LVM2/lib/error/errseg.c	2008/01/30 13:59:58	1.16
+++ LVM2/lib/error/errseg.c	2008/04/07 10:23:46	1.17
@@ -51,7 +51,8 @@
 	return dm_tree_node_add_error_target(node, len);
 }
 
-static int _errseg_target_present(const struct lv_segment *seg __attribute((unused)))
+static int _errseg_target_present(const struct lv_segment *seg __attribute((unused)),
+				  unsigned *attributes __attribute((unused)))
 {
 	static int _errseg_checked = 0;
 	static int _errseg_present = 0;
--- LVM2/lib/metadata/mirror.c	2008/02/22 13:28:29	1.70
+++ LVM2/lib/metadata/mirror.c	2008/04/07 10:23:46	1.71
@@ -1300,7 +1300,7 @@
 		return_0;
 
 	if (activation() && segtype->ops->target_present &&
-	    !segtype->ops->target_present(NULL)) {
+	    !segtype->ops->target_present(NULL, NULL)) {
 		log_error("%s: Required device-mapper target(s) not "
 			  "detected in your kernel", segtype->name);
 		return 0;
--- LVM2/lib/metadata/segtype.h	2007/08/20 20:55:26	1.18
+++ LVM2/lib/metadata/segtype.h	2008/04/07 10:23:46	1.19
@@ -78,7 +78,8 @@
 			       struct lv_segment *seg, char *params,
 			       uint64_t *total_numerator,
 			       uint64_t *total_denominator, float *percent);
-	int (*target_present) (const struct lv_segment *seg);
+	int (*target_present) (const struct lv_segment *seg,
+			       unsigned *attributes);
 	int (*modules_needed) (struct dm_pool *mem,
 			       const struct lv_segment *seg,
 			       struct list *modules);
--- LVM2/lib/mirror/mirrored.c	2008/01/31 12:19:35	1.52
+++ LVM2/lib/mirror/mirrored.c	2008/04/07 10:23:46	1.53
@@ -33,6 +33,7 @@
 #endif
 
 static int _block_on_error_available = 0;
+static unsigned _mirror_attributes = 0;
 
 enum {
 	MIRR_DISABLED,
@@ -343,7 +344,8 @@
 	return add_areas_line(dm, seg, node, start_area, area_count);
 }
 
-static int _mirrored_target_present(const struct lv_segment *seg __attribute((unused)))
+static int _mirrored_target_present(const struct lv_segment *seg __attribute((unused)),
+				    unsigned *attributes)
 {
 	static int _mirrored_checked = 0;
 	static int _mirrored_present = 0;
@@ -369,6 +371,15 @@
 			_block_on_error_available = 1;
 	}
 
+	/*
+	 * Check only for modules if atttributes requested and no previous check.
+	 * FIXME: need better check
+	 */
+	if (attributes) {
+		if (!_mirror_attributes && module_present("cmirror"))
+			_mirror_attributes |= MIRROR_LOG_CLUSTERED;
+		*attributes = _mirror_attributes;
+	}
 	_mirrored_checked = 1;
 
 	return _mirrored_present;
--- LVM2/lib/snapshot/snapshot.c	2008/01/31 12:19:36	1.29
+++ LVM2/lib/snapshot/snapshot.c	2008/04/07 10:23:47	1.30
@@ -114,7 +114,8 @@
 	return 1;
 }
 
-static int _snap_target_present(const struct lv_segment *seg __attribute((unused)))
+static int _snap_target_present(const struct lv_segment *seg __attribute((unused)),
+				unsigned *attributes __attribute((unused)))
 {
 	static int _snap_checked = 0;
 	static int _snap_present = 0;
--- LVM2/lib/striped/striped.c	2008/01/30 14:00:01	1.24
+++ LVM2/lib/striped/striped.c	2008/04/07 10:23:47	1.25
@@ -175,7 +175,8 @@
 	return add_areas_line(dm, seg, node, 0u, seg->area_count);
 }
 
-static int _striped_target_present(const struct lv_segment *seg __attribute((unused)))
+static int _striped_target_present(const struct lv_segment *seg __attribute((unused)),
+				   unsigned *attributes __attribute((unused)))
 {
 	static int _striped_checked = 0;
 	static int _striped_present = 0;
--- LVM2/lib/zero/zero.c	2008/01/30 14:00:01	1.16
+++ LVM2/lib/zero/zero.c	2008/04/07 10:23:47	1.17
@@ -50,7 +50,8 @@
 	return dm_tree_node_add_zero_target(node, len);
 }
 
-static int _zero_target_present(const struct lv_segment *seg __attribute((unused)))
+static int _zero_target_present(const struct lv_segment *seg __attribute((unused)),
+				unsigned *attributes __attribute((unused)))
 {
 	static int _zero_checked = 0;
 	static int _zero_present = 0;
--- LVM2/tools/lvconvert.c	2008/02/12 13:29:08	1.61
+++ LVM2/tools/lvconvert.c	2008/04/07 10:23:47	1.62
@@ -219,7 +219,7 @@
 	}
 
 	if (activation() && lp->segtype->ops->target_present &&
-	    !lp->segtype->ops->target_present(NULL)) {
+	    !lp->segtype->ops->target_present(NULL, NULL)) {
 		log_error("%s: Required device-mapper target(s) not "
 			  "detected in your kernel", lp->segtype->name);
 		return 0;
--- LVM2/tools/lvcreate.c	2008/01/30 14:00:01	1.172
+++ LVM2/tools/lvcreate.c	2008/04/07 10:23:47	1.173
@@ -420,7 +420,7 @@
 	}
 
 	if (activation() && lp->segtype->ops->target_present &&
-	    !lp->segtype->ops->target_present(NULL)) {
+	    !lp->segtype->ops->target_present(NULL, NULL)) {
 		log_error("%s: Required device-mapper target(s) not "
 			  "detected in your kernel", lp->segtype->name);
 		return 0;
--- LVM2/tools/pvmove.c	2008/04/04 11:59:31	1.49
+++ LVM2/tools/pvmove.c	2008/04/07 10:23:47	1.50
@@ -17,6 +17,30 @@
 #include "polldaemon.h"
 #include "display.h"
 
+static int pvmove_target_present(struct cmd_context *cmd, int clustered)
+{
+	const struct segment_type *segtype;
+	unsigned attr = 0;
+
+	if (!(segtype = get_segtype_from_string(cmd, "mirror")))
+		return_0;
+
+	if (activation() && segtype->ops->target_present &&
+	    !segtype->ops->target_present(NULL, clustered ? &attr : NULL)) {
+		log_error("%s: Required device-mapper target(s) not "
+			  "detected in your kernel", segtype->name);
+		return 0;
+	}
+
+	if (clustered && !(attr & MIRROR_LOG_CLUSTERED)) {
+		log_error("%s: Required device-mapper clustered log "
+			  "module not detected in your kernel", segtype->name);
+		return 0;
+	}
+
+	return 1;
+}
+
 /* Allow /dev/vgname/lvname, vgname/lvname or lvname */
 static const char *_extract_lvname(struct cmd_context *cmd, const char *vgname,
 				   const char *arg)
@@ -540,17 +564,9 @@
 	char *pv_name = NULL;
 	char *colon;
 	int ret;
-	const struct segment_type *segtype;
 
-	if (!(segtype = get_segtype_from_string(cmd, "mirror")))
-		return_0;
-
-	if (activation() && segtype->ops->target_present &&
-	    !segtype->ops->target_present(NULL)) {
-		log_error("%s: Required device-mapper target(s) not "
-			  "detected in your kernel", segtype->name);
+	if (!pvmove_target_present(cmd, 0))
 		return 0;
-	}
 
 	if (argc) {
 		pv_name = argv[0];



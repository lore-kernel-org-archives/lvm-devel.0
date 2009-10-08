From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 8 Oct 2009 16:19:47 -0500
Subject: [PATCH 9 of 10] LVM: corelog to log_count
Message-ID: <200910082119.n98LJlBM014800@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm-corelog-to-log_count.patch

s/corelog/log_count/  We must make the binary 'corelog' argument
more general.  This patch simply swaps 'corelog' for 'log_count'.

RFC: Jonathan Brassow <jbrassow@redhat.com>

Index: LVM2/lib/metadata/metadata-exported.h
===================================================================
--- LVM2.orig/lib/metadata/metadata-exported.h
+++ LVM2/lib/metadata/metadata-exported.h
@@ -523,7 +523,7 @@ struct lvcreate_params {
 	int zero; /* all */
 	int major; /* all */
 	int minor; /* all */
-	int corelog; /* mirror */
+	int log_count; /* mirror */
 	int nosync; /* mirror */
 
 	char *origin; /* snap */
Index: LVM2/tools/lvconvert.c
===================================================================
--- LVM2.orig/tools/lvconvert.c
+++ LVM2/tools/lvconvert.c
@@ -505,18 +505,18 @@ static int _using_corelog(struct logical
 static int _lv_update_log_type(struct cmd_context *cmd,
 			       struct lvconvert_params *lp,
 			       struct logical_volume *lv,
-			       int corelog)
+			       int log_count)
 {
 	struct logical_volume *original_lv = _original_lv(lv);
-	if (_using_corelog(lv) && !corelog) {
-		if (!add_mirror_log(cmd, original_lv, 1,
+	if (_using_corelog(lv) && log_count) {
+		if (!add_mirror_log(cmd, original_lv, log_count,
 				    adjusted_mirror_region_size(
 					lv->vg->extent_size,
 					lv->le_count,
 					lp->region_size),
 				    lp->pvh, lp->alloc))
 			return_0;
-	} else if (!_using_corelog(lv) && corelog) {
+	} else if (!_using_corelog(lv) && !log_count) {
 		if (!remove_mirror_log(cmd, original_lv,
 				       lp->pv_count ? lp->pvh : NULL))
 			return_0;
@@ -530,7 +530,7 @@ static int _lvconvert_mirrors(struct cmd
 	struct lv_segment *seg;
 	uint32_t existing_mirrors;
 	const char *mirrorlog;
-	unsigned corelog = 0;
+	unsigned log_count = 0;
 	int r = 0;
 	struct logical_volume *log_lv;
 	int failed_mirrors = 0, failed_log = 0;
@@ -590,8 +590,10 @@ static int _lvconvert_mirrors(struct cmd
 		if (!(lp->pvh = _failed_pv_list(lv->vg)))
 			return_0;
 		log_lv=first_seg(lv)->log_lv;
-		if (!log_lv || log_lv->status & PARTIAL_LV)
-			failed_log = corelog = 1;
+		if (!log_lv || log_lv->status & PARTIAL_LV) {
+			failed_log = 1;
+			log_count = 0;
+		}
 	} else {
 		/*
 		 * Did the user try to subtract more legs than available?
@@ -605,20 +607,27 @@ static int _lvconvert_mirrors(struct cmd
 		/*
 		 * Adjust log type
 		 */
+		/*
+		 * This param used to be 'corelog' and was initialized to '0'.
+		 * We initially set to '1' here so as not to screw the logic.
+		 */
+		log_count = 1;
 		if (arg_count(cmd, corelog_ARG))
-			corelog = 1;
+			log_count = 0;
 
 		mirrorlog = arg_str_value(cmd, mirrorlog_ARG,
-					  corelog ? "core" : DEFAULT_MIRRORLOG);
-		if (!strcmp("disk", mirrorlog)) {
-			if (corelog) {
-				log_error("--mirrorlog disk and --corelog "
-					  "are incompatible");
-				return 0;
-			}
-			corelog = 0;
-		} else if (!strcmp("core", mirrorlog))
-			corelog = 1;
+					  !log_count ? "core" : DEFAULT_MIRRORLOG);
+
+		if (strcmp("core", mirrorlog) && !log_count) {
+			log_error("--mirrorlog disk and --corelog "
+				  "are incompatible");
+			return 0;
+		}
+
+		if (!strcmp("disk", mirrorlog))
+			log_count = 1;
+		else if (!strcmp("core", mirrorlog))
+			log_count = 0;
 		else {
 			log_error("Unknown mirrorlog type: %s", mirrorlog);
 			return 0;
@@ -671,11 +680,11 @@ static int _lvconvert_mirrors(struct cmd
 		if (repair || lp->pv_count)
 			remove_pvs = lp->pvh;
 		if (!lv_remove_mirrors(cmd, lv, existing_mirrors - lp->mirrors,
-				       (corelog || lp->mirrors == 1) ? 1U : 0U,
+				       (!log_count || lp->mirrors == 1) ? 1U : 0U,
 				       remove_pvs, 0))
 			return_0;
 		if (lp->mirrors > 1 &&
-		    !_lv_update_log_type(cmd, lp, lv, corelog))
+		    !_lv_update_log_type(cmd, lp, lv, log_count))
 			return_0;
 	} else if (!(lv->status & MIRRORED)) {
 		/*
@@ -702,7 +711,7 @@ static int _lvconvert_mirrors(struct cmd
 						lv->vg->extent_size,
 						lv->le_count,
 						lp->region_size),
-				    corelog ? 0U : 1U, lp->pvh, lp->alloc,
+				    log_count, lp->pvh, lp->alloc,
 				    MIRROR_BY_LV))
 			return_0;
 		if (lp->wait_completion)
@@ -718,7 +727,7 @@ static int _lvconvert_mirrors(struct cmd
 		 * insertion to make the end result consistent with
 		 * linear-to-mirror conversion.
 		 */
-		if (!_lv_update_log_type(cmd, lp, lv, corelog))
+		if (!_lv_update_log_type(cmd, lp, lv, log_count))
 			return_0;
 		/* Insert a temporary layer for syncing,
 		 * only if the original lv is using disk log. */
@@ -740,8 +749,8 @@ static int _lvconvert_mirrors(struct cmd
 	}
 
 	if (lp->mirrors == existing_mirrors) {
-		if (_using_corelog(lv) != corelog) {
-			if (!_lv_update_log_type(cmd, lp, lv, corelog))
+		if (_using_corelog(lv) != !log_count) {
+			if (!_lv_update_log_type(cmd, lp, lv, log_count))
 				return_0;
 		} else {
 			log_error("Logical volume %s already has %"
@@ -778,8 +787,10 @@ static int _lvconvert_mirrors(struct cmd
 
 	if (failed_log || failed_mirrors) {
 		lp->pvh = old_pvh;
-		if (failed_log && replace_log)
-			failed_log = corelog = 0;
+		if (failed_log && replace_log) {
+			failed_log = 0;
+			log_count = 1;
+		}
 		if (replace_mirrors)
 			lp->mirrors += failed_mirrors;
 		failed_mirrors = 0;
Index: LVM2/tools/lvcreate.c
===================================================================
--- LVM2.orig/tools/lvcreate.c
+++ LVM2/tools/lvcreate.c
@@ -325,21 +325,27 @@ static int _read_mirror_params(struct lv
 	int region_size;
 	const char *mirrorlog;
 
+	/*
+	 * This param used to be 'corelog' and was initialized to '0'.
+	 * We initially set to '1' here so as not to screw the logic.
+	 */
+	lp->log_count = 1;
 	if (arg_count(cmd, corelog_ARG))
-		lp->corelog = 1;
+		lp->log_count = 0;
 
 	mirrorlog = arg_str_value(cmd, mirrorlog_ARG,
-				  lp->corelog ? "core" : DEFAULT_MIRRORLOG);
+				  !lp->log_count ? "core" : DEFAULT_MIRRORLOG);
 
-	if (!strcmp("disk", mirrorlog)) {
-		if (lp->corelog) {
-			log_error("--mirrorlog disk and --corelog "
-				  "are incompatible");
-			return 0;
-		}
-		lp->corelog = 0;
-	} else if (!strcmp("core", mirrorlog))
-		lp->corelog = 1;
+	if (strcmp("core", mirrorlog) && !lp->log_count) {
+		log_error("--mirrorlog disk and --corelog "
+			  "are incompatible");
+		return 0;
+	}
+
+	if (!strcmp("disk", mirrorlog))
+		lp->log_count = 1;
+	else if (!strcmp("core", mirrorlog))
+		lp->log_count = 0;
 	else {
 		log_error("Unknown mirrorlog type: %s", mirrorlog);
 		return 0;
Index: LVM2/lib/metadata/lv_manip.c
===================================================================
--- LVM2.orig/lib/metadata/lv_manip.c
+++ LVM2/lib/metadata/lv_manip.c
@@ -3097,7 +3097,7 @@ int lv_create_single(struct volume_group
 						vg->extent_size,
 						lv->le_count,
 						lp->region_size),
-				    lp->corelog ? 0U : 1U, lp->pvh, lp->alloc,
+				    lp->log_count, lp->pvh, lp->alloc,
 				    MIRROR_BY_LV |
 				    (lp->nosync ? MIRROR_SKIP_INIT_SYNC : 0))) {
 			stack;



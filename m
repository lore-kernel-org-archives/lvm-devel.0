From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 02:31:18 -0000
Subject: LVM2/tools lvcreate.c
Message-ID: <20090726023118.15809.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 02:31:18

Modified files:
	tools          : lvcreate.c 

Log message:
	Refactor extents calculations / updates in _lvcreate.
	
	Move extents calculation adjustments into their own local functions
	right after we read the vg.  This calculation really is not part of
	the LV create function but is rather an adjustment to the parameters
	based on what is given on the cmdline.  So we move it outside the main
	_lvcreate.
	
	Should be no functional change.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.200&r2=1.201

--- LVM2/tools/lvcreate.c	2009/07/26 02:30:57	1.200
+++ LVM2/tools/lvcreate.c	2009/07/26 02:31:18	1.201
@@ -18,6 +18,7 @@
 
 #include <fcntl.h>
 
+/* FIXME: refactor and reduce the size of this struct! */
 struct lvcreate_params {
 	/* flags */
 	int snapshot;
@@ -46,6 +47,7 @@
 	uint32_t voriginextents;
 	uint64_t voriginsize;
 	percent_t percent;
+	struct dm_list *pvh;
 
 	uint32_t permission;
 	uint32_t read_ahead;
@@ -56,6 +58,9 @@
 	const char *tag;
 };
 
+static uint64_t _extents_from_size(struct cmd_context *cmd, uint64_t size,
+				   uint32_t extent_size);
+
 static int _lvcreate_name_params(struct lvcreate_params *lp,
 				 struct cmd_context *cmd,
 				 int *pargc, char ***pargv)
@@ -151,6 +156,64 @@
 	return 1;
 }
 
+/*
+ * Update extents parameters based on other parameters which affect the size
+ * calcuation.
+ * NOTE: We must do this here because of the percent_t typedef and because we
+ * need the vg.
+ */
+static int _update_extents_params(struct volume_group *vg,
+			       struct lvcreate_params *lp)
+{
+	uint32_t pv_extent_count;
+
+	if (lp->size &&
+	    !(lp->extents = _extents_from_size(vg->cmd, lp->size,
+					       vg->extent_size)))
+		return_0;
+
+	if (lp->voriginsize &&
+	    !(lp->voriginextents = _extents_from_size(vg->cmd, lp->voriginsize,
+						      vg->extent_size)))
+		return_0;
+
+	/*
+	 * Create the pv list before we parse lp->percent - might be
+	 * PERCENT_PVSs
+	 */
+	if (lp->pv_count) {
+		if (!(lp->pvh = create_pv_list(vg->cmd->mem, vg,
+					   lp->pv_count, lp->pvs, 1)))
+			return_0;
+	} else
+		lp->pvh = &vg->pvs;
+
+	switch(lp->percent) {
+		case PERCENT_VG:
+			lp->extents = lp->extents * vg->extent_count / 100;
+			break;
+		case PERCENT_FREE:
+			lp->extents = lp->extents * vg->free_count / 100;
+			break;
+		case PERCENT_PVS:
+			if (!lp->pv_count) {
+				log_error("Please specify physical volume(s) "
+					  "with %%PVS");
+				return 0;
+			}
+			pv_extent_count = pv_list_extents_free(lp->pvh);
+			lp->extents = lp->extents * pv_extent_count / 100;
+			break;
+		case PERCENT_LV:
+			log_error("Please express size as %%VG, %%PVS, or "
+				  "%%FREE.");
+			return 0;
+		case PERCENT_NONE:
+			break;
+	}
+	return 1;
+}
+
 static int _read_size_params(struct lvcreate_params *lp,
 			     struct cmd_context *cmd)
 {
@@ -607,12 +670,10 @@
 	uint32_t size_rest;
 	uint32_t status = 0;
 	struct logical_volume *lv, *org = NULL;
-	struct dm_list *pvh;
 	int origin_active = 0;
 	char lv_name_buf[128];
 	const char *lv_name;
 	struct lvinfo info;
-	uint32_t pv_extent_count;
 
 	if (lp->lv_name && find_lv_in_vg(vg, lp->lv_name)) {
 		log_error("Logical volume \"%s\" already exists in "
@@ -656,49 +717,6 @@
 		return 0;
 	}
 
-	if (lp->size &&
-	    !(lp->extents = _extents_from_size(cmd, lp->size, vg->extent_size)))
-		return_0;
-
-	if (lp->voriginsize &&
-	    !(lp->voriginextents = _extents_from_size(cmd, lp->voriginsize,
-						      vg->extent_size)))
-		return_0;
-
-	/*
-	 * Create the pv list.
-	 */
-	if (lp->pv_count) {
-		if (!(pvh = create_pv_list(cmd->mem, vg,
-					   lp->pv_count, lp->pvs, 1)))
-			return_0;
-	} else
-		pvh = &vg->pvs;
-
-	switch(lp->percent) {
-		case PERCENT_VG:
-			lp->extents = lp->extents * vg->extent_count / 100;
-			break;
-		case PERCENT_FREE:
-			lp->extents = lp->extents * vg->free_count / 100;
-			break;
-		case PERCENT_PVS:
-			if (!lp->pv_count) {
-				log_error("Please specify physical volume(s) "
-					  "with %%PVS");
-				return 0;
-			}
-			pv_extent_count = pv_list_extents_free(pvh);
-			lp->extents = lp->extents * pv_extent_count / 100;
-			break;
-		case PERCENT_LV:
-			log_error("Please express size as %%VG, %%PVS, or "
-				  "%%FREE.");
-			return 0;
-		case PERCENT_NONE:
-			break;
-	}
-
 	if ((size_rest = lp->extents % lp->stripes)) {
 		log_print("Rounding size (%d extents) up to stripe boundary "
 			  "size (%d extents)", lp->extents,
@@ -782,10 +800,10 @@
 		return 0;
 	}
 
-	if (lp->stripes > dm_list_size(pvh) && lp->alloc != ALLOC_ANYWHERE) {
+	if (lp->stripes > dm_list_size(lp->pvh) && lp->alloc != ALLOC_ANYWHERE) {
 		log_error("Number of stripes (%u) must not exceed "
 			  "number of physical volumes (%d)", lp->stripes,
-			  dm_list_size(pvh));
+			  dm_list_size(lp->pvh));
 		return 0;
 	}
 
@@ -855,7 +873,7 @@
 	}
 
 	if (!lv_extend(lv, lp->segtype, lp->stripes, lp->stripe_size,
-		       1, lp->extents, NULL, 0u, 0u, pvh, lp->alloc))
+		       1, lp->extents, NULL, 0u, 0u, lp->pvh, lp->alloc))
 		return_0;
 
 	if (lp->mirrors > 1) {
@@ -864,7 +882,7 @@
 						vg->extent_size,
 						lv->le_count,
 						lp->region_size),
-				    lp->corelog ? 0U : 1U, pvh, lp->alloc,
+				    lp->corelog ? 0U : 1U, lp->pvh, lp->alloc,
 				    MIRROR_BY_LV |
 				    (lp->nosync ? MIRROR_SKIP_INIT_SYNC : 0))) {
 			stack;
@@ -1002,6 +1020,9 @@
 		return ECMD_FAILED;
 	}
 
+	if (!_update_extents_params(vg, &lp))
+		return ECMD_FAILED;
+
 	if (!_lvcreate(vg, &lp))
 		r = ECMD_FAILED;
 



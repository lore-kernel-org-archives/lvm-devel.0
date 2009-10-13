From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 13 Oct 2009 16:21:42 -0500
Subject: [PATCH 2 of 2] LVM: use new split capability
Message-ID: <200910132121.n9DLLgZR017156@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm-use-new-split-capability.patch

Percolate the ability split off a leg up to the user.

[FIXME:  This is just to illustrate things are working.
Getting consensus on CLI args will be the hard part.  It
should be easy to adjust this patch when that is done.]

RFC: Jonathan Brassow <jbrassow@redhat.com>

Index: LVM2/lib/metadata/mirror.c
===================================================================
--- LVM2.orig/lib/metadata/mirror.c
+++ LVM2/lib/metadata/mirror.c
@@ -1607,6 +1607,37 @@ int lv_add_mirrors(struct cmd_context *c
 	return 0;
 }
 
+int lv_split_mirror_images(struct logical_volume *lv, uint32_t split_count,
+			   struct dm_list *removable_pvs)
+{
+	int r;
+
+	/*
+	 * Right now, we only allow the user to split a single
+	 * leg off at a time.  In the future, we might allow a
+	 * 4-way mirror to be split into 2 2-way mirrors, but
+	 * not right now.
+	 */
+	if (split_count != 1) {
+		log_error("Unable to split more than one leg from a mirror.");
+		return_0;
+	}
+
+	/* Can't split a mirror that is not in-sync... unless force? */
+	if (!_mirrored_lv_in_sync(lv)) {
+		log_error("Unable to split mirror that is not in-sync.");
+		return_0;
+	}
+
+	r = _remove_mirror_images(lv, split_count,
+				  removable_pvs, 0, 0, 1, NULL);
+	if (!r)
+		return 0;
+
+	/* Rename split leg here? */
+	return 1;
+}
+
 /*
  * Generic interface for removing mirror and/or mirror log.
  * 'mirror' is the number of mirrors to be removed.
Index: LVM2/tools/args.h
===================================================================
--- LVM2.orig/tools/args.h
+++ LVM2/tools/args.h
@@ -49,6 +49,7 @@ arg(nosync_ARG, '\0', "nosync", NULL, 0)
 arg(resync_ARG, '\0', "resync", NULL, 0)
 arg(corelog_ARG, '\0', "corelog", NULL, 0)
 arg(mirrorlog_ARG, '\0', "mirrorlog", string_arg, 0)
+arg(mirrorsplit_ARG, '\0', "split", NULL, 0)
 arg(repair_ARG, '\0', "repair", NULL, 0)
 arg(use_policies_ARG, '\0', "use-policies", NULL, 0)
 arg(monitor_ARG, '\0', "monitor", yes_no_arg, 0)
Index: LVM2/tools/commands.h
===================================================================
--- LVM2.orig/tools/commands.h
+++ LVM2/tools/commands.h
@@ -122,8 +122,9 @@ xx(lvconvert,
    "\tOriginalLogicalVolume[Path] SnapshotLogicalVolume[Path]\n",
 
    alloc_ARG, background_ARG, chunksize_ARG, corelog_ARG, interval_ARG,
-   mirrorlog_ARG, mirrors_ARG, noudevsync_ARG, regionsize_ARG, repair_ARG,
-   snapshot_ARG, test_ARG, use_policies_ARG, yes_ARG, force_ARG, zero_ARG)
+   mirrorsplit_ARG, mirrorlog_ARG, mirrors_ARG, noudevsync_ARG,
+   regionsize_ARG, repair_ARG, snapshot_ARG, test_ARG, use_policies_ARG,
+   yes_ARG, force_ARG, zero_ARG)
 
 xx(lvcreate,
    "Create a logical volume",
Index: LVM2/tools/lvconvert.c
===================================================================
--- LVM2.orig/tools/lvconvert.c
+++ LVM2/tools/lvconvert.c
@@ -30,6 +30,8 @@ struct lvconvert_params {
 	uint32_t chunk_size;
 	uint32_t region_size;
 
+	int split;
+	int track_deltas;
 	uint32_t mirrors;
 	sign_t mirrors_sign;
 
@@ -125,6 +127,7 @@ static int _read_params(struct lvconvert
 		lp->snapshot = 1;
 
 	if (arg_count(cmd, mirrors_ARG)) {
+		lp->split = arg_count(cmd, mirrorsplit_ARG) ? 1 :0;
 		lp->mirrors = arg_uint_value(cmd, mirrors_ARG, 0);
 		lp->mirrors_sign = arg_sign_value(cmd, mirrors_ARG, 0);
 	}
@@ -681,10 +684,16 @@ static int _lvconvert_mirrors(struct cmd
 		/* Reduce number of mirrors */
 		if (repair || lp->pv_count)
 			remove_pvs = lp->pvh;
-		if (!lv_remove_mirrors(cmd, lv, existing_mirrors - lp->mirrors,
-				       (!log_count || lp->mirrors == 1) ? 1U : 0U,
-				       remove_pvs, 0))
+
+		if (lp->split) {
+			if (!lv_split_mirror_images(lv, existing_mirrors - lp->mirrors,
+						    remove_pvs))
+				return 0;
+		} else if (!lv_remove_mirrors(cmd, lv, existing_mirrors - lp->mirrors,
+					      (!log_count || lp->mirrors == 1) ? 1U : 0U,
+					      remove_pvs, 0))
 			return_0;
+
 		if (lp->mirrors > 1 &&
 		    !_lv_update_log_type(cmd, lp, lv, log_count))
 			return_0;
Index: LVM2/lib/metadata/metadata-exported.h
===================================================================
--- LVM2.orig/lib/metadata/metadata-exported.h
+++ LVM2/lib/metadata/metadata-exported.h
@@ -648,6 +648,8 @@ int lv_add_mirrors(struct cmd_context *c
 		   uint32_t mirrors, uint32_t stripes,
 		   uint32_t region_size, uint32_t log_count,
 		   struct dm_list *pvs, alloc_policy_t alloc, uint32_t flags);
+int lv_split_mirror_images(struct logical_volume *lv, uint32_t split_count,
+			   struct dm_list *removable_pvs);
 int lv_remove_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 		      uint32_t mirrors, uint32_t log_count,
 		      struct dm_list *pvs, uint32_t status_mask);



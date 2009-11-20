From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 20 Nov 2009 17:35:46 -0500
Subject: [PATCH 06/15] lvm-merge-lvconvert
In-Reply-To: <1258756555-14486-1-git-send-email-snitzer@redhat.com>
References: <1258756555-14486-1-git-send-email-snitzer@redhat.com>
Message-ID: <1258756555-14486-7-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Mikulas Patocka <mpatocka@redhat.com>

Add --merge support to lvconvert to start merging a snapshot into its
origin, example usage:  lvconvert --merge vg/snaplv

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 tools/args.h      |    1 +
 tools/commands.h  |   11 ++++-
 tools/lvconvert.c |  112 ++++++++++++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 115 insertions(+), 9 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 1f2427b..d2476ad 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -103,6 +103,7 @@ arg(list_ARG, 'l', "list", NULL, 0)
 arg(size_ARG, 'L', "size", size_mb_arg, 0)
 arg(logicalextent_ARG, 'L', "logicalextent", int_arg_with_sign, 0)
 arg(persistent_ARG, 'M', "persistent", yes_no_arg, 0)
+arg(merge_ARG, '\0', "merge", NULL, 0)
 arg(major_ARG, 'j', "major", major_arg, 0)
 arg(mirrors_ARG, 'm', "mirrors", int_arg_with_sign, 0)
 arg(metadatatype_ARG, 'M', "metadatatype", metadatatype_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 85222e4..93e9019 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -119,11 +119,16 @@ xx(lvconvert,
    "\t[-v|--verbose]\n"
    "\t[-Z|--zero {y|n}]\n"
    "\t[--version]" "\n"
-   "\tOriginalLogicalVolume[Path] SnapshotLogicalVolume[Path]\n",
+   "\tOriginalLogicalVolume[Path] SnapshotLogicalVolume[Path]\n\n"
+
+   "lvconvert "
+   "--merge\n"
+   "\tSnapshotLogicalVolume[Path]\n",
 
    alloc_ARG, background_ARG, chunksize_ARG, corelog_ARG, interval_ARG,
-   mirrorlog_ARG, mirrors_ARG, noudevsync_ARG, regionsize_ARG, repair_ARG,
-   snapshot_ARG, test_ARG, use_policies_ARG, yes_ARG, force_ARG, zero_ARG)
+   merge_ARG, mirrorlog_ARG, mirrors_ARG, noudevsync_ARG, regionsize_ARG,
+   repair_ARG, snapshot_ARG, test_ARG, use_policies_ARG, yes_ARG, force_ARG,
+   zero_ARG)
 
 xx(lvcreate,
    "Create a logical volume",
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index d1b86bf..517b4f3 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -18,6 +18,7 @@
 
 struct lvconvert_params {
 	int snapshot;
+	int merge;
 	int zero;
 
 	const char *origin;
@@ -49,7 +50,7 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 	char *ptr;
 	const char *vg_name = NULL;
 
-	if (lp->snapshot) {
+	if (lp->snapshot && !lp->merge) {
 		if (!*pargc) {
 			log_error("Please specify a logical volume to act as "
 				  "the snapshot origin.");
@@ -99,6 +100,11 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 	if (!apply_lvname_restrictions(lp->lv_name))
 		return_0;
 
+	if (*pargc && (lp->snapshot || lp->merge)) {
+		log_error("Extra arguments for snapshots");
+		return 0;
+	}
+
 	return 1;
 }
 
@@ -110,10 +116,10 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 
 	memset(lp, 0, sizeof(*lp));
 
-	if (arg_count(cmd, snapshot_ARG) &&
+	if ((arg_count(cmd, snapshot_ARG) || arg_count(cmd, merge_ARG)) &&
 	    (arg_count(cmd, mirrorlog_ARG) || arg_count(cmd, mirrors_ARG) ||
 	     arg_count(cmd, repair_ARG))) {
-		log_error("--snapshot argument cannot be mixed "
+		log_error("--snapshot or --merge argument cannot be mixed "
 			  "with --mirrors, --repair or --log");
 		return 0;
 	}
@@ -124,6 +130,9 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 	if (arg_count(cmd, snapshot_ARG))
 		lp->snapshot = 1;
 
+	if (arg_count(cmd, merge_ARG))
+		lp->merge = 1;
+
 	if (arg_count(cmd, mirrors_ARG)) {
 		lp->mirrors = arg_uint_value(cmd, mirrors_ARG, 0);
 		lp->mirrors_sign = arg_sign_value(cmd, mirrors_ARG, 0);
@@ -131,7 +140,17 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 
 	lp->alloc = arg_uint_value(cmd, alloc_ARG, ALLOC_INHERIT);
 
-	if (lp->snapshot) {
+	if (lp->merge) {
+		if (arg_count(cmd, regionsize_ARG) || arg_count(cmd, chunksize_ARG) ||
+		    arg_count(cmd, zero_ARG) || arg_count(cmd, regionsize_ARG)) {
+			log_error("invalid arguments for snapshot merge");
+			return 0;
+		}
+
+		if (!(lp->segtype = get_segtype_from_string(cmd, "snapshot")))
+			return_0;
+
+	} else if (lp->snapshot) {
 		if (arg_count(cmd, regionsize_ARG)) {
 			log_error("--regionsize is only available with mirrors");
 			return 0;
@@ -894,6 +913,73 @@ out:
 	return r;
 }
 
+static int lvconvert_merge(struct cmd_context *cmd,
+			   struct logical_volume *lv,
+			   struct lvconvert_params *lp)
+{
+	int r = 0;
+	struct logical_volume *origin = origin_from_cow(lv);
+	struct lv_segment *cow_seg = find_cow(lv);
+
+	/* Check if merge is possible */
+	if (cow_seg->status & SNAPSHOT_MERGE) {
+		log_error("Snapshot %s is already merging", lv->name);
+		return 0;
+	}
+	if (origin->merging_snapshot) {
+		log_error("Snapshot %s is already merging into the origin",
+			  origin->merging_snapshot->cow->name);
+		return 0;
+	}
+
+	/*
+	 * Even though lv_is_visible(cow_seg->lv) returns 0,
+	 * the cow_seg->lv (name: snapshotX) is _not_ hidden;
+	 * this is part of the lvm2 snapshot fiction.  Must
+	 * clear VISIBLE_LV directly (lv_set_visible can't)
+	 * - cow_seg->lv->status is used to control whether 'lv'
+	 *   (with user provided snapshot LV name) is visible
+	 * - this also enables vg_validate() to succeed with
+	 *   merge metadata (cow_seg->lv is now "internal")
+	 */
+	cow_seg->lv->status &= ~VISIBLE_LV;
+	cow_seg->status |= SNAPSHOT_MERGE;
+	origin->merging_snapshot = cow_seg;
+
+	/* store vg on disk(s) */
+	if (!vg_write(lv->vg))
+		return_0;
+
+	/* Perform merge */
+	if (!suspend_lv(cmd, origin)) {
+		log_error("Failed to suspend origin %s", origin->name);
+		vg_revert(lv->vg);
+		goto out;
+	}
+
+	if (!vg_commit(lv->vg)) {
+		if (!resume_lv(cmd, origin))
+			stack;
+		goto_out;
+	}
+
+	if (!resume_lv(cmd, origin)) {
+		log_error("Failed to reactivate origin %s", origin->name);
+		goto out;
+	}
+
+	if (!deactivate_lv(cmd, lv)) {
+		log_warn("WARNING: Unable to deactivate merging snapshot %s", lv->name);
+		/* merge is running regardless of this deactivation failure */
+	}
+
+	r = 1;
+	log_print("Merging of volume %s started.", lv->name);
+out:
+	backup(lv->vg);
+	return r;
+}
+
 static int lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 			    void *handle)
 {
@@ -904,7 +990,7 @@ static int lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return ECMD_FAILED;
 	}
 
-	if (lv_is_cow(lv)) {
+	if (lv_is_cow(lv) && !lp->merge) {
 		log_error("Can't convert snapshot logical volume \"%s\"",
 			  lv->name);
 		return ECMD_FAILED;
@@ -920,7 +1006,21 @@ static int lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return ECMD_FAILED;
 	}
 
-	if (lp->snapshot) {
+	if (lp->merge) {
+		if (!lv_is_cow(lv)) {
+			log_error("Logical volume \"%s\" is not a snapshot",
+				  lv->name);
+			return ECMD_FAILED;
+		}
+		if (!archive(lv->vg)) {
+			stack;
+			return ECMD_FAILED;
+		}
+		if (!lvconvert_merge(cmd, lv, lp)) {
+			stack;
+			return ECMD_FAILED;
+		}
+	} else if (lp->snapshot) {
 		if (lv->status & MIRRORED) {
 			log_error("Unable to convert mirrored LV \"%s\" into a snapshot.", lv->name);
 			return ECMD_FAILED;
-- 
1.6.5.2



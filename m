From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:32:42 +0000 (UTC)
Subject: master - lvcreate: refactor code
Message-ID: <20141006133242.CE449609E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=487723e0dfbaf23236e7ea1415497a8bb394440d
Commit:        487723e0dfbaf23236e7ea1415497a8bb394440d
Parent:        072e25a965afdd76145248edea18c3b9e36967df
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 28 22:31:30 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 14:52:16 2014 +0200

lvcreate: refactor code

Over the time lvcreate code has accumulated various hacks.
So try to move that code in right places.

Detect all types early in _lvcreate_params() so functions like
_read_size_params() do not need to change volume types.

Also ultimately respect give volume --type, that its shortcut
(-T, H, -m, -s) and after that options which do type estimation.
(i.e. --cachepool, --thinpool)

Avoid repeative tests - if we know all types are decode at once
place we can 'optimize' number of validations.
---
 WHATS_NEW        |    1 +
 tools/lvcreate.c |  163 ++++++++++++++++++++++++++++--------------------------
 2 files changed, 86 insertions(+), 78 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ad7bafb..1ac7750 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Refactor lvcreate code and better preserve --type argument.
   Refactor process_each_vg in toollib.
   Pools cannot be used as external origin.
   Use lv_update_and_reload() for snapshot reload.
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index bb3892d..fe405ea 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -460,6 +460,12 @@ static int _update_extents_params(struct volume_group *vg,
 	return 1;
 }
 
+/*
+ * Validate various common size arguments
+ *
+ * Note: at this place all volume types needs to be already
+ *       identified, do not change them here.
+ */
 static int _read_size_params(struct lvcreate_params *lp,
 			     struct lvcreate_cmdline_params *lcp,
 			     struct cmd_context *cmd)
@@ -474,6 +480,12 @@ static int _read_size_params(struct lvcreate_params *lp,
 		return 0;
 	}
 
+	/* poolmetadatasize_ARG is parsed in get_pool_params() */
+	if (!lp->create_pool && arg_count(cmd, poolmetadatasize_ARG)) {
+		log_error("--poolmetadatasize may only be specified when creating pools.");
+		return 0;
+	}
+
 	if (arg_count(cmd, extents_ARG)) {
 		if (arg_sign_value(cmd, extents_ARG, SIGN_NONE) == SIGN_MINUS) {
 			log_error("Negative number of extents is invalid");
@@ -493,38 +505,21 @@ static int _read_size_params(struct lvcreate_params *lp,
 		lcp->percent = PERCENT_NONE;
 	}
 
-	/* If size/extents given with thin, then we are creating a thin pool */
-	if (seg_is_thin(lp) && (arg_count(cmd, size_ARG) || arg_count(cmd, extents_ARG)))
-		lp->create_pool = 1;
-
-	if (!lp->create_pool && arg_count(cmd, poolmetadatasize_ARG)) {
-		log_error("--poolmetadatasize may only be specified when allocating the pool.");
-		return 0;
-	}
-
 	if (arg_count(cmd, virtualsize_ARG)) {
-		if (seg_is_thin_pool(lp)) {
-			log_error("Virtual size in incompatible with thin_pool segment type.");
+		if (!lp->thin && !lp->snapshot) {
+			log_error("--virtualsize may only be specified when creating thins or virtual snapshots.");
 			return 0;
 		}
 		if (arg_sign_value(cmd, virtualsize_ARG, SIGN_NONE) == SIGN_MINUS) {
-			log_error("Negative virtual origin size is invalid");
+			log_error("Negative virtual origin size is invalid.");
 			return 0;
 		}
 		/* Size returned in kilobyte units; held in sectors */
-		lp->voriginsize = arg_uint64_value(cmd, virtualsize_ARG,
-						   UINT64_C(0));
-		if (!lp->voriginsize) {
-			log_error("Virtual origin size may not be zero");
+		if (!(lp->voriginsize = arg_uint64_value(cmd, virtualsize_ARG,
+							 UINT64_C(0)))) {
+			log_error("Virtual origin size may not be zero.");
 			return 0;
 		}
-	} else {
-		/* No virtual size given and no snapshot, so no thin LV to create. */
-		if (seg_is_thin_volume(lp) && !lp->snapshot &&
-		    !(lp->segtype = get_segtype_from_string(cmd, "thin-pool")))
-			return_0;
-
-		lp->thin = 0;
 	}
 
 	return 1;
@@ -814,15 +809,6 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	dm_list_init(&lp->tags);
 	lp->target_attr = ~0;
 
-	/*
-	 * Check selected options are compatible and determine segtype
-	 */
-	if ((arg_count(cmd, thin_ARG) || arg_count(cmd, thinpool_ARG)) &&
-	    arg_count(cmd,mirrors_ARG)) {
-		log_error("--thin, --thinpool and --mirrors are incompatible.");
-		return 0;
-	}
-
 	/* Set default segtype - remember, '-m 0' implies stripe. */
 	if (arg_count(cmd, mirrors_ARG) &&
 	    arg_uint_value(cmd, mirrors_ARG, 0))
@@ -832,10 +818,17 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 		} else {
 			segtype_str = find_config_tree_str(cmd, global_mirror_segtype_default_CFG, NULL);
 		}
-	else if (arg_count(cmd, thin_ARG) || arg_count(cmd, thinpool_ARG))
+	else if (arg_count(cmd, snapshot_ARG))
+		segtype_str = "snapshot";
+	else if (arg_count(cmd, cache_ARG))
+		segtype_str = "cache";
+	else if (arg_count(cmd, thin_ARG))
 		segtype_str = "thin";
-	else if (arg_count(cmd, cache_ARG) || arg_count(cmd, cachepool_ARG))
+	/* estimations after valid shortcuts */
+	else if (arg_count(cmd, cachepool_ARG))
 		segtype_str = "cache";
+	else if (arg_count(cmd, thinpool_ARG))
+		segtype_str = "thin";
 	else
 		segtype_str = "striped";
 
@@ -849,32 +842,74 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 		return 0;
 	}
 
-	if ((arg_count(cmd, snapshot_ARG) || seg_is_snapshot(lp)) &&
-	     arg_count(cmd, thin_ARG)) {
-		log_error("--thin and --snapshot are incompatible.");
-		return 0;
-	}
+	if (seg_is_snapshot(lp) ||
+	    (!seg_is_thin(lp) && arg_count(cmd, virtualsize_ARG))) {
+		if (arg_from_list_is_set(cmd, "is unsupported with snapshots",
+					 cache_ARG, cachepool_ARG,
+					 mirrors_ARG,
+					 thin_ARG,
+					 zero_ARG,
+					 -1))
+			return_0;
+
+		if (seg_is_pool(lp)) {
+			log_error("Snapshots are incompatible with pool segment types.");
+			return 0;
+		}
+
+		if (arg_is_set(cmd, thinpool_ARG) &&
+		    (arg_is_set(cmd, extents_ARG) || arg_is_set(cmd, size_ARG))) {
+			log_error("Cannot specify snapshot size and thin pool.");
+			return 0;
+		}
 
-	if (arg_count(cmd, snapshot_ARG) || seg_is_snapshot(lp) ||
-	    (!seg_is_thin(lp) && arg_count(cmd, virtualsize_ARG)))
 		lp->snapshot = 1;
+	}
 
-	if (seg_is_pool(lp)) {
-		if (lp->snapshot) {
-			log_error("Snapshots are incompatible with pool segment_type.");
+	if (seg_is_thin_volume(lp)) {
+		if (arg_is_set(cmd, virtualsize_ARG))
+			lp->thin = 1;
+		else if (arg_is_set(cmd, name_ARG)) {
+			log_error("Missing --virtualsize when specified --name of thin volume.");
 			return 0;
+		/* When no virtual size -> create thin-pool only */
+		} else if (!(lp->segtype = get_segtype_from_string(cmd, "thin-pool")))
+			return_0;
+
+		/* If size/extents given with thin, then we are creating a thin pool */
+		if (arg_count(cmd, size_ARG) || arg_count(cmd, extents_ARG)) {
+			if (lp->snapshot &&
+			    (arg_is_set(cmd, cachepool_ARG) || arg_is_set(cmd, thinpool_ARG))) {
+				log_error("Size or extents cannot be specified with pool name.");
+				return 0;
+			}
+			lp->create_pool = 1;
 		}
+	} else if (seg_is_pool(lp)) {
+		if (arg_from_list_is_set(cmd, "is unsupported with pool segment type",
+					 cache_ARG, mirrors_ARG, snapshot_ARG, thin_ARG,
+					 virtualsize_ARG,
+					 -1))
+			return_0;
 		lp->create_pool = 1;
 	}
 
-	if (seg_is_thin_volume(lp))
-		lp->thin = 1;
-
-	lp->mirrors = 1;
+	if (seg_is_mirrored(lp) || seg_is_raid(lp)) {
+		/* Note: snapshots have snapshot_ARG or virtualsize_ARG */
+		if (arg_from_list_is_set(cmd, "is unsupported with mirrored segment type",
+					 cache_ARG, cachepool_ARG,
+					 snapshot_ARG,
+					 thin_ARG, thinpool_ARG,
+					 virtualsize_ARG,
+					 -1))
+			return_0;
+	} else if (arg_from_list_is_set(cmd, "is unsupported without mirrored segment type",
+					corelog_ARG, mirrorlog_ARG, nosync_ARG,
+					-1))
+		return_0;
 
 	/* Default to 2 mirrored areas if '--type mirror|raid1|raid10' */
-	if (segtype_is_mirrored(lp->segtype))
-		lp->mirrors = 2;
+	lp->mirrors = segtype_is_mirrored(lp->segtype) ? 2 : 1;
 
 	if (arg_count(cmd, mirrors_ARG)) {
 		if (arg_sign_value(cmd, mirrors_ARG, SIGN_NONE) == SIGN_MINUS) {
@@ -910,34 +945,6 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 		}
 	}
 
-	if (lp->snapshot && arg_count(cmd, zero_ARG)) {
-		log_error("-Z is incompatible with snapshots");
-		return 0;
-	}
-
-	if (segtype_is_mirrored(lp->segtype) || segtype_is_raid(lp->segtype)) {
-		if (lp->snapshot) {
-			log_error("mirrors and snapshots are currently "
-				  "incompatible");
-			return 0;
-		}
-	} else {
-		if (arg_count(cmd, corelog_ARG)) {
-			log_error("--corelog is only available with mirrors");
-			return 0;
-		}
-
-		if (arg_count(cmd, mirrorlog_ARG)) {
-			log_error("--mirrorlog is only available with mirrors");
-			return 0;
-		}
-
-		if (arg_count(cmd, nosync_ARG)) {
-			log_error("--nosync is only available with mirrors");
-			return 0;
-		}
-	}
-
 	if (activation() && lp->segtype->ops->target_present) {
 		if (!lp->segtype->ops->target_present(cmd, NULL, &lp->target_attr)) {
 			log_error("%s: Required device-mapper target(s) not detected in your kernel.",



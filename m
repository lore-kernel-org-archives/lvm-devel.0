From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Jul 2014 11:34:41 +0000 (UTC)
Subject: master - lvconvert: update for thin a cache
Message-ID: <20140711113441.5AF4F6056E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=970989655ff5cd9ca960bf3113b7bfdf6f575d78
Commit:        970989655ff5cd9ca960bf3113b7bfdf6f575d78
Parent:        fe3ea94e5846f48baf3b00d0f6b913f585b4404e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 11 12:15:23 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 11 13:32:22 2014 +0200

lvconvert: update for thin a cache

Major update of lvconvert code to handle cache and thin.
related targets.

Code tries to unify handling of cache and thin pools.
Better supports lvm2 syntax:

lvconvert --type cache --cachepool vg/pool vg/cache
lvconvert --type thin --thinpool vg/pool vg/extorg
lvconvert --type cache-pool vg/pool
lvconvert --type thin-pool vg/pool

as well as:

lvconvert --cache --cachepool vg/pool vg/cache
lvconvert --thin --thinpool vg/pool vg/extorg
lvconvert --cachepool vg/pool
lvconvert --thinpool vg/pool

While catching much more command line errors.
(Yet couple paths still needs more tests)

Detects as much cmdline errors prior opening VG.

Uses single lvconvert_name_params to convert LV names.

Detects as much incompatibilies in VG prior prompting.

Uses single prompt to confirm whole conversion.

TODO: still the code needs fixes...
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |  992 ++++++++++++++++++++++++++++-------------------------
 tools/toollib.c   |   22 +-
 3 files changed, 539 insertions(+), 476 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6cbf221..a81fddb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.108 -
 =================================
+  Enhance lvconvert thin, thinpool, cache and cachepool command line support.
   Display 'C' only for cache and cache-pool target types in lvs.
   Prompt for confirmation before change LV into a snapshot exception store.
   Return proper error codes for some failing lvconvert funtions.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 8c960f9..9710134 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005-2013 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2005-2014 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -17,6 +17,7 @@
 #include "lv_alloc.h"
 
 struct lvconvert_params {
+	int cache;
 	int force;
 	int snapshot;
 	int splitsnapshot;
@@ -27,8 +28,6 @@ struct lvconvert_params {
 	int yes;
 	int zero;
 
-	const char *origin;
-	const char *cachepool;
 	const char *lv_name;
 	const char *lv_split_name;
 	const char *lv_name_full;
@@ -64,84 +63,88 @@ struct lvconvert_params {
 	struct logical_volume *lv_to_poll;
 
 	int passed_args;
-	uint64_t poolmetadata_size;
+	uint64_t pool_metadata_size;
 	const char *origin_lv_name;
 	const char *pool_data_lv_name;
+	struct logical_volume *pool_data_lv;
 	const char *pool_metadata_lv_name;
+	struct logical_volume *pool_metadata_lv;
 	thin_discards_t discards;
 };
 
+static int _lvconvert_vg_name(struct lvconvert_params *lp,
+			      struct cmd_context *cmd,
+			      const char **lv_name)
+{
+	const char *vg_name;
+	const char *tmp_str;
+
+	if (!lv_name || !*lv_name)
+		return 1;
+
+	/* If contains VG name, extract it. */
+	if ((tmp_str = strchr(*lv_name, (int) '/'))) {
+		if (!(vg_name = extract_vgname(cmd, *lv_name)))
+			return_0;
+		if (!lp->vg_name)
+			lp->vg_name = vg_name;
+		else if (strcmp(vg_name, lp->vg_name)) {
+			log_error("Please use a single volume group name "
+				  "(\"%s\" or \"%s\")", vg_name, lp->vg_name);
+			return 0;
+		}
+		/* Strip VG from lv_name */
+		*lv_name = tmp_str + 1;
+	}
+
+	if (!apply_lvname_restrictions(*lv_name))
+		return_0;
+
+	return 1;
+}
+
 static int _lvconvert_name_params(struct lvconvert_params *lp,
 				  struct cmd_context *cmd,
 				  int *pargc, char ***pargv)
 {
 	char *ptr;
 	const char *vg_name = NULL;
-	const char *tmp_str;
 
 	if (lp->merge)
 		return 1;
 
-	if (lp->snapshot) {
-		if (!*pargc) {
+	if (!*pargc) {
+		if (lp->cache) {
+			log_error("Logical volume name for caching is missing.");
+			return 0;
+		}
+		if (lp->thin) {
 			log_error("Please specify a logical volume to act as "
-				  "the snapshot origin.");
+				  "the external origin.");
 			return 0;
 		}
-
-		lp->origin = *pargv[0];
-		(*pargv)++, (*pargc)--;
-		if (!(lp->vg_name = extract_vgname(cmd, lp->origin))) {
-			log_error("The origin name should include the "
-				  "volume group.");
+		if (lp->snapshot) {
+			log_error("Please specify a logical volume to act as "
+				  "the snapshot exception store.");
 			return 0;
 		}
-
-		/* Strip the volume group from the origin */
-		if ((ptr = strrchr(lp->origin, (int) '/')))
-			lp->origin = ptr + 1;
-	}
-
-	if (lp->pool_data_lv_name) {
-		if (*pargc) {
-			if (!lp->thin) {
-				log_error("More then one logical volume name specified.");
-				return 0;
-			}
-		} else {
-			if (lp->thin) {
-				log_error("External thin volume name is missing.");
-				return 0;
-			}
-
-			if (!lp->vg_name || !validate_name(lp->vg_name)) {
-				log_error("Please provide a valid volume group name.");
-				return 0;
-			}
-
-			lp->lv_name = lp->pool_data_lv_name;
-			return 1;
+		if (!lp->lv_name_full) {
+			log_error("Please provide logical volume path.");
+			return 0;
 		}
+	} else if (!lp->lv_name_full) {
+		lp->lv_name_full = (*pargv)[0];
+		(*pargv)++, (*pargc)--;
 	}
 
-	if (lp->origin_lv_name) {
-		/* FIXME: Using generic routine */
-		if (strchr(lp->origin_lv_name, '/')) {
-			if (!(lp->vg_name = extract_vgname(cmd, lp->origin_lv_name)))
-				return_0;
-			/* Strip VG from origin_lv_name */
-			if ((tmp_str = strrchr(lp->origin_lv_name, '/')))
-				lp->origin_lv_name = tmp_str + 1;
-		}
-	}
+	if (!_lvconvert_vg_name(lp, cmd, &lp->pool_metadata_lv_name))
+		return_0;
 
-	if (!*pargc) {
-		log_error("Please provide logical volume path");
-		return 0;
-	}
+	if (!_lvconvert_vg_name(lp, cmd, &lp->pool_data_lv_name))
+		return_0;
 
-	lp->lv_name = lp->lv_name_full = (*pargv)[0];
-	(*pargv)++, (*pargc)--;
+	if (!_lvconvert_vg_name(lp, cmd, &lp->origin_lv_name))
+		return_0;
 
 	if (strchr(lp->lv_name_full, '/') &&
 	    (vg_name = extract_vgname(cmd, lp->lv_name_full)) &&
@@ -161,6 +164,8 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 
 	if ((ptr = strrchr(lp->lv_name_full, '/')))
 		lp->lv_name = ptr + 1;
+	else
+                lp->lv_name = lp->lv_name_full;
 
 	if (!lp->merge_mirror &&
 	    !strstr(lp->lv_name, "_tdata") &&
@@ -168,19 +173,21 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 	    !apply_lvname_restrictions(lp->lv_name))
 		return_0;
 
-	if (*pargc && lp->snapshot) {
-		log_error("Too many arguments provided for snapshots");
-		return 0;
-	}
-
-	if (lp->splitsnapshot && *pargc) {
-		log_error("Too many arguments provided with --splitsnapshot.");
-		return 0;
-	}
-
-	if (lp->pool_data_lv_name && lp->lv_name && lp->poolmetadata_size) {
-		log_error("Please specify either metadata logical volume or its size.");
-		return 0;
+	log_error("PAR  %d  t:%d  c:%d  m:%s d:%s  l:%s", *pargc, lp->thin,lp->cache,
+		  lp->pool_metadata_lv_name, lp->pool_data_lv_name, lp->lv_name);
+	if (*pargc) {
+		if (lp->snapshot) {
+			log_error("Too many arguments provided for snapshots.");
+			return 0;
+		}
+		if (lp->splitsnapshot) {
+			log_error("Too many arguments provided with --splitsnapshot.");
+			return 0;
+		}
+		if (lp->pool_data_lv_name && lp->pool_metadata_lv_name) {
+			log_error("Too many arguments provided for pool.");
+			return 0;
+		}
 	}
 
 	return 1;
@@ -219,11 +226,159 @@ static int _mirror_or_raid_type_requested(struct cmd_context *cmd, const char *t
 	return (arg_count(cmd, mirrors_ARG) || !strncmp(type_str, "raid", 4) || !strcmp(type_str, "mirror"));
 }
 
+static int _read_pool_params(struct lvconvert_params *lp, struct cmd_context *cmd,
+			     const char *type_str, int *pargc, char ***pargv)
+{
+	const char *tmp_str;
+	int cachepool = 0;
+	int thinpool = 0;
+
+	if (arg_count(cmd, cachepool_ARG)) {
+		if (type_str[0] &&
+		    strcmp(type_str, "cache") &&
+		    strcmp(type_str, "cache-pool")) {
+			log_error("--cachepool argument is only valid with "
+				  " the cache or cache-pool segment type.");
+			return 0;
+		}
+		if (!(lp->pool_data_lv_name = arg_str_value(cmd, cachepool_ARG, NULL))) {
+			log_error("Missing cache pool logical volume name.");
+			return 0;
+		}
+		cachepool = 1;
+		type_str = "cache-pool";
+	} else if (!strcmp(type_str, "cache-pool"))
+		cachepool = 1;
+
+	if (arg_count(cmd, thinpool_ARG)) {
+		if (type_str[0] &&
+		    strcmp(type_str, "thin") &&
+		    strcmp(type_str, "thin-pool")) {
+			log_error("--thinpool argument is only valid with "
+				  " the thin or thin-pool segment type.");
+			return 0;
+		}
+		if (!(lp->pool_data_lv_name = arg_str_value(cmd, thinpool_ARG, NULL))) {
+			log_error("Missing thin pool logical volume name.");
+			return 0;
+		}
+		thinpool = 1;
+		type_str = "thin-pool";
+	} else if (!strcmp(type_str, "thin-pool"))
+		thinpool = 1;
+
+	if (thinpool) {
+		lp->discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, THIN_DISCARDS_PASSDOWN);
+
+		if (arg_count(cmd, originname_ARG)) {
+			if (!(lp->origin_lv_name = arg_str_value(cmd, originname_ARG, NULL))) {
+				log_error("Missing --originname argument.");
+				return 0;
+			}
+		}
+	} else {
+		if (!arg_is_any_set(cmd, "is valid only with thin pools",
+				    discards_ARG, originname_ARG, zero_ARG,
+				    -1))
+			return_0;
+		if (lp->thin) {
+			log_error("--thin requires --thinpool.");
+			return 0;
+		}
+	}
+
+	if (cachepool) {
+		if ((tmp_str = arg_str_value(cmd, cachemode_ARG, NULL))) {
+			if (!strcmp(tmp_str, "writeback"))
+				lp->feature_flags |= DM_CACHE_FEATURE_WRITEBACK;
+			else if (!strcmp(tmp_str, "writethrough"))
+				lp->feature_flags |= DM_CACHE_FEATURE_WRITETHROUGH;
+			else {
+				log_error("Unknown cachemode argument");
+				return 0;
+			}
+		}
+	} else {
+		if (!arg_is_any_set(cmd, "is valid only with cache pools",
+				    cachemode_ARG, -1))
+			return_0;
+		if (lp->cache) {
+			log_error("--cache requires --cachepool.");
+			return 0;
+		}
+	}
+
+	if (thinpool || cachepool) {
+		if (!arg_is_any_set(cmd, "is invalid with pools",
+				    merge_ARG, mirrors_ARG, repair_ARG, snapshot_ARG,
+				    splitmirrors_ARG, -1))
+			return_0;
+
+		if (arg_count(cmd, poolmetadatasize_ARG)) {
+			if (arg_sign_value(cmd, poolmetadatasize_ARG, SIGN_NONE) == SIGN_MINUS) {
+				log_error("Negative pool metadata size is invalid.");
+				return 0;
+			}
+			if (arg_count(cmd, poolmetadata_ARG)) {
+				log_error("Please specify either metadata logical volume or its size.");
+				return 0;
+			}
+			/* value is read in get_pool_params() */
+		}
+
+		if (arg_count(cmd, poolmetadata_ARG)) {
+			if (arg_count(cmd, stripesize_ARG) || arg_count(cmd, stripes_long_ARG)) {
+				log_error("Can't use --stripes and --stripesize with --poolmetadata.");
+				return 0;
+			}
+
+			if (arg_count(cmd, readahead_ARG)) {
+				log_error("Can't use --readahead with --poolmetadata.");
+				return 0;
+			}
+
+			if (!(lp->pool_metadata_lv_name = arg_str_value(cmd, poolmetadata_ARG, NULL))) {
+				log_error("Missing --poolmetadata argument.");
+				return 0;
+			}
+		}
+
+		if (arg_count(cmd, chunksize_ARG) &&
+		    (arg_sign_value(cmd, chunksize_ARG, SIGN_NONE) == SIGN_MINUS)) {
+			log_error("Negative chunk size is invalid.");
+			return 0;
+		}
+
+		if (!arg_count(cmd, cachepool_ARG) &&
+		    !arg_count(cmd, thinpool_ARG)) {
+			if (!*pargc) {
+				log_error("Please specify the pool data LV.");
+				return 0;
+			}
+			lp->pool_data_lv_name = (*pargv)[0];
+                        (*pargv)++, (*pargc)--;
+		}
+
+		if (!lp->thin && !lp->cache)
+			lp->lv_name_full = lp->pool_data_lv_name;
+		/* Hmm _read_activation_params */
+		lp->read_ahead = arg_uint_value(cmd, readahead_ARG,
+						cmd->default_settings.read_ahead);
+
+		if (!(lp->segtype = get_segtype_from_string(cmd, type_str)))
+			return_0;
+	} else if (!arg_is_any_set(cmd, "is valid only with pools",
+				   poolmetadatasize_ARG, poolmetadataspare_ARG,
+				   -1))
+		return_0;
+
+	return 1;
+}
+
 static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 			int argc, char **argv)
 {
 	int i;
-	int cache_pool = 0;
 	const char *tmp_str;
 	struct arg_value_group_list *group;
 	int region_size;
@@ -269,84 +424,45 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (!strcmp(type_str, "cache-pool")) {
-		cache_pool = 1;
-		if ((tmp_str = arg_str_value(cmd, cachemode_ARG, NULL))) {
-			if (!strcmp(tmp_str, "writeback"))
-				lp->feature_flags |= DM_CACHE_FEATURE_WRITEBACK;
-			else if (!strcmp(tmp_str, "writethrough"))
-				lp->feature_flags |= DM_CACHE_FEATURE_WRITETHROUGH;
-			else {
-				log_error("Unknown cachemode argument");
-				return 0;
-			}
-		}
-	}
+	if (arg_count(cmd, cache_ARG))
+		lp->cache = 1;
 
-	if (!arg_count(cmd, background_ARG))
-		lp->wait_completion = 1;
-
-	if (_snapshot_type_requested(cmd, type_str))
-		lp->snapshot = 1;
-
-	if (_snapshot_type_requested(cmd, type_str) && arg_count(cmd, merge_ARG)) {
-		log_error("--snapshot and --merge are mutually exclusive");
-		return 0;
-	}
-
-	if (arg_count(cmd, splitmirrors_ARG) && _mirror_or_raid_type_requested(cmd, type_str)) {
-		log_error("--mirrors/--type mirror/--type raid* and --splitmirrors are "
-			  "mutually exclusive");
-		return 0;
+	if (!strcmp(type_str, "cache"))
+		lp->cache = 1;
+	else if (lp->cache) {
+		if (type_str[0]) {
+			log_error("--cache is incompatible with --type %s", type_str);
+			return 0;
+		}
+		type_str = "cache";
 	}
 
 	if (arg_count(cmd, thin_ARG))
 		lp->thin = 1;
 
-	if (arg_count(cmd, cachepool_ARG)) {
-		if (strcmp(type_str, "cache")) {
-			log_error("--cachepool argument is only valid with "
-				  " the \"cache\" segment type");
+	if (!strcmp(type_str, "thin"))
+		lp->thin = 1;
+	else if (lp->thin) {
+		if (type_str[0]) {
+			log_error("--thin is incompatible with --type %s", type_str);
 			return 0;
 		}
-		lp->cachepool = arg_str_value(cmd, cachepool_ARG, NULL);
-	} else if (arg_count(cmd, thinpool_ARG) || cache_pool) {
+		type_str = "thin";
+	}
+
+	if (!_read_pool_params(lp, cmd, type_str, &argc, &argv))
+		return_0;
+
+	if (!arg_count(cmd, background_ARG))
+		lp->wait_completion = 1;
+
+	if (_snapshot_type_requested(cmd, type_str)) {
 		if (arg_count(cmd, merge_ARG)) {
-			log_error("--%spool and --merge are mutually exlusive.",
-				  cache_pool ? "type cache_" : "thin");
+			log_error("--snapshot and --merge are mutually exclusive.");
 			return 0;
 		}
-		if (_mirror_or_raid_type_requested(cmd, type_str)) {
-			log_error("--%spool and --mirrors/--type mirror/--type raid* are mutually exlusive.",
-				  cache_pool ? "type cache_" : "thin");
-			return 0;
-		}
-		if (arg_count(cmd, repair_ARG)) {
-			log_error("--%spool and --repair are mutually exlusive.",
-				  cache_pool ? "type cache_" : "thin");
-			return 0;
-		}
-		if (_snapshot_type_requested(cmd, type_str)) {
-			log_error("--%spool and --snapshot/--type snapshot are mutually exlusive.",
-				  cache_pool ? "type cache_" : "thin");
-			return 0;
-		}
-		if (arg_count(cmd, splitmirrors_ARG)) {
-			log_error("--%spool and --splitmirrors are mutually exlusive.",
-				  cache_pool ? "type cache_" : "thin");
-			return 0;
-		}
-		if (!cache_pool)
-			lp->discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, THIN_DISCARDS_PASSDOWN);
-	} else if (lp->thin) {
-		log_error("--thin is only valid with --thinpool.");
-		return 0;
-	} else if (arg_count(cmd, discards_ARG)) {
-		log_error("--discards is only valid with --thinpool.");
-		return 0;
-	} else if (arg_count(cmd, poolmetadataspare_ARG)) {
-		log_error("--poolmetadataspare is only valid with --thinpool.");
-		return 0;
+
+		lp->snapshot = 1;
 	}
 
 	/*
@@ -356,6 +472,11 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 	 * discarding it.
 	 */
 	if (arg_count(cmd, splitmirrors_ARG)) {
+		if (_mirror_or_raid_type_requested(cmd, type_str)) {
+			log_error("--mirrors/--type mirror/--type raid* and --splitmirrors are "
+				  "mutually exclusive.");
+			return 0;
+		}
 		if (!arg_count(cmd, name_ARG) &&
 		    !arg_count(cmd, trackchanges_ARG)) {
 			log_error("Please name the new logical volume using '--name'");
@@ -437,6 +558,13 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 	} else if (lp->splitsnapshot)	/* Destroy snapshot retaining cow as separate LV */
 		;
 	else if (lp->snapshot) {	/* Snapshot creation from pre-existing cow */
+		if (!argc) {
+			log_error("Please provide logical volume path for snaphost origin.");
+			return 0;
+		}
+		lp->origin_lv_name = argv[0];
+		argv++, argc--;
+
 		if (arg_count(cmd, regionsize_ARG)) {
 			log_error("--regionsize is only available with mirrors");
 			return 0;
@@ -490,65 +618,7 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 								    tmp_str)))
 				return_0;
 		}
-	} else if (arg_count(cmd, thinpool_ARG) || cache_pool) {
-		if (cache_pool) {
-			if (!argc) {
-				log_error("Please specify the pool data LV.");
-				return 0;
-			}
-			lp->pool_data_lv_name = argv[0];
-			argv++, argc--;
-		} else if (!(lp->pool_data_lv_name = arg_str_value(cmd, thinpool_ARG, NULL))) {
-			log_error("Missing pool logical volume name.");
-			return 0;
-		}
-
-		if (arg_count(cmd, poolmetadata_ARG)) {
-			if (arg_count(cmd, poolmetadatasize_ARG)) {
-				log_error("--poolmetadatasize is invalid with --poolmetadata.");
-				return 0;
-			}
-			if (arg_count(cmd, stripesize_ARG) || arg_count(cmd, stripes_long_ARG)) {
-				log_error("Can't use --stripes and --stripesize with --poolmetadata.");
-				return 0;
-			}
-
-			if (arg_count(cmd, readahead_ARG)) {
-				log_error("Can't use --readahead with --poolmetadata.");
-				return 0;
-			}
-			lp->pool_metadata_lv_name = arg_str_value(cmd, poolmetadata_ARG, "");
-		}
-
-		/* Hmm _read_activation_params */
-		lp->read_ahead = arg_uint_value(cmd, readahead_ARG,
-						cmd->default_settings.read_ahead);
-
-		/* If pool_data_lv_name contains VG name, extract it. */
-		if ((tmp_str = strchr(lp->pool_data_lv_name, (int) '/'))) {
-			if (!(lp->vg_name = extract_vgname(cmd, lp->pool_data_lv_name)))
-				return 0;
-			/* Strip VG from pool */
-			lp->pool_data_lv_name = tmp_str + 1;
-		}
-
-		if (arg_count(cmd, originname_ARG)) {
-			if (!(lp->origin_lv_name = arg_str_value(cmd, originname_ARG, NULL))) {
-				log_error("--originname is invalid.");
-				return 0;
-			}
-		}
-
-		lp->segtype = get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG, cache_pool ? "cache-pool" : "thin-pool"));
-		if (!lp->segtype)
-			return_0;
-
-		if (arg_count(cmd, chunksize_ARG) &&
-		    (arg_sign_value(cmd, chunksize_ARG, SIGN_NONE) == SIGN_MINUS)) {
-			log_error("Negative chunk size is invalid.");
-			return 0;
-		}
-	} else { /* Mirrors (and some RAID functions) */
+	} else if (_mirror_or_raid_type_requested(cmd, type_str)) { /* Mirrors (and some RAID functions) */
 		if (arg_count(cmd, chunksize_ARG)) {
 			log_error("--chunksize is only available with snapshots or pools.");
 			return 0;
@@ -2046,14 +2116,14 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (!(org = find_lv(lv->vg, lp->origin))) {
-		log_error("Couldn't find origin volume '%s'.", lp->origin);
+	if (!(org = find_lv(lv->vg, lp->origin_lv_name))) {
+		log_error("Couldn't find origin volume %s.", lp->origin_lv_name);
 		return 0;
 	}
 
 	if (org == lv) {
-		log_error("Unable to use \"%s\" as both snapshot and origin.",
-			  lv->name);
+		log_error("Unable to use %s as both snapshot and origin.",
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -2327,9 +2397,9 @@ out:
 	return r;
 }
 
-static int _lvconvert_thinpool_repair(struct cmd_context *cmd,
-				      struct logical_volume *pool_lv,
-				      struct lvconvert_params *lp)
+static int _lvconvert_pool_repair(struct cmd_context *cmd,
+				  struct logical_volume *pool_lv,
+				  struct lvconvert_params *lp)
 {
 	const char *dmdir = dm_dir();
 	const char *thin_dump =
@@ -2526,12 +2596,12 @@ deactivate_pmslv:
 	return 1;
 }
 
-static int _lvconvert_thinpool_external(struct cmd_context *cmd,
-					struct logical_volume *pool_lv,
-					struct logical_volume *external_lv,
-					struct lvconvert_params *lp)
+/* Currently converts only to thin volume with external origin */
+static int _lvconvert_thin(struct cmd_context *cmd,
+			   struct logical_volume *lv,
+			   struct lvconvert_params *lp)
 {
-	struct logical_volume *torigin_lv;
+	struct logical_volume *torigin_lv, *pool_lv = lp->pool_data_lv;
 	struct volume_group *vg = pool_lv->vg;
 	struct lvcreate_params lvc = {
 		.activate = CHANGE_AE,
@@ -2544,18 +2614,33 @@ static int _lvconvert_thinpool_external(struct cmd_context *cmd,
 		.pvh = &vg->pvs,
 		.read_ahead = DM_READ_AHEAD_AUTO,
 		.stripes = 1,
-		.voriginextents = external_lv->le_count,
-		.voriginsize = external_lv->size,
+		.voriginextents = lv->le_count,
+		.voriginsize = lv->size,
 	};
 
+	if (lv == pool_lv) {
+		log_error("Can't use same LV %s for thin pool and thin volume.",
+			  display_lvname(pool_lv));
+		return 0;
+	}
+
+	if (lv_is_thin_pool(lv)) {
+		log_error("Can't use pool %s as external origin.",
+			  display_lvname(lv));
+		return 0;
+	}
+
 	dm_list_init(&lvc.tags);
 
-	if (!pool_supports_external_origin(first_seg(pool_lv), external_lv))
+	if (!pool_supports_external_origin(first_seg(pool_lv), lv))
 		return_0;
 
 	if (!(lvc.segtype = get_segtype_from_string(cmd, "thin")))
 		return_0;
 
+	if (!archive(vg))
+		return_0;
+
 	/* New thin LV needs to be created (all messages sent to pool) */
 	if (!(torigin_lv = lv_create_single(vg, &lvc)))
 		return_0;
@@ -2572,15 +2657,15 @@ static int _lvconvert_thinpool_external(struct cmd_context *cmd,
 	 * which could be easily removed by the user after i.e. power-off
 	 */
 
-	if (!_swap_lv_identifiers(cmd, torigin_lv, external_lv)) {
+	if (!_swap_lv_identifiers(cmd, torigin_lv, lv)) {
 		stack;
 		goto revert_new_lv;
 	}
 
 	/* Preserve read-write status of original LV here */
-	torigin_lv->status |= (external_lv->status & LVM_WRITE);
+	torigin_lv->status |= (lv->status & LVM_WRITE);
 
-	if (!attach_thin_external_origin(first_seg(torigin_lv), external_lv)) {
+	if (!attach_thin_external_origin(first_seg(torigin_lv), lv)) {
 		stack;
 		goto revert_new_lv;
 	}
@@ -2590,15 +2675,17 @@ static int _lvconvert_thinpool_external(struct cmd_context *cmd,
 		goto deactivate_and_revert_new_lv;
 	}
 
-	log_print_unless_silent("Converted \"%s/%s\" to thin volume with "
-				"external origin \"%s/%s\".",
-				vg->name, torigin_lv->name,
-				vg->name, external_lv->name);
+	log_print_unless_silent("Converted %s to thin volume with "
+				"external origin %s.",
+				display_lvname(torigin_lv),
+				display_lvname(lv));
+
+	backup(vg);
 
 	return 1;
 
 deactivate_and_revert_new_lv:
-	if (!_swap_lv_identifiers(cmd, torigin_lv, external_lv))
+	if (!_swap_lv_identifiers(cmd, torigin_lv, lv))
 		stack;
 
 	if (!deactivate_lv(cmd, torigin_lv)) {
@@ -2632,7 +2719,7 @@ static int _lvconvert_update_pool_params(struct logical_volume *pool_lv,
 						&lp->thin_chunk_size_calc_policy,
 						&lp->chunk_size,
 						&lp->discards,
-						&lp->poolmetadata_size,
+						&lp->pool_metadata_size,
 						&lp->zero);
 
 	return update_thin_pool_params(pool_lv->vg, lp->target_attr,
@@ -2642,101 +2729,95 @@ static int _lvconvert_update_pool_params(struct logical_volume *pool_lv,
 				       &lp->thin_chunk_size_calc_policy,
 				       &lp->chunk_size,
 				       &lp->discards,
-				       &lp->poolmetadata_size,
+				       &lp->pool_metadata_size,
 				       &lp->zero);
 }
 
-
-
 /*
  * Thin lvconvert version which
  *  rename metadata
  *  convert/layers thinpool over data
  *  attach metadata
  */
-static int _lvconvert_to_pool(struct cmd_context *cmd,
-			      struct logical_volume *pool_lv,
-			      struct lvconvert_params *lp)
+static int _lvconvert_pool(struct cmd_context *cmd,
+			   struct logical_volume *pool_lv,
+			   struct lvconvert_params *lp)
 {
 	int r = 0;
-	uint64_t min_metadata_size;
-	uint64_t max_metadata_size;
 	const char *old_name;
 	struct lv_segment *seg;
+	struct volume_group *vg = pool_lv->vg;
 	struct logical_volume *data_lv;
-	struct logical_volume *metadata_lv;
+	struct logical_volume *metadata_lv = NULL;
 	struct logical_volume *pool_metadata_lv;
-	struct logical_volume *external_lv = NULL;
 	char metadata_name[NAME_LEN], data_name[NAME_LEN];
 	int activate_pool;
 
-	if (!lv_is_visible(pool_lv)) {
-		log_error("Can't convert internal LV %s/%s.",
-			  pool_lv->vg->name, pool_lv->name);
+	if (lp->pool_data_lv_name &&
+	    !(pool_lv = find_lv(vg, lp->pool_data_lv_name))) {
+		log_error("Unknown pool data LV %s.", lp->pool_data_lv_name);
 		return 0;
 	}
 
-	if (lv_is_mirrored(pool_lv) && !lv_is_raid_type(pool_lv)) {
-		log_error("Mirror logical volumes cannot be used as thinpools.\n"
-			  "Try \"raid1\" segment type instead.");
-		return 0;
-	}
-
-	if (lp->thin) {
-		if (strcmp(pool_lv->name, lp->pool_data_lv_name) == 0) {
-			log_error("Can't use same LV %s/%s for thin pool and thin volume.",
-				  pool_lv->vg->name, pool_lv->name);
+	if (lp->pool_metadata_lv_name) {
+		if (!(lp->pool_metadata_lv = find_lv(vg, lp->pool_metadata_lv_name))) {
+			log_error("Unknown pool metadata LV %s.", lp->pool_metadata_lv_name);
 			return 0;
 		}
+		lp->pool_metadata_size = lp->pool_metadata_lv->size;
+		metadata_lv = lp->pool_metadata_lv;
 
-		external_lv = pool_lv;
-		if (!(pool_lv = find_lv(external_lv->vg, lp->pool_data_lv_name))) {
-			log_error("Can't find pool LV %s/%s.",
-				  external_lv->vg->name, lp->pool_data_lv_name);
+		if (!lv_is_visible(metadata_lv)) {
+			log_error("Can't convert internal LV %s.",
+				  display_lvname(metadata_lv));
 			return 0;
 		}
-
-		if (lv_is_thin_pool(external_lv)) {
-			log_error("Can't convert pool \"%s/%s\" to external origin.",
-				  external_lv->vg->name, lp->pool_data_lv_name);
+		if (lv_is_mirrored(metadata_lv) && !lv_is_raid_type(metadata_lv)) {
+			log_error("Mirror logical volumes cannot be used "
+				  "for pool metadata.");
+			log_error("Try \"raid1\" segment type instead.");
+			return 0;
+		}
+		if (metadata_lv->status & LOCKED) {
+			log_error("Can't convert locked LV %s.",
+				  display_lvname(metadata_lv));
+			return 0;
+		}
+		if (metadata_lv == pool_lv) {
+			log_error("Can't use same LV for pool data and metadata LV %s.",
+				  display_lvname(metadata_lv));
+			return 0;
+		}
+		if (lv_is_thin_type(metadata_lv) ||
+		    lv_is_cache_type(metadata_lv)) {
+			log_error("Can't use %s LV %s for pool metadata.",
+				  lv_type_name(metadata_lv), display_lvname(metadata_lv));
 			return 0;
 		}
 
-		if (lv_is_thin_pool(pool_lv)) {
-			activate_pool = lv_is_active(pool_lv);
-			r = 1; /* Already existing thin pool */
-			goto out;
+		if (!lv_is_pool(pool_lv)) {
+			if (!_lvconvert_update_pool_params(pool_lv, lp))
+				return_0;
+
+			if (lp->pool_metadata_size > metadata_lv->size) {
+				log_error("Logical volume %s is too small for metadata.",
+					  display_lvname(metadata_lv));
+				return 0;
+			}
 		}
 	}
 
-	if (lv_is_thin_type(pool_lv) && !lp->pool_metadata_lv_name) {
-		log_error("Can't use thin logical volume %s/%s for thin pool data.",
-			  pool_lv->vg->name, pool_lv->name);
+	if (!lv_is_visible(pool_lv)) {
+		log_error("Can't convert internal LV %s.", display_lvname(pool_lv));
 		return 0;
 	}
 
-	if (segtype_is_cache_pool(lp->segtype))
-		activate_pool = 0; /* Cannot activate cache pool */
-	else
-		/* Allow to have only thinpool active and restore it's active state */
-		activate_pool = lv_is_active(pool_lv);
-
-	/* We are changing target type, so deactivate first */
-	if (!deactivate_lv(cmd, pool_lv)) {
-		log_error("Aborting. Failed to deactivate logical volume %s/%s.",
-			  pool_lv->vg->name, pool_lv->name);
+	if (lv_is_mirrored(pool_lv) && !lv_is_raid_type(pool_lv)) {
+		log_error("Mirror logical volumes cannot be used as pools.\n"
+			  "Try \"raid1\" segment type instead.");
 		return 0;
 	}
 
-	if (lv_is_thin_pool(pool_lv)) {
-		if (pool_is_active(pool_lv)) {
-		/* If any thin volume is also active - abort here */
-			log_error("Cannot convert pool %s/%s with active thin volumes.",
-				  pool_lv->vg->name, pool_lv->name);
-			return 0;
-		}
-	}
-
 	if ((dm_snprintf(metadata_name, sizeof(metadata_name), "%s%s",
 			 pool_lv->name,
 			 (segtype_is_cache_pool(lp->segtype)) ?
@@ -2750,149 +2831,144 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (!lp->pool_metadata_lv_name) {
-		if (!_lvconvert_update_pool_params(pool_lv, lp))
-			return_0;
-
-		if (!get_stripe_params(cmd, &lp->stripes, &lp->stripe_size))
-			return_0;
+	if (lv_is_pool(pool_lv)) {
+		lp->pool_data_lv = pool_lv;
 
-		if (!(metadata_lv = alloc_pool_metadata(pool_lv, metadata_name,
-							lp->read_ahead, lp->stripes,
-							lp->stripe_size,
-							lp->poolmetadata_size,
-							lp->alloc, lp->pvh)))
-			return_0;
-	} else {
-		if (!(metadata_lv = find_lv(pool_lv->vg, lp->pool_metadata_lv_name))) {
-			log_error("Unknown metadata LV %s.", lp->pool_metadata_lv_name);
-			return 0;
-		}
-		if (!lv_is_visible(metadata_lv)) {
-			log_error("Can't convert internal LV %s/%s.",
-				  metadata_lv->vg->name, metadata_lv->name);
-			return 0;
-		}
-		if (lv_is_mirrored(pool_lv) && !lv_is_raid_type(pool_lv)) {
-			log_error("Mirror logical volumes cannot be used"
-				  " for thinpool metadata.\n"
-				  "Try \"raid1\" segment type instead.");
-			return 0;
-		}
-		if (metadata_lv->status & LOCKED) {
-			log_error("Can't convert locked LV %s/%s.",
-				  metadata_lv->vg->name, metadata_lv->name);
-			return 0;
+		if (!metadata_lv) {
+			if (!arg_is_any_set(cmd, "is invalid with existing pool",
+					    cachemode_ARG,chunksize_ARG, discards_ARG,
+					    zero_ARG, poolmetadatasize_ARG, -1))
+				return_0;
+			return 1;
 		}
-		if (metadata_lv == pool_lv) {
-			log_error("Can't use same LV for thin pool data and metadata LV %s/%s.",
-				  metadata_lv->vg->name, metadata_lv->name);
+
+		if (lp->thin || lp->cache) {
+			log_error("--%s and pool metadata swap is not supported.",
+				  lp->thin ? "thin" : "cache");
 			return 0;
 		}
-		if (lv_is_thin_type(metadata_lv)) {
-			log_error("Can't use thin type LV %s/%s for thin pool metadata.",
-				  metadata_lv->vg->name, metadata_lv->name);
+
+		/* FIXME cache pool */
+		if (lv_is_thin_pool(pool_lv) && pool_is_active(pool_lv)) {
+			/* If any volume referencing pool active - abort here */
+			log_error("Cannot convert pool %s with active volumes.",
+				  display_lvname(pool_lv));
 			return 0;
 		}
 
-		/* Swap normal LV with pool's metadata LV ? */
-		if (lv_is_thin_pool(pool_lv)) {
-			if (!deactivate_lv(cmd, metadata_lv)) {
-				log_error("Aborting. Failed to deactivate LV %s/%s.",
-					  metadata_lv->vg->name, metadata_lv->name);
-				return 0;
-			}
+		seg = first_seg(pool_lv);
 
-			seg = first_seg(pool_lv);
-
-			if (!arg_count(cmd, chunksize_ARG))
-				lp->chunk_size = seg->chunk_size;
-			else if (lp->chunk_size != seg->chunk_size) {
-				if (lp->force == PROMPT) {
-					log_error("Chunk size can be only changed with --force. Conversion aborted.");
-					return 0;
-				}
-				/* Ok, user has likely some serious reason for this */
-				if (!lp->yes &&
-				    yes_no_prompt("Do you really want to change chunk size %s to %s "
-						  "for %s/%s pool volume? [y/n]: ",
-						  display_size(cmd, seg->chunk_size),
-						  display_size(cmd, lp->chunk_size),
-						  pool_lv->vg->name, pool_lv->name) == 'n') {
-					log_error("Conversion aborted.");
-					return 0;
-				}
-				log_warn("WARNING: Changing chunk size %s to %s for %s/%s pool volume.",
-					 display_size(cmd, seg->chunk_size),
-					 display_size(cmd, lp->chunk_size),
-					 pool_lv->vg->name, pool_lv->name);
+		/* Normally do NOT change chunk size when swapping */
+		if (arg_count(cmd, chunksize_ARG) &&
+		    (lp->chunk_size != seg->chunk_size)) {
+			if (lp->force == PROMPT) {
+				log_error("Chunk size can be only changed with --force. Conversion aborted.");
+				return 0;
 			}
-
+			log_warn("WARNING: Changing chunk size %s to "
+				 "%s for %s pool volume.",
+				 display_size(cmd, seg->chunk_size),
+				 display_size(cmd, lp->chunk_size),
+				 display_lvname(pool_lv));
+			/* Ok, user has likely some serious reason for this */
 			if (!lp->yes &&
-			    yes_no_prompt("Do you want to swap metadata of %s/%s pool with "
-					  "volume %s/%s? [y/n]: ",
-					  pool_lv->vg->name, pool_lv->name,
-					  metadata_lv->vg->name, metadata_lv->name) == 'n') {
+			    yes_no_prompt("Do you really want to change chunk size "
+					  "for %s pool volume? [y/n]: ",
+					  display_lvname(pool_lv)) == 'n') {
 				log_error("Conversion aborted.");
 				return 0;
 			}
+		} else
+			lp->chunk_size = seg->chunk_size;
 
-			/* Swap names between old and new metadata LV */
-			if (!detach_pool_metadata_lv(seg, &pool_metadata_lv))
-				return_0;
-			old_name = metadata_lv->name;
-			if (!lv_rename_update(cmd, metadata_lv, "pvmove_tmeta", 0))
-				return_0;
-			if (!lv_rename_update(cmd, pool_metadata_lv, old_name, 0))
-				return_0;
+		if (!_lvconvert_update_pool_params(pool_lv, lp))
+			return_0;
 
-			if (!arg_count(cmd, discards_ARG))
-				lp->discards = seg->discards;
-			if (!arg_count(cmd, zero_ARG))
-				lp->zero = seg->zero_new_blocks;
+		if (metadata_lv->size < lp->pool_metadata_size)
+			log_print_unless_silent("Continuing with swap...");
 
-			goto mda_write;
-		}
+		if (!arg_count(cmd, discards_ARG))
+			lp->discards = seg->discards;
+		if (!arg_count(cmd, zero_ARG))
+			lp->zero = seg->zero_new_blocks;
 
-		if (!deactivate_lv(cmd, metadata_lv)) {
-			log_error("Aborting. Failed to deactivate \"%s/%s\".",
-				  metadata_lv->vg->name, metadata_lv->name);
+		if (!lp->yes &&
+		    yes_no_prompt("Do you want to swap metadata of %s "
+				  "pool with %s volume %s? [y/n]: ",
+				  display_lvname(pool_lv),
+				  lv_type_name(metadata_lv),
+				  display_lvname(metadata_lv)) == 'n') {
+			log_error("Conversion aborted.");
 			return 0;
 		}
+	} else if (lv_is_thin_type(pool_lv)) {
+		log_error("Can't use %s logical volume %s for thin pool data.",
+			  lv_type_name(pool_lv), display_lvname(pool_lv));
+		return 0;
+	} else {
+		log_warn("WARNING: Converting logical volume %s%s%s to pool's data%s.",
+			 display_lvname(pool_lv),
+			 metadata_lv ? " and " : "",
+			 metadata_lv ? display_lvname(metadata_lv) : "",
+			 metadata_lv ? " and metadata volumes" : " volume");
+		log_warn("THIS WILL DESTROY CONTENT OF LOGICAL VOLUME (filesystem etc.)");
 
-		lp->poolmetadata_size = metadata_lv->size;
-		max_metadata_size = (segtype_is_cache_pool(lp->segtype)) ?
-			DEFAULT_CACHE_POOL_MAX_METADATA_SIZE * 2 :
-			DEFAULT_THIN_POOL_MAX_METADATA_SIZE * 2;
-		min_metadata_size = (segtype_is_cache_pool(lp->segtype)) ?
-			DEFAULT_CACHE_POOL_MIN_METADATA_SIZE * 2 :
-			DEFAULT_THIN_POOL_MIN_METADATA_SIZE * 2;
-
-		if (lp->poolmetadata_size > max_metadata_size) {
-			log_warn("WARNING: Maximum size used by metadata is %s, rest is unused.",
-				 display_size(cmd, max_metadata_size));
-			lp->poolmetadata_size = max_metadata_size;
-		} else if (lp->poolmetadata_size < min_metadata_size) {
-			log_error("Logical volume %s/%s is too small (<%s) for metadata.",
-				  metadata_lv->vg->name, metadata_lv->name,
-				  display_size(cmd, min_metadata_size));
+		if (!lp->yes &&
+		    yes_no_prompt("Do you really want to convert %s%s%s? [y/n]: ",
+				  display_lvname(pool_lv),
+				  metadata_lv ? " and " : "",
+				  metadata_lv ? display_lvname(metadata_lv) : "") == 'n') {
+			log_error("Conversion aborted.");
 			return 0;
 		}
+	}
 
+	if (segtype_is_cache_pool(lp->segtype))
+		activate_pool = 0; /* Cannot activate cache pool */
+	else
+		/* Allow to have only thinpool active and restore it's active state */
+		activate_pool = lv_is_active(pool_lv);
+
+	if (!metadata_lv) {
 		if (!_lvconvert_update_pool_params(pool_lv, lp))
 			return_0;
 
-		log_warn("WARNING: Converting logical volume %s/%s to pool's metadata volume.",
-			 metadata_lv->vg->name, metadata_lv->name);
-		log_warn("THIS WILL DESTROY CONTENT OF LOGICAL VOLUME (filesystem etc.)");
+		if (!get_stripe_params(cmd, &lp->stripes, &lp->stripe_size))
+			return_0;
 
-		if (!lp->yes &&
-		    yes_no_prompt("Do you really want to convert %s/%s? [y/n]: ",
-				  metadata_lv->vg->name, metadata_lv->name) == 'n') {
-			log_error("Conversion aborted.");
+		if (!archive(vg))
+			return_0;
+
+		if (!(metadata_lv = alloc_pool_metadata(pool_lv, metadata_name,
+							lp->read_ahead, lp->stripes,
+							lp->stripe_size,
+							lp->pool_metadata_size,
+							lp->alloc, lp->pvh)))
+			return_0;
+	} else {
+		if (!deactivate_lv(cmd, metadata_lv)) {
+			log_error("Aborting. Failed to deactivate %s.",
+				  display_lvname(metadata_lv));
 			return 0;
 		}
 
+		if (!archive(vg))
+			return_0;
+
+		/* Swap normal LV with pool's metadata LV ? */
+		if (lv_is_pool(pool_lv)) {
+			/* Swap names between old and new metadata LV */
+			if (!detach_pool_metadata_lv(seg, &pool_metadata_lv))
+				return_0;
+			old_name = metadata_lv->name;
+			if (!lv_rename_update(cmd, metadata_lv, "pvmove_tmeta", 0))
+				return_0;
+			if (!lv_rename_update(cmd, pool_metadata_lv, old_name, 0))
+				return_0;
+
+			goto mda_write;
+		}
+
 		metadata_lv->status |= LV_TEMPORARY;
 		if (!activate_lv_local(cmd, metadata_lv)) {
 			log_error("Aborting. Failed to activate metadata lv.");
@@ -2905,27 +2981,17 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 		}
 	}
 
+	/* We are changing target type, so deactivate first */
 	if (!deactivate_lv(cmd, metadata_lv)) {
 		log_error("Aborting. Failed to deactivate metadata lv. "
 			  "Manual intervention required.");
 		return 0;
 	}
 
-	if (!handle_pool_metadata_spare(pool_lv->vg, metadata_lv->le_count,
-					lp->pvh, lp->poolmetadataspare))
-		return_0;
-
-	if (!lv_is_thin_pool(pool_lv)) {
-		log_warn("WARNING: Converting logical volume %s/%s to pool's data volume.",
-			 pool_lv->vg->name, pool_lv->name);
-		log_warn("THIS WILL DESTROY CONTENT OF LOGICAL VOLUME (filesystem etc.)");
-
-		if (!lp->yes &&
-		    yes_no_prompt("Do you really want to convert %s/%s? [y/n]: ",
-				  pool_lv->vg->name, pool_lv->name) == 'n') {
-			log_error("Conversion aborted.");
-			return 0;
-		}
+	if (!deactivate_lv(cmd, pool_lv)) {
+		log_error("Aborting. Failed to deactivate logical volume %s.",
+			  display_lvname(pool_lv));
+		return 0;
 	}
 
 	data_lv = pool_lv;
@@ -2943,12 +3009,12 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 					((segtype_is_cache_pool(lp->segtype)) ?
 					 CACHE_POOL : THIN_POOL) |
 					VISIBLE_LV | LVM_READ | LVM_WRITE,
-					ALLOC_INHERIT, data_lv->vg))) {
+					ALLOC_INHERIT, vg))) {
 		log_error("Creation of pool LV failed.");
 		return 0;
 	}
 
-	/* Allocate a new linear segment */
+	/* Allocate a new pool segment */
 	if (!(seg = alloc_lv_segment(lp->segtype, pool_lv, 0, data_lv->le_count,
 				     pool_lv->status, 0, NULL, NULL, 1,
 				     data_lv->le_count, 0, 0, 0, NULL)))
@@ -2982,13 +3048,22 @@ mda_write:
 	if (!attach_pool_metadata_lv(seg, metadata_lv))
 		return_0;
 
-	if (!vg_write(pool_lv->vg) || !vg_commit(pool_lv->vg))
+	if (!handle_pool_metadata_spare(vg, metadata_lv->le_count,
+					lp->pvh, lp->poolmetadataspare))
 		return_0;
 
+	if (!vg_write(vg) || !vg_commit(vg))
+		return_0;
+
+	if (seg->zero_new_blocks &&
+	    seg->chunk_size  >= DEFAULT_THIN_POOL_CHUNK_SIZE_PERFORMANCE * 2)
+		log_warn("WARNING: Pool zeroing and large %s chunk size slows down "
+			 "provisioning.", display_size(cmd, seg->chunk_size));
+
 	if (activate_pool &&
 	    !activate_lv_excl(cmd, pool_lv)) {
-		log_error("Failed to activate pool logical volume %s/%s.",
-			  pool_lv->vg->name, pool_lv->name);
+		log_error("Failed to activate pool logical volume %s.",
+			  display_lvname(pool_lv));
 		/* Deactivate subvolumes */
 		if (!deactivate_lv(cmd, seg_lv(seg, 0)))
 			log_error("Failed to deactivate pool data logical volume.");
@@ -2997,53 +3072,68 @@ mda_write:
 		goto out;
 	}
 
-	log_print_unless_silent("Converted \"%s/%s\" to %s pool.",
-				pool_lv->vg->name, pool_lv->name,
+	log_print_unless_silent("Converted %s to %s pool.",
+				display_lvname(pool_lv),
 				(segtype_is_cache_pool(lp->segtype)) ?
 				"cache" : "thin");
 
 	r = 1;
-out:
-	if (r && external_lv &&
-	    !(r = _lvconvert_thinpool_external(cmd, pool_lv, external_lv, lp)))
-		stack;
 
-	backup(pool_lv->vg);
+	lp->pool_data_lv = pool_lv;
+
+out:
+	backup(vg);
 
 	return r;
+#if 0
+revert_new_lv:
+        /* TBD */
+	if (!lp->pool_metadata_lv_name) {
+		if (!deactivate_lv(cmd, metadata_lv)) {
+			log_error("Failed to deactivate metadata lv.");
+			return 0;
+		}
+		if (!lv_remove(metadata_lv) || !vg_write(vg) || !vg_commit(vg))
+			log_error("Manual intervention may be required to remove "
+				  "abandoned LV(s) before retrying.");
+		else
+			backup(vg);
+	}
+
+	return 0;
+#endif
 }
 
-static int _lvconvert_cache(struct logical_volume *origin,
+static int _lvconvert_cache(struct cmd_context *cmd,
+			    struct logical_volume *origin,
 			    struct lvconvert_params *lp)
 {
-	struct cmd_context *cmd = origin->vg->cmd;
+	struct logical_volume *pool_lv = lp->pool_data_lv;
 	struct logical_volume *cache_lv;
-	struct logical_volume *cachepool;
 
-	if (!lp->cachepool) {
-		log_error("--cachepool argument is required.");
+	if (origin == pool_lv) {
+		log_error("Can't use same LV %s for cache pool and cache volume.",
+			  display_lvname(pool_lv));
 		return 0;
 	}
 
-	if (!(cachepool = find_lv(origin->vg, lp->cachepool))) {
-		log_error("Unable to find cache pool LV, %s", lp->cachepool);
+	if (lv_is_pool(origin) || lv_is_cache_type(origin)) {
+		log_error("Can't cache %s volume %s.",
+			  lv_type_name(origin), display_lvname(origin));
 		return 0;
 	}
 
-	if (!(cache_lv = lv_cache_create(cachepool, origin)))
+	if (!archive(origin->vg))
 		return_0;
 
-	if (!vg_write(cache_lv->vg))
-		return_0;
-	if (!suspend_lv(cmd, cache_lv))
-		return_0;
-	if (!vg_commit(cache_lv->vg))
+	if (!(cache_lv = lv_cache_create(pool_lv, origin)))
 		return_0;
-	if (!resume_lv(cmd, cache_lv))
+
+	if (!_reload_lv(cmd, cache_lv->vg, cache_lv))
 		return_0;
 
-	log_print_unless_silent("%s/%s is now cached.",
-				cache_lv->vg->name, cache_lv->name);
+	log_print_unless_silent("Logical volume %s is now cached.",
+				display_lvname(cache_lv));
 
 	return 1;
 }
@@ -3073,8 +3163,8 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (lp->splitsnapshot)
 		return _lvconvert_splitsnapshot(cmd, lv, lp);
 
-	if (arg_count(cmd, repair_ARG) && lv_is_thin_pool(lv)) {
-		if (!_lvconvert_thinpool_repair(cmd, lv, lp))
+	if (arg_count(cmd, repair_ARG) && lv_is_pool(lv)) {
+		if (!_lvconvert_pool_repair(cmd, lv, lp))
 			return_ECMD_FAILED;
 		return ECMD_PROCESSED;
 	}
@@ -3112,28 +3202,19 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 	} else if (lp->snapshot) {
 		if (!_lvconvert_snapshot(cmd, lv, lp))
 			return_ECMD_FAILED;
-
-	} else if (segtype_is_cache(lp->segtype)) {
-		if (!archive(lv->vg))
+	} else if (segtype_is_pool(lp->segtype) || lp->thin || lp->cache) {
+		if (!get_pool_params(cmd, lv_config_profile(lv),
+				     &lp->passed_args, &lp->thin_chunk_size_calc_policy,
+				     &lp->chunk_size, &lp->discards,
+				     &lp->pool_metadata_size, &lp->zero))
 			return_ECMD_FAILED;
 
-		if (!_lvconvert_cache(lv, lp))
+		if (!_lvconvert_pool(cmd, lv, lp))
 			return_ECMD_FAILED;
 
-	} else if (segtype_is_cache_pool(lp->segtype)) {
-		if (!archive(lv->vg))
+		if ((lp->thin && !_lvconvert_thin(cmd, lv, lp)) ||
+		    (lp->cache && !_lvconvert_cache(cmd, lv, lp)))
 			return_ECMD_FAILED;
-
-		if (!_lvconvert_to_pool(cmd, lv, lp))
-			return_ECMD_FAILED;
-
-	} else if (arg_count(cmd, thinpool_ARG)) {
-		if (!archive(lv->vg))
-			return_ECMD_FAILED;
-
-		if (!_lvconvert_to_pool(cmd, lv, lp))
-			return_ECMD_FAILED;
-
 	} else if (segtype_is_raid(lp->segtype) ||
 		   (lv->status & RAID) || lp->merge_mirror) {
 		if (!archive(lv->vg))
@@ -3223,16 +3304,9 @@ static int lvconvert_single(struct cmd_context *cmd, struct lvconvert_params *lp
 		cmd->handles_missing_pvs = 1;
 	}
 
-	lv = get_vg_lock_and_logical_volume(cmd, lp->vg_name, lp->lv_name);
-	if (!lv)
+	if (!(lv = get_vg_lock_and_logical_volume(cmd, lp->vg_name, lp->lv_name)))
 		goto_out;
 
-	if (!get_pool_params(cmd, lv_config_profile(lv),
-			     &lp->passed_args, &lp->thin_chunk_size_calc_policy,
-			     &lp->chunk_size, &lp->discards,
-			     &lp->poolmetadata_size, &lp->zero))
-		goto_bad;
-
 	/*
 	 * lp->pvh holds the list of PVs available for allocation or removal
 	 */
diff --git a/tools/toollib.c b/tools/toollib.c
index b4e02d6..312a76d 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1661,18 +1661,9 @@ int get_pool_params(struct cmd_context *cmd,
 {
 	int cache_pool = 0;
 
-	if (!strcmp("cache-pool", arg_str_value(cmd, type_ARG, "none")))
+	if (!strcmp("cache-pool", arg_str_value(cmd, type_ARG, "")))
 		cache_pool = 1;
 
-	if (!cache_pool && !arg_count(cmd, thinpool_ARG)) {
-		/* Check for arguments that should only go with pools */
-		if (arg_count(cmd, poolmetadata_ARG)) {
-			log_error("'--poolmetadata' argument is only valid when"
-				  " converting to pool LVs.");
-			return_0;
-		}
-	}
-
 	*passed_args = 0;
 	if (!cache_pool && arg_count(cmd, zero_ARG)) {
 		*passed_args |= PASS_ARG_ZERO;
@@ -1706,14 +1697,11 @@ int get_pool_params(struct cmd_context *cmd,
 		return_0;
 
 	if (arg_count(cmd, poolmetadatasize_ARG)) {
-		if (arg_sign_value(cmd, poolmetadatasize_ARG, SIGN_NONE) == SIGN_MINUS) {
-			log_error("Negative pool metadata size is invalid.");
-			return 0;
-		}
 		*passed_args |= PASS_ARG_POOL_METADATA_SIZE;
-	}
-	*pool_metadata_size = arg_uint64_value(cmd, poolmetadatasize_ARG,
-					       UINT64_C(0));
+		*pool_metadata_size = arg_uint64_value(cmd, poolmetadatasize_ARG,
+						       UINT64_C(0));
+	} else if (arg_count(cmd, poolmetadata_ARG))
+		*passed_args |= PASS_ARG_POOL_METADATA_SIZE; /* fixed size */
 
 	return 1;
 }



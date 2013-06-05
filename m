From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:05:02 +0000 (UTC)
Subject: dev-mornfall-lvmcache - lvcreate: update thin validation
Message-ID: <20130605120502.C4C026134E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e5baaf4ac9f2de39558b23606432ebeed483c99a
Commit:        e5baaf4ac9f2de39558b23606432ebeed483c99a
Parent:        e01fbd9d8d310c0b0ddcf58782ac2b871185ddd9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 31 11:02:52 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 31 21:40:07 2013 +0200

lvcreate: update thin validation

Merge duplicate code that was validating lvcreate args
for creation of thin and snapshot.

Keep most of thin checks in _check_thin_parameters().

Update couple error messages.
---
 tools/lvcreate.c |  127 ++++++++++++++++++++----------------------------------
 1 files changed, 47 insertions(+), 80 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 7beaf6c..05f3b13 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -707,7 +707,6 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	struct arg_value_group_list *current_group;
 	const char *segtype_str;
 	const char *tag;
-	unsigned i;
 
 	memset(lp, 0, sizeof(*lp));
 	memset(lcp, 0, sizeof(*lcp));
@@ -719,7 +718,7 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	 */
 	if ((arg_count(cmd, thin_ARG) || arg_count(cmd, thinpool_ARG)) &&
 	    arg_count(cmd,mirrors_ARG)) {
-		log_error("--thin,--thinpool  and --mirrors are incompatible.");
+		log_error("--thin, --thinpool and --mirrors are incompatible.");
 		return 0;
 	}
 
@@ -864,46 +863,30 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	    !_read_raid_params(lp, cmd))
 		return_0;
 
-	if (!lp->create_thin_pool) {
-		if (seg_is_thin(lp)) {
-			static const int _argname[] = {
-				chunksize_ARG, discards_ARG, poolmetadatasize_ARG, zero_ARG
-			};
-			for (i = 0; i < sizeof(_argname)/sizeof(_argname[0]); ++i) {
-				if (arg_count(cmd, _argname[i])) {
-					log_error("%s is only available for thin pool creation.",
-						  arg_long_option_name(_argname[i]));
-					return 0;
-				}
-			}
-		} else if (lp->snapshot) {
-			if (arg_count(cmd, zero_ARG)) {
-				log_error("-Z is incompatible with snapshots.");
-				return 0;
-			}
-			if (arg_sign_value(cmd, chunksize_ARG, SIGN_NONE) == SIGN_MINUS) {
-				log_error("Negative chunk size is invalid.");
-				return 0;
-			}
-			lp->chunk_size = arg_uint_value(cmd, chunksize_ARG, 8);
-			if (lp->chunk_size < 8 || lp->chunk_size > 1024 ||
-			    (lp->chunk_size & (lp->chunk_size - 1))) {
-				log_error("Chunk size must be a power of 2 in the "
-					  "range 4K to 512K.");
-				return 0;
-			}
-			log_verbose("Setting chunksize to %s.", display_size(cmd, lp->chunk_size));
-
-			if (!(lp->segtype = get_segtype_from_string(cmd, "snapshot")))
-				return_0;
-		} else if (arg_count(cmd, chunksize_ARG)) {
-			log_error("--chunksize is only available with snapshots and thin pools.");
+	if (lp->snapshot && (lp->extents || lcp->size)) {
+		if (arg_sign_value(cmd, chunksize_ARG, SIGN_NONE) == SIGN_MINUS) {
+			log_error("Negative chunk size is invalid.");
+			return 0;
+		}
+		lp->chunk_size = arg_uint_value(cmd, chunksize_ARG, 8);
+		if (lp->chunk_size < 8 || lp->chunk_size > 1024 ||
+		    (lp->chunk_size & (lp->chunk_size - 1))) {
+			log_error("Chunk size must be a power of 2 in the "
+				  "range 4K to 512K.");
 			return 0;
 		}
+		log_verbose("Setting chunksize to %s.", display_size(cmd, lp->chunk_size));
+
+		if (!(lp->segtype = get_segtype_from_string(cmd, "snapshot")))
+			return_0;
+	} else if (!lp->create_thin_pool && arg_count(cmd, chunksize_ARG)) {
+		log_error("--chunksize is only available with snapshots and thin pools.");
+		return 0;
 	}
+
 	if (lp->mirrors > DEFAULT_MIRROR_MAX_IMAGES) {
-		log_error("Only up to %d images in mirror supported currently.",
-			  DEFAULT_MIRROR_MAX_IMAGES);
+		log_error("Only up to " DM_TO_STRING(DEFAULT_MIRROR_MAX_IMAGES)
+			  " images in mirror supported currently.");
 		return 0;
 	}
 
@@ -946,6 +929,7 @@ static int _check_thin_parameters(struct volume_group *vg, struct lvcreate_param
 				  struct lvcreate_cmdline_params *lcp)
 {
 	struct lv_list *lvl;
+	unsigned i;
 
 	if (!lp->thin && !lp->create_thin_pool && !lp->snapshot) {
 		log_error("Please specify device size(s).");
@@ -953,14 +937,28 @@ static int _check_thin_parameters(struct volume_group *vg, struct lvcreate_param
 	}
 
 	if (lp->thin && lp->snapshot) {
-		log_error("Please either creater snapshot or thin volume.");
+		log_error("Please either create snapshot or thin volume.");
 		return 0;
 	}
 
-	if (lp->thin && !lp->create_thin_pool) {
-		if (arg_count(vg->cmd, chunksize_ARG)) {
-			log_error("Only specify --chunksize when originally creating the thin pool.");
-			return 0;
+	if (!lp->create_thin_pool) {
+		static const int _argname[] = {
+			alloc_ARG,
+			chunksize_ARG,
+			contiguous_ARG,
+			discards_ARG,
+			poolmetadatasize_ARG,
+			stripes_ARG,
+			stripesize_ARG,
+			zero_ARG
+		};
+
+		for (i = 0; i < sizeof(_argname)/sizeof(_argname[0]); ++i) {
+			if (arg_count(vg->cmd, _argname[i])) {
+				log_error("%s is only available for thin pool creation.",
+					  arg_long_option_name(_argname[i]));
+				return 0;
+			}
 		}
 
 		if (lcp->pv_count) {
@@ -968,53 +966,22 @@ static int _check_thin_parameters(struct volume_group *vg, struct lvcreate_param
 			return 0;
 		}
 
-		if (arg_count(vg->cmd, alloc_ARG)) {
-			log_error("--alloc may only be specified when allocating the thin pool.");
-			return 0;
-		}
-
-		if (arg_count(vg->cmd, poolmetadatasize_ARG)) {
-			log_error("--poolmetadatasize may only be specified when allocating the thin pool.");
-			return 0;
-		}
-
-		if (arg_count(vg->cmd, stripesize_ARG)) {
-			log_error("--stripesize may only be specified when allocating the thin pool.");
-			return 0;
-		}
-
-		if (arg_count(vg->cmd, stripes_ARG)) {
-			log_error("--stripes may only be specified when allocating the thin pool.");
+		if (!lp->pool) {
+			log_error("Please specify name of existing thin pool.");
 			return 0;
 		}
 
-		if (arg_count(vg->cmd, contiguous_ARG)) {
-			log_error("--contiguous may only be specified when allocating the thin pool.");
-			return 0;
-		}
-
-		if (arg_count(vg->cmd, zero_ARG)) {
-			log_error("--zero may only be specified when allocating the thin pool.");
-			return 0;
-		}
-	}
-
-	if (lp->create_thin_pool && lp->pool) {
-		if (find_lv_in_vg(vg, lp->pool)) {
-			log_error("Pool %s already exists in Volume group %s.", lp->pool, vg->name);
-			return 0;
-		}
-	} else if (lp->pool) {
 		if (!(lvl = find_lv_in_vg(vg, lp->pool))) {
-			log_error("Pool %s not found in Volume group %s.", lp->pool, vg->name);
+			log_error("Thin pool %s not found in Volume group %s.", lp->pool, vg->name);
 			return 0;
 		}
+
 		if (!lv_is_thin_pool(lvl->lv)) {
 			log_error("Logical volume %s is not a thin pool.", lp->pool);
 			return 0;
 		}
-	} else if (!lp->create_thin_pool) {
-		log_error("Please specify name of existing pool.");
+	} else if (lp->pool && find_lv_in_vg(vg, lp->pool)) {
+		log_error("Thin pool %s already exists in Volume group %s.", lp->pool, vg->name);
 		return 0;
 	}
 



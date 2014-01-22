From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 22 Jan 2014 16:31:35 +0000 (UTC)
Subject: master - Misc: Change name of lvcreate_params field - s/create_thin_pool/create_pool/
Message-ID: <20140122163135.1CE216138D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=998af1a4fbf82cb9d5a2ba0c3c547ede39466a28
Commit:        998af1a4fbf82cb9d5a2ba0c3c547ede39466a28
Parent:        5590448c320eb76789110546cdea47dd1d7a97b3
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Jan 22 10:30:55 2014 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Jan 22 10:30:55 2014 -0600

Misc: Change name of lvcreate_params field - s/create_thin_pool/create_pool/

In preparation for other segment types that create and use "pools", we
s/create_thin_pool/create_pool/.  This way it is not awkward when creating
a cachepool, for example, to use "create_thin_pool".
---
 lib/metadata/lv_manip.c          |    2 +-
 lib/metadata/metadata-exported.h |    2 +-
 liblvm/lvm_lv.c                  |    2 +-
 tools/lvcreate.c                 |   36 ++++++++++++++++++------------------
 4 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index f45c89f..07ee764 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6227,7 +6227,7 @@ struct logical_volume *lv_create_single(struct volume_group *vg,
 	struct logical_volume *lv;
 
 	/* Create thin pool first if necessary */
-	if (lp->create_thin_pool) {
+	if (lp->create_pool) {
 		if (!seg_is_thin_pool(lp) &&
 		    !(lp->segtype = get_segtype_from_string(vg->cmd, "thin-pool")))
 			return_0;
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 8e36891..52a1c4c 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -731,7 +731,7 @@ struct lvcreate_params {
 	/* flags */
 	int snapshot; /* snap */
 	int thin; /* thin */
-	int create_thin_pool; /* thin */
+	int create_pool; /* thin */
 	int zero; /* all */
 	int wipe_signatures; /* all */
 	int major; /* all */
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 3b0e18d..9f3a9c6 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -507,7 +507,7 @@ static int _lv_set_pool_params(struct lvcreate_params *lp,
 
 	lp->pool = pool;
 
-	lp->create_thin_pool = 1;
+	lp->create_pool = 1;
 	lp->segtype = get_segtype_from_string(vg->cmd, "thin-pool");
 	lp->stripes = 1;
 
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index d0ca7bc..c8206ca 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -333,7 +333,7 @@ static int _update_extents_params(struct volume_group *vg,
 		lp->extents = lp->extents - size_rest;
 	}
 
-	if (lp->create_thin_pool) {
+	if (lp->create_pool) {
 		if (!update_pool_params(vg, lp->target_attr, lp->passed_args,
 					lp->extents, vg->extent_size,
 					&lp->thin_chunk_size_calc_policy,
@@ -392,9 +392,9 @@ static int _read_size_params(struct lvcreate_params *lp,
 
 	/* If size/extents given with thin, then we are creating a thin pool */
 	if (seg_is_thin(lp) && (arg_count(cmd, size_ARG) || arg_count(cmd, extents_ARG)))
-		lp->create_thin_pool = 1;
+		lp->create_pool = 1;
 
-	if (!lp->create_thin_pool && arg_count(cmd, poolmetadatasize_ARG)) {
+	if (!lp->create_pool && arg_count(cmd, poolmetadatasize_ARG)) {
 		log_error("--poolmetadatasize may only be specified when allocating the thin pool.");
 		return 0;
 	}
@@ -665,7 +665,7 @@ static int _read_activation_params(struct lvcreate_params *lp, struct cmd_contex
 
 	/* Persistent minor */
 	if (arg_count(cmd, persistent_ARG)) {
-		if (lp->create_thin_pool && !lp->thin) {
+		if (lp->create_pool && !lp->thin) {
 			log_error("--persistent is not permitted when creating a thin pool device.");
 			return 0;
 		}
@@ -779,7 +779,7 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 			log_error("Snapshots are incompatible with thin_pool segment_type.");
 			return 0;
 		}
-		lp->create_thin_pool = 1;
+		lp->create_pool = 1;
 	}
 
 	if (seg_is_thin_volume(lp))
@@ -895,7 +895,7 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	if (!_lvcreate_name_params(lp, cmd, &argc, &argv) ||
 	    !_read_size_params(lp, lcp, cmd) ||
 	    !get_stripe_params(cmd, &lp->stripes, &lp->stripe_size) ||
-	    (lp->create_thin_pool &&
+	    (lp->create_pool &&
 	     !get_pool_params(cmd, NULL, &lp->passed_args,
 			      &lp->thin_chunk_size_calc_policy,
 			      &lp->chunk_size, &lp->discards,
@@ -920,12 +920,12 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 
 		if (!(lp->segtype = get_segtype_from_string(cmd, "snapshot")))
 			return_0;
-	} else if (!lp->create_thin_pool && arg_count(cmd, chunksize_ARG)) {
+	} else if (!lp->create_pool && arg_count(cmd, chunksize_ARG)) {
 		log_error("--chunksize is only available with snapshots and thin pools.");
 		return 0;
 	}
 
-	if (lp->create_thin_pool) {
+	if (lp->create_pool) {
 		/* TODO: add lvm.conf default y|n */
 		lp->poolmetadataspare = arg_int_value(cmd, poolmetadataspare_ARG,
 						      DEFAULT_POOL_METADATA_SPARE);
@@ -974,7 +974,7 @@ static int _check_thin_parameters(struct volume_group *vg, struct lvcreate_param
 	struct lv_list *lvl;
 	unsigned i;
 
-	if (!lp->thin && !lp->create_thin_pool && !lp->snapshot) {
+	if (!lp->thin && !lp->create_pool && !lp->snapshot) {
 		log_error("Please specify device size(s).");
 		return 0;
 	}
@@ -984,7 +984,7 @@ static int _check_thin_parameters(struct volume_group *vg, struct lvcreate_param
 		return 0;
 	}
 
-	if (!lp->create_thin_pool) {
+	if (!lp->create_pool) {
 		static const int _argname[] = {
 			alloc_ARG,
 			chunksize_ARG,
@@ -1060,14 +1060,14 @@ static int _validate_internal_thin_processing(const struct lvcreate_params *lp)
 
 	/*
 	   The final state should be one of:
-	   thin  create_thin_pool  snapshot   origin   pool  
-	     1          1             0          0      y/n    - create new pool and a thin LV in it
-	     1          0             0          0      y      - create new thin LV in existing pool
-	     0          1             0          0      y/n    - create new pool only
-	     1          0             1          1      y      - create thin snapshot of existing thin LV
+	   thin  create_pool  snapshot   origin   pool
+	     1        1           0         0      y/n    - create new pool and a thin LV in it
+	     1        0           0         0      y      - create new thin LV in existing pool
+	     0        1           0         0      y/n    - create new pool only
+	     1        0           1         1      y      - create thin snapshot of existing thin LV
 	*/
 
-	if (!lp->create_thin_pool && !lp->pool) {
+	if (!lp->create_pool && !lp->pool) {
 		log_error(INTERNAL_ERROR "--thinpool not identified.");
 		r = 0;
 	}
@@ -1077,7 +1077,7 @@ static int _validate_internal_thin_processing(const struct lvcreate_params *lp)
 		r = 0;
 	}
 
-	if (!lp->thin && !lp->create_thin_pool && !lp->snapshot) {
+	if (!lp->thin && !lp->create_pool && !lp->snapshot) {
 		log_error(INTERNAL_ERROR "Failed to identify what type of thin target to use.");
 		r = 0;
 	}
@@ -1126,7 +1126,7 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 	if (seg_is_thin(&lp) && !_validate_internal_thin_processing(&lp))
 		goto_out;
 
-	if (lp.create_thin_pool) {
+	if (lp.create_pool) {
 		if (!handle_pool_metadata_spare(vg, lp.poolmetadataextents,
 						lp.pvh, lp.poolmetadataspare))
 			goto_out;



From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:32:44 +0000 (UTC)
Subject: master - thin: lvcreate improve check of thin params
Message-ID: <20141006133244.F4096611CF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1ef660be460a6dcd876f8077bac9478aca6df3e5
Commit:        1ef660be460a6dcd876f8077bac9478aca6df3e5
Parent:        487723e0dfbaf23236e7ea1415497a8bb394440d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 6 13:13:01 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 14:53:16 2014 +0200

thin: lvcreate improve check of thin params

Use arg_from_list_is_set()
Resolve pool_lv at one single place.
Replace use of find_lv_in_vg() with find_lv().
---
 tools/lvcreate.c |   47 +++++++++++++++++++++--------------------------
 1 files changed, 21 insertions(+), 26 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index fe405ea..9e2c85c 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1059,8 +1059,7 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 static int _check_thin_parameters(struct volume_group *vg, struct lvcreate_params *lp,
 				  struct lvcreate_cmdline_params *lcp)
 {
-	struct lv_list *lvl;
-	unsigned i;
+	struct logical_volume *pool_lv = NULL;
 
 	if (!lp->thin && !lp->create_pool && !lp->snapshot) {
 		log_error("Please specify device size(s).");
@@ -1072,26 +1071,22 @@ static int _check_thin_parameters(struct volume_group *vg, struct lvcreate_param
 		return 0;
 	}
 
+	if (lp->pool)
+		pool_lv = find_lv(vg, lp->pool);
+
 	if (!lp->create_pool) {
-		static const int _argname[] = {
-			alloc_ARG,
-			chunksize_ARG,
-			contiguous_ARG,
-			discards_ARG,
-			poolmetadatasize_ARG,
-			poolmetadataspare_ARG,
-			stripes_ARG,
-			stripesize_ARG,
-			zero_ARG
-		};
-
-		for (i = 0; i < DM_ARRAY_SIZE(_argname); ++i) {
-			if (arg_count(vg->cmd, _argname[i])) {
-				log_error("%s is only available for thin pool creation.",
-					  arg_long_option_name(_argname[i]));
-				return 0;
-			}
-		}
+		if (arg_from_list_is_set(vg->cmd, "is only available with thin pool creation",
+					 alloc_ARG,
+					 chunksize_ARG,
+					 contiguous_ARG,
+					 discards_ARG,
+					 poolmetadatasize_ARG,
+					 poolmetadataspare_ARG,
+					 stripes_ARG,
+					 stripesize_ARG,
+					 zero_ARG,
+					 -1))
+			return_0;
 
 		if (lcp->pv_count) {
 			log_error("Only specify Physical volumes when allocating the thin pool.");
@@ -1103,17 +1098,17 @@ static int _check_thin_parameters(struct volume_group *vg, struct lvcreate_param
 			return 0;
 		}
 
-		if (!(lvl = find_lv_in_vg(vg, lp->pool))) {
+		if (!pool_lv) {
 			log_error("Thin pool %s not found in Volume group %s.", lp->pool, vg->name);
 			return 0;
 		}
 
-		if (!lv_is_thin_pool(lvl->lv)) {
-			log_error("Logical volume %s is not a thin pool.", lp->pool);
+		if (!lv_is_thin_pool(pool_lv)) {
+			log_error("Logical volume %s is not a thin pool.", display_lvname(pool_lv));
 			return 0;
 		}
-	} else if (lp->pool && find_lv_in_vg(vg, lp->pool)) {
-		log_error("Thin pool %s already exists in Volume group %s.", lp->pool, vg->name);
+	} else if (pool_lv) {
+		log_error("Logical volume %s already exists in Volume group %s.", lp->pool, vg->name);
 		return 0;
 	}
 



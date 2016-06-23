From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Jun 2016 13:01:53 +0000 (UTC)
Subject: master - lvresize: do not pass struct cmd
Message-ID: <20160623130153.AE3E5608F4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d44e653fe184a6c179a13998b41e13f737d4926c
Commit:        d44e653fe184a6c179a13998b41e13f737d4926c
Parent:        5013999c8bd3f2b455ab6fe436df4884da6ebaf5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 14 15:32:21 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 23 14:57:09 2016 +0200

lvresize: do not pass struct cmd

Use common API design and pass just LV pointer to lv_manip.c functions.
Read cmd struct via    lv->vg->cmd when needed.
Also do not try to return EINVALID_CMD_LINE error when we
have already openned VG - this error code can only be returned before
locking VG.
---
 lib/locking/lvmlockd.c           |    3 +-
 lib/metadata/lv_manip.c          |   42 ++++++++++++++++++++++---------------
 lib/metadata/metadata-exported.h |    7 ++---
 liblvm/lvm_lv.c                  |    3 +-
 tools/lvresize.c                 |    7 +-----
 5 files changed, 31 insertions(+), 31 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index e2b3e25..e865c10 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -376,8 +376,7 @@ static int _extend_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg,
 		.sizeargs = 1,
 	};
 
-	if (!lv_resize_prepare(cmd, lv, &lp, &vg->pvs) ||
-	    !lv_resize(cmd, lv, &lp, &vg->pvs)) {
+	if (!lv_resize(lv, &lp, &vg->pvs)) {
 		log_error("Extend LV %s to size %s failed.",
 			  display_lvname(lv), display_size(cmd, lp.size));
 		return 0;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 487d7f9..e42a73c 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4336,10 +4336,10 @@ static int _validate_stripesize(const struct volume_group *vg,
 	return 1;
 }
 
-static int _request_confirmation(const struct volume_group *vg,
-				 const struct logical_volume *lv,
+static int _request_confirmation(const struct logical_volume *lv,
 				 const struct lvresize_params *lp)
 {
+	const struct volume_group *vg = lv->vg;
 	struct lvinfo info = { 0 };
 
 	if (!lv_info(vg->cmd, lv, 0, &info, 1, 0) && driver_version(NULL, 0)) {
@@ -4766,10 +4766,11 @@ static int _lvresize_adjust_size(struct volume_group *vg,
 /*
  * If percent options were used, convert them into actual numbers of extents.
  */
-static int _lvresize_extents_from_percent(struct logical_volume *lv, struct lvresize_params *lp,
+static int _lvresize_extents_from_percent(const struct logical_volume *lv,
+					  struct lvresize_params *lp,
 					  struct dm_list *pvh)
 {
-	struct volume_group *vg = lv->vg;
+	const struct volume_group *vg = lv->vg;
 	uint32_t pv_extent_count;
 	uint32_t old_extents = lp->extents;
 
@@ -4859,10 +4860,12 @@ static uint32_t _lv_pe_count(struct logical_volume *lv)
 }
 
 /* FIXME Avoid having variables like lp->extents mean different things at different places */
-static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volume *lv, 
-				    struct lvresize_params *lp, struct dm_list *pvh)
+static int _lvresize_adjust_extents(struct logical_volume *lv,
+				    struct lvresize_params *lp,
+				    struct dm_list *pvh)
 {
 	struct volume_group *vg = lv->vg;
+	struct cmd_context *cmd = vg->cmd;
 	uint32_t logical_extents_used = 0;
 	uint32_t physical_extents_used = 0;
 	uint32_t seg_stripes = 0, seg_stripesize = 0;
@@ -5173,7 +5176,7 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 }
 
 static int _lvresize_check_type(const struct logical_volume *lv,
-				struct lvresize_params *lp)
+				const struct lvresize_params *lp)
 {
 	if (lv_is_origin(lv)) {
 		if (lp->resize == LV_REDUCE) {
@@ -5210,12 +5213,12 @@ static int _lvresize_check_type(const struct logical_volume *lv,
 	return 1;
 }
 
-static struct logical_volume *_lvresize_volume(struct cmd_context *cmd,
-					       struct logical_volume *lv,
+static struct logical_volume *_lvresize_volume(struct logical_volume *lv,
 					       struct lvresize_params *lp,
 					       struct dm_list *pvh)
 {
 	struct volume_group *vg = lv->vg;
+	struct cmd_context *cmd = vg->cmd;
 	struct logical_volume *lock_lv = NULL;
 	struct lv_segment *seg = NULL;
 	uint32_t old_extents;
@@ -5235,7 +5238,7 @@ static struct logical_volume *_lvresize_volume(struct cmd_context *cmd,
 
 	/* Request confirmation before operations that are often mistakes. */
 	if ((lp->resizefs || (lp->resize == LV_REDUCE)) &&
-	    !_request_confirmation(vg, lv, lp))
+	    !_request_confirmation(lv, lp))
 		return_NULL;
 
 	if (lp->resizefs) {
@@ -5304,8 +5307,9 @@ static struct logical_volume *_lvresize_volume(struct cmd_context *cmd,
 	return lock_lv;
 }
 
-int lv_resize_prepare(struct cmd_context *cmd, struct logical_volume *lv,
-		      struct lvresize_params *lp, struct dm_list *pvh)
+static int _lvresize_prepare(struct logical_volume *lv,
+			     struct lvresize_params *lp,
+			     struct dm_list *pvh)
 {
 	if (!_lvresize_check_lv(lv, lp))
 		return_0;
@@ -5319,7 +5323,7 @@ int lv_resize_prepare(struct cmd_context *cmd, struct logical_volume *lv,
 	else if (lp->extents && !_lvresize_extents_from_percent(lv, lp, pvh))
 		return_0;
 
-	if (lp->extents && !_lvresize_adjust_extents(cmd, lv, lp, pvh))
+	if (lp->extents && !_lvresize_adjust_extents(lv, lp, pvh))
 		return_0;
 
 	if ((lp->extents == lv->le_count) && lp->use_policies) {
@@ -5338,14 +5342,18 @@ int lv_resize_prepare(struct cmd_context *cmd, struct logical_volume *lv,
 	return 1;
 }
 
-/* lv_resize_prepare MUST be called before this */
-int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
-	      struct lvresize_params *lp, struct dm_list *pvh)
+int lv_resize(struct logical_volume *lv,
+	      struct lvresize_params *lp,
+	      struct dm_list *pvh)
 {
 	struct volume_group *vg = lv->vg;
+	struct cmd_context *cmd = vg->cmd;
 	struct logical_volume *lock_lv = NULL;
 	int inactive = 0;
 
+	if (!_lvresize_prepare(lv, lp, pvh))
+		return_0;
+
 	if (lv_is_cache_type(lv)) {
 		log_error("Unable to resize logical volumes of cache type.");
 		return 0;
@@ -5359,7 +5367,7 @@ int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 		return_0;
 
 	if (lp->extents &&
-	    !(lock_lv = _lvresize_volume(cmd, lv, lp, pvh)))
+	    !(lock_lv = _lvresize_volume(lv, lp, pvh)))
 		return_0;
 
 	if (lp->poolmetadataextents) {
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index ddf51fc..d2c9db2 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -693,10 +693,9 @@ int vgs_are_compatible(struct cmd_context *cmd,
 		       struct volume_group *vg_to);
 uint32_t vg_lock_newname(struct cmd_context *cmd, const char *vgname);
 
-int lv_resize_prepare(struct cmd_context *cmd, struct logical_volume *lv,
-		      struct lvresize_params *lp, struct dm_list *pvh);
-int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
-	      struct lvresize_params *lp, struct dm_list *pvh);
+int lv_resize(struct logical_volume *lv,
+	      struct lvresize_params *lp,
+	      struct dm_list *pvh);
 
 /*
  * Return a handle to VG metadata.
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 467a9d0..d732ed7 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -467,8 +467,7 @@ int lvm_lv_resize(const lv_t lv, uint64_t new_size)
 	};
 	struct saved_env e = store_user_env(lv->vg->cmd);
 
-	if (!lv_resize_prepare(lv->vg->cmd, lv, &lp, &lv->vg->pvs) ||
-	    !lv_resize(lv->vg->cmd, lv, &lp, &lv->vg->pvs)) {
+	if (!lv_resize(lv, &lp, &lv->vg->pvs)) {
 		/* FIXME Improve msg */
 		log_error("LV resize failed.");
 		/* FIXME Define consistent symbolic return codes */
diff --git a/tools/lvresize.c b/tools/lvresize.c
index af2b3ac..1258f14 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -175,12 +175,7 @@ static int _lvresize_single(struct cmd_context *cmd, const char *vg_name,
 	if (!(pvh = lp->argc ? create_pv_list(cmd->mem, vg, lp->argc, lp->argv, 1) : &vg->pvs))
 		goto_out;
 
-	if (!lv_resize_prepare(cmd, lv, lp, pvh)) {
-		ret = EINVALID_CMD_LINE;
-		goto_out;
-	}
-
-	if (!lv_resize(cmd, lv, lp, pvh))
+	if (!lv_resize(lv, lp, pvh))
 		goto_out;
 
 	ret = ECMD_PROCESSED;



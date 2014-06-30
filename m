From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 30 Jun 2014 10:25:23 +0000 (UTC)
Subject: master - cleanup: ignore vg_name in /lib
Message-ID: <20140630102523.E7EA96030A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=13fb02ff1fe5ebc47f315774eac8a31e1b150550
Commit:        13fb02ff1fe5ebc47f315774eac8a31e1b150550
Parent:        667f93b7d95d23a45cc5040043c9117de83f7336
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 30 12:02:05 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 30 12:21:36 2014 +0200

cleanup: ignore vg_name in /lib

Since  vg_name inside /lib function has already been ignored mostly
except for a few debug prints - make it and official internal API
feature.

vg_name is used only in  /tools while the VG is not yet openned,
and when  lvresize/lvcreate /lib function is called with VG pointer
already being used, then vg_name becomes irrelevant (it's not been
validated anyway).

So any internal user of lvcreate_params and lvresize_params does not
need to set vg_name pointer and may leave it NULL.
---
 lib/metadata/lv_manip.c          |   10 +++++-----
 lib/metadata/metadata-exported.h |    4 ++--
 lib/metadata/thin_manip.c        |    2 --
 liblvm/lvm_lv.c                  |   24 ++++++++++--------------
 tools/lvconvert.c                |    1 -
 5 files changed, 17 insertions(+), 24 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 9581942..d35a244 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3658,8 +3658,8 @@ static int _fsadm_cmd(struct cmd_context *cmd,
 	if (status)
 		*status = -1;
 
-	if (dm_snprintf(lv_path, PATH_MAX, "%s%s/%s", cmd->dev_dir, lp->vg_name,
-			lp->lv_name) < 0) {
+	if (dm_snprintf(lv_path, sizeof(lv_path), "%s%s/%s", cmd->dev_dir,
+			vg->name, lp->lv_name) < 0) {
 		log_error("Couldn't create LV path for %s", lp->lv_name);
 		return 0;
 	}
@@ -3667,7 +3667,7 @@ static int _fsadm_cmd(struct cmd_context *cmd,
 	argv[i++] = lv_path;
 
 	if (fcmd == FSADM_CMD_RESIZE) {
-		if (dm_snprintf(size_buf, SIZE_BUF, "%" PRIu64 "K",
+		if (dm_snprintf(size_buf, sizeof(size_buf), "%" PRIu64 "K",
 				(uint64_t) lp->extents * (vg->extent_size / 2)) < 0) {
 			log_error("Couldn't generate new LV size string");
 			return 0;
@@ -3713,7 +3713,7 @@ static int _adjust_policy_params(struct cmd_context *cmd,
 		    (percent > policy_threshold)) {
 			if (!thin_pool_feature_supported(lv, THIN_FEATURE_METADATA_RESIZE)) {
 				log_error_once("Online metadata resize for %s/%s is not supported.",
-					       lp->vg_name, lp->lv_name);
+					       lv->vg->name, lv->name);
 				return 0;
 			}
 			lp->poolmetadatasize = (first_seg(lv)->metadata_lv->size *
@@ -6015,7 +6015,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 
 	if (new_lv_name && find_lv_in_vg(vg, new_lv_name)) {
 		log_error("Logical volume \"%s\" already exists in "
-			  "volume group \"%s\"", new_lv_name, lp->vg_name);
+			  "volume group \"%s\"", new_lv_name, vg->name);
 		return NULL;
 	}
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index eece882..85ea944 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -473,7 +473,7 @@ struct pvcreate_params {
 };
 
 struct lvresize_params {
-	const char *vg_name;
+	const char *vg_name; /* only-used when VG is not yet opened (in /tools) */
 	const char *lv_name;
 
 	uint32_t stripes;
@@ -782,7 +782,7 @@ struct lvcreate_params {
 
 	const char *origin; /* snap */
 	const char *pool;   /* thin */
-	const char *vg_name; /* all */
+	const char *vg_name; /* only-used when VG is not yet opened (in /tools) */
 	const char *lv_name; /* all */
 
 	/* Keep args given by the user on command line */
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 1000680..b2ebaa1 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -559,7 +559,6 @@ struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
 		.read_ahead = read_ahead,
 		.stripe_size = stripe_size,
 		.stripes = stripes,
-		.vg_name = pool_lv->vg->name,
 		.zero = 1,
 	};
 
@@ -600,7 +599,6 @@ static struct logical_volume *_alloc_pool_metadata_spare(struct volume_group *vg
 		.pvh = pvh ? : &vg->pvs,
 		.read_ahead = DM_READ_AHEAD_AUTO,
 		.stripes = 1,
-		.vg_name = vg->name,
 		.zero = 1,
 		.temporary = 1,
 	};
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index d89e8ae..89d0e92 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -194,7 +194,6 @@ static void _lv_set_default_params(struct lvcreate_params *lp,
 	lp->major = -1;
 	lp->minor = -1;
 	lp->activate = CHANGE_AY;
-	lp->vg_name = vg->name;
 	lp->lv_name = lvname; /* FIXME: check this for safety */
 	lp->pvh = &vg->pvs;
 
@@ -458,19 +457,16 @@ int lvm_lv_rename(lv_t lv, const char *new_name)
 int lvm_lv_resize(const lv_t lv, uint64_t new_size)
 {
 	int rc = 0;
-	struct lvresize_params lp = { 0 };
-	struct saved_env e = { 0 };
-
-	lp.vg_name = lv->vg->name;
-	lp.lv_name = lv->name;
-	lp.sign = SIGN_NONE;
-	lp.percent = PERCENT_NONE;
-	lp.resize = LV_ANY;
-	lp.size = new_size >> SECTOR_SHIFT;
-	lp.ac_force = 1;	/* Assume the user has a good backup? */
-	lp.sizeargs = 1;
-
-	e = store_user_env(lv->vg->cmd);
+	struct lvresize_params lp = {
+		.lv_name = lv->name,
+		.sign = SIGN_NONE,
+		.percent = PERCENT_NONE,
+		.resize = LV_ANY,
+		.size = new_size >> SECTOR_SHIFT,
+		.ac_force = 1,	/* Assume the user has a good backup? */
+		.sizeargs = 1,
+	};
+	struct saved_env e = store_user_env(lv->vg->cmd);
 
 	if (!lv_resize_prepare(lv->vg->cmd, lv, &lp, &lv->vg->pvs) ||
 	    !lv_resize(lv->vg->cmd, lv, &lp, &lv->vg->pvs)) {
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 9f2d114..d0555b3 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2522,7 +2522,6 @@ static int _lvconvert_thinpool_external(struct cmd_context *cmd,
 		.pvh = &vg->pvs,
 		.read_ahead = DM_READ_AHEAD_AUTO,
 		.stripes = 1,
-		.vg_name = vg->name,
 		.voriginextents = external_lv->le_count,
 		.voriginsize = external_lv->size,
 	};



From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 22 Jul 2013 10:42:14 +0000 (UTC)
Subject: master - liblvm: check extents_from_size
Message-ID: <20130722104214.1B3EB61478@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=90bdbcc2017cf9bc868aaa95616fcdb3de19b96f
Commit:        90bdbcc2017cf9bc868aaa95616fcdb3de19b96f
Parent:        d4ad728610db1751af1eab2c8c7d6130a3742394
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 19 15:35:04 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 22 12:41:21 2013 +0200

liblvm: check extents_from_size

Since the function may fail, check for error.
(in release fix)
---
 liblvm/lvm_lv.c |   34 ++++++++++++++++++++++------------
 1 files changed, 22 insertions(+), 12 deletions(-)

diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 27a0f07..f416195 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -368,7 +368,7 @@ lv_t lvm_lv_snapshot(const lv_t lv, const char *snap_name,
 }
 
 /* Set defaults for thin pool specific LV parameters */
-static void _lv_set_pool_params(struct lvcreate_params *lp,
+static int _lv_set_pool_params(struct lvcreate_params *lp,
 				vg_t vg, const char *pool,
 				uint64_t extents, uint64_t meta_size)
 {
@@ -396,9 +396,12 @@ static void _lv_set_pool_params(struct lvcreate_params *lp,
 		lp->poolmetadatasize +=
 			vg->extent_size - lp->poolmetadatasize % vg->extent_size;
 
-	lp->poolmetadataextents =
-		extents_from_size(vg->cmd, lp->poolmetadatasize / SECTOR_SIZE,
-						   vg->extent_size);
+	if (!(lp->poolmetadataextents =
+	      extents_from_size(vg->cmd, lp->poolmetadatasize / SECTOR_SIZE,
+				vg->extent_size)))
+		return_0;
+
+	return 1;
 }
 
 lv_create_params_t lvm_lv_params_create_thin_pool(vg_t vg,
@@ -453,7 +456,8 @@ lv_create_params_t lvm_lv_params_create_thin_pool(vg_t vg,
 			return NULL;
 		}
 
-		_lv_set_pool_params(&lvcp->lvp, vg, pool_name, extents, meta_size);
+		if (!_lv_set_pool_params(&lvcp->lvp, vg, pool_name, extents, meta_size))
+			return_NULL;
 
 		lvcp->magic = LV_CREATE_PARAMS_MAGIC;
 	}
@@ -461,7 +465,7 @@ lv_create_params_t lvm_lv_params_create_thin_pool(vg_t vg,
 }
 
 /* Set defaults for thin LV specific parameters */
-static void _lv_set_thin_params(struct lvcreate_params *lp,
+static int _lv_set_thin_params(struct lvcreate_params *lp,
 				vg_t vg, const char *pool,
 				const char *lvname,
 				uint64_t extents)
@@ -473,15 +477,18 @@ static void _lv_set_thin_params(struct lvcreate_params *lp,
 	lp->segtype = get_segtype_from_string(vg->cmd, "thin");
 
 	lp->voriginsize = extents * vg->extent_size;
-	lp->voriginextents = extents_from_size(vg->cmd, lp->voriginsize,
-						   vg->extent_size);
+	if (!(lp->voriginextents = extents_from_size(vg->cmd, lp->voriginsize,
+						     vg->extent_size)))
+		return_0;
 
 	lp->stripes = 1;
+
+	return 1;
 }
 
 lv_create_params_t lvm_lv_params_create_snapshot(const lv_t lv,
-													const char *snap_name,
-													uint64_t max_snap_size)
+						 const char *snap_name,
+						 uint64_t max_snap_size)
 {
 	uint64_t size = 0;
 	uint64_t extents = 0;
@@ -501,7 +508,8 @@ lv_create_params_t lvm_lv_params_create_snapshot(const lv_t lv,
 
 	if (max_snap_size) {
 		size = max_snap_size >> SECTOR_SHIFT;
-		extents = extents_from_size(lv->vg->cmd, size, lv->vg->extent_size);
+		if (!(extents = extents_from_size(lv->vg->cmd, size, lv->vg->extent_size)))
+			return_NULL;
 	}
 
 	if (!size && !lv_is_thin_volume(lv) ) {
@@ -572,7 +580,9 @@ lv_create_params_t lvm_lv_params_create_thin(const vg_t vg, const char *pool_nam
 	lvcp = dm_pool_zalloc(vg->vgmem, sizeof (struct lvm_lv_create_params));
 	if (lvcp) {
 		lvcp->vg = vg;
-		_lv_set_thin_params(&lvcp->lvp, vg, pool_name, lvname, extents);
+		if (!_lv_set_thin_params(&lvcp->lvp, vg, pool_name, lvname, extents))
+			return_NULL;
+
 		lvcp->magic = LV_CREATE_PARAMS_MAGIC;
 	}
 



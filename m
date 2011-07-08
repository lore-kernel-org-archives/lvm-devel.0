From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  8 Jul 2011 17:52:25 +0200
Subject: [PATCH 3/3] Use dm_pool locking
In-Reply-To: <cover.1310140154.git.zkabelac@redhat.com>
References: <cover.1310140154.git.zkabelac@redhat.com>
Message-ID: <5c101c3646a6c5f6b7af1003ecc17999dc40e38e.1310140154.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add debug pool locking functionality. So the command could check,
whether the memory in the pool was not modified.

For lv_postoder() instead of unlocking and locking for every changed
struct status member do it once when entering and leaving function.
Currently lv_postoder() does not modify other part of vg structure
then status flags of each LV with flags that are reverted back to
its original state after fucntion exit.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/cache/lvmcache.c    |    7 +++++++
 lib/metadata/metadata.c |   16 ++++++++++++++++
 2 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 275087f..19bae10 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -701,6 +701,9 @@ struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted)
 	vginfo->vg_ref_count = 2; /* Keep 1 reference for lvmcache */
 	vginfo->vg_use_count = 1;
 
+	if (!dm_pool_lock(vg->vgmem, 1))
+		goto_bad;
+
 out:
 	log_debug("Using cached %smetadata for VG %s.",
 		  vginfo->precommitted ? "pre-committed" : "", vginfo->vgname);
@@ -727,6 +730,10 @@ int lvmcache_release_vg(struct volume_group *vg)
 	log_debug("Released VG:%p %s from cache (used:%d).",
 		  vg, vg->name, vg->vginfo->vg_use_count);
 
+	/* Debug perform crc check only when it's been used more then once */
+	if (!dm_pool_unlock(vg->vgmem, vg->vginfo->vg_use_count > 1))
+		log_error(INTERNAL_ERROR "VG mempool.");
+
 	vg->vginfo->vg_cache = NULL;
 	vg->vginfo = NULL;
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index d7fb6c3..da15fc9 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2107,8 +2107,17 @@ static int _lv_postorder(struct logical_volume *lv,
 			       void *data)
 {
 	int r;
+	int lck = dm_pool_locked(lv->vg->vgmem);
+
+	if (lck && !dm_pool_unlock(lv->vg->vgmem, 0))
+		return_0;
+
 	r = _lv_postorder_visit(lv, fn, data);
 	_lv_postorder_cleanup(lv, 0);
+
+	if (lck && !dm_pool_lock(lv->vg->vgmem, 0))
+		return_0;
+
 	return r;
 }
 
@@ -2122,6 +2131,10 @@ static int _lv_postorder_vg(struct volume_group *vg,
 {
 	struct lv_list *lvl;
 	int r = 1;
+	int lck = dm_pool_locked(vg->vgmem);
+
+	if (lck && !dm_pool_unlock(vg->vgmem, 0))
+		return_0;
 
 	dm_list_iterate_items(lvl, &vg->lvs)
 		if (!_lv_postorder_visit(lvl->lv, fn, data)) {
@@ -2132,6 +2145,9 @@ static int _lv_postorder_vg(struct volume_group *vg,
 	dm_list_iterate_items(lvl, &vg->lvs)
 		_lv_postorder_cleanup(lvl->lv, 0);
 
+	if (lck && !dm_pool_lock(vg->vgmem, 0))
+		return_0;
+
 	return r;
 }
 
-- 
1.7.6



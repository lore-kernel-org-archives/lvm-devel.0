From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 11 Aug 2011 09:33:42 +0200
Subject: [PATCH 3/5] Lock memory for shared VG
In-Reply-To: <cover.1313047685.git.zkabelac@redhat.com>
References: <cover.1313047685.git.zkabelac@redhat.com>
Message-ID: <500364db87254ff5869b013228986e311774f30f.1313047685.git.zkabelac@redhat.com>
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
 lib/cache/lvmcache.c    |    8 ++++++++
 lib/metadata/metadata.c |   16 ++++++++++++++++
 2 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 45965cc..38d8934 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -689,6 +689,9 @@ struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted)
 	vginfo->use_count = 0;
 	vg->vginfo = vginfo;
 
+	if (!dm_pool_lock(vg->vgmem, 1))
+		goto_bad;
+
 out:
 	vginfo->holders++;
 	vginfo->use_count++;
@@ -715,6 +718,11 @@ int lvmcache_decrement_holders(struct lvmcache_vginfo *vginfo)
 		log_debug("VG %s reused %d times.",
 			  vginfo->cached_vg->name, vginfo->use_count);
 
+	/* Debug perform crc check only when it's been used more then once */
+	if (!dm_pool_unlock(vginfo->cached_vg->vgmem,
+			    (vginfo->use_count > 1)))
+		stack;
+
 	vginfo->cached_vg->vginfo = NULL;
 	vginfo->cached_vg = NULL;
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 44f5fa5..f846f6e 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2107,8 +2107,17 @@ static int _lv_postorder(struct logical_volume *lv,
 			       void *data)
 {
 	int r;
+	int pool_locked = dm_pool_locked(lv->vg->vgmem);
+
+	if (pool_locked && !dm_pool_unlock(lv->vg->vgmem, 0))
+		return_0;
+
 	r = _lv_postorder_visit(lv, fn, data);
 	_lv_postorder_cleanup(lv, 0);
+
+	if (pool_locked && !dm_pool_lock(lv->vg->vgmem, 0))
+		return_0;
+
 	return r;
 }
 
@@ -2122,6 +2131,10 @@ static int _lv_postorder_vg(struct volume_group *vg,
 {
 	struct lv_list *lvl;
 	int r = 1;
+	int pool_locked = dm_pool_locked(vg->vgmem);
+
+	if (pool_locked && !dm_pool_unlock(vg->vgmem, 0))
+		return_0;
 
 	dm_list_iterate_items(lvl, &vg->lvs)
 		if (!_lv_postorder_visit(lvl->lv, fn, data)) {
@@ -2132,6 +2145,9 @@ static int _lv_postorder_vg(struct volume_group *vg,
 	dm_list_iterate_items(lvl, &vg->lvs)
 		_lv_postorder_cleanup(lvl->lv, 0);
 
+	if (pool_locked && !dm_pool_lock(vg->vgmem, 0))
+		return_0;
+
 	return r;
 }
 
-- 
1.7.6



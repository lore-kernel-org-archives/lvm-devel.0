From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 19 Jul 2011 15:43:56 +0200
Subject: [PATCH 5/7] Lock memory for shared VG
In-Reply-To: <cover.1311082436.git.zkabelac@redhat.com>
References: <cover.1311082436.git.zkabelac@redhat.com>
Message-ID: <75d86dba551b2a773d234e338b9ba2a6118c684d.1311082436.git.zkabelac@redhat.com>
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
 lib/cache/lvmcache.c    |    5 +++++
 lib/cache/lvmcache.h    |    1 +
 lib/metadata/metadata.c |   16 ++++++++++++++++
 lib/metadata/vg.c       |   24 ++++++++++++++++++++++++
 lib/metadata/vg.h       |    1 +
 5 files changed, 47 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index c9c3220..0df8b65 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -692,9 +692,14 @@ struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted)
 	 * Cache VG struct for potential reuse
 	 */
 	vginfo->cached_vg = vg;
+	vg->vginfo = vginfo;
+
+	if (!dm_pool_lock(vg->vgmem, 1))
+		goto_bad;
 
 out:
 	increment_vg_holders(vg);
+	vginfo->use_count++;
 	log_debug("Using cached %smetadata for VG %s with %u holder(s).",
 		  vginfo->precommitted ? "pre-committed" : "", vginfo->vgname, vg->holders);
 
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 5f0a4d0..41bc63a 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -52,6 +52,7 @@ struct lvmcache_vginfo {
 				/* Lifetime is directly tied to vgmetadata */
 	struct volume_group *cached_vg;
 	unsigned precommitted;	/* Is vgmetadata live or precommitted? */
+	unsigned use_count;     /* counter of vg reusage */
 };
 
 /* One per device */
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 35770bf..529eeee 100644
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
 
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 08b78af..00677b4 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -17,6 +17,7 @@
 #include "metadata.h"
 #include "display.h"
 #include "activate.h"
+#include "lvmcache.h"
 #include "toolcontext.h"
 
 struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
@@ -57,9 +58,17 @@ struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
 
 void increment_vg_holders(struct volume_group *vg)
 {
+	int lck = dm_pool_locked(vg->vgmem);
+
+	if (lck && !dm_pool_unlock(vg->vgmem, 0))
+                stack;
+ 
 	vg->holders++;
 
 	log_debug("Incrementing VG %s holder(s) to %d at %p.", vg->name, vg->holders, vg);
+
+	if (lck && !dm_pool_lock(vg->vgmem, 0))
+		stack;
 }
 
 static void _free_vg(struct volume_group *vg)
@@ -72,6 +81,9 @@ static void _free_vg(struct volume_group *vg)
 		return;
 	}
 
+	if (vg->vginfo && vg->vginfo->use_count > 1)
+		log_debug("VG %s reused %d times.", vg->name, vg->vginfo->use_count);
+
 	log_debug("Freeing VG %s at %p.", vg->name, vg);
 
 	dm_pool_destroy(vg->vgmem);
@@ -79,13 +91,25 @@ static void _free_vg(struct volume_group *vg)
 
 void release_vg(struct volume_group *vg)
 {
+	int lck;
+
 	if (!vg)
 		return;
 
+	lck = dm_pool_locked(vg->vgmem);
+
 	log_debug("Releasing VG %s with %d holder(s) at %p.", vg->name, vg->holders, vg);
 
+	/* Debug perform crc check only when it's been used more then once */
+	if (lck && !dm_pool_unlock(vg->vgmem, (vg->vginfo &&
+					       vg->vginfo->use_count > 1 &&
+					       vg->holders == 1)))
+		stack;
+
 	if (!--vg->holders)
 		_free_vg(vg);
+	else if (lck && !dm_pool_lock(vg->vgmem, 0))
+		stack;
 }
 
 char *vg_fmt_dup(const struct volume_group *vg)
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index 9366e0f..3d42769 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -42,6 +42,7 @@ struct volume_group {
 	struct dm_pool *vgmem;
 	struct format_instance *fid;
 	unsigned holders;
+	struct lvmcache_vginfo *vginfo;
 	struct dm_list *cmd_vgs;/* List of wanted/locked and opened VGs */
 	uint32_t cmd_missing_vgs;/* Flag marks missing VG */
 	uint32_t seqno;		/* Metadata sequence number */
-- 
1.7.6



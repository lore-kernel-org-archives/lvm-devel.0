From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun, 30 Jan 2011 13:57:35 +0100
Subject: [PATCH 12/24] Perf: Increase hash sizes
In-Reply-To: <cover.1296391340.git.zkabelac@redhat.com>
References: <cover.1296391340.git.zkabelac@redhat.com>
Message-ID: <2483686e0452fbdc01bccd983c0d85672fc400ee.1296391340.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Modify size of created hash tables in a way, it could be uniquely
identified in debug code - as hash will be rouned up to nearest power
of two - so in most updated lines it presents no functional change.

There is one major increase of hass size for lv_hash from 128 to 1024 entries.
(With ideal hash - in case of 10000 LVs - 10 LVs would ocuppy one slot -
which should be still pretty fast).

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/lvm-functions.c   |    2 +-
 lib/cache/lvmcache.c            |    8 ++++----
 lib/device/dev-cache.c          |    2 +-
 lib/filters/filter-persistent.c |    2 +-
 lib/format1/import-export.c     |    2 +-
 lib/format1/import-extents.c    |    2 +-
 lib/format_text/export.c        |    2 +-
 lib/format_text/import_vsn1.c   |    4 ++--
 lib/log/log.c                   |    2 +-
 libdm/libdm-deptree.c           |    4 ++--
 10 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index f06657d..1fa2348 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -197,7 +197,7 @@ static int get_current_lock(char *resource)
 void init_lvhash()
 {
 	/* Create hash table for keeping LV locks & status */
-	lv_hash = dm_hash_create(100);
+	lv_hash = dm_hash_create(1024);
 	pthread_mutex_init(&lv_hash_lock, NULL);
 	pthread_mutex_init(&lvm_lock, NULL);
 }
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 0e9cae1..66e3aeb 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -48,16 +48,16 @@ int lvmcache_init(void)
 
 	dm_list_init(&_vginfos);
 
-	if (!(_vgname_hash = dm_hash_create(128)))
+	if (!(_vgname_hash = dm_hash_create(110)))
 		return 0;
 
-	if (!(_vgid_hash = dm_hash_create(128)))
+	if (!(_vgid_hash = dm_hash_create(111)))
 		return 0;
 
-	if (!(_pvid_hash = dm_hash_create(128)))
+	if (!(_pvid_hash = dm_hash_create(112)))
 		return 0;
 
-	if (!(_lock_hash = dm_hash_create(128)))
+	if (!(_lock_hash = dm_hash_create(113)))
 		return 0;
 
 	/*
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 8ba8515..7df6eb4 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -604,7 +604,7 @@ int dev_cache_init(struct cmd_context *cmd)
 	if (!(_cache.mem = dm_pool_create("dev_cache", 10 * 1024)))
 		return_0;
 
-	if (!(_cache.names = dm_hash_create(128))) {
+	if (!(_cache.names = dm_hash_create(120))) {
 		dm_pool_destroy(_cache.mem);
 		_cache.mem = 0;
 		return_0;
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 3025e68..873679e 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -45,7 +45,7 @@ static int _init_hash(struct pfilter *pf)
 	if (pf->devices)
 		dm_hash_destroy(pf->devices);
 
-	if (!(pf->devices = dm_hash_create(128)))
+	if (!(pf->devices = dm_hash_create(500)))
 		return_0;
 
 	return 1;
diff --git a/lib/format1/import-export.c b/lib/format1/import-export.c
index d0b1b31..70f4fb0 100644
--- a/lib/format1/import-export.c
+++ b/lib/format1/import-export.c
@@ -499,7 +499,7 @@ int export_lvs(struct disk_list *dl, struct volume_group *vg,
 	if (!_check_vg_name(vg->name))
 		return_0;
 
-	if (!(lvd_hash = dm_hash_create(32)))
+	if (!(lvd_hash = dm_hash_create(30)))
 		return_0;
 
 	/*
diff --git a/lib/format1/import-extents.c b/lib/format1/import-extents.c
index 99723ee..e8e3441 100644
--- a/lib/format1/import-extents.c
+++ b/lib/format1/import-extents.c
@@ -45,7 +45,7 @@ struct lv_map {
 static struct dm_hash_table *_create_lv_maps(struct dm_pool *mem,
 					  struct volume_group *vg)
 {
-	struct dm_hash_table *maps = dm_hash_create(32);
+	struct dm_hash_table *maps = dm_hash_create(31);
 	struct lv_list *ll;
 	struct lv_map *lvm;
 
diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 8ddfa85..d5332bc 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -663,7 +663,7 @@ static int _build_pv_names(struct formatter *f, struct volume_group *vg)
 	if (!(f->mem = dm_pool_create("text pv_names", 512)))
 		return_0;
 
-	if (!(f->pv_names = dm_hash_create(128)))
+	if (!(f->pv_names = dm_hash_create(100)))
 		return_0;
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 5fac7c4..5e70165 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -756,7 +756,7 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 	 * The pv hash memorises the pv section names -> pv
 	 * structures.
 	 */
-	if (!(pv_hash = dm_hash_create(32))) {
+	if (!(pv_hash = dm_hash_create(61))) {
 		log_error("Couldn't create hash table.");
 		goto bad;
 	}
@@ -784,7 +784,7 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 	 * The lv hash memorises the lv section names -> lv
 	 * structures.
 	 */
-	if (!(lv_hash = dm_hash_create(32))) {
+	if (!(lv_hash = dm_hash_create(999))) {
 		log_error("Couldn't create hash table.");
 		goto bad;
 	}
diff --git a/lib/log/log.c b/lib/log/log.c
index 86b4988..252d8d3 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -242,7 +242,7 @@ void print_log(int level, const char *file, int line, int dm_errno,
 
 	if (log_once) {
 		if (!_duplicated)
-			_duplicated = dm_hash_create(128);
+			_duplicated = dm_hash_create(101);
 		if (_duplicated) {
 			if (dm_hash_lookup(_duplicated, message))
 				level = _LOG_NOTICE;
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 8d00514..09aec4c 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -214,14 +214,14 @@ struct dm_tree *dm_tree_create(void)
 		return NULL;
 	}
 
-	if (!(dtree->devs = dm_hash_create(8))) {
+	if (!(dtree->devs = dm_hash_create(28))) {
 		log_error("dtree hash creation failed");
 		dm_pool_destroy(dtree->mem);
 		dm_free(dtree);
 		return NULL;
 	}
 
-	if (!(dtree->uuids = dm_hash_create(32))) {
+	if (!(dtree->uuids = dm_hash_create(63))) {
 		log_error("dtree uuid hash creation failed");
 		dm_hash_destroy(dtree->devs);
 		dm_pool_destroy(dtree->mem);
-- 
1.7.3.5



From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  8 Mar 2021 14:46:47 +0000 (GMT)
Subject: main - hash: use individual hint sizes
Message-ID: <20210308144647.AB1F7395201B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2d64ffaee521222e64b5c0bdfec367617e503f05
Commit:        2d64ffaee521222e64b5c0bdfec367617e503f05
Parent:        78c7ae7cd2dab7abf9ece9bec37979fa3b33c978
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 7 15:33:50 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 8 15:33:15 2021 +0100

hash: use individual hint sizes

Use different 'hint' size for dm_hash_create() call - so
when debug info about hash is printed we can recognize which
hash was in use.

This patch doesn't change actual used size since that is always
rounded to be power of 2 and >=16 - so as such is only a
help to developer.

We could eventually use 'name' arg, but since this would have changed
API and this patchset will be routed to libdm & stable - we will
just use this small trick.
---
 device_mapper/libdm-deptree.c   | 4 ++--
 device_mapper/libdm-report.c    | 2 +-
 lib/cache/lvmcache.c            | 6 +++---
 lib/config/config.c             | 2 +-
 lib/device/dev-cache.c          | 6 +++---
 lib/filters/filter-mpath.c      | 2 +-
 lib/filters/filter-persistent.c | 2 +-
 lib/format_text/export.c        | 2 +-
 lib/format_text/format-text.c   | 2 +-
 lib/format_text/import_vsn1.c   | 4 ++--
 lib/log/log.c                   | 2 +-
 lib/metadata/vg.c               | 2 +-
 12 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index 7045e1f26..ede75ef77 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -380,13 +380,13 @@ struct dm_tree *dm_tree_create(void)
 	dtree->mem = dmem;
 	dtree->optional_uuid_suffixes = NULL;
 
-	if (!(dtree->devs = dm_hash_create(8))) {
+	if (!(dtree->devs = dm_hash_create(61))) {
 		log_error("dtree hash creation failed");
 		dm_pool_destroy(dtree->mem);
 		return NULL;
 	}
 
-	if (!(dtree->uuids = dm_hash_create(32))) {
+	if (!(dtree->uuids = dm_hash_create(31))) {
 		log_error("dtree uuid hash creation failed");
 		dm_hash_destroy(dtree->devs);
 		dm_pool_destroy(dtree->mem);
diff --git a/device_mapper/libdm-report.c b/device_mapper/libdm-report.c
index 1928354d3..f14aa8bc7 100644
--- a/device_mapper/libdm-report.c
+++ b/device_mapper/libdm-report.c
@@ -2474,7 +2474,7 @@ dm_percent_t dm_make_percent(uint64_t numerator, uint64_t denominator)
 
 int dm_report_value_cache_set(struct dm_report *rh, const char *name, const void *data)
 {
-	if (!rh->value_cache && (!(rh->value_cache = dm_hash_create(64)))) {
+	if (!rh->value_cache && (!(rh->value_cache = dm_hash_create(63)))) {
 		log_error("Failed to create cache for values used during reporting.");
 		return 0;
 	}
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index b78262b65..d4acec509 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -101,13 +101,13 @@ int lvmcache_init(struct cmd_context *cmd)
 	dm_list_init(&_unused_duplicates);
 	dm_list_init(&_prev_unused_duplicate_devs);
 
-	if (!(_vgname_hash = dm_hash_create(128)))
+	if (!(_vgname_hash = dm_hash_create(127)))
 		return 0;
 
-	if (!(_vgid_hash = dm_hash_create(128)))
+	if (!(_vgid_hash = dm_hash_create(126)))
 		return 0;
 
-	if (!(_pvid_hash = dm_hash_create(128)))
+	if (!(_pvid_hash = dm_hash_create(125)))
 		return 0;
 
 	return 1;
diff --git a/lib/config/config.c b/lib/config/config.c
index 9725dece3..409555096 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1142,7 +1142,7 @@ int config_def_check(struct cft_check_handle *handle)
 	 * If section name is variable, use '#' as a substitute.
 	 */
 	if (!handle->cmd->cft_def_hash) {
-		if (!(handle->cmd->cft_def_hash = dm_hash_create(64))) {
+		if (!(handle->cmd->cft_def_hash = dm_hash_create(60))) {
 			log_error("Failed to create configuration definition hash.");
 			r = 0; goto out;
 		}
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 5632456bf..cf6334564 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1222,9 +1222,9 @@ int dev_cache_init(struct cmd_context *cmd)
 	if (!(_cache.mem = dm_pool_create("dev_cache", 10 * 1024)))
 		return_0;
 
-	if (!(_cache.names = dm_hash_create(128)) ||
-	    !(_cache.vgid_index = dm_hash_create(32)) ||
-	    !(_cache.lvid_index = dm_hash_create(32))) {
+	if (!(_cache.names = dm_hash_create(120)) ||
+	    !(_cache.vgid_index = dm_hash_create(30)) ||
+	    !(_cache.lvid_index = dm_hash_create(29))) {
 		dm_pool_destroy(_cache.mem);
 		_cache.mem = 0;
 		return_0;
diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index 853a2c569..202296458 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -374,7 +374,7 @@ struct dev_filter *mpath_filter_create(struct dev_types *dt)
 		return NULL;
 	}
 
-	if (!(hash = dm_hash_create(128))) {
+	if (!(hash = dm_hash_create(110))) {
 		log_error("mpath hash table creation failed.");
 		return NULL;
 	}
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 291f3932f..3f7007e4d 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -58,7 +58,7 @@ static int _init_hash(struct pfilter *pf)
 	if (pf->devices)
 		dm_hash_destroy(pf->devices);
 
-	if (!(pf->devices = dm_hash_create(128)))
+	if (!(pf->devices = dm_hash_create(111)))
 		return_0;
 
 	return 1;
diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 33844a2fd..7a95bdba4 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -960,7 +960,7 @@ static int _build_pv_names(struct formatter *f, struct volume_group *vg)
 	if (!(f->mem = dm_pool_create("text pv_names", 512)))
 		return_0;
 
-	if (!(f->pv_names = dm_hash_create(128)))
+	if (!(f->pv_names = dm_hash_create(115)))
 		return_0;
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index bf1b9b3a4..3ed6aa54a 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -2223,7 +2223,7 @@ static int _create_vg_text_instance(struct format_instance *fid,
 		vg_name = fic->context.vg_ref.vg_name;
 		vg_id = fic->context.vg_ref.vg_id;
 
-		if (!(fid->metadata_areas_index = dm_hash_create(128))) {
+		if (!(fid->metadata_areas_index = dm_hash_create(116))) {
 			log_error("Couldn't create metadata index for format "
 				  "instance of VG %s.", vg_name);
 			return 0;
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index ee56502e1..ef25369a6 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -1074,7 +1074,7 @@ static struct volume_group *_read_vg(struct cmd_context *cmd,
 	 * The pv hash memorises the pv section names -> pv
 	 * structures.
 	 */
-	if (!(pv_hash = dm_hash_create(64))) {
+	if (!(pv_hash = dm_hash_create(59))) {
 		log_error("Couldn't create pv hash table.");
 		goto bad;
 	}
@@ -1083,7 +1083,7 @@ static struct volume_group *_read_vg(struct cmd_context *cmd,
 	 * The lv hash memorises the lv section names -> lv
 	 * structures.
 	 */
-	if (!(lv_hash = dm_hash_create(1024))) {
+	if (!(lv_hash = dm_hash_create(1023))) {
 		log_error("Couldn't create lv hash table.");
 		goto bad;
 	}
diff --git a/lib/log/log.c b/lib/log/log.c
index ebf26b4de..cd676f2ae 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -576,7 +576,7 @@ static void _vprint_log(int level, const char *file, int line, int dm_errno_or_c
 
 	if (log_once) {
 		if (!_duplicated)
-			_duplicated = dm_hash_create(128);
+			_duplicated = dm_hash_create(117);
 		if (_duplicated) {
 			if (dm_hash_lookup(_duplicated, message))
 				level = _LOG_NOTICE;
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index e659579c2..3f9ec8d35 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -46,7 +46,7 @@ struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
 	vg->vgmem = vgmem;
 	vg->alloc = ALLOC_NORMAL;
 
-	if (!(vg->hostnames = dm_hash_create(16))) {
+	if (!(vg->hostnames = dm_hash_create(14))) {
 		log_error("Failed to allocate VG hostname hashtable.");
 		dm_pool_destroy(vgmem);
 		return NULL;



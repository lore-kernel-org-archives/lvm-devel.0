From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 5 Nov 2018 11:27:32 -0500
Subject: master - cov: remove unused assigns
Message-ID: <201811051627.wA5GRWan005454@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=70e3d0a613fb53e52f7a7cb31d65bcc2fa7ab738
Commit:        70e3d0a613fb53e52f7a7cb31d65bcc2fa7ab738
Parent:        a91ac41b93eff0f3ebd3af3319e8bbcb1fe8d00f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 3 16:48:20 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 5 17:25:11 2018 +0100

cov: remove unused assigns

---
 lib/cache/lvmcache.c        |    3 ---
 lib/device/dev-cache.c      |    3 +--
 lib/metadata/metadata.c     |    6 ++----
 libdm/dm-tools/dmfilemapd.c |    4 ++--
 tools/pvscan.c              |    3 +--
 tools/vgchange.c            |    2 +-
 6 files changed, 7 insertions(+), 14 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 46470a5..e681ed8 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -67,7 +67,6 @@ static DM_LIST_INIT(_vginfos);
 static DM_LIST_INIT(_found_duplicate_devs);
 static DM_LIST_INIT(_unused_duplicate_devs);
 static int _scanning_in_progress = 0;
-static int _has_scanned = 0;
 static int _vgs_locked = 0;
 static int _found_duplicate_pvs = 0;	/* If we never see a duplicate PV we can skip checking for them later. */
 
@@ -1808,8 +1807,6 @@ void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans, int reset)
 {
 	log_debug_cache("Dropping VG info");
 
-	_has_scanned = 0;
-
 	if (_vgid_hash) {
 		dm_hash_destroy(_vgid_hash);
 		_vgid_hash = NULL;
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 9b141fe..fa92031 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -666,10 +666,9 @@ struct dm_list *dev_cache_get_dev_list_for_lvid(const char *lvid)
 
 void dev_cache_failed_path(struct device *dev, const char *path)
 {
-	struct device *dev_by_path;
 	struct dm_str_list *strl;
 
-	if ((dev_by_path = (struct device *) dm_hash_lookup(_cache.names, path)))
+	if (dm_hash_lookup(_cache.names, path))
 		dm_hash_remove(_cache.names, path);
 
 	dm_list_iterate_items(strl, &dev->aliases) {
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 3b28bf5..57e1842 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1647,15 +1647,13 @@ struct generic_logical_volume *find_historical_glv(const struct volume_group *vg
 
 int lv_name_is_used_in_vg(const struct volume_group *vg, const char *name, int *historical)
 {
-	struct generic_logical_volume *historical_lv;
-	struct logical_volume *lv;
 	int found = 0;
 
-	if ((lv = find_lv(vg, name))) {
+	if (find_lv(vg, name)) {
 		found = 1;
 		if (historical)
 			*historical = 0;
-	} else if ((historical_lv = find_historical_glv(vg, name, 0, NULL))) {
+	} else if (find_historical_glv(vg, name, 0, NULL)) {
 		found = 1;
 		if (historical)
 			*historical = 1;
diff --git a/libdm/dm-tools/dmfilemapd.c b/libdm/dm-tools/dmfilemapd.c
index 0b17c2b..856df3d 100644
--- a/libdm/dm-tools/dmfilemapd.c
+++ b/libdm/dm-tools/dmfilemapd.c
@@ -628,10 +628,10 @@ check_unlinked:
 
 static int _daemonise(struct filemap_monitor *fm)
 {
-	pid_t pid = 0, sid;
+	pid_t pid = 0;
 	int fd;
 
-	if (!(sid = setsid())) {
+	if (!setsid()) {
 		_early_log("setsid failed.");
 		return 0;
 	}
diff --git a/tools/pvscan.c b/tools/pvscan.c
index d110a6b..e3cd410 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -452,7 +452,6 @@ static int _online_pvscan_one(struct cmd_context *cmd, struct device *dev,
 			      int disable_remove,
 			      const char **pvid_without_metadata)
 {
-	struct label *label;
 	struct lvmcache_info *info;
 	struct _pvscan_baton baton;
 	const struct format_type *fmt;
@@ -474,7 +473,7 @@ static int _online_pvscan_one(struct cmd_context *cmd, struct device *dev,
 		return 1;
 	}
 
-	if (!(label = lvmcache_get_label(info))) {
+	if (!lvmcache_get_label(info)) {
 		log_debug("No PV label found for %s.", dev_name(dev));
 		if (!disable_remove)
 			_online_pvid_file_remove_devno((int)MAJOR(dev->dev), (int)MINOR(dev->dev));
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 13b72cc..e8e302c 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -607,7 +607,7 @@ static int _vgchange_single(struct cmd_context *cmd, const char *vg_name,
 {
 	int ret = ECMD_PROCESSED;
 	unsigned i;
-	activation_change_t activate = CHANGE_AN;
+	activation_change_t activate;
 
 	static const struct {
 		int arg;



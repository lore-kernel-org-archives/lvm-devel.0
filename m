From: David Teigland <teigland@sourceware.org>
Date: Tue, 26 Jun 2018 13:16:55 -0400
Subject: 2018-06-01-stable - scan: reopen RDWR during rescan
Message-ID: <201806261716.w5QHGtke005699@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=90e419c645ac5ad3b82044fd3422f956442935a6
Commit:        90e419c645ac5ad3b82044fd3422f956442935a6
Parent:        49147cbaa7b3f73d273593f2353058a0ebf850ba
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 26 11:58:11 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 26 12:15:43 2018 -0500

scan: reopen RDWR during rescan

Commit a30e6222799:
  "scan: work around udev problems by avoiding open RDWR"

had us reopen a device RDWR in the write function.  Since
we know earlier that the command intends to write to devices
in the VG, we can reopen the VG's devices RDWR during the
rescan instead of waiting until the writes to happen.
---
 daemons/clvmd/lvm-functions.c    |    2 +-
 lib/cache/lvmcache.c             |    7 +++++--
 lib/cache/lvmcache.h             |    2 +-
 lib/label/label.c                |   22 ++++++++++++++++++++++
 lib/label/label.h                |    1 +
 lib/metadata/metadata-exported.h |    8 ++++++--
 lib/metadata/metadata.c          |   27 +++++++++++++++++++--------
 tools/toollib.c                  |    2 +-
 8 files changed, 56 insertions(+), 15 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 24ed7a0..d6d395f 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -832,7 +832,7 @@ void lvm_do_backup(const char *vgname)
 
 	pthread_mutex_lock(&lvm_lock);
 
-	vg = vg_read_internal(cmd, vgname, NULL /*vgid*/, 0, WARN_PV_READ, &consistent);
+	vg = vg_read_internal(cmd, vgname, NULL /*vgid*/, 0, 0, WARN_PV_READ, &consistent);
 
 	if (vg && consistent)
 		check_current_backup(vg);
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 4f1ae1b..3e681a2 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1351,7 +1351,7 @@ next:
  * comes directly from files.)
  */
 
-int lvmcache_label_rescan_vg(struct cmd_context *cmd, const char *vgname, const char *vgid)
+int lvmcache_label_rescan_vg(struct cmd_context *cmd, const char *vgname, const char *vgid, int open_rw)
 {
 	struct dm_list devs;
 	struct device_list *devl, *devl2;
@@ -1396,7 +1396,10 @@ int lvmcache_label_rescan_vg(struct cmd_context *cmd, const char *vgname, const
 	/* FIXME: should we also rescan unused_duplicate_devs for devs
 	   being rescanned here and then repeat resolving the duplicates? */
 
-	label_scan_devs(cmd, cmd->filter, &devs);
+	if (open_rw)
+		label_scan_devs_rw(cmd, cmd->filter, &devs);
+	else
+		label_scan_devs(cmd, cmd->filter, &devs);
 
 	dm_list_iterate_items_safe(devl, devl2, &devs) {
 		dm_list_del(&devl->list);
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index b988be6..bf976e9 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -69,7 +69,7 @@ void lvmcache_allow_reads_with_lvmetad(void);
 void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans, int reset);
 
 int lvmcache_label_scan(struct cmd_context *cmd);
-int lvmcache_label_rescan_vg(struct cmd_context *cmd, const char *vgname, const char *vgid);
+int lvmcache_label_rescan_vg(struct cmd_context *cmd, const char *vgname, const char *vgid, int open_rw);
 
 /* Add/delete a device */
 struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
diff --git a/lib/label/label.c b/lib/label/label.c
index ca465dd..ac37713 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -909,6 +909,28 @@ int label_scan_devs(struct cmd_context *cmd, struct dev_filter *f, struct dm_lis
 	return 1;
 }
 
+int label_scan_devs_rw(struct cmd_context *cmd, struct dev_filter *f, struct dm_list *devs)
+{
+	struct device_list *devl;
+	int failed = 0;
+
+	dm_list_iterate_items(devl, devs) {
+		if (_in_bcache(devl->dev)) {
+			bcache_invalidate_fd(scan_bcache, devl->dev->bcache_fd);
+			_scan_dev_close(devl->dev);
+		}
+
+		/* _scan_dev_open will open(RDWR) when this flag is set */
+		devl->dev->flags |= DEV_BCACHE_WRITE;
+	}
+
+	_scan_list(cmd, f, devs, &failed);
+
+	/* FIXME: this function should probably fail if any devs couldn't be scanned */
+
+	return 1;
+}
+
 int label_scan_devs_excl(struct dm_list *devs)
 {
 	struct device_list *devl;
diff --git a/lib/label/label.h b/lib/label/label.h
index 3d8882f..5ed8bc8 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -104,6 +104,7 @@ extern struct bcache *scan_bcache;
 
 int label_scan(struct cmd_context *cmd);
 int label_scan_devs(struct cmd_context *cmd, struct dev_filter *f, struct dm_list *devs);
+int label_scan_devs_rw(struct cmd_context *cmd, struct dev_filter *f, struct dm_list *devs);
 int label_scan_devs_excl(struct dm_list *devs);
 void label_scan_invalidate(struct device *dev);
 void label_scan_invalidate_lv(struct cmd_context *cmd, struct logical_volume *lv);
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 916d029..f4fb112 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -651,8 +651,12 @@ void pvcreate_params_set_defaults(struct pvcreate_params *pp);
 int vg_write(struct volume_group *vg);
 int vg_commit(struct volume_group *vg);
 void vg_revert(struct volume_group *vg);
-struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vg_name,
-				      const char *vgid, uint32_t lockd_state, uint32_t warn_flags, int *consistent);
+
+struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vg_name, const char *vgid,
+				      int write_lock_held,
+				      uint32_t lockd_state,
+				      uint32_t warn_flags,
+				      int *consistent);
 
 #define get_pvs( cmd ) get_pvs_internal((cmd), NULL, NULL)
 #define get_pvs_perserve_vg( cmd, pv_list, vg_list ) get_pvs_internal((cmd), (pv_list), (vg_list))
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 7da6718..2292568 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3731,6 +3731,7 @@ out:
 static struct volume_group *_vg_read(struct cmd_context *cmd,
 				     const char *vgname,
 				     const char *vgid,
+				     int write_lock_held,
 				     uint32_t lockd_state, 
 				     uint32_t warn_flags, 
 				     int *consistent, unsigned precommitted)
@@ -3863,8 +3864,15 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		if (warn_flags & SKIP_RESCAN)
 			goto find_vg;
 		skipped_rescan = 0;
+
+		/*
+		 * When a write lock is held, it implies we are going to be
+		 * writing to the devs in the VG, so when we rescan the VG
+		 * we should reopen the devices in RDWR (since they were
+		 * open RDONLY from the initial scan.
+		 */
 		log_debug_metadata("Rescanning devices for %s", vgname);
-		lvmcache_label_rescan_vg(cmd, vgname, vgid);
+		lvmcache_label_rescan_vg(cmd, vgname, vgid, write_lock_held);
 	} else {
 		log_debug_metadata("Skipped rescanning devices for %s", vgname);
 		skipped_rescan = 1;
@@ -4498,13 +4506,15 @@ static int _check_devs_used_correspond_with_vg(struct volume_group *vg)
 
 struct volume_group *vg_read_internal(struct cmd_context *cmd,
 				      const char *vgname, const char *vgid,
-				      uint32_t lockd_state, uint32_t warn_flags,
+				      int write_lock_held,
+				      uint32_t lockd_state,
+				      uint32_t warn_flags,
 				      int *consistent)
 {
 	struct volume_group *vg;
 	struct lv_list *lvl;
 
-	if (!(vg = _vg_read(cmd, vgname, vgid, lockd_state, warn_flags, consistent, 0)))
+	if (!(vg = _vg_read(cmd, vgname, vgid, write_lock_held, lockd_state, warn_flags, consistent, 0)))
 		goto_out;
 
 	if (!check_pv_dev_sizes(vg))
@@ -4612,7 +4622,7 @@ struct volume_group *vg_read_by_vgid(struct cmd_context *cmd,
 
 	label_scan_setup_bcache();
 
-	if (!(vg = _vg_read(cmd, vgname, vgid, 0, warn_flags, &consistent, precommitted))) {
+	if (!(vg = _vg_read(cmd, vgname, vgid, 0, 0, warn_flags, &consistent, precommitted))) {
 		log_error("Rescan devices to look for missing VG.");
 		goto scan;
 	}
@@ -4633,7 +4643,7 @@ struct volume_group *vg_read_by_vgid(struct cmd_context *cmd,
 	lvmcache_label_scan(cmd);
 	warn_flags |= SKIP_RESCAN;
 
-	if (!(vg = _vg_read(cmd, vgname, vgid, 0, warn_flags, &consistent, precommitted)))
+	if (!(vg = _vg_read(cmd, vgname, vgid, 0, 0, warn_flags, &consistent, precommitted)))
 		goto fail;
 
 	label_scan_destroy(cmd); /* drop bcache to close devs, keep lvmcache */
@@ -4872,7 +4882,7 @@ static int _get_pvs(struct cmd_context *cmd, uint32_t warn_flags,
 
 		warn_flags |= WARN_INCONSISTENT;
 
-		if (!(vg = vg_read_internal(cmd, vgname, (!vgslist) ? vgid : NULL, 0, warn_flags, &consistent))) {
+		if (!(vg = vg_read_internal(cmd, vgname, (!vgslist) ? vgid : NULL, 0, 0, warn_flags, &consistent))) {
 			stack;
 			continue;
 		}
@@ -5218,7 +5228,7 @@ static struct volume_group *_recover_vg(struct cmd_context *cmd,
 		lockd_state |= LDST_EX;
 	}
 
-	if (!(vg = vg_read_internal(cmd, vg_name, vgid, lockd_state, WARN_PV_READ, &consistent))) {
+	if (!(vg = vg_read_internal(cmd, vg_name, vgid, 1, lockd_state, WARN_PV_READ, &consistent))) {
 		unlock_vg(cmd, NULL, vg_name);
 		return_NULL;
 	}
@@ -5462,6 +5472,7 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 	uint32_t warn_flags = 0;
 	int is_shared = 0;
 	int already_locked;
+	int write_lock_held = (lock_flags == LCK_VG_WRITE);
 
 	if ((read_flags & READ_ALLOW_INCONSISTENT) || (lock_flags != LCK_VG_WRITE))
 		consistent = 0;
@@ -5493,7 +5504,7 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 		warn_flags |= WARN_INCONSISTENT;
 
 	/* If consistent == 1, we get NULL here if correction fails. */
-	if (!(vg = vg_read_internal(cmd, vg_name, vgid, lockd_state, warn_flags, &consistent))) {
+	if (!(vg = vg_read_internal(cmd, vg_name, vgid, write_lock_held, lockd_state, warn_flags, &consistent))) {
 		if (consistent_in && !consistent) {
 			failure |= FAILED_INCONSISTENT;
 			goto bad;
diff --git a/tools/toollib.c b/tools/toollib.c
index 19f4c33..413937f 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -5730,7 +5730,7 @@ do_command:
 	if (pp->preserve_existing && pp->orphan_vg_name) {
 		log_debug("Using existing orphan PVs in %s.", pp->orphan_vg_name);
 
-		if (!(orphan_vg = vg_read_internal(cmd, pp->orphan_vg_name, NULL, 0, 0, &consistent))) {
+		if (!(orphan_vg = vg_read_internal(cmd, pp->orphan_vg_name, NULL, 0, 0, 0, &consistent))) {
 			log_error("Cannot read orphans VG %s.", pp->orphan_vg_name);
 			goto bad;
 		}



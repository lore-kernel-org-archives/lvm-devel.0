From: David Teigland <teigland@sourceware.org>
Date: Fri, 11 May 2018 15:38:46 -0400
Subject: master - scan: remove unused args from label_read
Message-ID: <201805111938.w4BJckJx002956@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5c9dcd99fdd63b7113a19b799c69c207199ebdc2
Commit:        5c9dcd99fdd63b7113a19b799c69c207199ebdc2
Parent:        b5d99146282d2747b96d37efb5d2a7dc02fa6327
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 11 14:16:49 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 11 14:16:49 2018 -0500

scan: remove unused args from label_read

---
 lib/cache/lvmcache.c           |    6 +++---
 lib/label/label.c              |   16 +---------------
 lib/label/label.h              |    2 +-
 lib/metadata/metadata-liblvm.c |    3 +--
 lib/metadata/metadata.c        |    2 +-
 tools/toollib.c                |    2 +-
 6 files changed, 8 insertions(+), 23 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 3f9e6fd..4062faa 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -810,7 +810,7 @@ const struct format_type *lvmcache_fmt_from_vgname(struct cmd_context *cmd,
 
 	dm_list_iterate_safe(devh, tmp, &devs) {
 		devl = dm_list_item(devh, struct device_list);
-		label_read(devl->dev, NULL, UINT64_C(0));
+		label_read(devl->dev);
 		dm_list_del(&devl->list);
 		dm_free(devl);
 	}
@@ -1438,7 +1438,7 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 
 		dm_list_iterate_items(devl, &add_cache_devs) {
 			log_debug_cache("Rescan preferred device %s for lvmcache", dev_name(devl->dev));
-			label_read(devl->dev, NULL, UINT64_C(0));
+			label_read(devl->dev);
 		}
 
 		dm_list_splice(&_unused_duplicate_devs, &del_cache_devs);
@@ -1629,7 +1629,7 @@ const char *lvmcache_pvid_from_devname(struct cmd_context *cmd,
 		return NULL;
 	}
 
-	if (!(label_read(dev, NULL, UINT64_C(0))))
+	if (!label_read(dev))
 		return NULL;
 
 	return dev->pvid;
diff --git a/lib/label/label.c b/lib/label/label.c
index ab040e1..cd54b69 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -847,9 +847,7 @@ void label_scan_destroy(struct cmd_context *cmd)
  * device, this is not a commonly used function.
  */
 
-/* FIXME: remove unused_sector arg */
-
-int label_read(struct device *dev, struct label **labelp, uint64_t unused_sector)
+int label_read(struct device *dev)
 {
 	struct dm_list one_dev;
 	struct device_list *devl;
@@ -869,18 +867,6 @@ int label_read(struct device *dev, struct label **labelp, uint64_t unused_sector
 
 	_scan_list(NULL, NULL, &one_dev, &failed);
 
-	/*
-	 * FIXME: this ugliness of returning a pointer to the label is
-	 * temporary until the callers can be updated to not use this.
-	 */
-	if (labelp) {
-		struct lvmcache_info *info;
-
-		info = lvmcache_info_from_pvid(dev->pvid, dev, 1);
-		if (info)
-			*labelp = lvmcache_get_label(info);
-	}
-
 	if (failed)
 		return 0;
 	return 1;
diff --git a/lib/label/label.h b/lib/label/label.h
index 508cb6f..0ef1d83 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -109,7 +109,7 @@ void label_scan_invalidate(struct device *dev);
 void label_scan_invalidate_lv(struct cmd_context *cmd, struct logical_volume *lv);
 void label_scan_drop(struct cmd_context *cmd);
 void label_scan_destroy(struct cmd_context *cmd);
-int label_read(struct device *dev, struct label **labelp, uint64_t unused_sector);
+int label_read(struct device *dev);
 int label_read_sector(struct device *dev, uint64_t scan_sector);
 void label_scan_confirm(struct device *dev);
 int label_scan_setup_bcache(void);
diff --git a/lib/metadata/metadata-liblvm.c b/lib/metadata/metadata-liblvm.c
index f7a07a5..df4fdd9 100644
--- a/lib/metadata/metadata-liblvm.c
+++ b/lib/metadata/metadata-liblvm.c
@@ -483,7 +483,6 @@ static int _pvremove_check(struct cmd_context *cmd, const char *name,
 {
 	static const char really_wipe_msg[] = "Really WIPE LABELS from physical volume";
 	struct device *dev;
-	struct label *label;
 	struct pv_list *pvl;
 	struct physical_volume *pv = NULL;
 	int used;
@@ -498,7 +497,7 @@ static int _pvremove_check(struct cmd_context *cmd, const char *name,
 
 	/* Is there a pv here already? */
 	/* If not, this is an error unless you used -f. */
-	if (!label_read(dev, &label, 0)) {
+	if (!label_read(dev)) {
 		if (force_count)
 			return 1;
 		log_error("No PV label found on %s.", name);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index bfdc4cf..1636026 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4058,7 +4058,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 						release_vg(correct_vg);
 						correct_vg = NULL;
 						lvmcache_del(info);
-						label_read(pvl->pv->dev, NULL, 0);
+						label_read(pvl->pv->dev);
 						goto restart_scan;
 					}
 #endif
diff --git a/tools/toollib.c b/tools/toollib.c
index 5e5cc51..afd8060 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1558,7 +1558,7 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv,
 			/*
 			 * add info to lvmcache from the duplicate dev.
 			 */
-			label_read(devl->dev, NULL, 0);
+			label_read(devl->dev);
 
 			/*
 			 * the info/label should now be found because



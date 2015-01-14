From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 14 Jan 2015 20:47:48 +0000 (UTC)
Subject: master - toollib: search for duplicate PVs only when needed
Message-ID: <20150114204748.CEB6B60E1F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b64da4d8b52160be3ab5635b44d7bb06ef619f43
Commit:        b64da4d8b52160be3ab5635b44d7bb06ef619f43
Parent:        3a7c47af0e8840f4f5b5c39294e9f378de386a50
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jan 14 14:38:05 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jan 14 14:47:08 2015 -0600

toollib: search for duplicate PVs only when needed

A full search for duplicate PVs in the case of pvs -a
is only necessary when duplicates have previously been
detected in lvmcache.  Use a global variable from lvmcache
to indicate that duplicate PVs exist, so we can skip the
search for duplicates when none exist.
---
 lib/cache/lvmcache.c |   15 ++++++++++++++-
 lib/cache/lvmcache.h |    2 ++
 tools/toollib.c      |    4 +---
 3 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 6cdf766..6a9a05f 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -76,6 +76,7 @@ static int _scanning_in_progress = 0;
 static int _has_scanned = 0;
 static int _vgs_locked = 0;
 static int _vg_global_lock_held = 0;	/* Global lock held when cache wiped? */
+static int _found_duplicate_pvs = 0;	/* If we never see a duplicate PV we can skip checking for them later. */
 
 int lvmcache_init(void)
 {
@@ -402,6 +403,16 @@ int lvmcache_vgs_locked(void)
 	return _vgs_locked;
 }
 
+/*
+ * When lvmcache sees a duplicate PV, this is set.
+ * process_each_pv() can avoid searching for duplicates
+ * by checking this and seeing that no duplicate PVs exist.
+ */
+int lvmcache_found_duplicate_pvs(void)
+{
+	return _found_duplicate_pvs;
+}
+
 static void _vginfo_attach_info(struct lvmcache_vginfo *vginfo,
 				struct lvmcache_info *info)
 {
@@ -1560,10 +1571,12 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 			//else if (dm_is_dm_major(MAJOR(existing->dev->dev)) &&
 				 //dm_is_dm_major(MAJOR(dev->dev)))
 				 //
-			else if (!strcmp(pvid_s, existing->dev->pvid))
+			else if (!strcmp(pvid_s, existing->dev->pvid)) {
 				log_error("Found duplicate PV %s: using %s not "
 					  "%s", pvid, dev_name(dev),
 					  dev_name(existing->dev));
+				_found_duplicate_pvs = 1;
+			}
 		}
 		if (strcmp(pvid_s, existing->dev->pvid)) 
 			log_debug_cache("Updating pvid cache to %s (%s) from %s (%s)",
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 7a04917..0a7d898 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -160,4 +160,6 @@ uint64_t lvmcache_smallest_mda_size(struct lvmcache_info *info);
 void lvmcache_replace_dev(struct cmd_context *cmd, struct physical_volume *pv,
 			struct device *dev);
 
+int lvmcache_found_duplicate_pvs(void);
+
 #endif
diff --git a/tools/toollib.c b/tools/toollib.c
index 41e1581..17a9c71 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2329,11 +2329,9 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 			 * duplicate devices are being displayed by pvs -a, and
 			 * we want each of them to be displayed in the context
 			 * of this VG, so that this VG name appears next to it.
-			 * FIXME: the repeated search through all devices is a
-			 * high cost to pay for a very rare benefit.
 			 */
 
-			if (process_all_devices) {
+			if (process_all_devices && lvmcache_found_duplicate_pvs()) {
 				while ((dil = _device_list_find_pvid(all_devices, pv))) {
 					_device_list_remove(all_devices, dil->dev);
 



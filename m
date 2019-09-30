From: David Teigland <teigland@sourceware.org>
Date: Mon, 30 Sep 2019 12:39:59 -0400
Subject: master - scan: use PV device name hint for choosing duplicate PV
Message-ID: <201909301639.x8UGdx9Q024786@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f836fe3836e990e41b2c2b59c2af7ef6b979097f
Commit:        f836fe3836e990e41b2c2b59c2af7ef6b979097f
Parent:        4910a31f6d3a9e52e8be85c6409b5fa93895874a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Sep 27 11:34:55 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 30 11:38:10 2019 -0500

scan: use PV device name hint for choosing duplicate PV

Prefer a device if its name matches the PV device name hint.
---
 lib/cache/lvmcache.c |   36 ++++++++++++++++++++++++++++++++++--
 1 files changed, 34 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index d45b6db..316624f 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -404,6 +404,23 @@ static uint64_t _get_pvsummary_size(char *pvid)
 	return 0;
 }
 
+static const char *_get_pvsummary_device_hint(char *pvid)
+{
+	char pvid_s[ID_LEN + 1] __attribute__((aligned(8)));
+	struct lvmcache_vginfo *vginfo;
+	struct pv_list *pvl;
+
+	dm_list_iterate_items(vginfo, &_vginfos) {
+		dm_list_iterate_items(pvl, &vginfo->pvsummaries) {
+			(void) dm_strncpy(pvid_s, (char *) &pvl->pv->id, sizeof(pvid_s));
+			if (!strcmp(pvid_s, pvid))
+				return pvl->pv->device_hint;
+		}
+	}
+
+	return NULL;
+}
+
 /*
  * Check if any PVs in vg->pvs have the same PVID as any
  * entries in _unused_duplicates.
@@ -502,6 +519,7 @@ static void _choose_duplicates(struct cmd_context *cmd,
 {
 	char *pvid;
 	const char *reason;
+	const char *device_hint;
 	struct dm_list altdevs;
 	struct dm_list new_unused;
 	struct dev_types *dt = cmd->dev_types;
@@ -515,6 +533,7 @@ static void _choose_duplicates(struct cmd_context *cmd,
 	int has_fs1, has_fs2;
 	int has_lv1, has_lv2;
 	int same_size1, same_size2;
+	int same_name1 = 0, same_name2 = 0;
 	int prev_unchosen1, prev_unchosen2;
 	int change;
 
@@ -640,6 +659,11 @@ next:
 		same_size1 = (dev1_size == pv_size);
 		same_size2 = (dev2_size == pv_size);
 
+		if ((device_hint = _get_pvsummary_device_hint(devl->dev->pvid))) {
+			same_name1 = !strcmp(device_hint, dev_name(dev1));
+			same_name2 = !strcmp(device_hint, dev_name(dev2));
+		}
+
 		has_lv1 = (dev1->flags & DEV_USED_FOR_LV) ? 1 : 0;
 		has_lv2 = (dev2->flags & DEV_USED_FOR_LV) ? 1 : 0;
 
@@ -652,10 +676,11 @@ next:
 		has_fs1 = dm_device_has_mounted_fs(dev1_major, dev1_minor);
 		has_fs2 = dm_device_has_mounted_fs(dev2_major, dev2_minor);
 
-		log_debug_cache("PV %s compare duplicates: %s %u:%u. %s %u:%u.",
+		log_debug_cache("PV %s compare duplicates: %s %u:%u. %s %u:%u. device_hint %s.",
 				devl->dev->pvid,
 				dev_name(dev1), dev1_major, dev1_minor,
-				dev_name(dev2), dev2_major, dev2_minor);
+				dev_name(dev2), dev2_major, dev2_minor,
+				device_hint ?: "none");
 
 		log_debug_cache("PV %s: size %llu. %s is %llu. %s is %llu.",
 				devl->dev->pvid,
@@ -711,6 +736,13 @@ next:
 			/* change to 2 */
 			change = 1;
 			reason = "device size is correct";
+		} else if (same_name1 && !same_name2) {
+			/* keep 1 */
+			reason = "device name matches previous";
+		} else if (same_name2 && !same_name1) {
+			/* change to 2 */
+			change = 1;
+			reason = "device name matches previous";
 		} else if (has_fs1 && !has_fs2) {
 			/* keep 1 */
 			reason = "device has fs mounted";



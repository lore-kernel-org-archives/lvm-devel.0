From: David Teigland <teigland@sourceware.org>
Date: Mon, 30 Sep 2019 12:39:56 -0400
Subject: master - scan: use PV size for choosing duplicate PV
Message-ID: <201909301639.x8UGdugw024774@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4910a31f6d3a9e52e8be85c6409b5fa93895874a
Commit:        4910a31f6d3a9e52e8be85c6409b5fa93895874a
Parent:        f3084ee2e577abe05e4707730f3cb96f2cb5ec45
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Sep 27 11:11:57 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 30 11:38:10 2019 -0500

scan: use PV size for choosing duplicate PV

Prefer a device if it matches the size of the PV.
---
 lib/cache/lvmcache.c |   41 +++++++++++++++++++++++++++++++++++++++++
 1 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 7ee94c2..d45b6db 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -387,6 +387,23 @@ const char *lvmcache_vgname_from_info(struct lvmcache_info *info)
 	return NULL;
 }
 
+static uint64_t _get_pvsummary_size(char *pvid)
+{
+	char pvid_s[ID_LEN + 1] __attribute__((aligned(8)));
+	struct lvmcache_vginfo *vginfo;
+	struct pv_list *pvl;
+
+	dm_list_iterate_items(vginfo, &_vginfos) {
+		dm_list_iterate_items(pvl, &vginfo->pvsummaries) {
+			(void) dm_strncpy(pvid_s, (char *) &pvl->pv->id, sizeof(pvid_s));
+			if (!strcmp(pvid_s, pvid))
+				return pvl->pv->size;
+		}
+	}
+
+	return 0;
+}
+
 /*
  * Check if any PVs in vg->pvs have the same PVID as any
  * entries in _unused_duplicates.
@@ -492,10 +509,12 @@ static void _choose_duplicates(struct cmd_context *cmd,
 	struct lvmcache_info *info;
 	struct device *dev1, *dev2;
 	uint32_t dev1_major, dev1_minor, dev2_major, dev2_minor;
+	uint64_t dev1_size, dev2_size, pv_size;
 	int in_subsys1, in_subsys2;
 	int is_dm1, is_dm2;
 	int has_fs1, has_fs2;
 	int has_lv1, has_lv2;
+	int same_size1, same_size2;
 	int prev_unchosen1, prev_unchosen2;
 	int change;
 
@@ -612,6 +631,15 @@ next:
 		dev2_major = MAJOR(dev2->dev);
 		dev2_minor = MINOR(dev2->dev);
 
+		if (!dev_get_size(dev1, &dev1_size))
+			dev1_size = 0;
+		if (!dev_get_size(dev2, &dev2_size))
+			dev2_size = 0;
+
+		pv_size = _get_pvsummary_size(devl->dev->pvid);
+		same_size1 = (dev1_size == pv_size);
+		same_size2 = (dev2_size == pv_size);
+
 		has_lv1 = (dev1->flags & DEV_USED_FOR_LV) ? 1 : 0;
 		has_lv2 = (dev2->flags & DEV_USED_FOR_LV) ? 1 : 0;
 
@@ -629,6 +657,12 @@ next:
 				dev_name(dev1), dev1_major, dev1_minor,
 				dev_name(dev2), dev2_major, dev2_minor);
 
+		log_debug_cache("PV %s: size %llu. %s is %llu. %s is %llu.",
+				devl->dev->pvid,
+				(unsigned long long)pv_size,
+				dev_name(dev1), (unsigned long long)dev1_size,
+				dev_name(dev2), (unsigned long long)dev2_size);
+
 		log_debug_cache("PV %s: %s was prev %s. %s was prev %s.",
 				devl->dev->pvid,
 				dev_name(dev1), prev_unchosen1 ? "not chosen" : "<none>",
@@ -670,6 +704,13 @@ next:
 			/* change to 2 */
 			change = 1;
 			reason = "device is used by LV";
+		} else if (same_size1 && !same_size2) {
+			/* keep 1 */
+			reason = "device size is correct";
+		} else if (same_size2 && !same_size1) {
+			/* change to 2 */
+			change = 1;
+			reason = "device size is correct";
 		} else if (has_fs1 && !has_fs2) {
 			/* keep 1 */
 			reason = "device has fs mounted";



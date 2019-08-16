From: David Teigland <teigland@sourceware.org>
Date: Fri, 16 Aug 2019 14:28:43 -0400
Subject: master - lvmcache: use devl list helper
Message-ID: <201908161828.x7GIShYX006513@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ee4a32e99224a0d4d2156c55d195e217967490b1
Commit:        ee4a32e99224a0d4d2156c55d195e217967490b1
Parent:        96dfad50224e7e8d3168bd0db93452e819d052b5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Aug 1 13:58:14 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Aug 16 13:26:12 2019 -0500

lvmcache: use devl list helper

---
 lib/cache/lvmcache.c |   41 +++++++++++++++++++++++++----------------
 1 files changed, 25 insertions(+), 16 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index da83b84..f2503b2 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -116,6 +116,28 @@ void lvmcache_unlock_vgname(const char *vgname)
 	}
 }
 
+static struct device_list *_get_devl_in_device_list(struct device *dev, struct dm_list *head)
+{
+	struct device_list *devl;
+
+	dm_list_iterate_items(devl, head) {
+		if (devl->dev == dev)
+			return devl;
+	}
+	return NULL;
+}
+
+int dev_in_device_list(struct device *dev, struct dm_list *head)
+{
+	struct device_list *devl;
+
+	dm_list_iterate_items(devl, head) {
+		if (devl->dev == dev)
+			return 1;
+	}
+	return 0;
+}
+
 bool lvmcache_has_duplicate_devs(void)
 {
 	if (dm_list_empty(&_unused_duplicates) && dm_list_empty(&_initial_duplicates))
@@ -147,11 +169,9 @@ void lvmcache_del_dev_from_duplicates(struct device *dev)
 {
 	struct device_list *devl;
 
-	dm_list_iterate_items(devl, &_unused_duplicates) {
-		if (devl->dev == dev) {
-			dm_list_del(&devl->list);
-			return;
-		}
+	if ((devl = _get_devl_in_device_list(dev, &_unused_duplicates))) {
+		log_debug_cache("delete dev from unused duplicates %s", dev_name(dev));
+		dm_list_del(&devl->list);
 	}
 }
 
@@ -381,17 +401,6 @@ int vg_has_duplicate_pvs(struct volume_group *vg)
 	return 0;
 }
 
-int dev_in_device_list(struct device *dev, struct dm_list *head)
-{
-	struct device_list *devl;
-
-	dm_list_iterate_items(devl, head) {
-		if (devl->dev == dev)
-			return 1;
-	}
-	return 0;
-}
-
 bool lvmcache_dev_is_unused_duplicate(struct device *dev)
 {
 	return dev_in_device_list(dev, &_unused_duplicates) ? true : false;



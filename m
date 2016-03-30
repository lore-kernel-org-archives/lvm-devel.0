From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 30 Mar 2016 11:07:13 +0000 (UTC)
Subject: master - dev-cache: dev_cache_index_devs fn is available unconditionally
Message-ID: <20160330110713.D178660D63@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8b258a005ba6852209ec7af5b373a69f437abfaa
Commit:        8b258a005ba6852209ec7af5b373a69f437abfaa
Parent:        52e0d0db4460d90172e9bd45b9ef30e7f4f75ae7
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Mar 30 13:06:12 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Mar 30 13:06:20 2016 +0200

dev-cache: dev_cache_index_devs fn is available unconditionally

The new dev_cache_index_devs fn was under ifdef UDEV_SYNC_SUPPORT by mistake,
move it out of this ifdef.
---
 lib/device/dev-cache.c |   36 ++++++++++++++++++------------------
 1 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 1729aba..50ef2f2 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -777,6 +777,24 @@ static int _insert_file(const char *path)
 	return 1;
 }
 
+int dev_cache_index_devs(void)
+{
+	struct btree_iter *iter = btree_first(_cache.devices);
+	struct device *dev;
+	int r = 1;
+
+	while (iter) {
+		dev = btree_get_data(iter);
+
+		if (!_index_dev_by_vgid_and_lvid(dev))
+			r = 0;
+
+		iter = btree_next(iter);
+	}
+
+	return r;
+}
+
 #ifdef UDEV_SYNC_SUPPORT
 
 static int _device_in_udev_db(const dev_t d)
@@ -854,24 +872,6 @@ bad:
 	return 0;
 }
 
-int dev_cache_index_devs(void)
-{
-	struct btree_iter *iter = btree_first(_cache.devices);
-	struct device *dev;
-	int r = 1;
-
-	while (iter) {
-		dev = btree_get_data(iter);
-
-		if (!_index_dev_by_vgid_and_lvid(dev))
-			r = 0;
-
-		iter = btree_next(iter);
-	}
-
-	return r;
-}
-
 static void _insert_dirs(struct dm_list *dirs)
 {
 	struct dir_list *dl;



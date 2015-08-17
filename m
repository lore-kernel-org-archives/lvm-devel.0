From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 17 Aug 2015 11:59:52 +0000 (UTC)
Subject: master - device: Don't try to close config file on failure.
Message-ID: <20150817115952.0D07B60D7B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=623b46a17d4163b42f9f65c41d5c8d8f95ec95c5
Commit:        623b46a17d4163b42f9f65c41d5c8d8f95ec95c5
Parent:        a606966029d411a1336eb5bc2f99a4162e0d97d6
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Aug 17 12:57:01 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Aug 17 12:57:01 2015 +0100

device: Don't try to close config file on failure.

$file: open failed: Permission denied
Failed to load config file $file
Attempt to close device '$file' which is not open.
---
 WHATS_NEW              |    1 +
 lib/config/config.c    |    5 ++++-
 lib/device/dev-cache.c |   10 ++++++++++
 lib/device/dev-io.c    |    8 ++------
 lib/device/device.h    |    1 +
 5 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index dbb78d6..7508794 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.128 - 
 ===================================
+  Don't attempt to close config file that couldn't be opened.
   Check for valid cache mode in validation of cache segment.
   Change internal interface handling cache mode and policy.
   When no cache policy specified, prefer smq (if available) over mq.
diff --git a/lib/config/config.c b/lib/config/config.c
index cd6c1d8..ad2db76 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -582,8 +582,11 @@ int config_file_read(struct dm_config_tree *cft)
 		if (!(cf->dev = dev_create_file(filename, NULL, NULL, 1)))
 			return_0;
 
-		if (!dev_open_readonly_buffered(cf->dev))
+		if (!dev_open_readonly_buffered(cf->dev)) {
+			dev_destroy_file(cf->dev);
+			cf->dev = NULL;
 			return_0;
+		}
 	}
 
 	r = config_file_read_fd(cft, cf->dev, 0, (size_t) info.st_size, 0, 0,
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index e58ac0f..043a722 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -71,6 +71,16 @@ static void _dev_init(struct device *dev, int max_error_count)
 	dm_list_init(&dev->open_list);
 }
 
+void dev_destroy_file(struct device *dev)
+{
+	if (!(dev->flags & DEV_ALLOCED))
+		return;
+
+	dm_free((void *) dm_list_item(dev->aliases.n, struct dm_str_list)->str);
+	dm_free(dev->aliases.n);
+	dm_free(dev);
+}
+
 struct device *dev_create_file(const char *filename, struct device *dev,
 			       struct dm_str_list *alias, int use_malloc)
 {
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index d712f31..8c2388b 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -586,12 +586,8 @@ static void _close(struct device *dev)
 
 	log_debug_devs("Closed %s", dev_name(dev));
 
-	if (dev->flags & DEV_ALLOCED) {
-		dm_free((void *) dm_list_item(dev->aliases.n, struct dm_str_list)->
-			 str);
-		dm_free(dev->aliases.n);
-		dm_free(dev);
-	}
+	if (dev->flags & DEV_ALLOCED)
+		dev_destroy_file(dev);
 }
 
 static int _dev_close(struct device *dev, int immediate)
diff --git a/lib/device/device.h b/lib/device/device.h
index dcc3713..733b0d0 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -123,6 +123,7 @@ void dev_flush(struct device *dev);
 
 struct device *dev_create_file(const char *filename, struct device *dev,
 			       struct dm_str_list *alias, int use_malloc);
+void dev_destroy_file(struct device *dev);
 
 /* Return a valid device name from the alias list; NULL otherwise */
 const char *dev_name_confirmed(struct device *dev, int quiet);



From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 25 Nov 2011 10:59:03 +0100
Subject: [PATCH 1/7] Add common initialization code for struct device
In-Reply-To: <cover.1322213495.git.zkabelac@redhat.com>
References: <cover.1322213495.git.zkabelac@redhat.com>
Message-ID: <917b1baf3796c807461bc88d61bcb33a9ea0b95b.1322213495.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Avoid duplicate code and add _dev_init() where all common
member values are initialized.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/device/dev-cache.c |   34 +++++++++++++++++-----------------
 1 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 3c44333..22e5cce 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -54,6 +54,19 @@ static struct {
 
 static int _insert(const char *path, int rec, int check_with_udev_db);
 
+static void _dev_init(struct device *dev)
+{
+	dev->block_size = -1;
+	dev->end = UINT64_C(0);
+	dev->fd = -1;
+	dev->max_error_count = dev_disable_after_error_count();
+	dev->open_count = 0;
+	dev->read_ahead = -1;
+	memset(dev->pvid, 0, sizeof(dev->pvid));
+	dm_list_init(&dev->aliases);
+	dm_list_init(&dev->open_list);
+}
+
 struct device *dev_create_file(const char *filename, struct device *dev,
 			       struct str_list *alias, int use_malloc)
 {
@@ -97,19 +110,12 @@ struct device *dev_create_file(const char *filename, struct device *dev,
 		return NULL;
 	}
 
-	dev->flags |= DEV_REGULAR;
-	dm_list_init(&dev->aliases);
+	_dev_init(dev);
+	dev->flags = DEV_REGULAR;
 	dm_list_add(&dev->aliases, &alias->list);
-	dev->end = UINT64_C(0);
 	dev->dev = 0;
-	dev->fd = -1;
-	dev->open_count = 0;
 	dev->error_count = 0;
 	dev->max_error_count = NO_DEV_ERROR_COUNT_LIMIT;
-	dev->block_size = -1;
-	dev->read_ahead = -1;
-	memset(dev->pvid, 0, sizeof(dev->pvid));
-	dm_list_init(&dev->open_list);
 
 	return dev;
 }
@@ -122,17 +128,11 @@ static struct device *_dev_create(dev_t d)
 		log_error("struct device allocation failed");
 		return NULL;
 	}
+
+	_dev_init(dev);
 	dev->flags = 0;
-	dm_list_init(&dev->aliases);
 	dev->dev = d;
-	dev->fd = -1;
-	dev->open_count = 0;
 	dev->max_error_count = dev_disable_after_error_count();
-	dev->block_size = -1;
-	dev->read_ahead = -1;
-	dev->end = UINT64_C(0);
-	memset(dev->pvid, 0, sizeof(dev->pvid));
-	dm_list_init(&dev->open_list);
 
 	return dev;
 }
-- 
1.7.7.3



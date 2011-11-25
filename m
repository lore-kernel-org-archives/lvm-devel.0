From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 25 Nov 2011 10:59:04 +0100
Subject: [PATCH 2/7] Add caching of BLKGETSIZE64 ioctl
In-Reply-To: <cover.1322213495.git.zkabelac@redhat.com>
References: <cover.1322213495.git.zkabelac@redhat.com>
Message-ID: <431e8d13b872bed52fc9df15ac31fd69eda5b038.1322213495.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Do not open/ioctl/close same device multiple times,
when its in device cache.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/device/dev-cache.c |    1 +
 lib/device/dev-io.c    |   27 ++++++++++++++++-----------
 lib/device/device.h    |    1 +
 3 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 22e5cce..61f479d 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -56,6 +56,7 @@ static int _insert(const char *path, int rec, int check_with_udev_db);
 
 static void _dev_init(struct device *dev)
 {
+	dev->blkgetsize64 = -1;
 	dev->block_size = -1;
 	dev->end = UINT64_C(0);
 	dev->fd = -1;
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 9b486a9..46b90b5 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -252,21 +252,26 @@ static int _dev_get_size_dev(const struct device *dev, uint64_t *size)
 	int fd;
 	const char *name = dev_name(dev);
 
-	if ((fd = open(name, O_RDONLY)) < 0) {
-		log_sys_error("open", name);
-		return 0;
-	}
+	if (dev->blkgetsize64 == -1) {
+		if ((fd = open(name, O_RDONLY)) < 0) {
+			log_sys_error("open", name);
+			return 0;
+		}
+
+		if (ioctl(fd, BLKGETSIZE64, &dev->blkgetsize64) < 0) {
+			log_sys_error("ioctl BLKGETSIZE64", name);
+			if (close(fd))
+				log_sys_error("close", name);
+			return 0;
+		}
 
-	if (ioctl(fd, BLKGETSIZE64, size) < 0) {
-		log_sys_error("ioctl BLKGETSIZE64", name);
 		if (close(fd))
 			log_sys_error("close", name);
-		return 0;
-	}
 
-	*size >>= BLKSIZE_SHIFT;	/* Convert to sectors */
-	if (close(fd))
-		log_sys_error("close", name);
+	} else
+		log_debug("Using cached size for device %s.", name);
+
+	*size = dev->blkgetsize64 >> BLKSIZE_SHIFT;  /* Convert to sectors */
 
 	log_very_verbose("%s: size is %" PRIu64 " sectors", name, *size);
 
diff --git a/lib/device/device.h b/lib/device/device.h
index 8c32a03..1d6d27d 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -45,6 +45,7 @@ struct device {
 	int read_ahead;
 	uint32_t flags;
 	uint64_t end;
+	uint64_t blkgetsize64;
 	struct dm_list open_list;
 
 	char pvid[ID_LEN + 1];
-- 
1.7.7.3



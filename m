From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 10 Dec 2019 09:46:29 -0500
Subject: master - debug: avoid to slashes in debug message
Message-ID: <15354.119121009462601073@us-mta-32.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cff16b062badbc65661940b021c06d3b1c423562
Commit:        cff16b062badbc65661940b021c06d3b1c423562
Parent:        e70d5d470c196f81c125c2705c065302608dbfbe
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 24 16:36:01 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 10 15:44:16 2019 +0100

debug: avoid to slashes in debug message

---
 lib/device/dev-cache.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 3dcfc10..e17b13f 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1522,7 +1522,7 @@ struct device *dev_cache_get_by_devt(struct cmd_context *cmd, dev_t dev, struct
 		sysfs_dir = dm_sysfs_dir();
 		if (sysfs_dir && *sysfs_dir) {
 			/* First check if dev is sysfs to avoid useless scan */
-			if (dm_snprintf(path, sizeof(path), "%s/dev/block/%d:%d",
+			if (dm_snprintf(path, sizeof(path), "%sdev/block/%d:%d",
 					sysfs_dir, (int)MAJOR(dev), (int)MINOR(dev)) < 0) {
 				log_error("dm_snprintf partition failed.");
 				return NULL;




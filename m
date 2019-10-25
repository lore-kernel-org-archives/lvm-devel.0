From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 25 Oct 2019 18:55:33 -0400
Subject: stable-2.02 - debug: avoid to slashes in debug message
Message-ID: <201910252255.x9PMtXet011974@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=36b8b9ed5c4b96d3a6482d76ca3eae54c62f9f2b
Commit:        36b8b9ed5c4b96d3a6482d76ca3eae54c62f9f2b
Parent:        cd39b67b7e91c06937d422b1f230b3b3f6e5a1ca
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 24 16:36:01 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Oct 26 00:29:44 2019 +0200

debug: avoid to slashes in debug message

---
 lib/device/dev-cache.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index a429b10..f705ea3 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1590,7 +1590,7 @@ struct device *dev_cache_get_by_devt(dev_t dev, struct dev_filter *f)
 		sysfs_dir = dm_sysfs_dir();
 		if (sysfs_dir && *sysfs_dir) {
 			/* First check if dev is sysfs to avoid useless scan */
-			if (dm_snprintf(path, sizeof(path), "%s/dev/block/%d:%d",
+			if (dm_snprintf(path, sizeof(path), "%sdev/block/%d:%d",
 					sysfs_dir, (int)MAJOR(dev), (int)MINOR(dev)) < 0) {
 				log_error("dm_snprintf partition failed.");
 				return NULL;



From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 18 Oct 2021 19:51:39 +0000 (GMT)
Subject: main - dev-cache: enhance dir scan also for non-udev build
Message-ID: <20211018195139.349F03858404@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=60dc44b707149e31fa766885574484aa5172f498
Commit:        60dc44b707149e31fa766885574484aa5172f498
Parent:        88e0d68909c007576272d65216b0e7a9011b9c9b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 18 21:50:56 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 18 21:50:56 2021 +0200

dev-cache: enhance dir scan also for non-udev build

---
 lib/device/dev-cache.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 57fa916a9..c6e5f68cf 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1099,9 +1099,17 @@ static int _device_in_udev_db(const dev_t d)
 static void _insert_dirs(struct dm_list *dirs)
 {
 	struct dir_list *dl;
+	struct stat tinfo;
 
-	dm_list_iterate_items(dl, &_cache.dirs)
+	dm_list_iterate_items(dl, &_cache.dirs) {
+		if (stat(dl->dir, &tinfo) < 0) {
+			log_warn("WARNING: Cannot use dir %s, %s.",
+				 dl->dir, strerror(errno));
+			continue;
+		}
+		_cache.st_dev = tinfo.st_dev;
 		_insert_dir(dl->dir);
+	}
 }
 
 #endif	/* UDEV_SYNC_SUPPORT */



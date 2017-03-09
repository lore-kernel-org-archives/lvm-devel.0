From: Bryn Reeves <bmr@sourceware.org>
Date: Thu, 9 Mar 2017 16:22:15 -0500
Subject: master - libdm: don't nest FIEMAP and DMFILEMAPD ifdefs
Message-ID: <201703092122.v29LMFrr004290@int-mx10.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0104fd6c660d69b6e00bd906a2aed503bdb1ba5e
Commit:        0104fd6c660d69b6e00bd906a2aed503bdb1ba5e
Parent:        af7a11bc57b2a3bb103cde47812a876b8d7a2d71
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Mar 9 21:13:51 2017 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Mar 9 21:20:27 2017 +0000

libdm: don't nest FIEMAP and DMFILEMAPD ifdefs

---
 libdm/libdm-stats.c |   43 +++++++++++++++++--------------------------
 1 files changed, 17 insertions(+), 26 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 7552ac6..616c6bb 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4877,6 +4877,23 @@ out:
 	dm_free((char *) alias);
 	return NULL;
 }
+#else /* !HAVE_LINUX_FIEMAP */
+uint64_t *dm_stats_create_regions_from_fd(struct dm_stats *dms, int fd,
+					  int group, int precise,
+					  struct dm_histogram *bounds,
+					  const char *alias)
+{
+	log_error("File mapping requires FIEMAP ioctl support.");
+	return 0;
+}
+
+uint64_t *dm_stats_update_regions_from_fd(struct dm_stats *dms, int fd,
+					  uint64_t group_id)
+{
+	log_error("File mapping requires FIEMAP ioctl support.");
+	return 0;
+}
+#endif /* HAVE_LINUX_FIEMAP */
 
 #ifdef DMFILEMAPD
 static const char *_filemapd_mode_names[] = {
@@ -5026,32 +5043,6 @@ int dm_stats_start_filemapd(int fd, uint64_t group_id, const char *path,
 }
 #endif /* DMFILEMAPD */
 
-#else /* HAVE_LINUX_FIEMAP */
-
-uint64_t *dm_stats_create_regions_from_fd(struct dm_stats *dms, int fd,
-					  int group, int precise,
-					  struct dm_histogram *bounds,
-					  const char *alias)
-{
-	log_error("File mapping requires FIEMAP ioctl support.");
-	return 0;
-}
-
-uint64_t *dm_stats_update_regions_from_fd(struct dm_stats *dms, int fd,
-					  uint64_t group_id)
-{
-	log_error("File mapping requires FIEMAP ioctl support.");
-	return 0;
-}
-
-int dm_stats_start_filemapd(struct dm_stats *dms, int fd, uint64_t group_id,
-			    const char *path)
-{
-	log_error("File mapping requires FIEMAP ioctl support.");
-	return 0;
-}
-#endif /* HAVE_LINUX_FIEMAP */
-
 /*
  * Backward compatible dm_stats_create_region() implementations.
  *



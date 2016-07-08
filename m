From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri,  8 Jul 2016 21:05:52 +0000 (UTC)
Subject: master - libdm: use SECTOR_SHIFT constant in _stats_add_extent()
Message-ID: <20160708210552.30839608F3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=58bfea6a6e2789896e81fefe18e504fb7222e834
Commit:        58bfea6a6e2789896e81fefe18e504fb7222e834
Parent:        7771793a560b839e6bc4083819bc5b192d94835a
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Jul 8 21:12:18 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Jul 8 22:05:36 2016 +0100

libdm: use SECTOR_SHIFT constant in _stats_add_extent()

---
 libdm/libdm-stats.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 6504289..d911c60 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -38,6 +38,8 @@
 #define STATS_ROW_BUF_LEN 4096
 #define STATS_MSG_BUF_LEN 1024
 
+#define SECTOR_SHIFT 9L
+
 /* Histogram bin */
 struct dm_histogram_bin {
 	uint64_t upper; /* Upper bound on this bin. */
@@ -4120,8 +4122,8 @@ static int _stats_add_extent(struct dm_pool *mem, struct fiemap_extent *fm_ext,
 	memset(&extent.list, 0, sizeof(extent.list));
 
 	/* convert bytes to dm (512b) sectors */
-	extent.start = fm_ext->fe_physical >> 9;
-	extent.len = fm_ext->fe_length >> 9;
+	extent.start = fm_ext->fe_physical >> SECTOR_SHIFT;
+	extent.len = fm_ext->fe_length >> SECTOR_SHIFT;
 
 	extent.id = id;
 



From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri,  8 Jul 2016 21:05:54 +0000 (UTC)
Subject: master - libdm: use a constant for FIEMAP buffer size
Message-ID: <20160708210554.5EAE6608F3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2d1f03b6164bce6f871918f563de9d8233e76f93
Commit:        2d1f03b6164bce6f871918f563de9d8233e76f93
Parent:        58bfea6a6e2789896e81fefe18e504fb7222e834
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Jul 8 21:13:25 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Jul 8 22:05:36 2016 +0100

libdm: use a constant for FIEMAP buffer size

---
 libdm/libdm-stats.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index d911c60..bf9b7e3 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -37,6 +37,7 @@
 
 #define STATS_ROW_BUF_LEN 4096
 #define STATS_MSG_BUF_LEN 1024
+#define STATS_FIE_BUF_LEN 2048
 
 #define SECTOR_SHIFT 9L
 
@@ -4147,7 +4148,7 @@ static int _stats_add_extent(struct dm_pool *mem, struct fiemap_extent *fm_ext,
 static struct _extent *_stats_get_extents_for_file(struct dm_pool *mem, int fd,
 						   uint64_t *count)
 {
-	uint64_t buf[2048];
+	uint64_t buf[STATS_FIE_BUF_LEN];
 	struct fiemap *fiemap = (struct fiemap *)buf;
 	struct fiemap_extent *fm_ext = &fiemap->fm_extents[0];
 	struct fiemap_extent fm_last = {0};



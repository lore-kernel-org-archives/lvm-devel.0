From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon,  3 Oct 2016 13:43:06 +0000 (UTC)
Subject: master - libdm: convert FIEMAP buffer allocation from stack to pool
Message-ID: <20161003134306.6D3566108D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ca00a4d4e1c9b9742918e478b1f71310001b91fa
Commit:        ca00a4d4e1c9b9742918e478b1f71310001b91fa
Parent:        49a1c4d4b0f2c5fbc83a1ad4bfde59a366049b2a
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Oct 3 14:42:30 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Oct 3 14:42:30 2016 +0100

libdm: convert FIEMAP buffer allocation from stack to pool

---
 libdm/libdm-stats.c |   20 +++++++++++++++-----
 1 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index a033861..dc30051 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4195,9 +4195,9 @@ static int _stats_add_extent(struct dm_pool *mem, struct fiemap_extent *fm_ext,
 static struct _extent *_stats_get_extents_for_file(struct dm_pool *mem, int fd,
 						   uint64_t *count)
 {
-	uint64_t buf[STATS_FIE_BUF_LEN];
-	struct fiemap *fiemap = (struct fiemap *)buf;
-	struct fiemap_extent *fm_ext = &fiemap->fm_extents[0];
+	uint64_t *buf;
+	struct fiemap *fiemap = NULL;
+	struct fiemap_extent *fm_ext = NULL;
 	struct fiemap_extent fm_last = {0};
 	struct _extent *extents;
 	unsigned long long expected = 0;
@@ -4208,10 +4208,19 @@ static struct _extent *_stats_get_extents_for_file(struct dm_pool *mem, int fd,
 	int last = 0;
 	int rc;
 
-	memset(buf, 0, sizeof(buf));
+
+	buf = dm_pool_zalloc(mem, STATS_FIE_BUF_LEN);
+	if (!buf) {
+		log_error("Could not allocate memory for FIEMAP buffer.");
+		return NULL;
+	}
+
+	/* initialise pointers into the ioctl buffer. */
+	fiemap = (struct fiemap *) buf;
+	fm_ext = &fiemap->fm_extents[0];
 
 	/* space available per ioctl */
-	*count = (sizeof(buf) - sizeof(*fiemap))
+	*count = (STATS_FIE_BUF_LEN - sizeof(*fiemap))
 		  / sizeof(struct fiemap_extent);
 
 	/* grow temporary extent table in the pool */
@@ -4280,6 +4289,7 @@ static struct _extent *_stats_get_extents_for_file(struct dm_pool *mem, int fd,
 	return dm_pool_end_object(mem);
 bad:
 	dm_pool_abandon_object(mem);
+	dm_pool_free(mem, buf);
 	return NULL;
 }
 



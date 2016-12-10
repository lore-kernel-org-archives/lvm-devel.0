From: Bryn Reeves <bmr@fedoraproject.org>
Date: Sat, 10 Dec 2016 13:31:47 +0000 (UTC)
Subject: master - libdm: fix filemap cleanup loop condition
Message-ID: <20161210133147.AF0D96065A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b311122a5666489f5dbeae09952dfbcd533f5a36
Commit:        b311122a5666489f5dbeae09952dfbcd533f5a36
Parent:        d8ba8ee9aea0b23a4ff03d19f7ddbe6511cdcbbd
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sat Dec 10 13:28:21 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Sat Dec 10 13:31:12 2016 +0000

libdm: fix filemap cleanup loop condition

---
 libdm/libdm-stats.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 78b66ab..850aa49 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4323,7 +4323,7 @@ static uint64_t *_stats_create_file_regions(struct dm_stats *dms, int fd,
 					    struct dm_histogram *bounds,
 					    int precise, uint64_t *count)
 {
-	uint64_t *regions = NULL, i, max_region;
+	uint64_t *regions = NULL, i, fail_region;
 	struct dm_pool *extent_mem = NULL;
 	struct _extent *extents = NULL;
 	char *hist_arg = NULL;
@@ -4411,8 +4411,8 @@ out_remove:
 	 */
 	dm_stats_list(dms, NULL);
 
-	max_region = i;
-	for (i = max_region - 1; i < max_region; i++)
+	fail_region = i;
+	for (i = 0; i < fail_region; i++)
 		if (!_stats_delete_region(dms, regions[i]))
 			log_error("Could not delete region " FMTu64 ".", i);
 



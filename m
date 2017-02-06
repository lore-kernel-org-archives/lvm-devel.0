From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Feb 2017 12:17:36 +0000 (UTC)
Subject: master - cleanup: hide gcc warning
Message-ID: <20170206121736.CF53960D2C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=811d137d3f93da892365f9c9a4772033a891c687
Commit:        811d137d3f93da892365f9c9a4772033a891c687
Parent:        9fe8c2da36a42a9cf08ef44ede172e1341033a24
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 6 11:41:22 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 6 11:43:07 2017 +0100

cleanup: hide gcc warning

Gcc is not clever enough to see these vars are actually initialize in
given code path so let's just make sure it has a value.
---
 libdm/libdm-stats.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index f0342a0..f68874c 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4584,7 +4584,7 @@ static uint64_t *_stats_map_file_regions(struct dm_stats *dms, int fd,
 					 int precise, uint64_t group_id,
 					 uint64_t *count, int *regroup)
 {
-	struct _extent *extents = NULL, *old_extents;
+	struct _extent *extents = NULL, *old_extents = NULL;
 	uint64_t *regions = NULL, fail_region;
 	struct dm_stats_group *group = NULL;
 	struct dm_pool *extent_mem = NULL;
@@ -4592,7 +4592,7 @@ static uint64_t *_stats_map_file_regions(struct dm_stats *dms, int fd,
 	char *hist_arg = NULL;
 	int update, num_bits;
 	struct statfs fsbuf;
-	int64_t nr_kept, i;
+	int64_t nr_kept = 0, i;
 	struct stat buf;
 
 	update = _stats_group_id_present(dms, group_id);



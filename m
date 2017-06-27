From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 27 Jun 2017 06:20:23 -0400
Subject: master - coverity: move initilization of count variable
Message-ID: <201706271020.v5RAKNHm003934@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5ff6260071ef2465ba33ce6dd9b7c7b3168f4c88
Commit:        5ff6260071ef2465ba33ce6dd9b7c7b3168f4c88
Parent:        0349b6d889551b33d4bf26ffaa71dc6c0eb88198
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 27 12:05:27 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 27 12:16:33 2017 +0200

coverity: move initilization of count variable

Make code more understandble for Coverity, so it sees connection
between 'extents' and 'count' and in fact code is more readable.
---
 libdm/libdm-stats.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index b0c9e4b..5cb7c2c 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4606,6 +4606,7 @@ static uint64_t *_stats_map_file_regions(struct dm_stats *dms, int fd,
 	struct stat buf;
 	int update;
 
+	*count = 0;
 	update = _stats_group_id_present(dms, group_id);
 
 #ifdef BTRFS_SUPER_MAGIC
@@ -4771,7 +4772,7 @@ uint64_t *dm_stats_create_regions_from_fd(struct dm_stats *dms, int fd,
 					  struct dm_histogram *bounds,
 					  const char *alias)
 {
-	uint64_t *regions, count = 0;
+	uint64_t *regions, count;
 	int regroup = 1;
 
 	if (alias && !group) {



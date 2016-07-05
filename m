From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:54:31 +0000 (UTC)
Subject: master - libdm: rename 'region' to 'skip_region' in _stats_walk_next
Message-ID: <20160705185431.E601860DC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4cd3dcbbc20d0cd97a87d0e584dd91baea1ff34d
Commit:        4cd3dcbbc20d0cd97a87d0e584dd91baea1ff34d
Parent:        82e57660623c6b131632a5ec37deef3428de5399
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Jun 20 17:12:38 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:53:16 2016 +0100

libdm: rename 'region' to 'skip_region' in _stats_walk_next

In libdm-stats.c 'region' usually refers to a 'struct region*'.
Rename the argument to _stats_walk_start to avoid confusion.
---
 libdm/libdm-stats.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index e89f3d6..dc97346 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -1003,7 +1003,7 @@ bad:
 	return 0;
 }
 
-static void _stats_walk_next(const struct dm_stats *dms, int region,
+static void _stats_walk_next(const struct dm_stats *dms, int skip_region,
 			     uint64_t *cur_r, uint64_t *cur_a)
 {
 	struct dm_stats_region *cur;
@@ -1015,17 +1015,16 @@ static void _stats_walk_next(const struct dm_stats *dms, int region,
 	cur = dms->regions + *cur_r;
 	present = _stats_region_present(cur);
 
-	if (region && present)
+	if (skip_region && present)
 		*cur_a = _nr_areas_region(cur);
 
-	if (region || !present || ++(*cur_a) == _nr_areas_region(cur)) {
+	if (skip_region || !present || ++(*cur_a) == _nr_areas_region(cur)) {
 		*cur_a = 0;
 		while(!dm_stats_region_present(dms, ++(*cur_r))
 		      && *cur_r < dms->max_region)
 			; /* keep walking until a present region is found
 			   * or the end of the table is reached. */
 	}
-
 }
 
 static void _stats_walk_start(const struct dm_stats *dms,



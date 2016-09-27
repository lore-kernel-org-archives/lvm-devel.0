From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue, 27 Sep 2016 13:47:33 +0000 (UTC)
Subject: master - libdm: fix stats walk compatibility with older dmsetup
Message-ID: <20160927134733.5E5DE60804@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6ec8854fdb051b092d5e262dc6c6d4c2ea075cd1
Commit:        6ec8854fdb051b092d5e262dc6c6d4c2ea075cd1
Parent:        0a480c5c52bd34a1eb8337d59a7f4cc60317d2b1
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Tue Sep 27 14:35:22 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Sep 27 14:46:00 2016 +0100

libdm: fix stats walk compatibility with older dmsetup

The current dmsetup.c handles DR_STATS and DR_STATS_META reports
separately in _display_info_cols(), meaning that the stats walk
functions are never called for these report types.

Versions before v2.02.159 have a loop using dm_stats_walk_do() and
dm_stats_walk_while(), that executes once for non-stats reports,
and once per region, or area, for DR_STATS/DR_STATS_META reports.

This older behaviour relies on the documented behaviour that the
walk functions will accept a NULL pointer as the struct dm_stats*
argument.

This was broken by commit f1f2df7b: the NULL test on dms and
dms->regions were incorrectly moved from the dm_stats_walk_end()
wrapper to the internal '_stats_walk_end()' helper.

Since the pointer is dereferenced in between these points, using
an older dmsetup with current libdm results in a segfault when
running a non-stats report:

  # dmsetup info -c vg00/lvol0
  Segmentation fault (core dumped)

Restore the NULL checks to the wrapper function as intended.
---
 WHATS_NEW_DM        |    1 +
 libdm/libdm-stats.c |    6 +++---
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 29dbccc..b048f7a 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.136 - 
 ======================================
+  Fix stats walk segfault with dmsetup older than v1.02.129
 
 Version 1.02.135 - 26th September 2016
 ======================================
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index ffd349c..75e0144 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -1526,9 +1526,6 @@ static void _stats_walk_end_areas(const struct dm_stats *dms, uint64_t *flags,
 static int _stats_walk_end(const struct dm_stats *dms, uint64_t *flags,
 			   uint64_t *cur_r, uint64_t *cur_a, uint64_t *cur_g)
 {
-	if (!dms || !dms->regions)
-		return 1;
-
 	if (*flags & DM_STATS_WALK_AREA) {
 		_stats_walk_end_areas(dms, flags, cur_r, cur_a, cur_g);
 		goto out;
@@ -1553,6 +1550,9 @@ out:
 
 int dm_stats_walk_end(struct dm_stats *dms)
 {
+	if (!dms || !dms->regions)
+		return 1;
+
 	if (_stats_walk_end(dms, &dms->cur_flags,
 			    &dms->cur_region, &dms->cur_area,
 			    &dms->cur_group)) {



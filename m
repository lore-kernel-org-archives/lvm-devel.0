From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri, 14 Aug 2015 21:05:18 +0000 (UTC)
Subject: master - libdm: ensure dm_stats_get_area_start includes region offset
Message-ID: <20150814210518.8658860B3D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=77fae3d8522ffb1077dcb0e2e9ebfba86cf19daf
Commit:        77fae3d8522ffb1077dcb0e2e9ebfba86cf19daf
Parent:        16ff2d927f6ce2f8c2ad8f7e6ec8fb52bd2a066c
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Aug 14 20:28:06 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Aug 14 22:03:37 2015 +0100

libdm: ensure dm_stats_get_area_start includes region offset

The dm_stats_get_area_start (and its '_current_' variant) methods
are expected to return the start sector of the area in the
containing device.

Make sure the call adds region->start to the returned value.
---
 libdm/libdm-stats.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index ea4feef..51aba79 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -1328,9 +1328,10 @@ uint64_t dm_stats_get_current_region_area_len(const struct dm_stats *dms,
 uint64_t dm_stats_get_area_start(const struct dm_stats *dms, uint64_t *start,
 				 uint64_t region_id, uint64_t area_id)
 {
+	struct dm_stats_region *region = &dms->regions[region_id];
 	if (!dms || !dms->regions)
 		return_0;
-	*start = dms->regions[region_id].step * area_id;
+	*start = region->start + region->step * area_id;
 	return 1;
 }
 



From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon, 17 Aug 2015 17:37:30 +0000 (UTC)
Subject: master - libdm: do not read region before checking dms for NULL (Coverity)
Message-ID: <20150817173730.05F9060701@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8967776713e1be2d584bc8a9713eaaaf467d8ac7
Commit:        8967776713e1be2d584bc8a9713eaaaf467d8ac7
Parent:        d1c65d1b28c8942b4296da30dc95b7e7de33e5fe
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Aug 17 18:25:22 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Aug 17 18:37:16 2015 +0100

libdm: do not read region before checking dms for NULL (Coverity)

dm_stats_get_area_start() attempts to assign a region pointer from
a stats handle before checking it is non-NULL: move the assignment
after the test.
---
 libdm/libdm-stats.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index f8d0012..b7000cc 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -1328,9 +1328,10 @@ int dm_stats_get_current_region_area_len(const struct dm_stats *dms,
 int dm_stats_get_area_start(const struct dm_stats *dms, uint64_t *start,
 			    uint64_t region_id, uint64_t area_id)
 {
-	struct dm_stats_region *region = &dms->regions[region_id];
+	struct dm_stats_region *region;
 	if (!dms || !dms->regions)
 		return_0;
+	region = &dms->regions[region_id];
 	*start = region->start + region->step * area_id;
 	return 1;
 }



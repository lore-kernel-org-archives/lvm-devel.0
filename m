From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:55:28 +0000 (UTC)
Subject: master - libdm: fix <backtrace> in dm_stats_populate
Message-ID: <20160705185528.4F3EA613E4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0f64f2d5fcf6cc9fa6529bde918938755b644128
Commit:        0f64f2d5fcf6cc9fa6529bde918938755b644128
Parent:        53e92441a613270750c12089b119337a71ff545a
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Tue Jul 5 18:34:14 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:53:17 2016 +0100

libdm: fix <backtrace> in dm_stats_populate

---
 libdm/libdm-stats.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index ab15589..83c4d50 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -2227,7 +2227,7 @@ int dm_stats_populate(struct dm_stats *dms, const char *program_id,
 
 	/* successful list but no regions registered */
 	if (!dms->nr_regions)
-		return_0;
+		return 0;
 
 	dms->walk_flags = DM_STATS_WALK_REGION;
 	dm_stats_walk_start(dms);



From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 22 Feb 2016 13:28:27 +0000 (UTC)
Subject: master - cleanup: libdm clang warnings
Message-ID: <20160222132827.EE78560F3F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fba54ae55e888d290f8783d813bbecf3f1cfdd61
Commit:        fba54ae55e888d290f8783d813bbecf3f1cfdd61
Parent:        275c9f7e7789124ba67533522e7b3a347f5a6f8f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 22 10:49:45 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 22 14:18:28 2016 +0100

cleanup: libdm clang warnings

Add some extra clang pointer validation so we do not try deref NULL.
---
 libdm/libdm-stats.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index d32e4ea..1eeca06 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -963,7 +963,9 @@ static void _stats_walk_next(const struct dm_stats *dms, int region,
 	if (!dms || !dms->regions)
 		return;
 
-	cur = &dms->regions[*cur_r];
+	if (!(cur = &dms->regions[*cur_r]))
+		return;
+
 	present = _stats_region_present(cur);
 
 	if (region && present)
@@ -1314,7 +1316,7 @@ static int _dm_stats_populate_region(struct dm_stats *dms, uint64_t region_id,
 	if (!_stats_bound(dms))
 		return_0;
 
-	if (!_stats_parse_region(dms, resp, region, region->timescale)) {
+	if (!region || !_stats_parse_region(dms, resp, region, region->timescale)) {
 		log_error("Could not parse @stats_print message response.");
 		return 0;
 	}



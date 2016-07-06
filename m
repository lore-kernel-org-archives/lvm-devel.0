From: Bryn Reeves <bmr@fedoraproject.org>
Date: Wed,  6 Jul 2016 08:06:25 +0000 (UTC)
Subject: master - libdm: restore missing braces in _stats_walk_end_areas
Message-ID: <20160706080625.D16E16036F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5d3b136d38db40a6d26b8a09e7a4b504fa2f85d1
Commit:        5d3b136d38db40a6d26b8a09e7a4b504fa2f85d1
Parent:        69c721dd68a6ac517d7962f927f3f59f9e05d9c4
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Jul 6 09:04:13 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Jul 6 09:04:13 2016 +0100

libdm: restore missing braces in _stats_walk_end_areas

Jumping to the end of the region table must only happen if there
are no more present, non-skipped regions, and no group walk is
configured to begin.
---
 libdm/libdm-stats.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 07503a5..057bbcc 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -1479,11 +1479,12 @@ static void _stats_walk_end_areas(const struct dm_stats *dms, uint64_t *flags,
 		*cur_a = DM_STATS_WALK_REGION;
 		*cur_r = DM_STATS_REGION_NOT_PRESENT;
 		_stats_walk_next_present(dms, flags, cur_r, cur_a, cur_g);
-		if (!_stats_walk_any_unskipped(dms, flags, cur_r, cur_a))
+		if (!_stats_walk_any_unskipped(dms, flags, cur_r, cur_a)) {
 			/* no more regions */
 			*flags &= ~DM_STATS_WALK_REGION;
 			if (!(*flags & DM_STATS_WALK_GROUP))
 				*cur_r = dms->max_region;
+		}
 	}
 
 	if (*flags & DM_STATS_WALK_REGION)



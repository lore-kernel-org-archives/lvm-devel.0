From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Tue,  2 Aug 2016 13:27:25 +0000 (UTC)
Subject: master - vg_validate: correct min_recovery_rate check message
Message-ID: <20160802132725.B8A4460F5B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d0d03f315bd988bab50e45c4907ab626a780e600
Commit:        d0d03f315bd988bab50e45c4907ab626a780e600
Parent:        5765a2845600b827eab782e02250060eb4520c81
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Aug 2 15:27:13 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Aug 2 15:27:13 2016 +0200

vg_validate: correct min_recovery_rate check message

---
 lib/metadata/merge.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index be491e3..05cef17 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -121,7 +121,7 @@ static void _check_raid_region_recovery(struct lv_segment *seg, int *error_count
 	/* min/max recovery rate may be zero but min may not be larger than max if set */
 	if (seg->max_recovery_rate &&
 	    seg->min_recovery_rate > seg->max_recovery_rate)
-		raid_seg_error_val("min recovery larger than max recovery larger", seg->min_recovery_rate);
+		raid_seg_error_val("min recovery larger than max recovery", seg->min_recovery_rate);
 }
 
 /* Check raid1 segment properties in @seg */



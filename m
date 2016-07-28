From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Thu, 28 Jul 2016 12:42:23 +0000 (UTC)
Subject: master - vg_validate: only reject min_recovery_rate in case max_recovery_rate is set and smaller
Message-ID: <20160728124223.F3F6D60EED@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=43f455589377cb5e3b21434a58226a7365fe1d6f
Commit:        43f455589377cb5e3b21434a58226a7365fe1d6f
Parent:        d46de28a6c6107dceec1c61b76234e84c421b840
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Jul 27 23:20:58 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Jul 27 23:20:58 2016 +0200

vg_validate: only reject min_recovery_rate in case max_recovery_rate is set and smaller

---
 lib/metadata/merge.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 33aa421..12c3829 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -118,8 +118,9 @@ static void _check_raid_region_recovery(struct lv_segment *seg, int *error_count
 		raid_seg_error("zero region_size");
 	if (!is_power_of_2(seg->region_size))
 		raid_seg_error_val("non power of 2 region size", seg->region_size);
-	/* min/max recovery rate may be zero but min may not be larger than max*/
-	if (seg->min_recovery_rate > seg->max_recovery_rate)
+	/* min/max recovery rate may be zero but min may not be larger than max if set */
+	if (seg->max_recovery_rate &&
+	    seg->min_recovery_rate > seg->max_recovery_rate)
 		raid_seg_error_val("min recovery larger than max recovery larger", seg->min_recovery_rate);
 }
 



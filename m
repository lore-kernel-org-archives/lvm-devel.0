From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Mon, 9 Oct 2017 08:36:12 -0400
Subject: master - lvcreate: fix region size on striped RaidLVs
Message-ID: <201710091236.v99CaCkt011035@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5f13e33d541f7af77f586ac55edfed336ad8dcc1
Commit:        5f13e33d541f7af77f586ac55edfed336ad8dcc1
Parent:        2f754b73ffdaa95af4a6d703e31b76d4efbf7a36
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Oct 9 14:34:10 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Oct 9 14:35:06 2017 +0200

lvcreate: fix region size on striped RaidLVs

Creating striped RaidLVs with lv size not divisible by region size
caused the region size to be adjusted:

# lvcreate   --type raid5 -n region_check.32.00m_3 -i 3 -L 1g --nosync -R 32.00m raid_sanity
  Using default stripesize 64.00 KiB.
  Rounding size 1.00 GiB (256 extents) up to stripe boundary size <1.01 GiB(258 extents).
  WARNING: New raid5 won't be synchronised. Don't read what you didn't write!
  Using reduced mirror region size of 8.00 MiB
  Logical volume region_check.32.00m_3 created.

Fix by not imposing "mirror" constraints on "raid".

Resolves: rhbz1404007
---
 lib/metadata/lv_manip.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 1851783..719fcba 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7536,11 +7536,18 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			status |= LV_NOTSYNCED;
 		}
 
-		lp->region_size = adjusted_mirror_region_size(vg->cmd,
-							      vg->extent_size,
-							      lp->extents,
-							      lp->region_size, 0,
-							      vg_is_clustered(vg));
+		if (seg_is_raid(lp)) {
+			/* Value raid target constraint */
+			if (lp->region_size > (uint64_t)vg->extent_size * lp->extents) {
+				log_error("Cannot create RAID LV with region size larger than LV size.");
+				return NULL;
+			}
+		} else
+			lp->region_size = adjusted_mirror_region_size(vg->cmd,
+								      vg->extent_size,
+								      lp->extents,
+								      lp->region_size, 0,
+								      vg_is_clustered(vg));
 	} else if (pool_lv && seg_is_thin_volume(lp)) {
 		if (!lv_is_thin_pool(pool_lv)) {
 			log_error("Logical volume %s is not a thin pool.",



From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 14 Nov 2017 08:08:39 -0500
Subject: master - raid: correct raid6_n_6 -> raid5 convenience type
Message-ID: <201711141308.vAED8dm0029207@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bda0790949dccdd68b304437afa6a83bddc3ffca
Commit:        bda0790949dccdd68b304437afa6a83bddc3ffca
Parent:        762606a8c4070db7b3719c492bd9319d36ec271d
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Nov 13 18:03:50 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Nov 14 14:08:20 2017 +0100

raid: correct raid6_n_6 -> raid5 convenience type

Fix "lvconvert --type raid5 RaidLV" on a "raid6_n_6" LV offering
false "raid6_ls_6" instead of "raid5_n".
---
 lib/metadata/raid_manip.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index a904666..2d8aaed 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -6141,9 +6141,12 @@ static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_fr
 			seg_flag = SEG_RAID6_N_6;
 
 		} else if (segtype_is_any_raid5(*segtype))
-			/* No result for raid6_{zr,nr,nc} */
-			if (!(seg_flag = _raid_seg_flag_6_to_5(seg_from)) ||
-			    !(seg_flag & (*segtype)->flags))
+			if (!(seg_flag = _raid_seg_flag_6_to_5(seg_from)))
+				/*
+				 * No result for raid6_{zr,nr,nc}.
+				 *
+				 * Offer to convert to corresponding raid6_*_6 type first.
+				 */
 				seg_flag = _raid_segtype_flag_5_to_6(*segtype);
 
 	/* -> raid1 */



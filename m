From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 18 May 2017 10:21:04 -0400
Subject: master - lvconvert: fix logic in automatic settings of possible (raid) LV types
Message-ID: <201705181421.v4IEL4PB032230@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2bf01c2f3797d52f1ace72e32028912337918223
Commit:        2bf01c2f3797d52f1ace72e32028912337918223
Parent:        8e99a46d09ef21e9a1741eb333e16aaa08ac50f1
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu May 18 16:11:52 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu May 18 16:20:39 2017 +0200

lvconvert: fix logic in automatic settings of possible (raid) LV types

Commit 5fe07d3574ddce3d194f0fa57af9028348a91008 failed to set raid5 types
properly on conversions from raid6.  It always enforced raid6_ls_6
for types raid6/raid6_zr/raid6_nr/raid6_nc, thus requiring 3 conversions
instead of 2 when asking for raid5_{la,rs,ra,n}.

Related: rhbz1439403
---
 lib/metadata/raid_manip.c |   33 +++++++++++++++++++--------------
 1 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index d913301..005075c 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -5792,27 +5792,33 @@ static uint64_t _r5_to_r6[][2] = {
 
 
 /* Return segment type flag for raid5 -> raid6 conversions */
-static uint64_t _get_r56_flag(const struct lv_segment *seg, unsigned idx)
+static uint64_t _get_r56_flag(const struct segment_type *segtype, unsigned idx)
 {
 	unsigned elems = ARRAY_SIZE(_r5_to_r6);
 
 	while (elems--)
-		if (seg->segtype->flags & _r5_to_r6[elems][idx])
+		if (segtype->flags & _r5_to_r6[elems][idx])
 			return _r5_to_r6[elems][!idx];
 
 	return 0;
 }
 
-/* Return segment type flag for raid5 -> raid6 conversions */
+/* Return segment type flag of @seg for raid5 -> raid6 conversions */
 static uint64_t _raid_seg_flag_5_to_6(const struct lv_segment *seg)
 {
-	return _get_r56_flag(seg, 0);
+	return _get_r56_flag(seg->segtype, 0);
 }
 
-/* Return segment type flag for raid6 -> raid5 conversions */
+/* Return segment type flag of @seg for raid6 -> raid5 conversions */
 static uint64_t _raid_seg_flag_6_to_5(const struct lv_segment *seg)
 {
-	return _get_r56_flag(seg, 1);
+	return _get_r56_flag(seg->segtype, 1);
+}
+
+/* Return segment type flag of @segtype for raid5 -> raid6 conversions */
+static uint64_t _raid_segtype_flag_5_to_6(const struct segment_type *segtype)
+{
+	return _get_r56_flag(segtype, 0);
 }
 
 /* Change segtype for raid* for convenience where necessary. */
@@ -5892,17 +5898,16 @@ static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_fr
 
 			} else if (seg_is_raid4(seg_from) && !segtype_is_raid6_n_6(*segtype))
 				seg_flag = SEG_RAID6_N_6;
-
-			else if (!(seg_flag = _raid_seg_flag_5_to_6(seg_from)))
-				seg_flag = SEG_RAID5_N;
+			else
+				seg_flag = _raid_seg_flag_5_to_6(seg_from);
 		}
 
 	/* raid6 -> striped/raid0/raid5/raid10 */
 	} else if (seg_is_any_raid6(seg_from)) {
 		if (segtype_is_raid1(*segtype)) {
 			/* No result for raid6_{zr,nr,nc} */
-			if (!((seg_flag = _raid_seg_flag_6_to_5(seg_from)) ||
-			      !(seg_flag & (*segtype)->flags)))
+			if (!(seg_flag = _raid_seg_flag_6_to_5(seg_from)) ||
+			    !(seg_flag & (*segtype)->flags))
 				seg_flag = SEG_RAID6_LS_6;
 
 		} else if (segtype_is_any_raid10(*segtype)) {
@@ -5917,9 +5922,9 @@ static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_fr
 
 		} else if (segtype_is_any_raid5(*segtype))
 			/* No result for raid6_{zr,nr,nc} */
-			if (!((seg_flag = _raid_seg_flag_6_to_5(seg_from)) ||
-			      !(seg_flag & (*segtype)->flags)))
-				seg_flag = SEG_RAID6_N_6;
+			if (!(seg_flag = _raid_seg_flag_6_to_5(seg_from)) ||
+			    !(seg_flag & (*segtype)->flags))
+				seg_flag = _raid_segtype_flag_5_to_6(*segtype);
 
 	/* -> raid1 */
 	} else if (!seg_is_mirror(seg_from) && segtype_is_raid1(*segtype)) {



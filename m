From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 24 Sep 2015 12:44:03 +0000 (UTC)
Subject: master - style: lv_manip.c changes
Message-ID: <20150924124403.0E40460ACD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=41fe225b0deecea871354b321d23fad548857518
Commit:        41fe225b0deecea871354b321d23fad548857518
Parent:        1945a0f50415c024d706d29c39604347c4de883d
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Sep 24 13:43:58 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Sep 24 13:43:58 2015 +0100

style: lv_manip.c changes

---
 lib/metadata/lv_manip.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 808b630..69a6b6e 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1585,7 +1585,7 @@ static int _sufficient_pes_free(struct alloc_handle *ah, struct dm_list *pvms,
 {
 	uint32_t area_extents_needed = (extents_still_needed - allocated) * ah->area_count / ah->area_multiple;
 	uint32_t parity_extents_needed = (extents_still_needed - allocated) * ah->parity_count / ah->area_multiple;
-	uint32_t metadata_extents_needed = (ah->alloc_and_split_meta) ? 0 : ah->metadata_area_count * RAID_METADATA_AREA_LEN; /* One each */
+	uint32_t metadata_extents_needed = ah->alloc_and_split_meta ? 0 : ah->metadata_area_count * RAID_METADATA_AREA_LEN; /* One each */
 	uint32_t total_extents_needed = area_extents_needed + parity_extents_needed + metadata_extents_needed;
 	uint32_t free_pes = pv_maps_size(pvms);
 
@@ -1728,9 +1728,9 @@ static int _setup_alloced_segment(struct logical_volume *lv, uint64_t status,
 	struct lv_segment *seg;
 
 	area_multiple = _calc_area_multiple(segtype, area_count, 0);
+	extents = aa[0].len * area_multiple;
 
-	if (!(seg = alloc_lv_segment(segtype, lv, lv->le_count,
-				     aa[0].len * area_multiple,
+	if (!(seg = alloc_lv_segment(segtype, lv, lv->le_count, extents,
 				     status, stripe_size, NULL,
 				     area_count,
 				     aa[0].len, 0u, region_size, 0u, NULL))) {
@@ -4549,7 +4549,7 @@ static int _lvresize_poolmetadata(struct cmd_context *cmd, struct volume_group *
 				  struct dm_list *pvh)
 {
 	struct logical_volume *lv = first_seg(pool_lv)->metadata_lv;
-	alloc_policy_t alloc = lp->ac_alloc ?: lv->alloc;
+	alloc_policy_t alloc = lp->ac_alloc ? : lv->alloc;
 	struct lv_segment *mseg = last_seg(lv);
 	uint32_t seg_mirrors = lv_mirror_count(lv);
 
@@ -5158,7 +5158,7 @@ static struct logical_volume *_lvresize_volume(struct cmd_context *cmd,
 		/* Switch to layered LV resizing */
 		lv = seg_lv(seg, 0);
 	}
-	alloc = lp->ac_alloc ?: lv->alloc;
+	alloc = lp->ac_alloc ? : lv->alloc;
 
 	if ((lp->resize == LV_REDUCE) && lp->argc)
 		log_print_unless_silent("Ignoring PVs on command line when reducing.");



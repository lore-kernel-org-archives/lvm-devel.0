From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Mon, 13 Jul 2020 17:05:08 +0000 (GMT)
Subject: master - lvconvert: preset raid1 in case of striped conversions
Message-ID: <20200713170508.5E7C83858D37@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a33156365fe59f84c588a714ecbd4d24305d6521
Commit:        a33156365fe59f84c588a714ecbd4d24305d6521
Parent:        00c9a788cc617e5e40746dee2e17287d61ee5c81
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Jul 9 18:51:33 2020 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Jul 13 19:04:41 2020 +0200

lvconvert: preset raid1 in case of striped conversions

Fixed invoking "lvconvert -m+1 $StripedLV" to cause errors
(preset raid conversion implied by '-m').

Resolves: https://bugzilla.redhat.com/show_bug.cgi?id=1781406
---
 tools/lvconvert.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 2896c67c3..b6505c1a9 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1320,6 +1320,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 {
 	int image_count = 0;
 	int images_reduced = 0;
+	int type_enforced = 0;
 	struct cmd_context *cmd = lv->vg->cmd;
 	struct lv_segment *seg = first_seg(lv);
 
@@ -1372,6 +1373,12 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 				  display_lvname(lv));
 			return 0;
 		}
+
+		if (!*lp->type_str) {
+			lp->type_str = SEG_TYPE_NAME_RAID1;
+			lp->segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_RAID1);
+			type_enforced = 1;
+		}
 	}
 
 	if ((lp->corelog || lp->mirrorlog) && strcmp(lp->type_str, SEG_TYPE_NAME_MIRROR)) {
@@ -1386,7 +1393,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		return lv_raid_split(lv, lp->yes, lp->lv_split_name, image_count, lp->pvh);
 
 	if (lp->mirrors_supplied) {
-		if ((seg_is_striped(seg) && seg->area_count == 1) || seg_is_raid1(seg)) { /* ??? */
+		if (seg_is_linear(seg) || seg_is_raid1(seg)) { /* ??? */
 		if (!*lp->type_str || !strcmp(lp->type_str, SEG_TYPE_NAME_RAID1) || !strcmp(lp->type_str, SEG_TYPE_NAME_LINEAR) ||
 		    (!strcmp(lp->type_str, SEG_TYPE_NAME_STRIPED) && image_count == 1)) {
 			if (image_count > DEFAULT_RAID1_MAX_IMAGES) {
@@ -1449,7 +1456,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		/* FIXME This needs changing globally. */
 		if (!arg_is_set(cmd, stripes_long_ARG))
 			lp->stripes = 0;
-		if (!arg_is_set(cmd, type_ARG))
+		if (!type_enforced && !arg_is_set(cmd, type_ARG))
 		       lp->segtype = NULL;
 		if (!arg_is_set(cmd, regionsize_ARG))
 		       lp->region_size = 0;
@@ -1477,7 +1484,7 @@ try_new_takeover_or_reshape:
 	/* FIXME This needs changing globally. */
 	if (!arg_is_set(cmd, stripes_long_ARG))
 		lp->stripes = 0;
-	if (!arg_is_set(cmd, type_ARG))
+	if (!type_enforced && !arg_is_set(cmd, type_ARG))
 	       lp->segtype = NULL;
 
 	if (!lv_raid_convert(lv, lp->segtype,



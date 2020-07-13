From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Mon, 13 Jul 2020 17:17:50 +0000 (GMT)
Subject: stable-2.02 - lvconvert: preset raid1 in case of striped conversions
Message-ID: <20200713171750.AD2A23858D37@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=61e831aa5e09dfec25d6975f1c9950181c6a71f7
Commit:        61e831aa5e09dfec25d6975f1c9950181c6a71f7
Parent:        7ebe1bc901c3ed9404f92c7415c7c491593aed47
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Jul 13 19:16:45 2020 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Jul 13 19:16:47 2020 +0200

lvconvert: preset raid1 in case of striped conversions

Fixed invoking "lvconvert -m+1 $StripedLV" to cause errors
(preset raid conversion implied by '-m').

Resolves: https://bugzilla.redhat.com/show_bug.cgi?id=1781406
---
 WHATS_NEW         |  1 +
 tools/lvconvert.c | 13 ++++++++++---
 2 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 846510b28..3db623d6c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.188 - 
 ==================================
+  Fix conversion to raid from striped lagging type.
   Fix conversion to 'mirrored' mirror log with larger regionsize.
   Fix support for lvconvert --repair used by foreign apps (i.e. Docker).
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 0bc1a0128..fc740fb3e 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1336,6 +1336,7 @@ static int _raid4_conversion_supported(struct logical_volume *lv, struct lvconve
 static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *lp)
 {
 	int image_count = 0;
+	int type_enforced = 0;
 	struct cmd_context *cmd = lv->vg->cmd;
 	struct lv_segment *seg = first_seg(lv);
 
@@ -1386,6 +1387,12 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
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
@@ -1400,7 +1407,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		return lv_raid_split(lv, lp->yes, lp->lv_split_name, image_count, lp->pvh);
 
 	if (lp->mirrors_supplied) {
-		if ((seg_is_striped(seg) && seg->area_count == 1) || seg_is_raid1(seg)) { /* ??? */
+		if (seg_is_linear(seg) || seg_is_raid1(seg)) { /* ??? */
 		if (!*lp->type_str || !strcmp(lp->type_str, SEG_TYPE_NAME_RAID1) || !strcmp(lp->type_str, SEG_TYPE_NAME_LINEAR) ||
 		    (!strcmp(lp->type_str, SEG_TYPE_NAME_STRIPED) && image_count == 1)) {
 			if (image_count > DEFAULT_RAID1_MAX_IMAGES) {
@@ -1445,7 +1452,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		/* FIXME This needs changing globally. */
 		if (!arg_is_set(cmd, stripes_long_ARG))
 			lp->stripes = 0;
-		if (!arg_is_set(cmd, type_ARG))
+		if (!type_enforced && !arg_is_set(cmd, type_ARG))
 		       lp->segtype = NULL;
 		if (!arg_is_set(cmd, regionsize_ARG))
 		       lp->region_size = 0;
@@ -1467,7 +1474,7 @@ try_new_takeover_or_reshape:
 	/* FIXME This needs changing globally. */
 	if (!arg_is_set(cmd, stripes_long_ARG))
 		lp->stripes = 0;
-	if (!arg_is_set(cmd, type_ARG))
+	if (!type_enforced && !arg_is_set(cmd, type_ARG))
 	       lp->segtype = NULL;
 
 	if (!lv_raid_convert(lv, lp->segtype,



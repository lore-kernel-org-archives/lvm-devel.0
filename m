From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 6 Apr 2017 14:00:42 -0400
Subject: master - lvconvert: cleanup prompting
Message-ID: <201704061800.v36I0gS6015011@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ef3e1013aa8d7797fa432e2da219255178b8ede3
Commit:        ef3e1013aa8d7797fa432e2da219255178b8ede3
Parent:        eb6302c8cb6bfd1d9831e5ff3d76ecbb49613178
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Apr 6 19:59:57 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Apr 6 19:59:57 2017 +0200

lvconvert: cleanup prompting

---
 lib/metadata/raid_manip.c |   29 ++++++++++++-----------------
 1 files changed, 12 insertions(+), 17 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 922eea7..93c3c30 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1989,8 +1989,8 @@ static int _raid_reshape_keep_images(struct logical_volume *lv,
 	if (seg->segtype != new_segtype)
 		log_print_unless_silent("Converting %s LV %s to %s.",
 					lvseg_name(seg), display_lvname(lv), new_segtype->name);
-	if (!yes && yes_no_prompt("Are you sure you want to convert %s LV %s? [y/n]: ",
-				  lvseg_name(seg), display_lvname(lv)) == 'n') {
+	if (!yes && yes_no_prompt("Are you sure you want to convert %s LV %s to %s? [y/n]: ",
+				  lvseg_name(seg), display_lvname(lv), new_segtype->name) == 'n') {
 			log_error("Logical volume %s NOT converted.", display_lvname(lv));
 			return 0;
 	}
@@ -4577,7 +4577,7 @@ static int _raid1_to_mirrored_wrapper(TAKEOVER_FN_ARGS)
 	if (!_raid_in_sync(lv))
 		return_0;
 
-	if (!yes && yes_no_prompt("Are you sure you want to convert %s back to the older \"%s\" type? [y/n]: ",
+	if (!yes && yes_no_prompt("Are you sure you want to convert %s back to the older %s type? [y/n]: ",
 				  display_lvname(lv), SEG_TYPE_NAME_MIRROR) == 'n') {
 		log_error("Logical volume %s NOT converted to \"%s\".",
 			  display_lvname(lv), SEG_TYPE_NAME_MIRROR);
@@ -4888,13 +4888,6 @@ static int _takeover_downconvert_wrapper(TAKEOVER_FN_ARGS)
 	} else
 		*res_str = '\0';
 
-	if (!yes && yes_no_prompt("Are you sure you want to convert \"%s\" LV %s to \"%s\" type%s? [y/n]: ",
-				  lvseg_name(seg), display_lvname(lv), new_segtype->name, res_str) == 'n') {
-		log_error("Logical volume %s NOT converted to \"%s\"",
-			  display_lvname(lv), new_segtype->name);
-		return 0;
-	}
-
 	/* Archive metadata */
 	if (!archive(lv->vg))
 		return_0;
@@ -5737,13 +5730,6 @@ replaced:
 	if (segtype_sav != *segtype)
 		log_warn("Replaced LV type %s with possible type %s.",
 			 segtype_sav->name, (*segtype)->name);
-	if (!yes && yes_no_prompt("Do you want to convert %s LV %s to %s? [y/n]: ",
-				  lvseg_name(seg_from), display_lvname(seg_from->lv),
-				  (*segtype)->name) == 'n') {
-		log_error("Logical volume %s NOT converted.", display_lvname(seg_from->lv));
-		return 0;
-	}
-
 	return 1;
 }
 
@@ -5855,6 +5841,15 @@ static int _conversion_options_allowed(const struct lv_segment *seg_from,
 		r = 0;
 	}
 
+	if (r &&
+	    strcmp((*segtype_to)->name, SEG_TYPE_NAME_MIRROR) && /* "mirror" is prompted for later */
+	    !yes && yes_no_prompt("Are you sure you want to convert %s LV %s to %s type? [y/n]: ",
+				  lvseg_name(seg_from), display_lvname(seg_from->lv),
+				  (*segtype_to)->name) == 'n') {
+		log_error("Logical volume %s NOT converted.", display_lvname(seg_from->lv));
+		r = 0;
+	}
+
 	return r;
 }
 



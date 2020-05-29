From: David Teigland <teigland@sourceware.org>
Date: Fri, 29 May 2020 18:21:41 +0000 (GMT)
Subject: master - integrity: skip calling add when removing images
Message-ID: <20200529182141.C0834386F477@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ae029fcced5f79af748df28f20f952d158804482
Commit:        ae029fcced5f79af748df28f20f952d158804482
Parent:        7b04ed07ba2e68f527ebb4f8d2b2bd092692f2d2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 29 13:18:24 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 29 13:18:24 2020 -0500

integrity: skip calling add when removing images

When lvconvert is used to remove raid images, we can
skip calling lv_add_integrity_to_raid(), which finds
nothing to do, but the the blocksize validation would
be called unnecessarily and trigger spurious errors.
---
 tools/lvconvert.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 8652252d3..76e00f0a2 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1319,6 +1319,7 @@ static int _raid4_conversion_supported(struct logical_volume *lv, struct lvconve
 static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *lp)
 {
 	int image_count = 0;
+	int images_reduced = 0;
 	struct cmd_context *cmd = lv->vg->cmd;
 	struct lv_segment *seg = first_seg(lv);
 
@@ -1357,6 +1358,8 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		else
 			image_count = lp->mirrors + 1;
 
+		images_reduced = (image_count < lv_raid_image_count(lv));
+
 		if (image_count < 1) {
 			log_error("Unable to %s images by specified amount.",
 				  lp->keep_mimages ? "split" : "reduce");
@@ -1400,7 +1403,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 							lp->region_size : seg->region_size , lp->pvh))
 				return_0;
 
-			if (lv_raid_has_integrity(lv)) {
+			if (lv_raid_has_integrity(lv) && !images_reduced) {
 				struct integrity_settings *isettings = NULL;
 				if (!lv_get_raid_integrity_settings(lv, &isettings))
 					return_0;



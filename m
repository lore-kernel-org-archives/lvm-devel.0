From: David Teigland <teigland@sourceware.org>
Date: Thu, 25 May 2023 17:11:36 +0000 (GMT)
Subject: main - lvreduce: simplify _lvseg_get_stripes integrity check
Message-ID: <20230525171136.C2F223858D32@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0591131a539fb668412fc38807686d2a89decd27
Commit:        0591131a539fb668412fc38807686d2a89decd27
Parent:        4cdb178968b44125c41dee6dd28997283c0afefa
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 25 12:09:41 2023 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 25 12:09:41 2023 -0500

lvreduce: simplify _lvseg_get_stripes integrity check

Simplify unnecessary loop to avoid coverity complaint.
---
 lib/metadata/lv_manip.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index fa3661739..a4593c969 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5187,7 +5187,7 @@ int lv_extend_policy_calculate_percent(struct logical_volume *lv,
 
 static uint32_t _lvseg_get_stripes(struct lv_segment *seg, uint32_t *stripesize)
 {
-	uint32_t s, a;
+	uint32_t s;
 	struct lv_segment *seg_get, *seg_image, *seg_iorig;
 	struct logical_volume *lv_image, *lv_iorig;
 
@@ -5203,12 +5203,9 @@ static uint32_t _lvseg_get_stripes(struct lv_segment *seg, uint32_t *stripesize)
 
 			if (seg_is_integrity(seg_image)) {
 				/* Get stripe values from the iorig layer. */
-				for (a = 0; a < seg_image->area_count; a++) {
-					lv_iorig = seg_lv(seg_image, a);
-					seg_iorig = first_seg(lv_iorig);
-					seg_get = seg_iorig;
-					break;
-				}
+				lv_iorig = seg_lv(seg_image, 0);
+				seg_iorig = first_seg(lv_iorig);
+				seg_get = seg_iorig;
 			} else {
 				/* Get stripe values from the image layer. */
 				seg_get = seg_image;


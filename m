From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Mon, 12 Dec 2016 21:10:04 +0000 (UTC)
Subject: master - lvchange: allow a transiently failed RaidLV to be refreshed
Message-ID: <20161212211004.DDDE860D79@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=87117c2b2546231c789f92c75590f053a8fb987c
Commit:        87117c2b2546231c789f92c75590f053a8fb987c
Parent:        75ec7c8deeed95f005d78b4b962f70f783f7f0a0
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Dec 12 22:06:17 2016 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Dec 12 22:08:47 2016 +0100

lvchange: allow a transiently failed RaidLV to be refreshed

Enhance commit 0b8bf73a63d8 to refresh the top-level LV correctly
in case of a clustered, remotely activated RaidLV.

Related: rhbz1399844
---
 lib/metadata/lv_manip.c |   26 ++++++++++++++++----------
 1 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 120217f..fdfee36 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1417,17 +1417,23 @@ int lv_refresh_suspend_resume(const struct logical_volume *lv)
 	 * with transient failures of SubLVs.
 	 */
 	if (lv_is_raid(lv)) {
-		uint32_t s;
-		struct lv_segment *seg = first_seg(lv);
-
-		for (s = 0; s < seg->area_count; s++) {
-			if (seg_type(seg, s) == AREA_LV &&
-			    !_lv_refresh_suspend_resume(seg_lv(seg, s)))
-				return 0;
-			if (seg->meta_areas &&
-			    seg_metatype(seg, s) == AREA_LV &&
-			    !_lv_refresh_suspend_resume(seg_metalv(seg, s)))
+		if (vg_is_clustered(lv->vg) &&
+		    lv_is_active_remotely(lv)) {
+			if (!_lv_refresh_suspend_resume(lv))
 				return 0;
+		} else {
+			uint32_t s;
+			struct lv_segment *seg = first_seg(lv);
+
+			for (s = 0; s < seg->area_count; s++) {
+				if (seg_type(seg, s) == AREA_LV &&
+				    !_lv_refresh_suspend_resume(seg_lv(seg, s)))
+					return 0;
+				if (seg->meta_areas &&
+				    seg_metatype(seg, s) == AREA_LV &&
+				    !_lv_refresh_suspend_resume(seg_metalv(seg, s)))
+					return 0;
+			}
 		}
 	}
 



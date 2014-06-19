From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Thu, 19 Jun 2014 15:59:59 +0000 (UTC)
Subject: master - pvmove: Fix code that looks up the "move pv" for display
Message-ID: <20140619155959.6185A610AB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c6d82c992b4a4271287233dbedc3a075fa03ca43
Commit:        c6d82c992b4a4271287233dbedc3a075fa03ca43
Parent:        3964a1a89f52584878c09cf93bc971b96c0d3de1
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Thu Jun 19 10:57:08 2014 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Thu Jun 19 10:57:08 2014 -0500

pvmove: Fix code that looks up the "move pv" for display

'lvs' would segfault if trying to display the "move pv" if the
pvmove was run with '--atomic'.  The structure of an atomic pvmove
is different and requires us to descend another level in the
LV tree to retrieve the PV information.
---
 lib/metadata/lv.c |   23 +++++++++++++++++++----
 1 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 733e9f6..a1211a8 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -316,11 +316,26 @@ char *lv_convert_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
 
 char *lv_move_pv_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
+	struct logical_volume *mimage0_lv;
 	struct lv_segment *seg;
-
-	dm_list_iterate_items(seg, &lv->segments)
-		if (seg->status & PVMOVE)
-			return dm_pool_strdup(mem, dev_name(seg_dev(seg, 0)));
+	const struct device *dev;
+
+	dm_list_iterate_items(seg, &lv->segments) {
+		if (seg->status & PVMOVE) {
+			if (seg_type(seg, 0) == AREA_LV) { /* atomic pvmove */
+				mimage0_lv = seg_lv(seg, 0);
+				if (!lv_is_mirror_type(mimage0_lv)) {
+					log_error(INTERNAL_ERROR
+						  "Bad pvmove structure");
+					return NULL;
+				}
+				dev = seg_dev(first_seg(mimage0_lv), 0);
+			} else /* Segment pvmove */
+				dev = seg_dev(seg, 0);
+
+			return dm_pool_strdup(mem, dev_name(dev));
+		}
+	}
 
 	return NULL;
 }



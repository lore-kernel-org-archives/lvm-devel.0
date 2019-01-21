From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 21 Jan 2019 06:55:46 -0500
Subject: master - cleanup: better naming
Message-ID: <201901211155.x0LBtkJT024532@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a16d914d34fff420c663ba34ac8dabfc4403de51
Commit:        a16d914d34fff420c663ba34ac8dabfc4403de51
Parent:        08cabe9b83bcce59a5aabc100aad2cb61a7bac0c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 10 18:01:06 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 21 12:53:16 2019 +0100

cleanup: better naming

---
 lib/metadata/lv_manip.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d32bd24..7e542fe 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1852,21 +1852,21 @@ static void _init_alloc_parms(struct alloc_handle *ah,
 /* Handles also stacking */
 static int _setup_lv_size(struct logical_volume *lv, uint32_t extents)
 {
-	struct lv_segment *thin_pool_seg;
+	struct lv_segment *pool_seg;
 
 	lv->le_count = extents;
 	lv->size = (uint64_t) extents * lv->vg->extent_size;
 
 	if (lv_is_thin_pool_data(lv) ||
 	    lv_is_vdo_pool_data(lv)) {
-		if (!(thin_pool_seg = get_only_segment_using_this_lv(lv)))
+		if (!(pool_seg = get_only_segment_using_this_lv(lv)))
 			return_0;
 
-		/* Update thin pool segment from the layered LV */
-		thin_pool_seg->lv->le_count =
-			thin_pool_seg->len =
-			thin_pool_seg->area_len = lv->le_count;
-		thin_pool_seg->lv->size = lv->size;
+		/* Update pool segment from the layered LV */
+		pool_seg->lv->le_count =
+			pool_seg->len =
+			pool_seg->area_len = lv->le_count;
+		pool_seg->lv->size = lv->size;
 	}
 
 	return 1;



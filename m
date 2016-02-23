From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 23 Feb 2016 20:41:34 +0000 (UTC)
Subject: master - coverity: ensure thin_pool_seg is not NULL
Message-ID: <20160223204134.8C44D61053@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=63c052b9e2a69b94fea33490130e76aac9a8c735
Commit:        63c052b9e2a69b94fea33490130e76aac9a8c735
Parent:        ddfec5b51a46faab3f64de3e07dc52e0adaf81bc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 23 21:36:51 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 23 21:40:17 2016 +0100

coverity: ensure thin_pool_seg is not NULL

thin_pool_seg being NULL would be an internal error.
---
 lib/metadata/lv_manip.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 64eb6b7..5e4a81f 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1662,8 +1662,10 @@ static int _setup_alloced_segment(struct logical_volume *lv, uint64_t status,
 	lv->size += (uint64_t) extents * lv->vg->extent_size;
 
 	if (lv_is_thin_pool_data(lv)) {
+		if (!(thin_pool_seg = get_only_segment_using_this_lv(lv)))
+			return_0;
+
 		/* Update thin pool segment from the layered LV */
-		thin_pool_seg = get_only_segment_using_this_lv(lv);
 		thin_pool_seg->lv->le_count =
 			thin_pool_seg->len =
 			thin_pool_seg->area_len = lv->le_count;



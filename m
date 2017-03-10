From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 10 Mar 2017 08:43:56 -0500
Subject: master - raid: fix compile time warning
Message-ID: <201703101343.v2ADhuZH024023@int-mx09.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bc3bec6c5486105f50fe94e66c1a16dc0fdfe332
Commit:        bc3bec6c5486105f50fe94e66c1a16dc0fdfe332
Parent:        59e57be54f9b4c9e83ec1ede480285965a7411eb
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Mar 10 14:43:37 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Mar 10 14:43:37 2017 +0100

raid: fix compile time warning

---
 lib/metadata/raid_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index a8c2e19..2e31bf7 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1491,7 +1491,7 @@ static int _lv_alloc_reshape_space(struct logical_volume *lv,
 		uint32_t data_rimages = _data_rimages_count(seg, seg->area_count);
 		uint32_t reshape_len = out_of_place_les_per_disk * data_rimages;
 		uint32_t prev_rimage_len = _lv_total_rimage_len(lv);
-		uint64_t lv_size = lv->size;
+		uint64_t lv_size_cur = lv->size;
 
 		if (!lv_extend(lv, seg->segtype, data_rimages,
 			       seg->stripe_size, 1, /* seg_is_any_raid10(seg) ? seg->data_copies : 1, */ seg->region_size,
@@ -1502,7 +1502,7 @@ static int _lv_alloc_reshape_space(struct logical_volume *lv,
 			return 0;
 		}
 
-		lv->size = lv_size;
+		lv->size = lv_size_cur;
 		/* pay attention to lv_extend maybe having allocated more because of layout specific rounding */
 		if (!_lv_set_reshape_len(lv, _lv_total_rimage_len(lv) - prev_rimage_len))
 			return 0;



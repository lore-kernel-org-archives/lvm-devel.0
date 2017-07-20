From: Alasdair Kergon <agk@sourceware.org>
Date: Thu, 20 Jul 2017 11:24:22 -0400
Subject: master - raid: avoid lv_size compiler warning
Message-ID: <201707201524.v6KFOMY8003148@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7ba0017468d977cf51bfce0e708317ab84bc04e7
Commit:        7ba0017468d977cf51bfce0e708317ab84bc04e7
Parent:        c78316b7a5341aa9259c118988e659d38ef862f2
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Jul 20 16:16:51 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Jul 20 16:16:51 2017 +0100

raid: avoid lv_size compiler warning

warning: declaration of ???lv_size??? shadows a global declaration
---
 lib/metadata/raid_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index e275da1..b90d6f4 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1526,7 +1526,7 @@ static int _lv_relocate_reshape_space(struct logical_volume *lv, enum alloc_wher
 /* HM Helper: reset @lv to @segtype, @stripe_size and @lv_size post lv_extend() when changed for area_count < 3. */
 static int _lv_alloc_reshape_post_extend(struct logical_volume *lv,
 					 const struct segment_type *segtype,
-					 uint32_t stripe_size, uint64_t lv_size)
+					 uint32_t stripe_size, uint64_t lv_size_cur)
 {
 	struct lv_segment *seg = first_seg(lv);
 
@@ -1534,7 +1534,7 @@ static int _lv_alloc_reshape_post_extend(struct logical_volume *lv,
 		/* Reset segment type, stripe and lv size */
 		seg->segtype = segtype;
 		seg->stripe_size = stripe_size;
-		lv->size = lv_size;
+		lv->size = lv_size_cur;
 
 		/* Update and reload mapping for proper size of data SubLVs in the cluster */
 		if (!lv_update_and_reload(lv))



From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  3 Jan 2017 13:56:17 +0000 (UTC)
Subject: master - cleanup: use macros
Message-ID: <20170103135617.375476102C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dc5bb12956d11f84352d45c69805570fc64ba66e
Commit:        dc5bb12956d11f84352d45c69805570fc64ba66e
Parent:        ee784fd28f70eb35e23da91fe935c601e44648aa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Dec 24 23:46:47 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 3 14:55:16 2017 +0100

cleanup: use macros

---
 lib/metadata/lv_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e5808ec..e948512 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3467,7 +3467,7 @@ int lv_add_segment(struct alloc_handle *ah,
 				     region_size))
 		return_0;
 
-	if ((segtype->flags & SEG_CAN_SPLIT) && !lv_merge_segments(lv)) {
+	if (segtype_can_split(segtype) && !lv_merge_segments(lv)) {
 		log_error("Couldn't merge segments after extending "
 			  "logical volume.");
 		return 0;
@@ -7048,7 +7048,7 @@ static int _should_wipe_lv(struct lvcreate_params *lp,
 			   struct logical_volume *lv, int warn)
 {
 	/* Unzeroable segment */
-	if (first_seg(lv)->segtype->flags & SEG_CANNOT_BE_ZEROED)
+	if (seg_cannot_be_zeroed(first_seg(lv)))
 		return 0;
 
 	/* Thin snapshot need not to be zeroed */



From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 25 Sep 2013 02:35:03 +0000 (UTC)
Subject: master - Test/clean-up: Indent clean-up and additional RAID resize test
Message-ID: <20130925023503.3F68B6148C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c37c59e155813545c2e674eb370a4609e97aa769
Commit:        c37c59e155813545c2e674eb370a4609e97aa769
Parent:        5ded7314ae00629da8d21d925c3fa091cce2a939
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Sep 24 21:32:53 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Sep 24 21:32:53 2013 -0500

Test/clean-up: Indent clean-up and additional RAID resize test

Better indenting and a test for bug 1005434 (parity RAID should
extend in a contiguous fashion).
---
 lib/metadata/lv_manip.c     |   26 ++++++++++++++++++--------
 test/shell/lvresize-raid.sh |   10 +++++++++-
 2 files changed, 27 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index c16288e..d1ec4cd 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1190,7 +1190,9 @@ static uint32_t _stripes_per_mimage(struct lv_segment *seg)
 	return 1;
 }
 
-static void _init_alloc_parms(struct alloc_handle *ah, struct alloc_parms *alloc_parms, alloc_policy_t alloc,
+static void _init_alloc_parms(struct alloc_handle *ah,
+			      struct alloc_parms *alloc_parms,
+			      alloc_policy_t alloc,
 			      struct lv_segment *prev_lvseg, unsigned can_split,
 			      uint32_t allocated, uint32_t extents_still_needed)
 {
@@ -1199,23 +1201,29 @@ static void _init_alloc_parms(struct alloc_handle *ah, struct alloc_parms *alloc
 	alloc_parms->flags = 0;
 	alloc_parms->extents_still_needed = extents_still_needed;
 
-	/* Only attempt contiguous/cling allocation to previous segment areas if the number of areas matches. */
+	/*
+	 * Only attempt contiguous/cling allocation to previous segment
+	 * areas if the number of areas matches.
+	 */
 	if (alloc_parms->prev_lvseg &&
 	    ((ah->area_count + ah->parity_count) == prev_lvseg->area_count))
 		alloc_parms->flags |= A_AREA_COUNT_MATCHES;
 
 	/* Are there any preceding segments we must follow on from? */
-	if (alloc_parms->prev_lvseg && (alloc_parms->flags & A_AREA_COUNT_MATCHES)) {
+	if (alloc_parms->prev_lvseg &&
+	    (alloc_parms->flags & A_AREA_COUNT_MATCHES)) {
 		if (alloc_parms->alloc == ALLOC_CONTIGUOUS)
 			alloc_parms->flags |= A_CONTIGUOUS_TO_LVSEG;
-		else if ((alloc_parms->alloc == ALLOC_CLING) || (alloc_parms->alloc == ALLOC_CLING_BY_TAGS))
+		else if ((alloc_parms->alloc == ALLOC_CLING) ||
+			 (alloc_parms->alloc == ALLOC_CLING_BY_TAGS))
 			alloc_parms->flags |= A_CLING_TO_LVSEG;
 	} else
 		/*
-		 * A cling allocation that follows a successful contiguous allocation
-		 * must use the same PVs (or else fail).
+		 * A cling allocation that follows a successful contiguous
+		 * allocation must use the same PVs (or else fail).
 		 */
-		if ((alloc_parms->alloc == ALLOC_CLING) || (alloc_parms->alloc == ALLOC_CLING_BY_TAGS))
+		if ((alloc_parms->alloc == ALLOC_CLING) ||
+		    (alloc_parms->alloc == ALLOC_CLING_BY_TAGS))
 			alloc_parms->flags |= A_CLING_TO_ALLOCED;
 
 	if (alloc_parms->alloc == ALLOC_CLING_BY_TAGS)
@@ -1226,7 +1234,9 @@ static void _init_alloc_parms(struct alloc_handle *ah, struct alloc_parms *alloc
 	 * for allocation, prefer to place further extents on the same disks as
 	 * have already been used.
 	 */
-	if (ah->maximise_cling && alloc_parms->alloc == ALLOC_NORMAL && allocated != alloc_parms->extents_still_needed)
+	if (ah->maximise_cling &&
+	    (alloc_parms->alloc == ALLOC_NORMAL) &&
+	    (allocated != alloc_parms->extents_still_needed))
 		alloc_parms->flags |= A_CLING_TO_ALLOCED;
 
 	if (can_split)
diff --git a/test/shell/lvresize-raid.sh b/test/shell/lvresize-raid.sh
index e61f194..6908635 100644
--- a/test/shell/lvresize-raid.sh
+++ b/test/shell/lvresize-raid.sh
@@ -13,7 +13,7 @@
 
 aux target_at_least dm-raid 1 1 0 || skip
 
-aux prepare_vg 5 80
+aux prepare_vg 6 80
 
 for deactivate in true false; do
 
@@ -45,3 +45,11 @@ for deactivate in true false; do
 		lvremove -ff $vg
 	done
 done
+
+# Bug 1005434
+# Ensure extend is contiguous
+lvcreate --type raid4 -l 2 -i 2 -n $lv1 $vg $dev4 $dev5 $dev6
+lvextend -l +2 --alloc contiguous $vg/$lv1
+not $(lvs -a -o devices $vg | egrep "$dev1|$dev2|$dev3")
+lvremove -ff $vg
+



From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 29 Jul 2013 18:37:26 +0000 (UTC)
Subject: master - alloc: fix lvextend when stripe number varies
Message-ID: <20130729183726.3A6A1611E4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b6bfddcd0a830d0c9312bc3ab906cb3d1b7a6dd9
Commit:        b6bfddcd0a830d0c9312bc3ab906cb3d1b7a6dd9
Parent:        9b28255aac9386db6d51cd1b501a9f39e81778a5
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jul 29 19:35:45 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Jul 29 19:35:45 2013 +0100

alloc: fix lvextend when stripe number varies

The PREFERRED allocation mechanism requires the number of areas in the
previous LV segment to match the number in the new segment being
allocated.  If they do not match, the code may crash.
  E.g. https://bugzilla.redhat.com/989347

Introduce A_AREA_COUNT_MATCHES and when not set avoid referring
to the previous segment with the contiguous and cling policies.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   21 ++++++++++++++++-----
 2 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3318454..21c1f6d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.100 -
 ================================
+  Ignore previous LV seg with alloc contiguous & cling when num stripes varies.
   Fix segfault if devices/global_filter is not specified correctly.
 
 Version 2.02.99 - 24th July 2013
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 088c05d..24c66ef 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -47,6 +47,7 @@ typedef enum {
 
 #define A_CLING_BY_TAGS		0x08	/* Must match tags against existing segment */
 #define A_CAN_SPLIT		0x10
+#define A_AREA_COUNT_MATCHES	0x20	/* Existing lvseg has same number of areas as new segment */
 
 #define SNAPSHOT_MIN_CHUNKS	3       /* Minimum number of chunks in snapshot */
 
@@ -1118,8 +1119,12 @@ static void _init_alloc_parms(struct alloc_handle *ah, struct alloc_parms *alloc
 	alloc_parms->flags = 0;
 	alloc_parms->extents_still_needed = extents_still_needed;
 
+	/* Only attempt contiguous/cling allocation to previous segment areas if the number of areas matches. */
+	if (alloc_parms->prev_lvseg && (ah->area_count == prev_lvseg->area_count))
+		alloc_parms->flags |= A_AREA_COUNT_MATCHES;
+
 	/* Are there any preceding segments we must follow on from? */
-	if (alloc_parms->prev_lvseg) {
+	if (alloc_parms->prev_lvseg && (alloc_parms->flags & A_AREA_COUNT_MATCHES)) {
 		if (alloc_parms->alloc == ALLOC_CONTIGUOUS)
 			alloc_parms->flags |= A_CONTIGUOUS_TO_LVSEG;
 		else if ((alloc_parms->alloc == ALLOC_CLING) || (alloc_parms->alloc == ALLOC_CLING_BY_TAGS))
@@ -1721,7 +1726,8 @@ static area_use_t _check_pva(struct alloc_handle *ah, struct pv_area *pva, uint3
 	/* If maximise_cling is set, perform several checks, otherwise perform exactly one. */
 	if (!iteration_count && !log_iteration_count && alloc_parms->flags & (A_CONTIGUOUS_TO_LVSEG | A_CLING_TO_LVSEG | A_CLING_TO_ALLOCED)) {
 		/* Contiguous? */
-		if (((alloc_parms->flags & A_CONTIGUOUS_TO_LVSEG) || (ah->maximise_cling && alloc_parms->prev_lvseg)) &&
+		if (((alloc_parms->flags & A_CONTIGUOUS_TO_LVSEG) ||
+		     (ah->maximise_cling && alloc_parms->prev_lvseg && (alloc_parms->flags & A_AREA_COUNT_MATCHES))) &&
 		    _check_contiguous(ah->cmd, alloc_parms->prev_lvseg, pva, alloc_state))
 			return PREFERRED;
 
@@ -1730,7 +1736,8 @@ static area_use_t _check_pva(struct alloc_handle *ah, struct pv_area *pva, uint3
 			return NEXT_AREA;
 
 		/* Cling to prev_lvseg? */
-		if (((alloc_parms->flags & A_CLING_TO_LVSEG) || (ah->maximise_cling && alloc_parms->prev_lvseg)) &&
+		if (((alloc_parms->flags & A_CLING_TO_LVSEG) ||
+		     (ah->maximise_cling && alloc_parms->prev_lvseg && (alloc_parms->flags & A_AREA_COUNT_MATCHES))) &&
 		    _check_cling(ah, NULL, alloc_parms->prev_lvseg, pva, alloc_state))
 			/* If this PV is suitable, use this first area */
 			return PREFERRED;
@@ -1744,7 +1751,7 @@ static area_use_t _check_pva(struct alloc_handle *ah, struct pv_area *pva, uint3
 		if (!(alloc_parms->flags & A_CLING_BY_TAGS) || !ah->cling_tag_list_cn)
 			return NEXT_PV;
 
-		if (alloc_parms->prev_lvseg) {
+		if (alloc_parms->prev_lvseg && (alloc_parms->flags & A_AREA_COUNT_MATCHES)) {
 			if (_check_cling(ah, ah->cling_tag_list_cn, alloc_parms->prev_lvseg, pva, alloc_state))
 				return PREFERRED;
 		} else if (_check_cling_to_alloced(ah, ah->cling_tag_list_cn, pva, alloc_state))
@@ -1967,8 +1974,12 @@ static int _find_some_parallel_space(struct alloc_handle *ah, const struct alloc
 			/* First area in each list is the largest */
 			dm_list_iterate_items(pva, &pvm->areas) {
 				/*
-				 * There are two types of allocations, which can't be mixed at present.
+				 * There are two types of allocations, which can't be mixed at present:
+				 *
 				 * PREFERRED are stored immediately in a specific parallel slot.
+				 *   This requires the number of slots to match, so if comparing with
+				 *   prev_lvseg then A_AREA_COUNT_MATCHES must be set.
+				 *
 				 * USE_AREA are stored for later, then sorted and chosen from.
 				 */
 				switch(_check_pva(ah, pva, max_to_allocate, alloc_parms,



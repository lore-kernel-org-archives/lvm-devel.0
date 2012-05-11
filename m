From: agk@sourceware.org <agk@sourceware.org>
Date: 11 May 2012 22:19:13 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20120511221913.31966.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-05-11 22:19:12

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	Fix allocation policy loop so it doesn't continue beyond cling using later
	policies it shouldn't be using when --alloc cling is specified but no tags
	are defined.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2402&r2=1.2403
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.378&r2=1.379

--- LVM2/WHATS_NEW	2012/05/11 18:59:01	1.2402
+++ LVM2/WHATS_NEW	2012/05/11 22:19:12	1.2403
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Fix policy loop not to use later policies when --alloc cling without tags.
   Append _TO_LVSEG to names of internal A_CONTIGUOUS and A_CLING flags.
   Add missing pkg init --with-systemdsystemunitdir in configure.in (2.02.92).
   Fix division by zero if PV with zero PE count is used during vgcfgrestore.
--- LVM2/lib/metadata/lv_manip.c	2012/05/11 18:59:01	1.378
+++ LVM2/lib/metadata/lv_manip.c	2012/05/11 22:19:12	1.379
@@ -2022,7 +2022,7 @@
 		ah->alloc = ALLOC_CLING_BY_TAGS;
 
 	/* Attempt each defined allocation policy in turn */
-	for (alloc = ALLOC_CONTIGUOUS; alloc < ALLOC_INHERIT; alloc++) {
+	for (alloc = ALLOC_CONTIGUOUS; alloc <= ah->alloc; alloc++) {
 		/* Skip cling_by_tags if no list defined */
 		if (alloc == ALLOC_CLING_BY_TAGS && !ah->cling_tag_list_cn)
 			continue;
@@ -2039,7 +2039,7 @@
 		if (!_find_max_parallel_space_for_one_policy(ah, &alloc_parms, pvms, &alloc_state))
 			goto_out;
 
-		if ((alloc_state.allocated == ah->new_extents && !alloc_state.log_area_count_still_needed) || (ah->alloc == alloc) ||
+		if ((alloc_state.allocated == ah->new_extents && !alloc_state.log_area_count_still_needed) ||
 		    (!can_split && (alloc_state.allocated != old_allocated)))
 			break;
 	}
@@ -2154,7 +2154,7 @@
 		return NULL;
 	}
 
-	if (alloc == ALLOC_INHERIT)
+	if (alloc >= ALLOC_INHERIT)
 		alloc = vg->alloc;
 
 	new_extents = (lv ? lv->le_count : 0) + extents;



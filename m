From: agk@sourceware.org <agk@sourceware.org>
Date: 11 May 2012 18:59:03 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20120511185903.521.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-05-11 18:59:02

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	Append _TO_LVSEG to names of internal A_CONTIGUOUS and A_CLING flags.
	Remove some unnecesary prev_lvseg checks.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2401&r2=1.2402
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.377&r2=1.378

--- LVM2/WHATS_NEW	2012/05/10 08:54:33	1.2401
+++ LVM2/WHATS_NEW	2012/05/11 18:59:01	1.2402
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Append _TO_LVSEG to names of internal A_CONTIGUOUS and A_CLING flags.
   Add missing pkg init --with-systemdsystemunitdir in configure.in (2.02.92).
   Fix division by zero if PV with zero PE count is used during vgcfgrestore.
   Add initial support for thin pool lvconvert.
--- LVM2/lib/metadata/lv_manip.c	2012/05/11 15:32:19	1.377
+++ LVM2/lib/metadata/lv_manip.c	2012/05/11 18:59:01	1.378
@@ -39,10 +39,12 @@
 #define RAID_METADATA_AREA_LEN 1
 
 /* FIXME These ended up getting used differently from first intended.  Refactor. */
-#define A_CONTIGUOUS		0x01
-#define A_CLING			0x02
-#define A_CLING_BY_TAGS		0x04
-#define A_CLING_TO_ALLOCED	0x08	/* Only for ALLOC_NORMAL */
+/* Only one of A_CONTIGUOUS_TO_LVSEG, A_CLING_TO_LVSEG, A_CLING_TO_ALLOCED may be set */
+#define A_CONTIGUOUS_TO_LVSEG	0x01	/* Must be contiguous to an existing segment */
+#define A_CLING_TO_LVSEG	0x02	/* Must use same disks as existing LV segment */
+#define A_CLING_TO_ALLOCED	0x04	/* Must use same disks as already-allocated segment */
+
+#define A_CLING_BY_TAGS		0x08	/* Must match tags against existing segment */
 #define A_CAN_SPLIT		0x10
 
 /*
@@ -907,11 +909,11 @@
 	/* Are there any preceding segments we must follow on from? */
 	if (alloc_parms->prev_lvseg) {
 		if (alloc_parms->alloc == ALLOC_CONTIGUOUS)
-			alloc_parms->flags |= A_CONTIGUOUS;
+			alloc_parms->flags |= A_CONTIGUOUS_TO_LVSEG;
 		else if (alloc_parms->alloc == ALLOC_CLING)
-			alloc_parms->flags |= A_CLING;
+			alloc_parms->flags |= A_CLING_TO_LVSEG;
 		else if (alloc_parms->alloc == ALLOC_CLING_BY_TAGS) {
-			alloc_parms->flags |= A_CLING;
+			alloc_parms->flags |= A_CLING_TO_LVSEG;
 			alloc_parms->flags |= A_CLING_BY_TAGS;
 		}
 	}
@@ -1494,14 +1496,14 @@
 				return NEXT_AREA;
 
 	/* If maximise_cling is set, perform several checks, otherwise perform exactly one. */
-	if (!iteration_count && !log_iteration_count && alloc_parms->flags & (A_CONTIGUOUS | A_CLING | A_CLING_TO_ALLOCED)) {
+	if (!iteration_count && !log_iteration_count && alloc_parms->flags & (A_CONTIGUOUS_TO_LVSEG | A_CLING_TO_LVSEG | A_CLING_TO_ALLOCED)) {
 		/* Contiguous? */
-		if (((alloc_parms->flags & A_CONTIGUOUS) || ah->maximise_cling) &&
-		    alloc_parms->prev_lvseg && _check_contiguous(ah->cmd, alloc_parms->prev_lvseg, pva, alloc_state))
+		if (((alloc_parms->flags & A_CONTIGUOUS_TO_LVSEG) || (ah->maximise_cling && alloc_parms->prev_lvseg)) &&
+		    _check_contiguous(ah->cmd, alloc_parms->prev_lvseg, pva, alloc_state))
 			return PREFERRED;
 	
 		/* Try next area on same PV if looking for contiguous space */
-		if (alloc_parms->flags & A_CONTIGUOUS)
+		if (alloc_parms->flags & A_CONTIGUOUS_TO_LVSEG)
 			return NEXT_AREA;
 	
 		/* Cling_to_alloced? */
@@ -1667,7 +1669,7 @@
 	uint32_t devices_needed = ah->area_count + ah->parity_count;
 
 	/* ix_offset holds the number of parallel allocations that must be contiguous/cling */
-	if (alloc_parms->flags & (A_CONTIGUOUS | A_CLING) && alloc_parms->prev_lvseg)
+	if (alloc_parms->flags & (A_CONTIGUOUS_TO_LVSEG | A_CLING_TO_LVSEG))
 		ix_offset = _stripes_per_mimage(alloc_parms->prev_lvseg) * alloc_parms->prev_lvseg->area_count;
 
 	if (alloc_parms->flags & A_CLING_TO_ALLOCED)



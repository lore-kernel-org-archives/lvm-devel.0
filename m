From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Aug 2011 20:17:35 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c lib/m ...
Message-ID: <20110810201735.18647.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-08-10 20:17:33

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c metadata.h 

Log message:
	Remove INCONSISTENT_VG flag
	
	As this flag could not have been set by the current code - removing it.
	
	Note: because of the wrong code logic this call:
	
	lvmcache_update_vg(correct_vg, correct_vg->status & PRECOMMITTED &
	(inconsistent ? INCONSISTENT_VG : 0));
	
	had always passed '0' - now after flag removal it's passing
	PRECOMMITTED flag in - this present functinal change in this patch.
	
	To match the original functionality - 0 had to be always passed.
	More testing is needed here.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2056&r2=1.2057
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.460&r2=1.461
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.248&r2=1.249

--- LVM2/WHATS_NEW	2011/08/10 16:07:53	1.2056
+++ LVM2/WHATS_NEW	2011/08/10 20:17:33	1.2057
@@ -1,5 +1,6 @@
 Version 2.02.87 - 
 ===============================
+  Remove INCONSISTENT_VG flag from the code.
   Remove lock from cache even if unlock fails.
   Initialise clvmd locks before lvm context to avoid open descriptor leaks.
   Remove obsoleted GULM clvmd cluster locking support.
--- LVM2/lib/metadata/metadata.c	2011/08/04 15:18:11	1.460
+++ LVM2/lib/metadata/metadata.c	2011/08/10 20:17:33	1.461
@@ -2861,12 +2861,8 @@
 	 * the missing PV logic below.
 	 */
 	if ((correct_vg = lvmcache_get_vg(vgid, precommitted)) &&
-	    (use_precommitted || !*consistent || !(correct_vg->status & INCONSISTENT_VG))) {
-		if (!(correct_vg->status & INCONSISTENT_VG))
-			*consistent = 1;
-		else	/* Inconsistent but we can't repair it */
-			correct_vg->status &= ~INCONSISTENT_VG;
-
+	    (use_precommitted || !*consistent)) {
+		*consistent = 1;
 		return correct_vg;
 	} else {
 		free_vg(correct_vg);
@@ -3131,8 +3127,7 @@
 	 * If there is no precommitted metadata, committed metadata
 	 * is read and stored in the cache even if use_precommitted is set
 	 */
-	lvmcache_update_vg(correct_vg, correct_vg->status & PRECOMMITTED &
-			   (inconsistent ? INCONSISTENT_VG : 0));
+	lvmcache_update_vg(correct_vg, (correct_vg->status & PRECOMMITTED));
 
 	if (inconsistent) {
 		/* FIXME Test should be if we're *using* precommitted metadata not if we were searching for it */
--- LVM2/lib/metadata/metadata.h	2011/08/02 22:07:22	1.248
+++ LVM2/lib/metadata/metadata.h	2011/08/10 20:17:33	1.249
@@ -75,7 +75,6 @@
 //#define CONVERTING		0x00400000U	/* LV */
 
 //#define MISSING_PV		0x00800000U	/* PV */
-#define INCONSISTENT_VG		0x00800000U	/* VG - internal use only */
 //#define PARTIAL_LV		0x01000000U	/* LV - derived flag, not
 //						   written out in metadata*/
 



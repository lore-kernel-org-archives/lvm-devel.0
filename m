From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Jun 2008 21:38:58 -0000
Subject: LVM2 ./WHATS_NEW tools/lvconvert.c
Message-ID: <20080626213858.21682.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-06-26 21:38:58

Modified files:
	.              : WHATS_NEW 
	tools          : lvconvert.c 

Log message:
	Fix lvconvert to disallow snapshot and mirror combinations. (mpatocka)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.917&r2=1.918
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.64&r2=1.65

--- LVM2/WHATS_NEW	2008/06/25 16:52:26	1.917
+++ LVM2/WHATS_NEW	2008/06/26 21:38:57	1.918
@@ -1,5 +1,6 @@
 Version 2.02.39 -
 ================================
+  Fix lvconvert to disallow snapshot and mirror combinations.
   Fix reporting of LV fields alongside unallocated PV segments.
   Add --unquoted and --rows to reporting tools.
   Add and use uninitialized_var() macro to suppress invalid compiler warnings.
--- LVM2/tools/lvconvert.c	2008/04/18 12:50:24	1.64
+++ LVM2/tools/lvconvert.c	2008/06/26 21:38:58	1.65
@@ -629,10 +629,12 @@
 		return 0;
 	}
 
-	if (org->status & (LOCKED|PVMOVE) || lv_is_cow(org)) {
+	if (org->status & (LOCKED|PVMOVE|MIRRORED) || lv_is_cow(org)) {
 		log_error("Unable to create a snapshot of a %s LV.",
 			  org->status & LOCKED ? "locked" :
-			  org->status & PVMOVE ? "pvmove" : "snapshot");
+			  org->status & PVMOVE ? "pvmove" :
+			  org->status & MIRRORED ? "mirrored" :
+			  "snapshot");
 		return 0;
 	}
 
@@ -707,15 +709,19 @@
 		return ECMD_FAILED;
 	}
 
-	if (arg_count(cmd, mirrors_ARG) || (lv->status & MIRRORED)) {
+	if (lp->snapshot) {
+		if (lv->status & MIRRORED) {
+			log_error("Unable to convert mirrored LV \"%s\" into a snapshot.", lv->name);
+			return ECMD_FAILED;
+		}
 		if (!archive(lv->vg))
 			return ECMD_FAILED;
-		if (!lvconvert_mirrors(cmd, lv, lp))
+		if (!lvconvert_snapshot(cmd, lv, lp))
 			return ECMD_FAILED;
-	} else if (lp->snapshot) {
+	} else if (arg_count(cmd, mirrors_ARG) || (lv->status & MIRRORED)) {
 		if (!archive(lv->vg))
 			return ECMD_FAILED;
-		if (!lvconvert_snapshot(cmd, lv, lp))
+		if (!lvconvert_mirrors(cmd, lv, lp))
 			return ECMD_FAILED;
 	}
 



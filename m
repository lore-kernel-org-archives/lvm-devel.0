From: agk@sourceware.org <agk@sourceware.org>
Date: 21 Dec 2007 01:08:19 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20071221010819.28713.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-12-21 01:08:18

Modified files:
	tools          : lvconvert.c 

Log message:
	auto-collapse layers

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50

--- LVM2/tools/lvconvert.c	2007/12/20 18:55:46	1.49
+++ LVM2/tools/lvconvert.c	2007/12/21 01:08:18	1.50
@@ -236,7 +236,14 @@
 	unsigned corelog = 0;
 
 	seg = first_seg(lv);
-	existing_mirrors = (lv->status & MIRRORED) ? seg->area_count : 1;
+	existing_mirrors = lv_mirror_count(lv);
+
+	/* If called with no argument, try collapsing the resync layers */
+	if (!arg_count(cmd, mirrors_ARG) && !arg_count(cmd, mirrorlog_ARG)) {
+		if (!collapse_mirrored_lv(lv))
+			return_0;
+		goto commit_changes;
+	}
 
 	/*
 	 * Adjust required number of mirrors
@@ -516,8 +523,7 @@
 		return ECMD_FAILED;
 	}
 
-	if (arg_count(cmd, mirrors_ARG) ||
-	    ((lv->status & MIRRORED) && arg_count(cmd, mirrorlog_ARG))) {
+	if (arg_count(cmd, mirrors_ARG) || (lv->status & MIRRORED)) {
 		if (!archive(lv->vg))
 			return ECMD_FAILED;
 		if (!lvconvert_mirrors(cmd, lv, lp))



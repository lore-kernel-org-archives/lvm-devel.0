From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 15 Jun 2009 12:08:59 -0000
Subject: LVM2 ./WHATS_NEW tools/lvconvert.c
Message-ID: <20090615120859.26504.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-06-15 12:08:59

Modified files:
	.              : WHATS_NEW 
	tools          : lvconvert.c 

Log message:
	Fix lvconvert to not poll mirror if no conversion in progress.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1148&r2=1.1149
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.79&r2=1.80

--- LVM2/WHATS_NEW	2009/06/15 11:56:31	1.1148
+++ LVM2/WHATS_NEW	2009/06/15 12:08:59	1.1149
@@ -1,5 +1,6 @@
 Version 2.02.48 - 
 ===============================
+  Fix lvconvert to not poll mirror if no conversion in progress.
   Fix memory leaks in toolcontext error path.
   Re-instate partial activation support in clustered mode. (2.02.40)
   Allow metadata correction even when PVs are missing.
--- LVM2/tools/lvconvert.c	2009/06/10 15:27:57	1.79
+++ LVM2/tools/lvconvert.c	2009/06/15 12:08:59	1.80
@@ -523,7 +523,8 @@
 	if (!arg_count(cmd, mirrors_ARG) && !arg_count(cmd, mirrorlog_ARG) &&
 	    !arg_count(cmd, corelog_ARG) && !arg_count(cmd, regionsize_ARG) &&
 	    !repair) {
-		lp->need_polling = 1;
+		if (find_temporary_mirror(lv) || (lv->status & CONVERTING))
+			lp->need_polling = 1;
 		return 1;
 	}
 



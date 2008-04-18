From: agk@sourceware.org <agk@sourceware.org>
Date: 18 Apr 2008 12:50:25 -0000
Subject: LVM2 ./WHATS_NEW tools/lvconvert.c
Message-ID: <20080418125025.29262.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-04-18 12:50:24

Modified files:
	.              : WHATS_NEW 
	tools          : lvconvert.c 

Log message:
	Fix lvconvert -m0 allocatable space check.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.853&r2=1.854
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.63&r2=1.64

--- LVM2/WHATS_NEW	2008/04/15 15:01:18	1.853
+++ LVM2/WHATS_NEW	2008/04/18 12:50:24	1.854
@@ -1,5 +1,6 @@
 Version 2.02.36 - 
 =================================
+  Fix lvconvert -m0 allocatable space check.
 
 Version 2.02.35 - 15th April 2008
 =================================
--- LVM2/tools/lvconvert.c	2008/04/09 12:56:34	1.63
+++ LVM2/tools/lvconvert.c	2008/04/18 12:50:24	1.64
@@ -750,7 +750,7 @@
 
 	if (lp.pv_count) {
 		if (!(lp.pvh = create_pv_list(cmd->mem, vg, lp.pv_count,
-					      lp.pvs, 1)))
+					      lp.pvs, 0)))
 			goto_bad;
 	} else
 		lp.pvh = &vg->pvs;



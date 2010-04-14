From: agk@sourceware.org <agk@sourceware.org>
Date: 14 Apr 2010 02:19:50 -0000
Subject: LVM2 ./WHATS_NEW tools/toollib.c
Message-ID: <20100414021950.27930.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-14 02:19:49

Modified files:
	.              : WHATS_NEW 
	tools          : toollib.c 

Log message:
	Only pass visible LVs to tools in cmdline VG name/tag expansions without -a

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1516&r2=1.1517
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.193&r2=1.194

--- LVM2/WHATS_NEW	2010/04/13 23:57:41	1.1516
+++ LVM2/WHATS_NEW	2010/04/14 02:19:49	1.1517
@@ -1,5 +1,6 @@
 Version 2.02.63 -  
 ================================
+  Only pass visible LVs to tools in cmdline VG name/tag expansions without -a.
   Use typedefs for toollib process_each functions.
   Use C locales and use_mlockall for clvmd.
   Refactor code related to vg->pvs list and add pv->vg link.
--- LVM2/tools/toollib.c	2010/04/13 23:57:41	1.193
+++ LVM2/tools/toollib.c	2010/04/14 02:19:49	1.194
@@ -125,6 +125,13 @@
 		if (lv_is_virtual_origin(lvl->lv) && !arg_count(cmd, all_ARG))
 			continue;
 
+		/*
+		 * Only let hidden LVs through it --all was used or the LVs 
+		 * were specifically named on the command line.
+		 */
+		if (!lvargs_supplied && !lv_is_visible(lvl->lv) && !arg_count(cmd, all_ARG))
+			continue;
+
 		/* Should we process this LV? */
 		if (process_all)
 			process_lv = 1;



From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 19 Aug 2010 23:04:38 -0000
Subject: LVM2 ./WHATS_NEW tools/pvremove.c tools/toollib.c
Message-ID: <20100819230438.25296.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-08-19 23:04:38

Modified files:
	.              : WHATS_NEW 
	tools          : pvremove.c toollib.c 

Log message:
	Remove assumption that --yes must be used only in --force mode
	
	This is not only undocumented but is is also in violation with --help
	documentation.
	
	Using --yes without --force is useful in pvcreate when it detects
	old signature.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1713&r2=1.1714
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvremove.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.207&r2=1.208

--- LVM2/WHATS_NEW	2010/08/19 23:03:34	1.1713
+++ LVM2/WHATS_NEW	2010/08/19 23:04:37	1.1714
@@ -1,6 +1,7 @@
 Version 2.02.74 - 
 ==================================
   Simplify MD/swap signature detection in pvcreate and allow aborting.
+  Remove assumption that --yes must be used only in --force mode.
 
 Version 2.02.73 - 18th August 2010
 ==================================
--- LVM2/tools/pvremove.c	2010/07/09 15:34:48	1.28
+++ LVM2/tools/pvremove.c	2010/08/19 23:04:37	1.29
@@ -143,11 +143,6 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, yes_ARG) && !arg_count(cmd, force_ARG)) {
-		log_error("Option y can only be given with option f");
-		return EINVALID_CMD_LINE;
-	}
-
 	for (i = 0; i < argc; i++) {
 		r = pvremove_single(cmd, argv[i], NULL);
 		if (r > ret)
--- LVM2/tools/toollib.c	2010/06/30 20:03:53	1.207
+++ LVM2/tools/toollib.c	2010/08/19 23:04:37	1.208
@@ -1344,11 +1344,6 @@
 		return 0;
 	}
 
-	if (arg_count(cmd, yes_ARG) && !arg_count(cmd, force_ARG)) {
-		log_error("Option y can only be given with option f");
-		return 0;
-	}
-
 	pp->yes = arg_count(cmd, yes_ARG);
 	pp->force = arg_count(cmd, force_ARG);
 



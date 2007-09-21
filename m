From: meyering@sourceware.org <meyering@sourceware.org>
Date: 21 Sep 2007 18:06:56 -0000
Subject: LVM2 ./WHATS_NEW tools/lvmcmdline.c
Message-ID: <20070921180656.21738.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2007-09-21 18:06:56

Modified files:
	.              : WHATS_NEW 
	tools          : lvmcmdline.c 

Log message:
	Print --help output to stdout, not stderr.
	
	* tools/lvmcmdline.c (_usage): Use log_print, not log_error.
	
	Author: Jim Meyering <jim@meyering.net>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.712&r2=1.713
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51

--- LVM2/WHATS_NEW	2007/09/21 18:06:33	1.712
+++ LVM2/WHATS_NEW	2007/09/21 18:06:56	1.713
@@ -1,5 +1,6 @@
 Version 2.02.29 -
 ==================================
+  All tools: print --help output to stdout, not stderr.
   After a diagnostic, suggest --help, rather than printing all --help output.
   Add %PVS extents option to lvresize, lvextend, and lvcreate.
   Moved the obsolete test subdirectory to old-tests.
--- LVM2/tools/lvmcmdline.c	2007/09/21 18:06:33	1.50
+++ LVM2/tools/lvmcmdline.c	2007/09/21 18:06:56	1.51
@@ -478,7 +478,7 @@
 	if (!com)
 		return;
 
-	log_error("%s: %s\n\n%s", com->name, com->desc, com->usage);
+	log_print("%s: %s\n\n%s", com->name, com->desc, com->usage);
 }
 
 /*



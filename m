From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 10 Apr 2009 09:53:43 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/mirror.c
Message-ID: <20090410095343.16943.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-04-10 09:53:43

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : mirror.c 

Log message:
	Fix mirror log convert validation question.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1081&r2=1.1082
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.82&r2=1.83

--- LVM2/WHATS_NEW	2009/04/08 14:08:23	1.1081
+++ LVM2/WHATS_NEW	2009/04/10 09:53:42	1.1082
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Fix mirror log convert validation question.
   Avoid referencing files from DESTDIR during build process.
   Avoid creating some static libraries without static_link.
   Enable use of cached metadata for pvs and pvdisplay commands.
--- LVM2/lib/metadata/mirror.c	2009/04/07 10:20:29	1.82
+++ LVM2/lib/metadata/mirror.c	2009/04/10 09:53:43	1.83
@@ -1219,7 +1219,7 @@
 		return 0;
 	} else if (yes_no_prompt("Full resync required to convert "
 				 "inactive mirror %s to core log. "
-				 "Proceed? [y/n]: "))
+				 "Proceed? [y/n]: ") == 'y')
 		sync_percent = 0;
 	else
 		return 0;



From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Jul 2007 13:28:33 -0000
Subject: LVM2 ./WHATS_NEW lib/filters/filter.c
Message-ID: <20070726132833.28636.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-07-26 13:28:32

Modified files:
	.              : WHATS_NEW 
	lib/filters    : filter.c 

Log message:
	Add ps3disk devices.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.671&r2=1.672
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41

--- LVM2/WHATS_NEW	2007/07/24 17:48:07	1.671
+++ LVM2/WHATS_NEW	2007/07/26 13:28:32	1.672
@@ -10,7 +10,7 @@
   In _line_append, use "sizeof buf - 1" rather than equivalent "4095"
   Introduce is_same_inode macro, now including a comparison of st_dev.
   Don't leak a file descriptor in _lock_file(), when flock fails.
-  Add SUN's LDOM virtual block device to filters
+  Add SUN's LDOM virtual block device (vdisk) and ps3disk to filters.
   Split metadata-external.h out from metadata.h for the tools to use.
 
 Version 2.02.27 - 17th July 2007
--- LVM2/lib/filters/filter.c	2007/07/19 07:06:47	1.40
+++ LVM2/lib/filters/filter.c	2007/07/26 13:28:32	1.41
@@ -76,6 +76,7 @@
 	{"device-mapper", 1},	/* Other mapped devices */
 	{"xvd", 16},		/* Xen virtual block device */
 	{"vdisk", 8},		/* SUN's LDOM virtual block device */
+	{"ps3disk", 16},	/* PlayStation 3 internal disk */
 	{NULL, 0}
 };
 



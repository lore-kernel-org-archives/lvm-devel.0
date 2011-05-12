From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 12 May 2011 12:42:50 -0000
Subject: LVM2 ./WHATS_NEW lib/filters/filter-persistent.c
Message-ID: <20110512124250.15910.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-05-12 12:42:48

Modified files:
	.              : WHATS_NEW 
	lib/filters    : filter-persistent.c 

Log message:
	Do not issue an error message when unable to remove .cache on read-only fs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1988&r2=1.1989
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-persistent.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50

--- LVM2/WHATS_NEW	2011/05/07 15:52:50	1.1988
+++ LVM2/WHATS_NEW	2011/05/12 12:42:47	1.1989
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Do not issue an error message when unable to remove .cache on read-only fs.
   Avoid memlock size mismatch by preallocating stdio line buffers.
   Reorganize lvconvert --repair code to allow reuse.
   Rewrite vgreduce --removemissing --force leveraging shared lvconvert code.
--- LVM2/lib/filters/filter-persistent.c	2011/04/22 12:05:33	1.49
+++ LVM2/lib/filters/filter-persistent.c	2011/05/12 12:42:48	1.50
@@ -108,7 +108,7 @@
 			log_very_verbose("Obtaining device list from "
 					 "udev. Removing obolete %s.",
 					 pf->file);
-			if (unlink(pf->file) < 0)
+			if (unlink(pf->file) < 0 && errno != EROFS)
 				log_sys_error("unlink", pf->file);
 		}
 		return 1;



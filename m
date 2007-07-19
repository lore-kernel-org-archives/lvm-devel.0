From: pcaulfield@sourceware.org <pcaulfield@sourceware.org>
Date: 19 Jul 2007 07:06:47 -0000
Subject: LVM2 ./WHATS_NEW lib/filters/filter.c
Message-ID: <20070719070647.31485.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	pcaulfield at sourceware.org	2007-07-19 07:06:47

Modified files:
	.              : WHATS_NEW 
	lib/filters    : filter.c 

Log message:
	Add SUN's LDOM virtual block device to filters
	Thanks to Fabio Massimo Di Nitto

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.660&r2=1.661
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40

--- LVM2/WHATS_NEW	2007/07/18 15:38:57	1.660
+++ LVM2/WHATS_NEW	2007/07/19 07:06:47	1.661
@@ -1,5 +1,6 @@
 Version 2.02.28 -
 ================================
+  Add SUN's LDOM virtual block device to filters
   Split metadata-external.h out from metadata.h for the tools to use.
 
 Version 2.02.27 - 17th July 2007
--- LVM2/lib/filters/filter.c	2007/01/25 23:03:48	1.39
+++ LVM2/lib/filters/filter.c	2007/07/19 07:06:47	1.40
@@ -75,6 +75,7 @@
 	{"aoe", 16},		/* ATA over Ethernet */
 	{"device-mapper", 1},	/* Other mapped devices */
 	{"xvd", 16},		/* Xen virtual block device */
+	{"vdisk", 8},		/* SUN's LDOM virtual block device */
 	{NULL, 0}
 };
 



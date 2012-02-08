From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Feb 2012 12:48:15 -0000
Subject: LVM2 ./WHATS_NEW lib/filters/filter.c
Message-ID: <20120208124815.20897.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-08 12:48:14

Modified files:
	.              : WHATS_NEW 
	lib/filters    : filter.c 

Log message:
	Add range test for device number
	
	Check the output of atoi is in valid range.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2267&r2=1.2268
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.67&r2=1.68

--- LVM2/WHATS_NEW	2012/02/08 11:34:46	1.2267
+++ LVM2/WHATS_NEW	2012/02/08 12:48:14	1.2268
@@ -1,5 +1,6 @@
 Version 2.02.91 -
 ===================================
+  Add range test for device number in _scan_proc_dev().
   Use signed long for sysconf() call in cmirrord.
   Do not write in front of log buffer in print_log().
   Add boundary test for number of mirror devs and logs.
--- LVM2/lib/filters/filter.c	2012/01/11 20:38:42	1.67
+++ LVM2/lib/filters/filter.c	2012/02/08 12:48:14	1.68
@@ -226,7 +226,7 @@
 
 		/* If it's not a number it may be name of section */
 		line_maj = atoi(((char *) (line + i)));
-		if (!line_maj) {
+		if ((line_maj <= 0) || (line_maj >= NUMBER_OF_MAJORS)) {
 			blocksection = (line[i] == 'B') ? 1 : 0;
 			continue;
 		}



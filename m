From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Feb 2012 11:34:47 -0000
Subject: LVM2 ./WHATS_NEW daemons/cmirrord/functions.c
Message-ID: <20120208113447.24920.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-08 11:34:46

Modified files:
	.              : WHATS_NEW 
	daemons/cmirrord: functions.c 

Log message:
	Keep page_size as signed number
	
	Since it's return value from sysconf and is checked for <0.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2266&r2=1.2267
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/functions.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31

--- LVM2/WHATS_NEW	2012/02/08 11:31:29	1.2266
+++ LVM2/WHATS_NEW	2012/02/08 11:34:46	1.2267
@@ -1,5 +1,6 @@
 Version 2.02.91 -
 ===================================
+  Use signed long for sysconf() call in cmirrord.
   Do not write in front of log buffer in print_log().
   Add boundary test for number of mirror devs and logs.
   Check that whole locking_dir fits _lock_dir buffer in init_file_locking().
--- LVM2/daemons/cmirrord/functions.c	2011/10/14 14:18:49	1.30
+++ LVM2/daemons/cmirrord/functions.c	2012/02/08 11:34:46	1.31
@@ -375,7 +375,7 @@
 	int disk_log = 0;
 	char disk_path[128];
 	int unlink_path = 0;
-	size_t page_size;
+	long page_size;
 	int pages;
 
 	/* If core log request, then argv[0] will be region_size */



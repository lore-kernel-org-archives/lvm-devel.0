From: meyering@sourceware.org <meyering@sourceware.org>
Date: Fri, 20 Jul 2007 15:30:38 -0000
Subject: LVM2 ./WHATS_NEW lib/config/config.c
Message-ID: <20070720152640.7952.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2007-07-20 15:26:39

Modified files:
	.              : WHATS_NEW 
	lib/config     : config.c 

Log message:
	In _line_append, use "sizeof buf - 1" rather than equivalent "4095"
	* lib/config/config.c:

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.663&r2=1.664
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61

--- LVM2/WHATS_NEW	2007/07/20 15:22:45	1.663
+++ LVM2/WHATS_NEW	2007/07/20 15:26:39	1.664
@@ -1,4 +1,5 @@
 Version 2.02.28 -
+  In _line_append, use "sizeof buf - 1" rather than equivalent "4095"
   Introduce is_same_inode macro, now including a comparison of st_dev.
   Don't leak a file descriptor in _lock_file(), when flock fails.
   Add SUN's LDOM virtual block device to filters
--- LVM2/lib/config/config.c	2007/07/08 22:51:20	1.60
+++ LVM2/lib/config/config.c	2007/07/20 15:26:39	1.61
@@ -367,8 +367,8 @@
 	int n;
 
 	va_start(ap, fmt);
-	n = vsnprintf(&buf[0], 4095, fmt, ap);
-	if (n < 0 || n > 4095) {
+	n = vsnprintf(&buf[0], sizeof buf - 1, fmt, ap);
+	if (n < 0 || n > sizeof buf - 1) {
 		log_error("vsnprintf failed for config line");
 		return 0;
 	}



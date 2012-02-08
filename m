From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Feb 2012 11:31:30 -0000
Subject: LVM2 ./WHATS_NEW lib/log/log.c
Message-ID: <20120208113130.6471.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-08 11:31:29

Modified files:
	.              : WHATS_NEW 
	lib/log        : log.c 

Log message:
	Move done jump lower
	
	Since before 'goto done' is bufused zeroed, it would otherwise write 1
	byte in front of buffer.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2265&r2=1.2266
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.67&r2=1.68

--- LVM2/WHATS_NEW	2012/02/08 11:17:34	1.2265
+++ LVM2/WHATS_NEW	2012/02/08 11:31:29	1.2266
@@ -1,5 +1,7 @@
 Version 2.02.91 -
 ===================================
+  Do not write in front of log buffer in print_log().
+  Add boundary test for number of mirror devs and logs.
   Check that whole locking_dir fits _lock_dir buffer in init_file_locking().
   Use list functions for label_exit().
   Ensure strncpy() function always ends with '\0'.
--- LVM2/lib/log/log.c	2012/02/08 11:05:04	1.67
+++ LVM2/lib/log/log.c	2012/02/08 11:31:29	1.68
@@ -388,8 +388,8 @@
 		va_end(ap);
 		bufused += n;
 
-	      done:
 		buf[bufused - 1] = '\n';
+	      done:
 		buf[bufused] = '\n';
 		buf[sizeof(buf) - 1] = '\n';
 		/* FIXME real size bufused */



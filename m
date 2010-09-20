From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 20 Sep 2010 14:25:28 -0000
Subject: LVM2 ./WHATS_NEW lib/misc/lvm-string.c
Message-ID: <20100920142528.16716.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-09-20 14:25:27

Modified files:
	.              : WHATS_NEW 
	lib/misc       : lvm-string.c 

Log message:
	Revert to old glibc behaviour for vsnprintf used in emit_to_buffer function.
	
	Revert to old glibc behaviour for vsnprintf used in emit_to_buffer fn.
	Otherwise, the check that follows would be wrong for new glibc versions.
	This caused the rh bug #633033 to be undetected and pass throught the check,
	corrupting the metadata!

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1730&r2=1.1731
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-string.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21

--- LVM2/WHATS_NEW	2010/09/20 14:23:20	1.1730
+++ LVM2/WHATS_NEW	2010/09/20 14:25:27	1.1731
@@ -1,5 +1,6 @@
 Version 2.02.74 - 
 ==================================
+  Revert to old glibc behaviour for vsnprintf used in emit_to_buffer function.
   Use dynamic allocation for metadata's tag buffer (removes 4096 char. limit).
   Add random suffix to archive file names to prevent races when being created.
   Reinitialize archive and backup handling on toolcontext refresh.
--- LVM2/lib/misc/lvm-string.c	2010/04/23 14:16:33	1.20
+++ LVM2/lib/misc/lvm-string.c	2010/09/20 14:25:27	1.21
@@ -27,6 +27,14 @@
 	n = vsnprintf(*buffer, *size, fmt, ap);
 	va_end(ap);
 
+	/*
+	 * Revert to old glibc behaviour (version <= 2.0.6) where snprintf
+	 * returned -1 if buffer was too small. From glibc 2.1 it returns number
+	 * of chars that would have been written had there been room.
+	 */
+	if (n < 0 || ((unsigned) n + 1 > *size))
+		n = -1;
+
 	if (n < 0 || ((size_t)n == *size))
 		return 0;
 



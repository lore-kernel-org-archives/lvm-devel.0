From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Nov 2009 10:50:58 -0000
Subject: LVM2 ./WHATS_NEW lib/display/display.c
Message-ID: <20091103105058.22155.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2009-11-03 10:50:57

Modified files:
	.              : WHATS_NEW 
	lib/display    : display.c 

Log message:
	Add fflush for the case the log is redirected to the buffered file.
	
	Without this patch it have not been obvious, why the application
	waits on the stdin as the prompt might be still buffered in memory.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1310&r2=1.1311
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.106&r2=1.107

--- LVM2/WHATS_NEW	2009/10/31 17:43:57	1.1310
+++ LVM2/WHATS_NEW	2009/11/03 10:50:57	1.1311
@@ -1,5 +1,6 @@
 Version 2.02.55 -
 ===================================
+  Flush stdout after yes/no prompt.
   Update vgsplit and vgcreate to use vg_set_clustered.
   Add vg_mda_count and vg_set_clustered library function.
   Add more vgcreate and vgsplit nightly tests.
--- LVM2/lib/display/display.c	2009/10/26 10:01:57	1.106
+++ LVM2/lib/display/display.c	2009/11/03 10:50:57	1.107
@@ -824,6 +824,7 @@
 			va_start(ap, prompt);
 			vprintf(prompt, ap);
 			va_end(ap);
+			fflush(stdout);
 		}
 
 		if ((c = getchar()) == EOF) {



From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 16 Jun 2010 13:03:52 -0000
Subject: LVM2 ./WHATS_NEW doc/example_cmdlib.c
Message-ID: <20100616130352.29460.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-06-16 13:03:51

Modified files:
	.              : WHATS_NEW 
	doc            : example_cmdlib.c 

Log message:
	Fix lvm2cmd example in documentation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1612&r2=1.1613
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example_cmdlib.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/WHATS_NEW	2010/06/16 13:01:25	1.1612
+++ LVM2/WHATS_NEW	2010/06/16 13:03:48	1.1613
@@ -1,5 +1,6 @@
 Version 2.02.68 -
 ===============================
+  Fix lvm2cmd example in documentation.
   Allow use of lvm2app and lvm2cmd headers in C++ mode.
   Fix wrong lvm path creation from configure introduced in previous release.
   Fix segfault in clvmd -R if no response from daemon received.
--- LVM2/doc/example_cmdlib.c	2009/07/15 23:57:55	1.2
+++ LVM2/doc/example_cmdlib.c	2010/06/16 13:03:50	1.3
@@ -13,10 +13,11 @@
  */
 
 #include "lvm2cmd.h"
+#include <stdio.h>
 
 /* All output gets passed to this function line-by-line */
-void test_log_fn(int level, int dm_errno, const char *file, int line,
-		 const char *format)
+void test_log_fn(int level, const char *file, int line,
+		 int dm_errno, const char *format)
 {
 	/* Extract and process output here rather than printing it */
 



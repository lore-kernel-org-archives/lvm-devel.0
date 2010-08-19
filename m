From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 19 Aug 2010 23:05:45 -0000
Subject: LVM2 ./WHATS_NEW lib/device/dev-swap.c
Message-ID: <20100819230545.26070.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-08-19 23:05:45

Modified files:
	.              : WHATS_NEW 
	lib/device     : dev-swap.c 

Log message:
	Fix file descriptor leak in swap signature detection

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1714&r2=1.1715
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-swap.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/WHATS_NEW	2010/08/19 23:04:37	1.1714
+++ LVM2/WHATS_NEW	2010/08/19 23:05:45	1.1715
@@ -2,6 +2,7 @@
 ==================================
   Simplify MD/swap signature detection in pvcreate and allow aborting.
   Remove assumption that --yes must be used only in --force mode.
+  Fix file descriptor leak in swap signature detection error path.
 
 Version 2.02.73 - 18th August 2010
 ==================================
--- LVM2/lib/device/dev-swap.c	2009/03/17 14:40:00	1.1
+++ LVM2/lib/device/dev-swap.c	2010/08/19 23:05:45	1.2
@@ -42,7 +42,7 @@
 {
 	char buf[10];
 	uint64_t size;
-	int page;
+	int page, ret = 0;
 
 	if (!dev_get_size(dev, &size)) {
 		stack;
@@ -66,11 +66,12 @@
 			break;
 		if (!dev_read(dev, page - SIGNATURE_SIZE,
 			      SIGNATURE_SIZE, buf)) {
-			stack;
-			return -1;
+			ret = -1;
+			break;
 		}
 		if (_swap_detect_signature(buf)) {
 			*signature = page - SIGNATURE_SIZE;
+			ret = 1;
 			break;
 		}
 	}
@@ -78,10 +79,7 @@
 	if (!dev_close(dev))
 		stack;
 
-	if (*signature)
-		return 1;
-
-	return 0;
+	return ret;
 }
 
 #endif



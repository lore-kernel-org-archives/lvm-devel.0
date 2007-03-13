From: pcaulfield@sourceware.org <pcaulfield@sourceware.org>
Date: 13 Mar 2007 14:59:22 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/no_locking.c
Message-ID: <20070313145922.16499.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	pcaulfield at sourceware.org	2007-03-13 14:59:21

Modified files:
	.              : WHATS_NEW 
	lib/locking    : no_locking.c 

Log message:
	Flag nolocking as a clustered locking module as we need to be able
	to look at clustered LVs at clvmd startup

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.584&r2=1.585
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/no_locking.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/WHATS_NEW	2007/03/09 21:25:33	1.584
+++ LVM2/WHATS_NEW	2007/03/13 14:59:21	1.585
@@ -2,6 +2,8 @@
 ====================================
   Add a few missing pieces of vgname command line validation.
   Support the /dev/mapper prefix on most command lines.
+  Flag nolocking as a clustered locking module as we need to be able
+    to look at clustered LVs at clvmd startup (2.02.10)
 
 Version 2.02.23 - 8th March 2007
 ================================
--- LVM2/lib/locking/no_locking.c	2006/05/16 16:48:30	1.10
+++ LVM2/lib/locking/no_locking.c	2007/03/13 14:59:21	1.11
@@ -81,7 +81,7 @@
 	locking->lock_resource = _no_lock_resource;
 	locking->reset_locking = _no_reset_locking;
 	locking->fin_locking = _no_fin_locking;
-	locking->flags = 0;
+	locking->flags = LCK_CLUSTERED;
 
 	return 1;
 }



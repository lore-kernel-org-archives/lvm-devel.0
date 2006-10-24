From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Oct 2006 18:25:30 -0000
Subject: LVM2 ./WHATS_NEW tools/toollib.c
Message-ID: <20061024182530.3254.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-10-24 18:25:30

Modified files:
	.              : WHATS_NEW 
	tools          : toollib.c 

Log message:
	Add dev_flush() to set_lv()

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.480&r2=1.481
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.91&r2=1.92

--- LVM2/WHATS_NEW	2006/10/24 17:18:24	1.480
+++ LVM2/WHATS_NEW	2006/10/24 18:25:30	1.481
@@ -1,5 +1,6 @@
 Version 2.02.13 -
 ===================================
+  Add dev_flush() to set_lv().
   Add lvchange --resync.
   Perform high-level free space check before each allocation attempt.
   Don't allow a node to remove an LV that's exclusively active on anther node.
--- LVM2/tools/toollib.c	2006/10/21 23:18:43	1.91
+++ LVM2/tools/toollib.c	2006/10/24 18:25:30	1.92
@@ -1222,6 +1222,7 @@
 		return 0;
 
 	dev_set(dev, UINT64_C(0), (size_t) 4096, value);
+	dev_flush(dev);
 	dev_close_immediate(dev);
 
 	return 1;



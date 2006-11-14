From: agk@sourceware.org <agk@sourceware.org>
Date: 14 Nov 2006 15:03:08 -0000
Subject: LVM2 ./WHATS_NEW lib/label/label.c
Message-ID: <20061114150308.6231.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-11-14 15:03:07

Modified files:
	.              : WHATS_NEW 
	lib/label      : label.c 

Log message:
	Fix a label_verify error path.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.495&r2=1.496
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/label/label.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35

--- LVM2/WHATS_NEW	2006/11/10 21:27:51	1.495
+++ LVM2/WHATS_NEW	2006/11/14 15:03:07	1.496
@@ -1,5 +1,6 @@
 Version 2.02.15 -
 ====================================
+  Fix a label_verify error path.
 
 Version 2.02.14 - 10th November 2006
 ====================================
--- LVM2/lib/label/label.c	2006/06/08 22:15:49	1.34
+++ LVM2/lib/label/label.c	2006/11/14 15:03:07	1.35
@@ -347,13 +347,11 @@
 	int r = 0;
 
 	if (!dev_open(dev)) {
-		stack;
-
 		if ((info = info_from_pvid(dev->pvid)))
 			lvmcache_update_vgname_and_id(info, ORPHAN, ORPHAN,
 						      0, NULL);
 
-		goto out;
+		return_0;
 	}
 
 	if (!(l = _find_labeller(dev, buf, &sector)))



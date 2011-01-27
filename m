From: agk@sourceware.org <agk@sourceware.org>
Date: 27 Jan 2011 00:21:38 -0000
Subject: LVM2 ./WHATS_NEW lib/filters/filter.c
Message-ID: <20110127002138.17816.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-01-27 00:21:38

Modified files:
	.              : WHATS_NEW 
	lib/filters    : filter.c 

Log message:
	Use O_DIRECT when reading block devices.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1891&r2=1.1892
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60

--- LVM2/WHATS_NEW	2011/01/24 23:34:47	1.1891
+++ LVM2/WHATS_NEW	2011/01/27 00:21:37	1.1892
@@ -1,5 +1,6 @@
 Version 2.02.83 - 
 ===================================
+  Always use O_DIRECT when opening block devices to check for partitioning.
 
 Version 2.02.82 - 24th January 2011
 ===================================
--- LVM2/lib/filters/filter.c	2011/01/12 15:28:34	1.59
+++ LVM2/lib/filters/filter.c	2011/01/27 00:21:37	1.60
@@ -147,7 +147,7 @@
 	}
 
 	/* Check it's accessible */
-	if (!dev_open_flags(dev, O_RDONLY, 0, 1)) {
+	if (!dev_open_flags(dev, O_RDONLY, 1, 1)) {
 		log_debug("%s: Skipping: open failed", name);
 		return 0;
 	}



From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 28 Aug 2008 13:28:13 -0000
Subject: LVM2/lib/label label.c
Message-ID: <20080828132813.1347.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-08-28 13:28:13

Modified files:
	lib/label      : label.c 

Log message:
	Not detecing label on disc is not error, remove <backtrace> from debug log
	and report it only if device cannot be read.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/label/label.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43

--- LVM2/lib/label/label.c	2008/02/06 15:47:28	1.42
+++ LVM2/lib/label/label.c	2008/08/28 13:28:13	1.43
@@ -119,7 +119,7 @@
 	if (!dev_read(dev, scan_sector << SECTOR_SHIFT,
 		      LABEL_SCAN_SIZE, readbuf)) {
 		log_debug("%s: Failed to read label area", dev_name(dev));
-		goto out;
+		goto_out;
 	}
 
 	/* Scan a few sectors for a valid label */
@@ -284,7 +284,7 @@
 	}
 
 	if (!(l = _find_labeller(dev, buf, &sector, scan_sector)))
-		goto_out;
+		goto out;
 
 	if ((r = (l->ops->read)(l, dev, buf, result)) && result && *result)
 		(*result)->sector = sector;
@@ -361,7 +361,7 @@
 	}
 
 	if (!(l = _find_labeller(dev, buf, &sector, UINT64_C(0))))
-		goto_out;
+		goto out;
 
 	r = l->ops->verify ? l->ops->verify(l, buf, sector) : 1;
 



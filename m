From: agk@sourceware.org <agk@sourceware.org>
Date: 15 Sep 2008 17:06:55 -0000
Subject: LVM2/lib format1/disk-rep.c label/label.c
Message-ID: <20080915170655.32500.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-09-15 17:06:55

Modified files:
	lib/format1    : disk-rep.c 
	lib/label      : label.c 

Log message:
	revert unnecessary 'stack's

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/disk-rep.c.diff?cvsroot=lvm2&r1=1.74&r2=1.75
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/label/label.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44

--- LVM2/lib/format1/disk-rep.c	2008/08/28 13:41:46	1.74
+++ LVM2/lib/format1/disk-rep.c	2008/09/15 17:06:54	1.75
@@ -194,7 +194,7 @@
 	if (!_munge_formats(pvd)) {
 		log_very_verbose("format1: Unknown metadata version %d "
 				 "found on %s", pvd->version, dev_name(dev));
-		return_0;
+		return 0;
 	}
 
 	/* If VG is exported, set VG name back to the real name */
@@ -208,7 +208,7 @@
 	if (!dev_read(dev, UINT64_C(0), sizeof(*pvd), pvd)) {
 		log_very_verbose("Failed to read PV data from %s",
 				 dev_name(dev));
-		return_0;
+		return 0;
 	}
 
 	return munge_pvd(dev, pvd);
--- LVM2/lib/label/label.c	2008/08/28 13:28:13	1.43
+++ LVM2/lib/label/label.c	2008/09/15 17:06:55	1.44
@@ -119,7 +119,7 @@
 	if (!dev_read(dev, scan_sector << SECTOR_SHIFT,
 		      LABEL_SCAN_SIZE, readbuf)) {
 		log_debug("%s: Failed to read label area", dev_name(dev));
-		goto_out;
+		goto out;
 	}
 
 	/* Scan a few sectors for a valid label */



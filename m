From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 28 Aug 2008 13:41:47 -0000
Subject: LVM2/lib/format1 disk-rep.c
Message-ID: <20080828134147.15622.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-08-28 13:41:46

Modified files:
	lib/format1    : disk-rep.c 

Log message:
	format1: Not detecing label on disc is not error, remove <backtrace> from debug log
	(happens when you explicitly use -M 1)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/disk-rep.c.diff?cvsroot=lvm2&r1=1.73&r2=1.74

--- LVM2/lib/format1/disk-rep.c	2008/02/06 15:47:27	1.73
+++ LVM2/lib/format1/disk-rep.c	2008/08/28 13:41:46	1.74
@@ -194,7 +194,7 @@
 	if (!_munge_formats(pvd)) {
 		log_very_verbose("format1: Unknown metadata version %d "
 				 "found on %s", pvd->version, dev_name(dev));
-		return 0;
+		return_0;
 	}
 
 	/* If VG is exported, set VG name back to the real name */
@@ -208,7 +208,7 @@
 	if (!dev_read(dev, UINT64_C(0), sizeof(*pvd), pvd)) {
 		log_very_verbose("Failed to read PV data from %s",
 				 dev_name(dev));
-		return 0;
+		return_0;
 	}
 
 	return munge_pvd(dev, pvd);
@@ -356,7 +356,7 @@
 	list_init(&dl->lvds);
 
 	if (!_read_pvd(dev, &dl->pvd))
-		goto_bad;
+		goto bad;
 
 	/*
 	 * is it an orphan ?



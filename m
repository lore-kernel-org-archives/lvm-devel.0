From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 11 Nov 2011 16:59:31 -0000
Subject: LVM2/lib/filters filter.c
Message-ID: <20111111165931.28329.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-11-11 16:59:30

Modified files:
	lib/filters    : filter.c 

Log message:
	Fix major number filter structure boundary test.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.64&r2=1.65

--- LVM2/lib/filters/filter.c	2011/11/11 15:11:12	1.64
+++ LVM2/lib/filters/filter.c	2011/11/11 16:59:30	1.65
@@ -154,7 +154,7 @@
 		log_debug("%s: Skipping: open failed", name);
 		return 0;
 	}
-	
+
 	/* Check it's not too small */
 	if (!dev_get_size(dev, &size)) {
 		log_debug("%s: Skipping: dev_get_size failed", name);
@@ -319,7 +319,7 @@
 
 int max_partitions(int major)
 {
-	if (major > NUMBER_OF_MAJORS)
+	if (major >= NUMBER_OF_MAJORS)
 		return 0;
 
 	return _partitions[major].max_partitions;
@@ -327,7 +327,7 @@
 
 int major_is_scsi_device(int major)
 {
-	if (major > NUMBER_OF_MAJORS)
+	if (major >= NUMBER_OF_MAJORS)
 		return 0;
 
 	return (_partitions[major].flags & PARTITION_SCSI_DEVICE) ? 1 : 0;



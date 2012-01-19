From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Jan 2012 15:22:32 -0000
Subject: LVM2/libdm libdm-deptree.c
Message-ID: <20120119152232.25927.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-19 15:22:32

Modified files:
	libdm          : libdm-deptree.c 

Log message:
	Thin handle empty thin volume case
	
	Report both values as 0 in case the volume is unused.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.149&r2=1.150

--- LVM2/libdm/libdm-deptree.c	2012/01/19 15:21:23	1.149
+++ LVM2/libdm/libdm-deptree.c	2012/01/19 15:22:32	1.150
@@ -3143,7 +3143,10 @@
 		return 0;
 	}
 
-	if (sscanf(params, "%" PRIu64 " %" PRIu64,
+	if (strchr(params, '-')) {
+		s->mapped_sectors = 0;
+		s->highest_mapped_sector = 0;
+	} else if (sscanf(params, "%" PRIu64 " %" PRIu64,
 		   &s->mapped_sectors,
 		   &s->highest_mapped_sector) != 2) {
 		log_error("Failed to parse thin params: %s.", params);



From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Jan 2008 19:50:23 -0000
Subject: LVM2/lib/metadata mirror.c
Message-ID: <20080116195023.29189.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-16 19:50:23

Modified files:
	lib/metadata   : mirror.c 

Log message:
	adjust mirror log error message

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59

--- LVM2/lib/metadata/mirror.c	2008/01/16 19:38:39	1.58
+++ LVM2/lib/metadata/mirror.c	2008/01/16 19:50:23	1.59
@@ -1187,7 +1187,7 @@
 			      0, 0, log_count, 0,
 			      allocatable_pvs, alloc, parallel_areas);
 	if (!ah) {
-		log_error("Unable to allocate temporary LV for pvmove.");
+		log_error("Unable to allocate extents for mirror log.");
 		return 0;
 	}
 



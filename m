From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Nov 2006 20:15:10 -0000
Subject: LVM2/lib/metadata mirror.c
Message-ID: <20061110201510.23906.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-11-10 20:15:10

Modified files:
	lib/metadata   : mirror.c 

Log message:
	fix cast

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36

--- LVM2/lib/metadata/mirror.c	2006/11/10 19:35:03	1.35
+++ LVM2/lib/metadata/mirror.c	2006/11/10 20:15:10	1.36
@@ -44,7 +44,7 @@
 {
 	uint64_t region_max;
 
-	region_max = (1 << (ffs((int)extents) - 1)) * extent_size;
+	region_max = (1 << (ffs((int)extents) - 1)) * (uint64_t) extent_size;
 
 	if (region_max < UINT32_MAX && region_size > region_max) {
 		region_size = (uint32_t) region_max;



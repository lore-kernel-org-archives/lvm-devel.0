From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 29 Sep 2008 09:59:11 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20080929095911.18767.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-09-29 09:59:10

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	Fix misleading error message when there is no allocatable extents in VG.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.967&r2=1.968
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.155&r2=1.156

--- LVM2/WHATS_NEW	2008/09/25 15:59:10	1.967
+++ LVM2/WHATS_NEW	2008/09/29 09:59:10	1.968
@@ -1,5 +1,6 @@
 Version 2.02.41 -
 =====================================
+  Fix misleading error message when there is no allocatable extents in VG.
   Fix handling of PVs which reappeared with old metadata version.
   Fix mirror DSO to call vgreduce with proper parameters.
   Fix validation of --minor and --major in lvcreate to require -My always.
--- LVM2/lib/metadata/lv_manip.c	2008/08/05 12:05:25	1.155
+++ LVM2/lib/metadata/lv_manip.c	2008/09/29 09:59:10	1.156
@@ -1169,7 +1169,7 @@
 		stack;
 
 	areas_size = list_size(pvms);
-	if (areas_size < ah->area_count + ah->log_count) {
+	if (areas_size && areas_size < (ah->area_count + ah->log_count)) {
 		if (ah->alloc != ALLOC_ANYWHERE) {
 			log_error("Not enough PVs with free space available "
 				  "for parallel allocation.");



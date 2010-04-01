From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Apr 2010 12:29:08 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20100401122908.9120.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-01 12:29:08

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	initialise log_allocated to 0

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.221&r2=1.222

--- LVM2/lib/metadata/lv_manip.c	2010/04/01 10:34:10	1.221
+++ LVM2/lib/metadata/lv_manip.c	2010/04/01 12:29:07	1.222
@@ -1268,7 +1268,7 @@
 	uint32_t areas_size;
 	alloc_policy_t alloc;
 	struct alloced_area *aa;
-	unsigned log_allocated;
+	unsigned log_allocated = 0;
 
 	if (allocated >= ah->new_extents && !ah->log_area_count) {
 		log_error("_allocate called with no work to do!");



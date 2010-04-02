From: agk@sourceware.org <agk@sourceware.org>
Date: 2 Apr 2010 01:35:35 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20100402013535.19654.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-02 01:35:35

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	remove compiler warning

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.223&r2=1.224

--- LVM2/lib/metadata/lv_manip.c	2010/04/01 13:58:13	1.223
+++ LVM2/lib/metadata/lv_manip.c	2010/04/02 01:35:34	1.224
@@ -1269,7 +1269,6 @@
 	struct dm_list *pvms;
 	uint32_t areas_size;
 	alloc_policy_t alloc;
-	struct alloced_area *aa;
 	unsigned log_needs_allocating = 0;
 
 	if (allocated >= ah->new_extents && !ah->log_area_count) {



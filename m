From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Apr 2010 00:52:42 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20100408005242.20337.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-08 00:52:41

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	suppress bogus compiler warning

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.225&r2=1.226

--- LVM2/lib/metadata/lv_manip.c	2010/04/08 00:28:58	1.225
+++ LVM2/lib/metadata/lv_manip.c	2010/04/08 00:52:41	1.226
@@ -2063,7 +2063,7 @@
 	struct dm_list *parallel_areas;
 	struct seg_pvs *spvs;
 	uint32_t current_le = 0;
-	struct lv_segment *seg;
+	struct lv_segment * uninitialized_var(seg);
 
 	if (!(parallel_areas = dm_pool_alloc(cmd->mem, sizeof(*parallel_areas)))) {
 		log_error("parallel_areas allocation failed");



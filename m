From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 17 Oct 2011 13:15:36 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-deptree.c
Message-ID: <20111017131536.905.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-10-17 13:15:35

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-deptree.c 

Log message:
	Fix alignment warning in bitcount calculation for raid segment.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.510&r2=1.511
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.123&r2=1.124

--- LVM2/WHATS_NEW_DM	2011/10/14 13:34:19	1.510
+++ LVM2/WHATS_NEW_DM	2011/10/17 13:15:35	1.511
@@ -1,5 +1,6 @@
 Version 1.02.68 -
 ==================================
+  Fix alignment warning in bitcount calculation for raid segment.
   Allocate dm_tree structure from dm_tree pool.
   Update debug logging for _resume_node.
   Add functions to support thin provisioning target (API unstable).
--- LVM2/libdm/libdm-deptree.c	2011/10/14 13:34:19	1.123
+++ LVM2/libdm/libdm-deptree.c	2011/10/17 13:15:35	1.124
@@ -1856,7 +1856,7 @@
 				   uint64_t *seg_start, char *params,
 				   size_t paramsize)
 {
-	uint32_t i, *tmp;
+	uint32_t i;
 	int param_count = 1; /* mandatory 'chunk size'/'stripe size' arg */
 	int pos = 0;
 
@@ -1866,9 +1866,9 @@
 	if (seg->region_size)
 		param_count += 2;
 
-	tmp = (uint32_t *)(&seg->rebuilds); /* rebuilds is 64-bit */
-	param_count += 2 * hweight32(tmp[0]);
-	param_count += 2 * hweight32(tmp[1]);
+	/* rebuilds is 64-bit */
+	param_count += 2 * hweight32(seg->rebuilds & 0xFFFFFFFF);
+	param_count += 2 * hweight32(seg->rebuilds >> 32);
 
 	if ((seg->type == SEG_RAID1) && seg->stripe_size)
 		log_error("WARNING: Ignoring RAID1 stripe size");



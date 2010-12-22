From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 22 Dec 2010 12:06:55 -0000
Subject: LVM2/tools lvscan.c
Message-ID: <20101222120655.18310.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-22 12:06:54

Modified files:
	tools          : lvscan.c 

Log message:
	Remove dead assignment of lv_total and lv_capasity_total
	
	Variables 'lv_total' and 'lv_capasity_total' are unused.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvscan.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44

--- LVM2/tools/lvscan.c	2010/11/30 11:53:33	1.43
+++ LVM2/tools/lvscan.c	2010/12/22 12:06:54	1.44
@@ -19,8 +19,6 @@
 			 void *handle __attribute__((unused)))
 {
 	struct lvinfo info;
-	int lv_total = 0;
-	uint64_t lv_capacity_total = 0;
 	int inkernel, snap_active = 1;
 	struct lv_segment *snap_seg = NULL;
 	percent_t snap_percent;     /* fused, fsize; */
@@ -66,10 +64,6 @@
 		  display_size(cmd, lv->size),
 		  get_alloc_string(lv->alloc));
 
-	lv_total++;
-
-	lv_capacity_total += lv->size;
-
 	return ECMD_PROCESSED;
 }
 



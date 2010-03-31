From: agk@sourceware.org <agk@sourceware.org>
Date: 31 Mar 2010 20:39:53 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20100331203953.31969.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-03-31 20:39:51

Modified files:
	tools          : lvconvert.c 

Log message:
	remove unused var

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.123&r2=1.124

--- LVM2/tools/lvconvert.c	2010/03/26 22:15:44	1.123
+++ LVM2/tools/lvconvert.c	2010/03/31 20:39:51	1.124
@@ -918,7 +918,6 @@
 				  int allocation_failures_ok)
 {
 	uint32_t region_size;
-	struct dm_list *tmp;
 	struct lv_segment *seg;
 	struct logical_volume *layer_lv;
 	uint32_t old_mimage_count = lv_mirror_count(lv);



From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 22:38:41 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20120125223841.7623.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 22:38:40

Modified files:
	tools          : lvconvert.c 

Log message:
	Cosmetic change use return macro with implicit stack

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.179&r2=1.180

--- LVM2/tools/lvconvert.c	2012/01/20 22:03:48	1.179
+++ LVM2/tools/lvconvert.c	2012/01/25 22:38:40	1.180
@@ -1084,10 +1084,9 @@
 		 */
 		if (!lv_add_mirrors(cmd, lv, new_mimage_count - 1, lp->stripes,
 				    lp->stripe_size, region_size, new_log_count, operable_pvs,
-				    lp->alloc, MIRROR_BY_LV)) {
-			stack;
-			return 0;
-		}
+				    lp->alloc, MIRROR_BY_LV))
+			return_0;
+
 		if (lp->wait_completion)
 			lp->need_polling = 1;
 



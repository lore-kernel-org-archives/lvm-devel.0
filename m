From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Nov 2011 15:46:52 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20111103154652.24233.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-03 15:46:51

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Thin no device is created - so nothing to revert here

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.318&r2=1.319

--- LVM2/lib/metadata/lv_manip.c	2011/11/03 14:56:20	1.318
+++ LVM2/lib/metadata/lv_manip.c	2011/11/03 15:46:51	1.319
@@ -4114,10 +4114,8 @@
 				  lp->pool, vg->name);
 			return 0;
 		}
-		if (!update_pool_lv(lvl->lv, 1)) {
-			stack;
-			goto revert_new_lv;
-		}
+		if (!update_pool_lv(lvl->lv, 1))
+			return_0;
 	}
 
 	if (segtype_is_mirrored(lp->segtype) || segtype_is_raid(lp->segtype)) {



From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 22 Feb 2012 15:20:51 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20120222152051.16857.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2012-02-22 15:20:51

Modified files:
	tools          : lvconvert.c 

Log message:
	Fix a bad return code in 'lvconvert_raid'
	
	Functions at this level do return 0 or 1, not ECMD_* values.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.182&r2=1.183

--- LVM2/tools/lvconvert.c	2012/02/13 18:38:36	1.182
+++ LVM2/tools/lvconvert.c	2012/02/22 15:20:50	1.183
@@ -1528,10 +1528,9 @@
 		_lvconvert_raid_repair_ask(cmd, &replace);
 
 		if (replace) {
-			if (!(failed_pvs = _failed_pv_list(lv->vg))) {
-				stack;
-				return ECMD_FAILED;
-			}
+			if (!(failed_pvs = _failed_pv_list(lv->vg)))
+				return_0;
+
 			return lv_raid_replace(lv, failed_pvs, lp->pvh);
 		}
 



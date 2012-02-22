From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 22 Feb 2012 16:03:56 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20120222160356.23322.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2012-02-22 16:03:55

Modified files:
	tools          : lvconvert.c 

Log message:
	Add some messages that indicate completion of RAID device replacement.
	
	There were no messages printed upon completiion of RAID device replacement.
	This could cause confusion/concern during automated recovery, because the
	user sees the failure messages but no other messages indicating correction.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.183&r2=1.184

--- LVM2/tools/lvconvert.c	2012/02/22 15:20:50	1.183
+++ LVM2/tools/lvconvert.c	2012/02/22 16:03:55	1.184
@@ -1531,7 +1531,15 @@
 			if (!(failed_pvs = _failed_pv_list(lv->vg)))
 				return_0;
 
-			return lv_raid_replace(lv, failed_pvs, lp->pvh);
+			if (!lv_raid_replace(lv, failed_pvs, lp->pvh)) {
+				log_error("Failed to replace faulty devices in"
+					  " %s/%s.", lv->vg->name, lv->name);
+				return 0;
+			}
+
+			log_print("Faulty devices in %s/%s successfully"
+				  " replaced.", lv->vg->name, lv->name);
+			return 1;
 		}
 
 		/* "warn" if policy not set to replace */



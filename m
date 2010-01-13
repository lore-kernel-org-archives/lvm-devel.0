From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 13 Jan 2010 01:52:58 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20100113015258.7526.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-13 01:52:58

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	When turning merging origin into non-merging origin, there is bad sequence:
	snapshots are suspended, new origin is created, snapshots are resumed, new
	origin is resumed.  So it allocates memory while suspended.
	
	To fix it, move vg_commit after suspend_lv, so that the suspend code will
	treat it as precommitted vg and will preload new origin prior to suspend.
	
	NOTE: agk doesn't like this "hack"; need to revisit and fix

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.199&r2=1.200

--- LVM2/lib/metadata/lv_manip.c	2010/01/13 01:51:45	1.199
+++ LVM2/lib/metadata/lv_manip.c	2010/01/13 01:52:58	1.200
@@ -2140,19 +2140,28 @@
 	}
 
 	/* store it on disks */
-	if (!vg_write(vg) || !vg_commit(vg))
+	if (!vg_write(vg))
 		return_0;
 
-	backup(vg);
-
 	/* If no snapshots left or if we stopped merging, reload */
 	if (origin && (!lv_is_origin(origin) || was_merging)) {
-		if (!suspend_lv(cmd, origin))
+		if (!suspend_lv(cmd, origin)) {
 			log_error("Failed to refresh %s without snapshot.", origin->name);
-		else if (!resume_lv(cmd, origin))
+			return 0;
+		}
+		if (!vg_commit(vg))
+			return_0;
+		if (!resume_lv(cmd, origin)) {
 			log_error("Failed to resume %s.", origin->name);
+			return 0;
+		}
+	} else {
+		if (!vg_commit(vg))
+			return_0;
 	}
 
+	backup(vg);
+
 	if (lv_is_visible(lv))
 		log_print("Logical volume \"%s\" successfully removed", lv->name);
 



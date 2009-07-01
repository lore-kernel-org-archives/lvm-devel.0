From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 1 Jul 2009 17:02:18 -0000
Subject: LVM2/tools vgrename.c
Message-ID: <20090701170218.11388.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-01 17:02:18

Modified files:
	tools          : vgrename.c 

Log message:
	Convert vgrename to vg_read_for_update.
	
	Sun May  3 12:54:28 CEST 2009  Petr Rockai <me@mornfall.net>
	* Convert vgrename to vg_read_for_update.
	
	Rebased 6/26/2009 - Dave W.
	
	Author: Petr Rockai <prockai@redhat.com>
	Committer: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.63&r2=1.64

--- LVM2/tools/vgrename.c	2009/06/09 14:30:16	1.63
+++ LVM2/tools/vgrename.c	2009/07/01 17:02:18	1.64
@@ -20,7 +20,6 @@
 {
 	char *dev_dir;
 	struct id id;
-	int consistent = 1;
 	int match = 0;
 	int found_id = 0;
 	struct dm_list *vgids;
@@ -71,25 +70,11 @@
 	} else
 		vgid = NULL;
 
-	if (!lock_vol(cmd, vg_name_old, LCK_VG_WRITE)) {
-		log_error("Can't get lock for %s", vg_name_old);
-		return 0;
-	}
-
-	if (!(vg = vg_read_internal(cmd, vg_name_old, vgid, &consistent)) || !consistent) {
-		log_error("Volume group %s %s%s%snot found.", vg_name_old,
-		vgid ? "(" : "", vgid ? vgid : "", vgid ? ") " : "");
-		unlock_vg(cmd, vg_name_old);
-		return 0;
-	}
-
-	if (!vg_check_status(vg, CLUSTERED | LVM_WRITE)) {
-		unlock_and_release_vg(cmd, vg, vg_name_old);
-		return 0;
-	}
-
-	/* Don't return failure for EXPORTED_VG */
-	vg_check_status(vg, EXPORTED_VG);
+	/* FIXME we used to print an error about EXPORTED, but proceeded
+	   nevertheless. */
+	vg = vg_read_for_update(cmd, vg_name_old, vgid, READ_ALLOW_EXPORTED);
+	if (vg_read_error(vg))
+		return_0;
 
 	if (lvs_in_vg_activated_by_uuid_only(vg)) {
 		unlock_and_release_vg(cmd, vg, vg_name_old);



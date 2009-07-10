From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 10 Jul 2009 20:10:19 -0000
Subject: LVM2/tools vgcfgrestore.c
Message-ID: <20090710201019.26066.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-10 20:10:18

Modified files:
	tools          : vgcfgrestore.c 

Log message:
	Change lock ordering of vgcfgrestore to be consistent with other tools.
	
	Orphan lock is now obtained second and released first, and all tools
	are consistent in this regard.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcfgrestore.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20

--- LVM2/tools/vgcfgrestore.c	2009/05/13 13:02:55	1.19
+++ LVM2/tools/vgcfgrestore.c	2009/07/10 20:10:18	1.20
@@ -43,17 +43,17 @@
 		return ECMD_PROCESSED;
 	}
 
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
-		log_error("Unable to lock orphans");
-		return ECMD_FAILED;
-	}
-
 	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
 		log_error("Unable to lock volume group %s", vg_name);
 		unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;
 	}
 
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
+		log_error("Unable to lock orphans");
+		return ECMD_FAILED;
+	}
+
 	if (!(arg_count(cmd, file_ARG) ?
 	      backup_restore_from_file(cmd, vg_name,
 				       arg_str_value(cmd, file_ARG, "")) :
@@ -66,7 +66,7 @@
 
 	log_print("Restored volume group %s", vg_name);
 
-	unlock_vg(cmd, vg_name);
 	unlock_vg(cmd, VG_ORPHANS);
+	unlock_vg(cmd, vg_name);
 	return ECMD_PROCESSED;
 }



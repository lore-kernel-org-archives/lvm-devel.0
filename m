From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 13 Aug 2009 17:16:41 -0000
Subject: LVM2 ./WHATS_NEW tools/vgcfgrestore.c
Message-ID: <20090813171641.14711.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-08-13 17:16:39

Modified files:
	.              : WHATS_NEW 
	tools          : vgcfgrestore.c 

Log message:
	Fix error paths for vgcfgrestore when locking fails.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1240&r2=1.1241
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcfgrestore.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22

--- LVM2/WHATS_NEW	2009/08/13 16:36:49	1.1240
+++ LVM2/WHATS_NEW	2009/08/13 17:16:38	1.1241
@@ -1,5 +1,6 @@
 Version 2.02.52 -
 =================================
+  Fix vgcfgrestore error paths when locking fails (2.02.49).
   Added configure --enable-clogd to conditionally build the cluster log daemon.
   Make lvchange --refresh only take a read lock on volume group.
   Fix bug where non-blocking file locks could be granted in error.
--- LVM2/tools/vgcfgrestore.c	2009/07/15 20:02:48	1.21
+++ LVM2/tools/vgcfgrestore.c	2009/08/13 17:16:39	1.22
@@ -45,12 +45,12 @@
 
 	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
 		log_error("Unable to lock volume group %s", vg_name);
-		unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;
 	}
 
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
 		log_error("Unable to lock orphans");
+		unlock_vg(cmd, vg_name);
 		return ECMD_FAILED;
 	}
 
@@ -58,8 +58,8 @@
 	      backup_restore_from_file(cmd, vg_name,
 				       arg_str_value(cmd, file_ARG, "")) :
 	      backup_restore(cmd, vg_name))) {
-		unlock_vg(cmd, vg_name);
 		unlock_vg(cmd, VG_ORPHANS);
+		unlock_vg(cmd, vg_name);
 		log_error("Restore failed.");
 		return ECMD_FAILED;
 	}



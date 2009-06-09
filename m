From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 9 Jun 2009 14:30:17 -0000
Subject: LVM2/tools vgrename.c
Message-ID: <20090609143017.6822.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-06-09 14:30:16

Modified files:
	tools          : vgrename.c 

Log message:
	Update vgrename to use vg_lock_newname.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.62&r2=1.63

--- LVM2/tools/vgrename.c	2009/05/21 03:04:54	1.62
+++ LVM2/tools/vgrename.c	2009/06/09 14:30:16	1.63
@@ -28,7 +28,8 @@
 	char *vg_name_new;
 	const char *vgid = NULL, *vg_name, *vg_name_old;
 	char old_path[NAME_LEN], new_path[NAME_LEN];
-	struct volume_group *vg = NULL, *vg_new = NULL;
+	struct volume_group *vg = NULL;
+	uint32_t rc;
 
 	vg_name_old = skip_dev_dir(cmd, old_vg_path, NULL);
 	vg_name_new = skip_dev_dir(cmd, new_vg_path, NULL);
@@ -100,17 +101,19 @@
 
 	log_verbose("Checking for new volume group \"%s\"", vg_name_new);
 
-	if (!lock_vol(cmd, vg_name_new, LCK_VG_WRITE)) {
+	rc = vg_lock_newname(cmd, vg_name_new);
+
+	if (rc == FAILED_LOCKING) {
 		unlock_and_release_vg(cmd, vg, vg_name_old);
 		log_error("Can't get lock for %s", vg_name_new);
 		return 0;
 	}
 
-	consistent = 0;
-	if ((vg_new = vg_read_internal(cmd, vg_name_new, NULL, &consistent))) {
+	if (rc == FAILED_EXIST) {
 		log_error("New volume group \"%s\" already exists",
 			  vg_name_new);
-		goto error;
+		unlock_and_release_vg(cmd, vg, vg_name_old);
+		return 0;
 	}
 
 	if (!archive(vg))
@@ -151,7 +154,7 @@
 	backup(vg);
 	backup_remove(cmd, vg_name_old);
 
-	unlock_and_release_vg(cmd, vg_new, vg_name_new);
+	unlock_vg(cmd, vg_name_new);
 	unlock_and_release_vg(cmd, vg, vg_name_old);
 
 	log_print("Volume group \"%s\" successfully renamed to \"%s\"",
@@ -164,7 +167,7 @@
 	return 1;
 
       error:
-	unlock_and_release_vg(cmd, vg_new, vg_name_new);
+	unlock_vg(cmd, vg_name_new);
 	unlock_and_release_vg(cmd, vg, vg_name_old);
 	return 0;
 }



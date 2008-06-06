From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Jun 2008 16:13:40 -0000
Subject: LVM2/tools vgrename.c
Message-ID: <20080606161340.25161.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-06-06 16:13:40

Modified files:
	tools          : vgrename.c 

Log message:
	cache dropping needs to use old name not new
	rename variable to reduce confusion

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54

--- LVM2/tools/vgrename.c	2008/06/06 13:04:43	1.53
+++ LVM2/tools/vgrename.c	2008/06/06 16:13:35	1.54
@@ -28,7 +28,7 @@
 	char *vg_name_new;
 	const char *vgid = NULL, *vg_name, *vg_name_old;
 	char old_path[NAME_LEN], new_path[NAME_LEN];
-	struct volume_group *vg_old, *vg_new;
+	struct volume_group *vg, *vg_new;
 
 	vg_name_old = skip_dev_dir(cmd, old_vg_path, NULL);
 	vg_name_new = skip_dev_dir(cmd, new_vg_path, NULL);
@@ -75,22 +75,22 @@
 		return 0;
 	}
 
-	if (!(vg_old = vg_read(cmd, vg_name_old, vgid, &consistent)) || !consistent) {
+	if (!(vg = vg_read(cmd, vg_name_old, vgid, &consistent)) || !consistent) {
 		log_error("Volume group %s %s%s%snot found.", vg_name_old,
 		vgid ? "(" : "", vgid ? vgid : "", vgid ? ") " : "");
 		unlock_vg(cmd, vg_name_old);
 		return 0;
 	}
 
-	if (!vg_check_status(vg_old, CLUSTERED | LVM_WRITE)) {
+	if (!vg_check_status(vg, CLUSTERED | LVM_WRITE)) {
 		unlock_vg(cmd, vg_name_old);
 		return 0;
 	}
 
 	/* Don't return failure for EXPORTED_VG */
-	vg_check_status(vg_old, EXPORTED_VG);
+	vg_check_status(vg, EXPORTED_VG);
 
-	if (lvs_in_vg_activated_by_uuid_only(vg_old)) {
+	if (lvs_in_vg_activated_by_uuid_only(vg)) {
 		unlock_vg(cmd, vg_name_old);
 		log_error("Volume group \"%s\" still has active LVs",
 			  vg_name_old);
@@ -113,11 +113,14 @@
 		goto error;
 	}
 
-	if (!archive(vg_old))
+	if (!archive(vg))
 		goto error;
 
+	/* Remove references based on old name */
+	drop_cached_metadata(vg);
+
 	/* Change the volume group name */
-	vg_rename(cmd, vg_old, vg_name_new);
+	vg_rename(cmd, vg, vg_name_new);
 
 	sprintf(old_path, "%s%s", dev_dir, vg_name_old);
 	sprintf(new_path, "%s%s", dev_dir, vg_name_new);
@@ -133,17 +136,15 @@
 		}
 	}
 
-	drop_cached_metadata(vg_old);
-
 	/* store it on disks */
 	log_verbose("Writing out updated volume group");
-	if (!vg_write(vg_old) || !vg_commit(vg_old)) {
+	if (!vg_write(vg) || !vg_commit(vg)) {
 		goto error;
 	}
 
 /******* FIXME Rename any active LVs! *****/
 
-	backup(vg_old);
+	backup(vg);
 
 	unlock_vg(cmd, vg_name_new);
 	unlock_vg(cmd, vg_name_old);



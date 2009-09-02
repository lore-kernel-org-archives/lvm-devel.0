From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 2 Sep 2009 21:29:40 -0000
Subject: LVM2/tools vgrename.c
Message-ID: <20090902212940.13777.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-09-02 21:29:40

Modified files:
	tools          : vgrename.c 

Log message:
	Update vgrename to take into account vgname lock ordering.
	
	Should be no functional change.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.66&r2=1.67

--- LVM2/tools/vgrename.c	2009/09/02 21:29:23	1.66
+++ LVM2/tools/vgrename.c	2009/09/02 21:29:40	1.67
@@ -74,7 +74,7 @@
 	const char *vgid = NULL, *vg_name, *vg_name_old;
 	char old_path[NAME_LEN], new_path[NAME_LEN];
 	struct volume_group *vg = NULL;
-	uint32_t rc;
+	int lock_vg_old_first = 1;
 
 	vg_name_old = skip_dev_dir(cmd, old_vg_path, NULL);
 	vg_name_new = skip_dev_dir(cmd, new_vg_path, NULL);
@@ -116,13 +116,26 @@
 	} else
 		vgid = NULL;
 
-	vg = vg_rename_old(cmd, vg_name_old, vgid);
-	if (!vg)
-		return 0;
+	if (strcmp(vg_name_new, vg_name_old) < 0)
+		lock_vg_old_first = 0;
 
-	if (!vg_rename_new(cmd, vg_name_new)) {
-		unlock_and_release_vg(cmd, vg, vg_name_old);
-		return 0;
+	if (lock_vg_old_first) {
+		vg = vg_rename_old(cmd, vg_name_old, vgid);
+		if (!vg)
+			return 0;
+
+		if (!vg_rename_new(cmd, vg_name_new)) {
+			unlock_and_release_vg(cmd, vg, vg_name_old);
+			return 0;
+		}
+	} else {
+		if (!vg_rename_new(cmd, vg_name_new)) {
+			return 0;
+		}
+
+		vg = vg_rename_old(cmd, vg_name_old, vgid);
+		if (!vg)
+			return 0;
 	}
 
 	if (!archive(vg))
@@ -176,8 +189,13 @@
 	return 1;
 
       error:
-	unlock_vg(cmd, vg_name_new);
-	unlock_and_release_vg(cmd, vg, vg_name_old);
+	if (lock_vg_old_first) {
+		unlock_vg(cmd, vg_name_new);
+		unlock_and_release_vg(cmd, vg, vg_name_old);
+	} else {
+		unlock_and_release_vg(cmd, vg, vg_name_old);
+		unlock_vg(cmd, vg_name_new);
+	}
 	return 0;
 }
 



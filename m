From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 23 Jul 2007 22:20:43 -0000
Subject: LVM2/tools lvconvert.c lvrename.c
Message-ID: <20070723222043.16274.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-07-23 22:20:42

Modified files:
	tools          : lvconvert.c lvrename.c 

Log message:
	Update lvconvert and lvrename to use vg_lock_and_read

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvrename.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44

--- LVM2/tools/lvconvert.c	2007/06/28 17:33:44	1.28
+++ LVM2/tools/lvconvert.c	2007/07/23 22:20:41	1.29
@@ -534,7 +534,6 @@
 
 int lvconvert(struct cmd_context * cmd, int argc, char **argv)
 {
-	int consistent = 1;
 	struct volume_group *vg;
 	struct lv_list *lvl;
 	struct lvconvert_params lp;
@@ -547,18 +546,10 @@
 
 	log_verbose("Checking for existing volume group \"%s\"", lp.vg_name);
 
-	if (!lock_vol(cmd, lp.vg_name, LCK_VG_WRITE)) {
-		log_error("Can't get lock for %s", lp.vg_name);
+	if (!(vg = vg_lock_and_read(cmd, lp.vg_name, LCK_VG_WRITE,
+				    CLUSTERED | EXPORTED_VG | LVM_WRITE,
+				    CORRECT_INCONSISTENT)))
 		return ECMD_FAILED;
-	}
-
-	if (!(vg = vg_read(cmd, lp.vg_name, NULL, &consistent))) {
-		log_error("Volume group \"%s\" doesn't exist", lp.vg_name);
-		goto error;
-	}
-
-	if (!vg_check_status(vg, CLUSTERED | EXPORTED_VG | LVM_WRITE))
-		goto error;
 
 	if (!(lvl = find_lv_in_vg(vg, lp.lv_name))) {
 		log_error("Logical volume \"%s\" not found in "
--- LVM2/tools/lvrename.c	2007/06/06 19:40:28	1.43
+++ LVM2/tools/lvrename.c	2007/07/23 22:20:42	1.44
@@ -22,7 +22,6 @@
 	char *lv_name_old, *lv_name_new;
 	const char *vg_name, *vg_name_new, *vg_name_old;
 	char *st;
-	int consistent = 1;
 
 	struct volume_group *vg;
 	struct logical_volume *lv;
@@ -99,18 +98,10 @@
 
 	log_verbose("Checking for existing volume group \"%s\"", vg_name);
 
-	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
-		log_error("Can't get lock for %s", vg_name);
+	if (!(vg = vg_lock_and_read(cmd, vg_name, LCK_VG_WRITE,
+				    CLUSTERED | EXPORTED_VG | LVM_WRITE,
+				    CORRECT_INCONSISTENT)))
 		return ECMD_FAILED;
-	}
-
-	if (!(vg = vg_read(cmd, vg_name, NULL, &consistent))) {
-		log_error("Volume group \"%s\" doesn't exist", vg_name);
-		goto error;
-	}
-
-	if (!vg_check_status(vg, CLUSTERED | EXPORTED_VG | LVM_WRITE))
-		goto error;
 
 	if (find_lv_in_vg(vg, lv_name_new)) {
 		log_error("Logical volume \"%s\" already exists in "



From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jun 2009 09:47:38 -0000
Subject: LVM2 ./WHATS_NEW tools/lvconvert.c tools/lvcre ...
Message-ID: <20090626094738.24996.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-06-26 09:47:37

Modified files:
	.              : WHATS_NEW 
	tools          : lvconvert.c lvcreate.c lvrename.c lvresize.c 
	                 polldaemon.c pvchange.c pvdisplay.c pvmove.c 
	                 pvresize.c reporter.c vgextend.c vgmerge.c 

Log message:
	Convert the straight instances of vg_lock_and_read to new vg_read(_for_update).
	
	Sun May  3 11:40:51 CEST 2009  Petr Rockai <me@mornfall.net>
	* Convert the straight instances of vg_lock_and_read to new vg_read(_for_update).
	
	Author: Petr Rockai <prockai@redhat.com>
	Committer: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1155&r2=1.1156
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.83&r2=1.84
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.194&r2=1.195
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvrename.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.110&r2=1.111
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.67&r2=1.68
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvdisplay.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56

--- LVM2/WHATS_NEW	2009/06/26 09:19:13	1.1155
+++ LVM2/WHATS_NEW	2009/06/26 09:47:36	1.1156
@@ -1,5 +1,6 @@
 Version 2.02.48 - 
 ===============================
+  Replace use of vg_lock_and_read with vg_read/vg_read_for_update.
   Abort if automatic metadata correction fails when reading VG to update it.
   Explicitly request fallback to default major number in device mapper.
   Ignore suspended devices during repair.
--- LVM2/tools/lvconvert.c	2009/06/26 09:04:00	1.83
+++ LVM2/tools/lvconvert.c	2009/06/26 09:47:36	1.84
@@ -239,13 +239,8 @@
 {
 	dev_close_all();
 
-	/*
-	 * uuid is here LV uuid, but vg_read will use only first part.
-	 */
-        return vg_lock_and_read(cmd, extract_vgname(cmd, lv_name),
-				uuid, LCK_VG_WRITE,
- 				CLUSTERED | EXPORTED_VG | LVM_WRITE,
-				CORRECT_INCONSISTENT | FAIL_INCONSISTENT);
+        return vg_read_for_update(cmd, extract_vgname(cmd, lv_name),
+				  NULL, 0);
 }
 
 static struct logical_volume *_get_lvconvert_lv(struct cmd_context *cmd __attribute((unused)),
@@ -938,10 +933,9 @@
 
 	log_verbose("Checking for existing volume group \"%s\"", lp.vg_name);
 
-	if (!(vg = vg_lock_and_read(cmd, lp.vg_name, NULL, LCK_VG_WRITE,
-				    CLUSTERED | EXPORTED_VG | LVM_WRITE,
-				    CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
-		goto out;
+	vg = vg_read_for_update(cmd, lp.vg_name, NULL, 0);
+	if (vg_read_error(vg))
+		return ECMD_FAILED;
 
 	if (!(lvl = find_lv_in_vg(vg, lp.lv_name))) {
 		log_error("Logical volume \"%s\" not found in "
--- LVM2/tools/lvcreate.c	2009/06/26 09:19:13	1.194
+++ LVM2/tools/lvcreate.c	2009/06/26 09:47:36	1.195
@@ -994,9 +994,8 @@
 		return EINVALID_CMD_LINE;
 
 	log_verbose("Finding volume group \"%s\"", lp.vg_name);
-	if (!(vg = vg_lock_and_read(cmd, lp.vg_name, NULL, LCK_VG_WRITE,
-				    CLUSTERED | EXPORTED_VG | LVM_WRITE,
-				    CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
+	vg = vg_read_for_update(cmd, lp.vg_name, NULL, 0);
+	if (vg_read_error(vg))
 		return ECMD_FAILED;
 
 	if (!_lvcreate(cmd, vg, &lp))
--- LVM2/tools/lvrename.c	2009/06/26 09:19:13	1.51
+++ LVM2/tools/lvrename.c	2009/06/26 09:47:37	1.52
@@ -102,9 +102,8 @@
 	}
 
 	log_verbose("Checking for existing volume group \"%s\"", vg_name);
-	if (!(vg = vg_lock_and_read(cmd, vg_name, NULL, LCK_VG_WRITE,
-				    CLUSTERED | EXPORTED_VG | LVM_WRITE,
-				    CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
+	vg = vg_read_for_update(cmd, vg_name, NULL, 0);
+	if (vg_read_error(vg))
 		return ECMD_FAILED;
 
 	if (!(lvl = find_lv_in_vg(vg, lv_name_old))) {
--- LVM2/tools/lvresize.c	2009/06/26 09:19:13	1.110
+++ LVM2/tools/lvresize.c	2009/06/26 09:47:37	1.111
@@ -671,9 +671,8 @@
 		return EINVALID_CMD_LINE;
 
 	log_verbose("Finding volume group %s", lp.vg_name);
-	if (!(vg = vg_lock_and_read(cmd, lp.vg_name, NULL, LCK_VG_WRITE,
-				    CLUSTERED | EXPORTED_VG | LVM_WRITE,
-				    CORRECT_INCONSISTENT | FAIL_INCONSISTENT))) {
+	vg = vg_read_for_update(cmd, lp.vg_name, NULL, 0);
+	if (vg_read_error(vg)) {
 		stack;
 		return ECMD_FAILED;
 	}
--- LVM2/tools/polldaemon.c	2009/06/05 20:00:52	1.15
+++ LVM2/tools/polldaemon.c	2009/06/26 09:47:37	1.16
@@ -147,7 +147,8 @@
 		}
 
 		/* Locks the (possibly renamed) VG again */
-		if (!(vg = parms->poll_fns->get_copy_vg(cmd, name, uuid))) {
+		vg = parms->poll_fns->get_copy_vg(cmd, name);
+		if (vg_read_error(vg)) {
 			log_error("ABORTING: Can't reread VG for %s", name);
 			/* What more could we do here? */
 			return 0;
--- LVM2/tools/pvchange.c	2009/06/26 09:19:13	1.67
+++ LVM2/tools/pvchange.c	2009/06/26 09:47:37	1.68
@@ -57,9 +57,8 @@
 
 		log_verbose("Finding volume group %s of physical volume %s",
 			    vg_name, pv_name);
-		if (!(vg = vg_lock_and_read(cmd, vg_name, NULL, LCK_VG_WRITE,
-					    CLUSTERED | EXPORTED_VG | LVM_WRITE,
-					    CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
+		vg = vg_read_for_update(cmd, vg_name, NULL, 0);
+		if (vg_read_error(vg))
 			return_0;
 
 		if (!(pvl = find_pv_in_vg(vg, pv_name))) {
--- LVM2/tools/pvdisplay.c	2009/04/10 10:01:38	1.49
+++ LVM2/tools/pvdisplay.c	2009/06/26 09:47:37	1.50
@@ -29,8 +29,8 @@
 
 	if (!is_orphan(pv) && !vg) {
 		vg_name = pv_vg_name(pv);
-		if (!(vg = vg_lock_and_read(cmd, vg_name, (char *)&pv->vgid,
-					    LCK_VG_READ, CLUSTERED, 0))) {
+		vg = vg_read(cmd, vg_name, (char *)&pv->vgid, 0);
+		if (vg_read_error(vg)) {
 		 	log_error("Skipping volume group %s", vg_name);
 			/* FIXME If CLUSTERED should return ECMD_PROCESSED here */
 		 	return ECMD_FAILED;
--- LVM2/tools/pvmove.c	2009/06/01 14:43:28	1.61
+++ LVM2/tools/pvmove.c	2009/06/26 09:47:37	1.62
@@ -89,16 +89,9 @@
 
 static struct volume_group *_get_vg(struct cmd_context *cmd, const char *vgname)
 {
-	struct volume_group *vg;
-
 	dev_close_all();
 
-	if (!(vg = vg_lock_and_read(cmd, vgname, NULL, LCK_VG_WRITE,
-				    CLUSTERED | EXPORTED_VG | LVM_WRITE,
-				    CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
-		 return NULL;
-
-	return vg;
+	return vg_read_for_update(cmd, vgname, NULL, 0);
 }
 
 /* Create list of PVs for allocation of replacement extents */
@@ -392,7 +385,8 @@
 	/* Read VG */
 	log_verbose("Finding volume group \"%s\"", pv_vg_name(pv));
 
-	if (!(vg = _get_vg(cmd, pv_vg_name(pv)))) {
+	vg = _get_vg(cmd, pv_vg_name(pv));
+	if (vg_read_error(vg)) {
 		stack;
 		return ECMD_FAILED;
 	}
--- LVM2/tools/pvresize.c	2009/04/10 10:01:38	1.27
+++ LVM2/tools/pvresize.c	2009/06/26 09:47:37	1.28
@@ -29,7 +29,6 @@
 			     const uint64_t new_size)
 {
 	struct pv_list *pvl;
-	int consistent = 1;
 	uint64_t size = 0;
 	uint32_t new_pe_count = 0;
 	int r = 0;
@@ -59,19 +58,9 @@
 	} else {
 		vg_name = pv_vg_name(pv);
 
-		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
-			log_error("Can't get lock for %s", pv_vg_name(pv));
-			return 0;
-		}
-
-		if (!(vg = vg_read_internal(cmd, vg_name, NULL, &consistent))) {
-			unlock_vg(cmd, vg_name);
-			log_error("Unable to find volume group of \"%s\"",
-				  pv_name);
-			return 0;
-		}
+ 		vg = vg_read_for_update(cmd, vg_name, NULL, 0);
 
-		if (!vg_check_status(vg, CLUSTERED | EXPORTED_VG | LVM_WRITE))
+		if (vg_read_error(vg))
 			goto bad;
 
 		if (!(pvl = find_pv_in_vg(vg, pv_name))) {
--- LVM2/tools/reporter.c	2009/06/05 20:00:52	1.49
+++ LVM2/tools/reporter.c	2009/06/26 09:47:37	1.50
@@ -132,8 +132,8 @@
 	if (is_pv(pv) && !is_orphan(pv) && !vg) {
 		vg_name = pv_vg_name(pv);
 
-		if (!(vg = vg_lock_and_read(cmd, vg_name, (char *)&pv->vgid,
-					    LCK_VG_READ, CLUSTERED, 0))) {
+		vg = vg_read(cmd, vg_name, (char *)&pv->vgid, 0);
+		if (vg_read_error(vg)) {
 			log_error("Skipping volume group %s", vg_name);
 			return ECMD_FAILED;
 		}
--- LVM2/tools/vgextend.c	2009/05/21 03:04:53	1.40
+++ LVM2/tools/vgextend.c	2009/06/26 09:47:37	1.41
@@ -42,13 +42,12 @@
 	}
 
 	log_verbose("Checking for volume group \"%s\"", vg_name);
-	if (!(vg = vg_lock_and_read(cmd, vg_name, NULL, LCK_VG_WRITE,
-				    CLUSTERED | EXPORTED_VG |
-				    LVM_WRITE | RESIZEABLE_VG,
-				    CORRECT_INCONSISTENT | FAIL_INCONSISTENT))) {
-		unlock_vg(cmd, VG_ORPHANS);
+ 	vg = vg_read_for_update(cmd, vg_name, NULL,
+ 				READ_REQUIRE_RESIZEABLE | LOCK_NONBLOCKING);
+ 	if (vg_read_error(vg)) {
+ 		unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;
-	 }
+	}
 /********** FIXME
 	log_print("maximum logical volume size is %s",
 		  (dummy = lvm_show_size(LVM_LV_SIZE_MAX(vg) / 2, LONG)));
--- LVM2/tools/vgmerge.c	2009/05/21 03:04:54	1.55
+++ LVM2/tools/vgmerge.c	2009/06/26 09:47:37	1.56
@@ -28,17 +28,15 @@
 	}
 
 	log_verbose("Checking for volume group \"%s\"", vg_name_to);
-	if (!(vg_to = vg_lock_and_read(cmd, vg_name_to, NULL, LCK_VG_WRITE,
-				       CLUSTERED | EXPORTED_VG | LVM_WRITE,
-				       CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
+ 	vg_to = vg_read_for_update(cmd, vg_name_to, NULL, 0);
+ 	if (vg_read_error(vg_to))
 		 return ECMD_FAILED;
 
 	log_verbose("Checking for volume group \"%s\"", vg_name_from);
-	if (!(vg_from = vg_lock_and_read(cmd, vg_name_from, NULL,
-					 LCK_VG_WRITE,
-					 CLUSTERED | EXPORTED_VG | LVM_WRITE,
-					 CORRECT_INCONSISTENT | FAIL_INCONSISTENT))) {
-		unlock_and_release_vg(cmd, vg_to, vg_name_to);
+ 	vg_from = vg_read_for_update(cmd, vg_name_from, NULL,
+ 				     LOCK_NONBLOCKING);
+ 	if (vg_read_error(vg_from)) {
+		unlock_release_vg(cmd, vg_to, vg_name_to);
 		return ECMD_FAILED;
 	}
 



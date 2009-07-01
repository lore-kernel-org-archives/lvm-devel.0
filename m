From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 1 Jul 2009 16:59:39 -0000
Subject: LVM2/tools lvconvert.c lvcreate.c lvrename.c l ...
Message-ID: <20090701165939.31339.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-01 16:59:37

Modified files:
	tools          : lvconvert.c lvcreate.c lvrename.c lvresize.c 
	                 polldaemon.c pvchange.c pvdisplay.c pvmove.c 
	                 pvresize.c reporter.c vgextend.c vgmerge.c 

Log message:
	Convert the straight instances of vg_lock_and_read to new vg_read(_for_update).
	
	Sun May  3 11:40:51 CEST 2009  Petr Rockai <me@mornfall.net>
	* Convert the straight instances of vg_lock_and_read to new vg_read(_for_update).
	
	Rebased 6/26/09 by Dave W.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.87&r2=1.88
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.196&r2=1.197
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvrename.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.112&r2=1.113
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.69&r2=1.70
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvdisplay.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58

--- LVM2/tools/lvconvert.c	2009/06/30 18:39:32	1.87
+++ LVM2/tools/lvconvert.c	2009/07/01 16:59:37	1.88
@@ -240,13 +240,8 @@
 {
 	dev_close_all();
 
-	/*
-	 * uuid is here LV uuid, but vg_read will use only first part.
-	 */
-        return vg_lock_and_read(cmd, extract_vgname(cmd, lv_name),
-                               uuid, LCK_VG_WRITE,
-                               CLUSTERED | EXPORTED_VG | LVM_WRITE,
-                               CORRECT_INCONSISTENT | FAIL_INCONSISTENT);
+        return vg_read_for_update(cmd, extract_vgname(cmd, lv_name),
+				  NULL, 0);
 }
 
 static struct logical_volume *_get_lvconvert_lv(struct cmd_context *cmd __attribute((unused)),
@@ -939,9 +934,8 @@
 
 	log_verbose("Checking for existing volume group \"%s\"", lp.vg_name);
 
-	if (!(vg = vg_lock_and_read(cmd, lp.vg_name, NULL, LCK_VG_WRITE,
-				    CLUSTERED | EXPORTED_VG | LVM_WRITE,
-				    CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
+	vg = vg_read_for_update(cmd, lp.vg_name, NULL, 0);
+	if (vg_read_error(vg))
 		goto out;
 
 	if (!(lvl = find_lv_in_vg(vg, lp.lv_name))) {
--- LVM2/tools/lvcreate.c	2009/06/26 10:55:58	1.196
+++ LVM2/tools/lvcreate.c	2009/07/01 16:59:37	1.197
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
--- LVM2/tools/lvrename.c	2009/06/26 10:55:58	1.53
+++ LVM2/tools/lvrename.c	2009/07/01 16:59:37	1.54
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
--- LVM2/tools/lvresize.c	2009/06/26 10:55:58	1.112
+++ LVM2/tools/lvresize.c	2009/07/01 16:59:37	1.113
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
--- LVM2/tools/polldaemon.c	2009/06/26 10:55:58	1.17
+++ LVM2/tools/polldaemon.c	2009/07/01 16:59:37	1.18
@@ -147,7 +147,8 @@
 		}
 
 		/* Locks the (possibly renamed) VG again */
-		if (!(vg = parms->poll_fns->get_copy_vg(cmd, name, uuid))) {
+		vg = parms->poll_fns->get_copy_vg(cmd, name, uuid);
+		if (vg_read_error(vg)) {
 			log_error("ABORTING: Can't reread VG for %s", name);
 			/* What more could we do here? */
 			return 0;
--- LVM2/tools/pvchange.c	2009/06/26 10:55:58	1.69
+++ LVM2/tools/pvchange.c	2009/07/01 16:59:37	1.70
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
--- LVM2/tools/pvdisplay.c	2009/06/26 10:55:58	1.51
+++ LVM2/tools/pvdisplay.c	2009/07/01 16:59:37	1.52
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
--- LVM2/tools/pvmove.c	2009/06/26 10:55:58	1.63
+++ LVM2/tools/pvmove.c	2009/07/01 16:59:37	1.64
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
--- LVM2/tools/pvresize.c	2009/06/26 10:55:58	1.29
+++ LVM2/tools/pvresize.c	2009/07/01 16:59:37	1.30
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
+		vg = vg_read_for_update(cmd, vg_name, NULL, 0);
 
-		if (!vg_check_status(vg, CLUSTERED | EXPORTED_VG | LVM_WRITE))
+		if (vg_read_error(vg))
 			goto bad;
 
 		if (!(pvl = find_pv_in_vg(vg, pv_name))) {
--- LVM2/tools/reporter.c	2009/06/26 10:55:58	1.51
+++ LVM2/tools/reporter.c	2009/07/01 16:59:37	1.52
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
--- LVM2/tools/vgextend.c	2009/06/26 10:55:58	1.42
+++ LVM2/tools/vgextend.c	2009/07/01 16:59:37	1.43
@@ -42,13 +42,12 @@
 	}
 
 	log_verbose("Checking for volume group \"%s\"", vg_name);
-	if (!(vg = vg_lock_and_read(cmd, vg_name, NULL, LCK_VG_WRITE,
-				    CLUSTERED | EXPORTED_VG |
-				    LVM_WRITE | RESIZEABLE_VG,
-				    CORRECT_INCONSISTENT | FAIL_INCONSISTENT))) {
+	vg = vg_read_for_update(cmd, vg_name, NULL,
+				READ_REQUIRE_RESIZEABLE | LOCK_NONBLOCKING);
+	if (vg_read_error(vg)) {
 		unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;
-	 }
+	}
 /********** FIXME
 	log_print("maximum logical volume size is %s",
 		  (dummy = lvm_show_size(LVM_LV_SIZE_MAX(vg) / 2, LONG)));
--- LVM2/tools/vgmerge.c	2009/06/26 10:55:58	1.57
+++ LVM2/tools/vgmerge.c	2009/07/01 16:59:37	1.58
@@ -28,16 +28,14 @@
 	}
 
 	log_verbose("Checking for volume group \"%s\"", vg_name_to);
-	if (!(vg_to = vg_lock_and_read(cmd, vg_name_to, NULL, LCK_VG_WRITE,
-				       CLUSTERED | EXPORTED_VG | LVM_WRITE,
-				       CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
+	vg_to = vg_read_for_update(cmd, vg_name_to, NULL, 0);
+	if (vg_read_error(vg_to))
 		 return ECMD_FAILED;
 
 	log_verbose("Checking for volume group \"%s\"", vg_name_from);
-	if (!(vg_from = vg_lock_and_read(cmd, vg_name_from, NULL,
-					 LCK_VG_WRITE,
-					 CLUSTERED | EXPORTED_VG | LVM_WRITE,
-					 CORRECT_INCONSISTENT | FAIL_INCONSISTENT))) {
+	vg_from = vg_read_for_update(cmd, vg_name_from, NULL,
+				     LOCK_NONBLOCKING);
+	if (vg_read_error(vg_from)) {
 		unlock_and_release_vg(cmd, vg_to, vg_name_to);
 		return ECMD_FAILED;
 	}



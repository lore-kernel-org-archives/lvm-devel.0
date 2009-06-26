From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Jun 2009 10:55:59 -0000
Subject: LVM2 ./WHATS_NEW tools/lvconvert.c tools/lvcre ...
Message-ID: <20090626105559.32206.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-06-26 10:55:58

Modified files:
	.              : WHATS_NEW 
	tools          : lvconvert.c lvcreate.c lvrename.c lvresize.c 
	                 polldaemon.c pvchange.c pvdisplay.c pvmove.c 
	                 pvresize.c reporter.c vgextend.c vgmerge.c 

Log message:
	revert last patch - let's do a release first

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1156&r2=1.1157
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.84&r2=1.85
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.195&r2=1.196
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvrename.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.111&r2=1.112
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.68&r2=1.69
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvdisplay.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.62&r2=1.63
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57

--- LVM2/WHATS_NEW	2009/06/26 09:47:36	1.1156
+++ LVM2/WHATS_NEW	2009/06/26 10:55:57	1.1157
@@ -1,6 +1,5 @@
 Version 2.02.48 - 
 ===============================
-  Replace use of vg_lock_and_read with vg_read/vg_read_for_update.
   Abort if automatic metadata correction fails when reading VG to update it.
   Explicitly request fallback to default major number in device mapper.
   Ignore suspended devices during repair.
--- LVM2/tools/lvconvert.c	2009/06/26 09:47:36	1.84
+++ LVM2/tools/lvconvert.c	2009/06/26 10:55:58	1.85
@@ -239,7 +239,10 @@
 {
 	dev_close_all();
 
-        return vg_read_for_update(cmd, extract_vgname(cmd, lv_name),
+	/*
+	 * uuid is here LV uuid, but vg_read will use only first part.
+	 */
+	return vg_read_for_update(cmd, extract_vgname(cmd, lv_name),
 				  NULL, 0);
 }
 
@@ -933,9 +936,10 @@
 
 	log_verbose("Checking for existing volume group \"%s\"", lp.vg_name);
 
-	vg = vg_read_for_update(cmd, lp.vg_name, NULL, 0);
-	if (vg_read_error(vg))
-		return ECMD_FAILED;
+	if (!(vg = vg_lock_and_read(cmd, lp.vg_name, NULL, LCK_VG_WRITE,
+				    CLUSTERED | EXPORTED_VG | LVM_WRITE,
+				    CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
+		goto out;
 
 	if (!(lvl = find_lv_in_vg(vg, lp.lv_name))) {
 		log_error("Logical volume \"%s\" not found in "
--- LVM2/tools/lvcreate.c	2009/06/26 09:47:36	1.195
+++ LVM2/tools/lvcreate.c	2009/06/26 10:55:58	1.196
@@ -994,8 +994,9 @@
 		return EINVALID_CMD_LINE;
 
 	log_verbose("Finding volume group \"%s\"", lp.vg_name);
-	vg = vg_read_for_update(cmd, lp.vg_name, NULL, 0);
-	if (vg_read_error(vg))
+	if (!(vg = vg_lock_and_read(cmd, lp.vg_name, NULL, LCK_VG_WRITE,
+				    CLUSTERED | EXPORTED_VG | LVM_WRITE,
+				    CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
 		return ECMD_FAILED;
 
 	if (!_lvcreate(cmd, vg, &lp))
--- LVM2/tools/lvrename.c	2009/06/26 09:47:37	1.52
+++ LVM2/tools/lvrename.c	2009/06/26 10:55:58	1.53
@@ -102,8 +102,9 @@
 	}
 
 	log_verbose("Checking for existing volume group \"%s\"", vg_name);
-	vg = vg_read_for_update(cmd, vg_name, NULL, 0);
-	if (vg_read_error(vg))
+	if (!(vg = vg_lock_and_read(cmd, vg_name, NULL, LCK_VG_WRITE,
+				    CLUSTERED | EXPORTED_VG | LVM_WRITE,
+				    CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
 		return ECMD_FAILED;
 
 	if (!(lvl = find_lv_in_vg(vg, lv_name_old))) {
--- LVM2/tools/lvresize.c	2009/06/26 09:47:37	1.111
+++ LVM2/tools/lvresize.c	2009/06/26 10:55:58	1.112
@@ -671,8 +671,9 @@
 		return EINVALID_CMD_LINE;
 
 	log_verbose("Finding volume group %s", lp.vg_name);
-	vg = vg_read_for_update(cmd, lp.vg_name, NULL, 0);
-	if (vg_read_error(vg)) {
+	if (!(vg = vg_lock_and_read(cmd, lp.vg_name, NULL, LCK_VG_WRITE,
+				    CLUSTERED | EXPORTED_VG | LVM_WRITE,
+				    CORRECT_INCONSISTENT | FAIL_INCONSISTENT))) {
 		stack;
 		return ECMD_FAILED;
 	}
--- LVM2/tools/polldaemon.c	2009/06/26 09:47:37	1.16
+++ LVM2/tools/polldaemon.c	2009/06/26 10:55:58	1.17
@@ -147,8 +147,7 @@
 		}
 
 		/* Locks the (possibly renamed) VG again */
-		vg = parms->poll_fns->get_copy_vg(cmd, name);
-		if (vg_read_error(vg)) {
+		if (!(vg = parms->poll_fns->get_copy_vg(cmd, name, uuid))) {
 			log_error("ABORTING: Can't reread VG for %s", name);
 			/* What more could we do here? */
 			return 0;
--- LVM2/tools/pvchange.c	2009/06/26 09:47:37	1.68
+++ LVM2/tools/pvchange.c	2009/06/26 10:55:58	1.69
@@ -57,8 +57,9 @@
 
 		log_verbose("Finding volume group %s of physical volume %s",
 			    vg_name, pv_name);
-		vg = vg_read_for_update(cmd, vg_name, NULL, 0);
-		if (vg_read_error(vg))
+		if (!(vg = vg_lock_and_read(cmd, vg_name, NULL, LCK_VG_WRITE,
+					    CLUSTERED | EXPORTED_VG | LVM_WRITE,
+					    CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
 			return_0;
 
 		if (!(pvl = find_pv_in_vg(vg, pv_name))) {
--- LVM2/tools/pvdisplay.c	2009/06/26 09:47:37	1.50
+++ LVM2/tools/pvdisplay.c	2009/06/26 10:55:58	1.51
@@ -29,8 +29,8 @@
 
 	if (!is_orphan(pv) && !vg) {
 		vg_name = pv_vg_name(pv);
-		vg = vg_read(cmd, vg_name, (char *)&pv->vgid, 0);
-		if (vg_read_error(vg)) {
+		if (!(vg = vg_lock_and_read(cmd, vg_name, (char *)&pv->vgid,
+					    LCK_VG_READ, CLUSTERED, 0))) {
 		 	log_error("Skipping volume group %s", vg_name);
 			/* FIXME If CLUSTERED should return ECMD_PROCESSED here */
 		 	return ECMD_FAILED;
--- LVM2/tools/pvmove.c	2009/06/26 09:47:37	1.62
+++ LVM2/tools/pvmove.c	2009/06/26 10:55:58	1.63
@@ -89,9 +89,16 @@
 
 static struct volume_group *_get_vg(struct cmd_context *cmd, const char *vgname)
 {
+	struct volume_group *vg;
+
 	dev_close_all();
 
-	return vg_read_for_update(cmd, vgname, NULL, 0);
+	if (!(vg = vg_lock_and_read(cmd, vgname, NULL, LCK_VG_WRITE,
+				    CLUSTERED | EXPORTED_VG | LVM_WRITE,
+				    CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
+		 return NULL;
+
+	return vg;
 }
 
 /* Create list of PVs for allocation of replacement extents */
@@ -385,8 +392,7 @@
 	/* Read VG */
 	log_verbose("Finding volume group \"%s\"", pv_vg_name(pv));
 
-	vg = _get_vg(cmd, pv_vg_name(pv));
-	if (vg_read_error(vg)) {
+	if (!(vg = _get_vg(cmd, pv_vg_name(pv)))) {
 		stack;
 		return ECMD_FAILED;
 	}
--- LVM2/tools/pvresize.c	2009/06/26 09:47:37	1.28
+++ LVM2/tools/pvresize.c	2009/06/26 10:55:58	1.29
@@ -29,6 +29,7 @@
 			     const uint64_t new_size)
 {
 	struct pv_list *pvl;
+	int consistent = 1;
 	uint64_t size = 0;
 	uint32_t new_pe_count = 0;
 	int r = 0;
@@ -58,9 +59,19 @@
 	} else {
 		vg_name = pv_vg_name(pv);
 
- 		vg = vg_read_for_update(cmd, vg_name, NULL, 0);
+		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
+			log_error("Can't get lock for %s", pv_vg_name(pv));
+			return 0;
+		}
+
+		if (!(vg = vg_read_internal(cmd, vg_name, NULL, &consistent))) {
+			unlock_vg(cmd, vg_name);
+			log_error("Unable to find volume group of \"%s\"",
+				  pv_name);
+			return 0;
+		}
 
-		if (vg_read_error(vg))
+		if (!vg_check_status(vg, CLUSTERED | EXPORTED_VG | LVM_WRITE))
 			goto bad;
 
 		if (!(pvl = find_pv_in_vg(vg, pv_name))) {
--- LVM2/tools/reporter.c	2009/06/26 09:47:37	1.50
+++ LVM2/tools/reporter.c	2009/06/26 10:55:58	1.51
@@ -132,8 +132,8 @@
 	if (is_pv(pv) && !is_orphan(pv) && !vg) {
 		vg_name = pv_vg_name(pv);
 
-		vg = vg_read(cmd, vg_name, (char *)&pv->vgid, 0);
-		if (vg_read_error(vg)) {
+		if (!(vg = vg_lock_and_read(cmd, vg_name, (char *)&pv->vgid,
+					    LCK_VG_READ, CLUSTERED, 0))) {
 			log_error("Skipping volume group %s", vg_name);
 			return ECMD_FAILED;
 		}
--- LVM2/tools/vgextend.c	2009/06/26 09:47:37	1.41
+++ LVM2/tools/vgextend.c	2009/06/26 10:55:58	1.42
@@ -42,12 +42,13 @@
 	}
 
 	log_verbose("Checking for volume group \"%s\"", vg_name);
- 	vg = vg_read_for_update(cmd, vg_name, NULL,
- 				READ_REQUIRE_RESIZEABLE | LOCK_NONBLOCKING);
- 	if (vg_read_error(vg)) {
- 		unlock_vg(cmd, VG_ORPHANS);
+	if (!(vg = vg_lock_and_read(cmd, vg_name, NULL, LCK_VG_WRITE,
+				    CLUSTERED | EXPORTED_VG |
+				    LVM_WRITE | RESIZEABLE_VG,
+				    CORRECT_INCONSISTENT | FAIL_INCONSISTENT))) {
+		unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;
-	}
+	 }
 /********** FIXME
 	log_print("maximum logical volume size is %s",
 		  (dummy = lvm_show_size(LVM_LV_SIZE_MAX(vg) / 2, LONG)));
--- LVM2/tools/vgmerge.c	2009/06/26 09:47:37	1.56
+++ LVM2/tools/vgmerge.c	2009/06/26 10:55:58	1.57
@@ -28,15 +28,17 @@
 	}
 
 	log_verbose("Checking for volume group \"%s\"", vg_name_to);
- 	vg_to = vg_read_for_update(cmd, vg_name_to, NULL, 0);
- 	if (vg_read_error(vg_to))
+	if (!(vg_to = vg_lock_and_read(cmd, vg_name_to, NULL, LCK_VG_WRITE,
+				       CLUSTERED | EXPORTED_VG | LVM_WRITE,
+				       CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
 		 return ECMD_FAILED;
 
 	log_verbose("Checking for volume group \"%s\"", vg_name_from);
- 	vg_from = vg_read_for_update(cmd, vg_name_from, NULL,
- 				     LOCK_NONBLOCKING);
- 	if (vg_read_error(vg_from)) {
-		unlock_release_vg(cmd, vg_to, vg_name_to);
+	if (!(vg_from = vg_lock_and_read(cmd, vg_name_from, NULL,
+					 LCK_VG_WRITE,
+					 CLUSTERED | EXPORTED_VG | LVM_WRITE,
+					 CORRECT_INCONSISTENT | FAIL_INCONSISTENT))) {
+		unlock_and_release_vg(cmd, vg_to, vg_name_to);
 		return ECMD_FAILED;
 	}
 



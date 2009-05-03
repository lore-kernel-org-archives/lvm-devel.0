From: Petr Rockai <prockai@redhat.com>
Date: Sun,  3 May 2009 13:38:53 +0200
Subject: [PATCH 1/9] Convert the straight instances of vg_lock_and_read to new vg_read(_for_update).
In-Reply-To: <1241350741-31349-1-git-send-email-prockai@redhat.com>
References: <1241350741-31349-1-git-send-email-prockai@redhat.com>
Message-ID: <1241350741-31349-2-git-send-email-prockai@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Sun May  3 11:40:51 CEST 2009  Petr Rockai <me@mornfall.net>
  * Convert the straight instances of vg_lock_and_read to new vg_read(_for_update).
diff -rN -u -p old-temp.31080/tools/lvconvert.c new-temp.31080/tools/lvconvert.c
--- old-temp.31080/tools/lvconvert.c	2009-05-03 13:29:24.954235823 +0200
+++ new-temp.31080/tools/lvconvert.c	2009-05-03 13:29:25.046236063 +0200
@@ -240,10 +240,8 @@ static struct volume_group *_get_lvconve
 {
 	dev_close_all();
 
-        return vg_lock_and_read(cmd, extract_vgname(cmd, lv_name),
-				NULL, LCK_VG_WRITE,
- 				CLUSTERED | EXPORTED_VG | LVM_WRITE,
-				CORRECT_INCONSISTENT | FAIL_INCONSISTENT);
+        return vg_read_for_update(cmd, extract_vgname(cmd, lv_name),
+				  NULL, 0);
 }
 
 static struct logical_volume *_get_lvconvert_lv(struct cmd_context *cmd __attribute((unused)),
@@ -852,9 +850,8 @@ int lvconvert(struct cmd_context * cmd, 
 
 	log_verbose("Checking for existing volume group \"%s\"", lp.vg_name);
 
-	if (!(vg = vg_lock_and_read(cmd, lp.vg_name, NULL, LCK_VG_WRITE,
-				    CLUSTERED | EXPORTED_VG | LVM_WRITE,
-				    CORRECT_INCONSISTENT)))
+	vg = vg_read_for_update(cmd, lp.vg_name, NULL, 0);
+	if (vg_read_error(vg))
 		return ECMD_FAILED;
 
 	if (!(lvl = find_lv_in_vg(vg, lp.lv_name))) {
diff -rN -u -p old-temp.31080/tools/lvcreate.c new-temp.31080/tools/lvcreate.c
--- old-temp.31080/tools/lvcreate.c	2009-05-03 13:29:24.954235823 +0200
+++ new-temp.31080/tools/lvcreate.c	2009-05-03 13:29:25.046236063 +0200
@@ -984,9 +984,8 @@ int lvcreate(struct cmd_context *cmd, in
 		return EINVALID_CMD_LINE;
 
 	log_verbose("Finding volume group \"%s\"", lp.vg_name);
-	if (!(vg = vg_lock_and_read(cmd, lp.vg_name, NULL, LCK_VG_WRITE,
-				    CLUSTERED | EXPORTED_VG | LVM_WRITE,
-				    CORRECT_INCONSISTENT)))
+	vg = vg_read_for_update(cmd, lp.vg_name, NULL, 0);
+	if (vg_read_error(vg))
 		return ECMD_FAILED;
 
 	if (!_lvcreate(cmd, vg, &lp))
diff -rN -u -p old-temp.31080/tools/lvrename.c new-temp.31080/tools/lvrename.c
--- old-temp.31080/tools/lvrename.c	2009-05-03 13:29:24.954235823 +0200
+++ new-temp.31080/tools/lvrename.c	2009-05-03 13:29:25.050236572 +0200
@@ -102,9 +102,8 @@ int lvrename(struct cmd_context *cmd, in
 	}
 
 	log_verbose("Checking for existing volume group \"%s\"", vg_name);
-	if (!(vg = vg_lock_and_read(cmd, vg_name, NULL, LCK_VG_WRITE,
-				    CLUSTERED | EXPORTED_VG | LVM_WRITE,
-				    CORRECT_INCONSISTENT)))
+	vg = vg_read_for_update(cmd, vg_name, NULL, 0);
+	if (vg_read_error(vg))
 		return ECMD_FAILED;
 
 	if (!(lvl = find_lv_in_vg(vg, lv_name_old))) {
diff -rN -u -p old-temp.31080/tools/lvresize.c new-temp.31080/tools/lvresize.c
--- old-temp.31080/tools/lvresize.c	2009-05-03 13:29:24.954235823 +0200
+++ new-temp.31080/tools/lvresize.c	2009-05-03 13:29:25.050236572 +0200
@@ -677,9 +677,8 @@ int lvresize(struct cmd_context *cmd, in
 		return EINVALID_CMD_LINE;
 
 	log_verbose("Finding volume group %s", lp.vg_name);
-	if (!(vg = vg_lock_and_read(cmd, lp.vg_name, NULL, LCK_VG_WRITE,
-				    CLUSTERED | EXPORTED_VG | LVM_WRITE,
-				    CORRECT_INCONSISTENT))) {
+	vg = vg_read_for_update(cmd, lp.vg_name, NULL, 0);
+	if (vg_read_error(vg)) {
 		stack;
 		return ECMD_FAILED;
 	}
diff -rN -u -p old-temp.31080/tools/polldaemon.c new-temp.31080/tools/polldaemon.c
--- old-temp.31080/tools/polldaemon.c	2009-05-03 13:29:24.954235823 +0200
+++ new-temp.31080/tools/polldaemon.c	2009-05-03 13:29:25.050236572 +0200
@@ -147,7 +147,8 @@ static int _wait_for_single_mirror(struc
 		}
 
 		/* Locks the (possibly renamed) VG again */
-		if (!(vg = parms->poll_fns->get_copy_vg(cmd, name))) {
+		vg = parms->poll_fns->get_copy_vg(cmd, name);
+		if (vg_read_error(vg)) {
 			log_error("ABORTING: Can't reread VG for %s", name);
 			/* What more could we do here? */
 			return 0;
diff -rN -u -p old-temp.31080/tools/pvchange.c new-temp.31080/tools/pvchange.c
--- old-temp.31080/tools/pvchange.c	2009-05-03 13:29:24.954235823 +0200
+++ new-temp.31080/tools/pvchange.c	2009-05-03 13:29:25.050236572 +0200
@@ -57,9 +57,8 @@ static int _pvchange_single(struct cmd_c
 
 		log_verbose("Finding volume group %s of physical volume %s",
 			    vg_name, pv_name);
-		if (!(vg = vg_lock_and_read(cmd, vg_name, NULL, LCK_VG_WRITE,
-					    CLUSTERED | EXPORTED_VG | LVM_WRITE,
-					    CORRECT_INCONSISTENT)))
+		vg = vg_read_for_update(cmd, vg_name, NULL, 0);
+		if (vg_read_error(vg))
 			return_0;
 
 		if (!(pvl = find_pv_in_vg(vg, pv_name))) {
diff -rN -u -p old-temp.31080/tools/pvdisplay.c new-temp.31080/tools/pvdisplay.c
--- old-temp.31080/tools/pvdisplay.c	2009-05-03 13:29:24.954235823 +0200
+++ new-temp.31080/tools/pvdisplay.c	2009-05-03 13:29:25.050236572 +0200
@@ -29,8 +29,8 @@ static int _pvdisplay_single(struct cmd_
 
 	if (!is_orphan(pv) && !vg) {
 		vg_name = pv_vg_name(pv);
-		if (!(vg = vg_lock_and_read(cmd, vg_name, (char *)&pv->vgid,
-					    LCK_VG_READ, CLUSTERED, 0))) {
+		vg = vg_read(cmd, vg_name, (char *)&pv->vgid, 0);
+		if (vg_read_error(vg)) {
 		 	log_error("Skipping volume group %s", vg_name);
 			/* FIXME If CLUSTERED should return ECMD_PROCESSED here */
 		 	return ECMD_FAILED;
diff -rN -u -p old-temp.31080/tools/pvmove.c new-temp.31080/tools/pvmove.c
--- old-temp.31080/tools/pvmove.c	2009-05-03 13:29:24.950234547 +0200
+++ new-temp.31080/tools/pvmove.c	2009-05-03 13:29:25.050236572 +0200
@@ -89,16 +89,9 @@ static const char *_extract_lvname(struc
 
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
@@ -384,7 +377,8 @@ static int _set_up_pvmove(struct cmd_con
 	/* Read VG */
 	log_verbose("Finding volume group \"%s\"", pv_vg_name(pv));
 
-	if (!(vg = _get_vg(cmd, pv_vg_name(pv)))) {
+	vg = _get_vg(cmd, pv_vg_name(pv));
+	if (vg_read_error(vg)) {
 		stack;
 		return ECMD_FAILED;
 	}
diff -rN -u -p old-temp.31080/tools/pvresize.c new-temp.31080/tools/pvresize.c
--- old-temp.31080/tools/pvresize.c	2009-05-03 13:29:24.950234547 +0200
+++ new-temp.31080/tools/pvresize.c	2009-05-03 13:29:25.050236572 +0200
@@ -29,7 +29,6 @@ static int _pv_resize_single(struct cmd_
 			     const uint64_t new_size)
 {
 	struct pv_list *pvl;
-	int consistent = 1;
 	uint64_t size = 0;
 	uint32_t new_pe_count = 0;
 	int r = 0;
@@ -59,19 +58,9 @@ static int _pv_resize_single(struct cmd_
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
diff -rN -u -p old-temp.31080/tools/reporter.c new-temp.31080/tools/reporter.c
--- old-temp.31080/tools/reporter.c	2009-05-03 13:29:24.950234547 +0200
+++ new-temp.31080/tools/reporter.c	2009-05-03 13:29:25.050236572 +0200
@@ -137,8 +137,8 @@ static int _pvs_single(struct cmd_contex
 	if (is_pv(pv) && !is_orphan(pv) && !vg) {
 		vg_name = pv_vg_name(pv);
 
-		if (!(vg = vg_lock_and_read(cmd, vg_name, (char *)&pv->vgid,
-					    LCK_VG_READ, CLUSTERED, 0))) {
+		vg = vg_read(cmd, vg_name, (char *)&pv->vgid, 0);
+		if (vg_read_error(vg)) {
 			log_error("Skipping volume group %s", vg_name);
 			return ECMD_FAILED;
 		}
diff -rN -u -p old-temp.31080/tools/vgextend.c new-temp.31080/tools/vgextend.c
--- old-temp.31080/tools/vgextend.c	2009-05-03 13:29:24.946235086 +0200
+++ new-temp.31080/tools/vgextend.c	2009-05-03 13:29:25.054237779 +0200
@@ -42,13 +42,12 @@ int vgextend(struct cmd_context *cmd, in
 	}
 
 	log_verbose("Checking for volume group \"%s\"", vg_name);
-	if (!(vg = vg_lock_and_read(cmd, vg_name, NULL, LCK_VG_WRITE | LCK_NONBLOCK,
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
diff -rN -u -p old-temp.31080/tools/vgmerge.c new-temp.31080/tools/vgmerge.c
--- old-temp.31080/tools/vgmerge.c	2009-05-03 13:29:24.946235086 +0200
+++ new-temp.31080/tools/vgmerge.c	2009-05-03 13:29:25.054237779 +0200
@@ -28,16 +28,14 @@ static int _vgmerge_single(struct cmd_co
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
-					 LCK_VG_WRITE | LCK_NONBLOCK,
-					 CLUSTERED | EXPORTED_VG | LVM_WRITE,
-					 CORRECT_INCONSISTENT | FAIL_INCONSISTENT))) {
+ 	vg_from = vg_read_for_update(cmd, vg_name_from, NULL,
+ 				     LOCK_NONBLOCKING);
+ 	if (vg_read_error(vg_from)) {
 		unlock_release_vg(cmd, vg_to, vg_name_to);
 		return ECMD_FAILED;
 	}



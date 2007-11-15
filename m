From: agk@sourceware.org <agk@sourceware.org>
Date: 15 Nov 2007 02:20:05 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata-exporte ...
Message-ID: <20071115022005.7862.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-11-15 02:20:04

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : lvconvert.c lvcreate.c lvrename.c lvresize.c 
	                 pvchange.c pvdisplay.c pvmove.c reporter.c 
	                 toollib.c vgextend.c vgmerge.c vgsplit.c 

Log message:
	Convert some vg_reads into vg_lock_and_reads

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.735&r2=1.736
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.143&r2=1.144
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.159&r2=1.160
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvrename.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.88&r2=1.89
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvdisplay.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.115&r2=1.116
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39

--- LVM2/WHATS_NEW	2007/11/14 18:41:05	1.735
+++ LVM2/WHATS_NEW	2007/11/15 02:20:03	1.736
@@ -1,5 +1,6 @@
 Version 2.02.29 -
 ==================================
+  Convert some vg_reads into vg_lock_and_reads.
   Avoid nested vg_reads when processing PVs in VGs and fix associated locking.
   Accept sizes with --readahead argument.
   Store size arguments as sectors internally.
--- LVM2/lib/metadata/metadata-exported.h	2007/11/09 16:51:54	1.23
+++ LVM2/lib/metadata/metadata-exported.h	2007/11/15 02:20:03	1.24
@@ -308,6 +308,7 @@
 int is_orphan_vg(const char *vg_name);
 int is_orphan(pv_t *pv);
 vg_t *vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
+		       const char *vgid,
 		       uint32_t lock_flags, uint32_t status_flags,
 		       uint32_t misc_flags);
 
--- LVM2/lib/metadata/metadata.c	2007/11/05 17:17:55	1.143
+++ LVM2/lib/metadata/metadata.c	2007/11/15 02:20:03	1.144
@@ -1922,6 +1922,7 @@
  * non-NULL - success; volume group handle
  */
 vg_t *vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
+		       const char *vgid,
 		       uint32_t lock_flags, uint32_t status_flags,
 		       uint32_t misc_flags)
 {
@@ -1942,7 +1943,7 @@
 		return NULL;
 	}
 
-	if (!(vg = vg_read(cmd, vg_name, NULL, &consistent)) ||
+	if (!(vg = vg_read(cmd, vg_name, vgid, &consistent)) ||
 	    ((misc_flags & FAIL_INCONSISTENT) && !consistent)) {
 		log_error("Volume group \"%s\" not found", vg_name);
 		unlock_vg(cmd, vg_name);
@@ -1953,10 +1954,10 @@
 		unlock_vg(cmd, vg_name);
 		return NULL;
 	}
+
 	return vg;
 }
 
-
 /*
  * Gets/Sets for external LVM library
  */
--- LVM2/tools/lvconvert.c	2007/11/14 00:08:25	1.44
+++ LVM2/tools/lvconvert.c	2007/11/15 02:20:03	1.45
@@ -608,7 +608,7 @@
 
 	log_verbose("Checking for existing volume group \"%s\"", lp.vg_name);
 
-	if (!(vg = vg_lock_and_read(cmd, lp.vg_name, LCK_VG_WRITE,
+	if (!(vg = vg_lock_and_read(cmd, lp.vg_name, NULL, LCK_VG_WRITE,
 				    CLUSTERED | EXPORTED_VG | LVM_WRITE,
 				    CORRECT_INCONSISTENT)))
 		return ECMD_FAILED;
--- LVM2/tools/lvcreate.c	2007/11/14 00:08:25	1.159
+++ LVM2/tools/lvcreate.c	2007/11/15 02:20:03	1.160
@@ -508,16 +508,16 @@
 	return 1;
 }
 
-static int _lvcreate(struct cmd_context *cmd, struct lvcreate_params *lp)
+static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
+		     struct lvcreate_params *lp)
 {
 	uint32_t size_rest;
 	uint32_t status = 0;
 	uint64_t tmp_size;
-	struct volume_group *vg;
 	struct logical_volume *lv, *org = NULL, *log_lv = NULL;
 	struct list *pvh, tags;
 	const char *tag = NULL;
-	int consistent = 1, origin_active = 0;
+	int origin_active = 0;
 	struct alloc_handle *ah = NULL;
 	char lv_name_buf[128];
 	const char *lv_name;
@@ -526,17 +526,6 @@
 
 	status |= lp->permission | VISIBLE_LV;
 
-	/* does VG exist? */
-	log_verbose("Finding volume group \"%s\"", lp->vg_name);
-
-	if (!(vg = vg_read(cmd, lp->vg_name, NULL, &consistent))) {
-		log_error("Volume group \"%s\" doesn't exist", lp->vg_name);
-		return 0;
-	}
-
-	if (!vg_check_status(vg, CLUSTERED | EXPORTED_VG | LVM_WRITE))
-		return 0;
-
 	if (lp->lv_name && find_lv_in_vg(vg, lp->lv_name)) {
 		log_error("Logical volume \"%s\" already exists in "
 			  "volume group \"%s\"", lp->lv_name, lp->vg_name);
@@ -926,27 +915,24 @@
 
 int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 {
-	int r = ECMD_FAILED;
+	int r = ECMD_PROCESSED;
 	struct lvcreate_params lp;
+	struct volume_group *vg;
 
 	memset(&lp, 0, sizeof(lp));
 
 	if (!_lvcreate_params(&lp, cmd, argc, argv))
 		return EINVALID_CMD_LINE;
 
-	if (!lock_vol(cmd, lp.vg_name, LCK_VG_WRITE)) {
-		log_error("Can't get lock for %s", lp.vg_name);
+	log_verbose("Finding volume group \"%s\"", lp.vg_name);
+	if (!(vg = vg_lock_and_read(cmd, lp.vg_name, NULL, LCK_VG_WRITE,
+				    CLUSTERED | EXPORTED_VG | LVM_WRITE,
+				    CORRECT_INCONSISTENT)))
 		return ECMD_FAILED;
-	}
-
-	if (!_lvcreate(cmd, &lp)) {
-		stack;
-		goto out;
-	}
 
-	r = ECMD_PROCESSED;
+	if (!_lvcreate(cmd, vg, &lp))
+		r = ECMD_FAILED;
 
-      out:
 	unlock_vg(cmd, lp.vg_name);
 	return r;
 }
--- LVM2/tools/lvrename.c	2007/08/20 20:55:30	1.46
+++ LVM2/tools/lvrename.c	2007/11/15 02:20:03	1.47
@@ -101,8 +101,7 @@
 	}
 
 	log_verbose("Checking for existing volume group \"%s\"", vg_name);
-
-	if (!(vg = vg_lock_and_read(cmd, vg_name, LCK_VG_WRITE,
+	if (!(vg = vg_lock_and_read(cmd, vg_name, NULL, LCK_VG_WRITE,
 				    CLUSTERED | EXPORTED_VG | LVM_WRITE,
 				    CORRECT_INCONSISTENT)))
 		return ECMD_FAILED;
--- LVM2/tools/lvresize.c	2007/11/14 00:08:25	1.88
+++ LVM2/tools/lvresize.c	2007/11/15 02:20:03	1.89
@@ -254,9 +254,9 @@
 	return 1;
 }
 
-static int _lvresize(struct cmd_context *cmd, struct lvresize_params *lp)
+static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
+		     struct lvresize_params *lp)
 {
-	struct volume_group *vg;
 	struct logical_volume *lv;
 	struct lvinfo info;
 	uint32_t stripesize_extents = 0;
@@ -268,7 +268,6 @@
 	alloc_policy_t alloc;
 	struct logical_volume *lock_lv;
 	struct lv_list *lvl;
-	int consistent = 1;
 	struct lv_segment *seg;
 	uint32_t seg_extents;
 	uint32_t sz, str;
@@ -276,14 +275,6 @@
 	char size_buf[SIZE_BUF];
 	char lv_path[PATH_MAX];
 
-	if (!(vg = vg_read(cmd, lp->vg_name, NULL, &consistent))) {
-		log_error("Volume group %s doesn't exist", lp->vg_name);
-		return ECMD_FAILED;
-	}
-
-	if (!vg_check_status(vg, CLUSTERED | EXPORTED_VG | LVM_WRITE))
-		return ECMD_FAILED;
-
 	/* does LV exist? */
 	if (!(lvl = find_lv_in_vg(vg, lp->lv_name))) {
 		log_error("Logical volume %s not found in volume group %s",
@@ -649,6 +640,7 @@
 int lvresize(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct lvresize_params lp;
+	struct volume_group *vg;
 	int r;
 
 	memset(&lp, 0, sizeof(lp));
@@ -657,12 +649,14 @@
 		return EINVALID_CMD_LINE;
 
 	log_verbose("Finding volume group %s", lp.vg_name);
-	if (!lock_vol(cmd, lp.vg_name, LCK_VG_WRITE)) {
-		log_error("Can't get lock for %s", lp.vg_name);
+	if (!(vg = vg_lock_and_read(cmd, lp.vg_name, NULL, LCK_VG_WRITE,
+				    CLUSTERED | EXPORTED_VG | LVM_WRITE,
+				    CORRECT_INCONSISTENT))) {
+		log_error("Volume group %s doesn't exist", lp.vg_name);
 		return ECMD_FAILED;
 	}
 
-	if (!(r = _lvresize(cmd, &lp)))
+	if (!(r = _lvresize(cmd, vg, &lp)))
 		stack;
 
 	unlock_vg(cmd, lp.vg_name);
--- LVM2/tools/pvchange.c	2007/11/02 20:40:04	1.55
+++ LVM2/tools/pvchange.c	2007/11/15 02:20:03	1.56
@@ -32,7 +32,6 @@
 	const char *orig_vg_name;
 	char uuid[64] __attribute((aligned(8)));
 
-	int consistent = 1;
 	int allocatable = 0;
 	int tagarg = 0;
 
@@ -54,27 +53,14 @@
 	/* If in a VG, must change using volume group. */
 	/* FIXME: handle PVs with no MDAs */
 	if (!is_orphan(pv)) {
-		log_verbose("Finding volume group of physical volume \"%s\"",
-			    pv_name);
-
 		vg_name = pv_vg_name(pv);
-		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
-			log_error("Can't get lock for %s", vg_name);
-			return 0;
-		}
-
-		if (!(vg = vg_read(cmd, vg_name, NULL, &consistent))) {
-			unlock_vg(cmd, vg_name);
-			log_error("Unable to find volume group of \"%s\"",
-				  pv_name);
-			return 0;
-		}
 
-		if (!vg_check_status(vg,
-				     CLUSTERED | EXPORTED_VG | LVM_WRITE)) {
-			unlock_vg(cmd, vg_name);
-			return 0;
-		}
+		log_verbose("Finding volume group %s of physical volume %s",
+			    vg_name, pv_name);
+		if (!(vg = vg_lock_and_read(cmd, vg_name, NULL, LCK_VG_WRITE,
+					    CLUSTERED | EXPORTED_VG | LVM_WRITE,
+					    CORRECT_INCONSISTENT)))
+			return_0;
 
 		if (!(pvl = find_pv_in_vg(vg, pv_name))) {
 			unlock_vg(cmd, vg_name);
--- LVM2/tools/pvdisplay.c	2007/11/14 18:41:05	1.42
+++ LVM2/tools/pvdisplay.c	2007/11/15 02:20:03	1.43
@@ -20,7 +20,6 @@
 			     struct physical_volume *pv, void *handle)
 {
 	struct pv_list *pvl;
-	int consistent = 0;
 	int ret = ECMD_PROCESSED;
 	uint64_t size;
 
@@ -29,21 +28,12 @@
 
 	 if (!is_orphan(pv) && !vg) {
 		vg_name = pv_vg_name(pv);
-         	if (!lock_vol(cmd, vg_name, LCK_VG_READ)) {
-                 	log_error("Can't lock %s: skipping", vg_name);
+		if (!(vg = vg_lock_and_read(cmd, vg_name, (char *)&pv->vgid,
+					    LCK_VG_READ, CLUSTERED, 0))) {
+                 	log_error("Skipping volume group %s", vg_name);
                  	return ECMD_FAILED;
          	}
 
-         	if (!(vg = vg_read(cmd, vg_name, (char *)&pv->vgid, &consistent))) {
-                 	log_error("Can't read %s: skipping", vg_name);
-                 	goto out;
-         	}
-
-		if (!vg_check_status(vg, CLUSTERED)) {
-			ret = ECMD_FAILED;
-			goto out;
-		}
-
 	 	/*
 		 * Replace possibly incomplete PV structure with new one
 		 * allocated in vg_read() path.
--- LVM2/tools/pvmove.c	2007/10/11 19:20:38	1.42
+++ LVM2/tools/pvmove.c	2007/11/15 02:20:03	1.43
@@ -54,7 +54,7 @@
 
 	dev_close_all();
 
-	if (!(vg = vg_lock_and_read(cmd, vgname, LCK_VG_WRITE,
+	if (!(vg = vg_lock_and_read(cmd, vgname, NULL, LCK_VG_WRITE,
 				    CLUSTERED | EXPORTED_VG | LVM_WRITE,
 				    CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
 		 return NULL;
--- LVM2/tools/reporter.c	2007/11/14 18:41:05	1.29
+++ LVM2/tools/reporter.c	2007/11/15 02:20:03	1.30
@@ -86,28 +86,18 @@
 		       struct physical_volume *pv, void *handle)
 {
 	struct pv_list *pvl;
-	int consistent = 0;
 	int ret = ECMD_PROCESSED;
 	const char *vg_name = NULL;
 
 	if (!is_orphan(pv) && !vg) {
 		vg_name = pv_vg_name(pv);
 
-		if (!lock_vol(cmd, vg_name, LCK_VG_READ)) {
-			log_error("Can't lock %s: skipping", vg_name);
+		if (!(vg = vg_lock_and_read(cmd, vg_name, (char *)&pv->vgid,
+					    LCK_VG_READ, CLUSTERED, 0))) {
+			log_error("Skipping volume group %s", vg_name);
 			return ECMD_FAILED;
 		}
 
-		if (!(vg = vg_read(cmd, vg_name, (char *)&pv->vgid, &consistent))) {
-			log_error("Can't read %s: skipping", vg_name);
-			goto out;
-		}
-
-		if (!vg_check_status(vg, CLUSTERED)) {
-			ret = ECMD_FAILED;
-			goto out;
-		}
-
 		/*
 		 * Replace possibly incomplete PV structure with new one
 		 * allocated in vg_read() path.
--- LVM2/tools/toollib.c	2007/11/14 18:41:05	1.115
+++ LVM2/tools/toollib.c	2007/11/15 02:20:03	1.116
@@ -427,23 +427,14 @@
 	const char *vg_name = NULL;
 	int ret_max = 0;
 	int ret;
-	int consistent = 0;
 
 	if (!vg) {
 		vg_name = pv_vg_name(pv);
-		if (!lock_vol(cmd, vg_name, LCK_VG_READ)) {
-			log_error("Can't lock %s: skipping", vg_name);
-			return ECMD_FAILED;
-		}
 
-		if (!(vg = vg_read(cmd, vg_name, NULL, &consistent))) {
-			log_error("Can't read %s: skipping", vg_name);
-			goto out;
-		}
-
-		if (!vg_check_status(vg, CLUSTERED)) {
-			ret = ECMD_FAILED;
-			goto out;
+		if (!(vg = vg_lock_and_read(cmd, vg_name, NULL, LCK_VG_READ,
+					    CLUSTERED, 0))) {
+			log_error("Skipping volume group %s", vg_name);
+			return ECMD_FAILED;
 		}
 	}
 
--- LVM2/tools/vgextend.c	2007/11/02 20:40:05	1.35
+++ LVM2/tools/vgextend.c	2007/11/15 02:20:03	1.36
@@ -41,7 +41,7 @@
 	}
 
 	log_verbose("Checking for volume group \"%s\"", vg_name);
-	if (!(vg = vg_lock_and_read(cmd, vg_name, LCK_VG_WRITE | LCK_NONBLOCK,
+	if (!(vg = vg_lock_and_read(cmd, vg_name, NULL, LCK_VG_WRITE | LCK_NONBLOCK,
 				    CLUSTERED | EXPORTED_VG | 
 				    LVM_WRITE | RESIZEABLE_VG,
 				    CORRECT_INCONSISTENT | FAIL_INCONSISTENT))) {
--- LVM2/tools/vgmerge.c	2007/10/12 14:29:32	1.41
+++ LVM2/tools/vgmerge.c	2007/11/15 02:20:03	1.42
@@ -29,13 +29,13 @@
 	}
 
 	log_verbose("Checking for volume group \"%s\"", vg_name_to);
-	if (!(vg_to = vg_lock_and_read(cmd, vg_name_to, LCK_VG_WRITE,
+	if (!(vg_to = vg_lock_and_read(cmd, vg_name_to, NULL, LCK_VG_WRITE,
 				       CLUSTERED | EXPORTED_VG | LVM_WRITE,
 				       CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
 		 return ECMD_FAILED;
 
 	log_verbose("Checking for volume group \"%s\"", vg_name_from);
-	if (!(vg_from = vg_lock_and_read(cmd, vg_name_from,
+	if (!(vg_from = vg_lock_and_read(cmd, vg_name_from, NULL,
 					 LCK_VG_WRITE | LCK_NONBLOCK,
 					 CLUSTERED | EXPORTED_VG | LVM_WRITE,
 					 CORRECT_INCONSISTENT | FAIL_INCONSISTENT))) {
--- LVM2/tools/vgsplit.c	2007/11/02 20:40:05	1.38
+++ LVM2/tools/vgsplit.c	2007/11/15 02:20:03	1.39
@@ -234,7 +234,7 @@
 	}
 
 	log_verbose("Checking for volume group \"%s\"", vg_name_from);
-	if (!(vg_from = vg_lock_and_read(cmd, vg_name_from, LCK_VG_WRITE,
+	if (!(vg_from = vg_lock_and_read(cmd, vg_name_from, NULL, LCK_VG_WRITE,
 				       CLUSTERED | EXPORTED_VG |
 				       RESIZEABLE_VG | LVM_WRITE,
 				       CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))



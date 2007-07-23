From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 23 Jul 2007 17:27:55 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata-exporte ...
Message-ID: <20070723172755.15375.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-07-23 17:27:55

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : pvmove.c vgextend.c vgmerge.c vgsplit.c 

Log message:
	Add vg_lock_and_read() external library function.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.667&r2=1.668
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.127&r2=1.128
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32

--- LVM2/WHATS_NEW	2007/07/23 10:45:49	1.667
+++ LVM2/WHATS_NEW	2007/07/23 17:27:54	1.668
@@ -1,5 +1,6 @@
 Version 2.02.28 -
 ================================
+  Add vg_lock_and_read() external library function.
   Fix loading of persistent cache if cache_dir is used. (2.02.23)
   Eliminate uses of strdup+basename.  Use last_path_component instead.
   Use gcc's printf attribute wherever possible.
--- LVM2/lib/metadata/metadata-exported.h	2007/07/18 15:38:58	1.1
+++ LVM2/lib/metadata/metadata-exported.h	2007/07/23 17:27:54	1.2
@@ -292,6 +292,8 @@
 int pv_write(struct cmd_context *cmd, struct physical_volume *pv,
 	     struct list *mdas, int64_t label_sector);
 int is_orphan(pv_t *pv);
+vg_t *vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
+		       uint32_t lock_flags, uint32_t status_flags);
 
 /* pe_start and pe_end relate to any existing data so that new metadata
 * areas can avoid overlap */
--- LVM2/lib/metadata/metadata.c	2007/07/12 15:38:53	1.127
+++ LVM2/lib/metadata/metadata.c	2007/07/23 17:27:54	1.128
@@ -1792,6 +1792,41 @@
 	return 1;
 }
 
+/**
+ * vg_lock_and_read - Attempt to lock a volume group, read, and check status
+ * @cmd - command context
+ * @vg_name - name of the volume group to lock and read
+ * @lock_flags - locking flags to use
+ * @status_flags - status flags to check
+ *
+ * Returns:
+ * NULL - failure
+ * non-NULL - success; volume group handle
+ */
+vg_t *vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
+		       uint32_t lock_flags, uint32_t status_flags)
+{
+	struct volume_group *vg;
+	int consistent = 1;
+	
+	if (!lock_vol(cmd, vg_name, lock_flags)) {
+		log_error("Can't get lock for %s", vg_name);
+		return NULL;
+	}
+
+	if (!(vg = vg_read(cmd, vg_name, NULL, &consistent)) || !consistent) {
+		log_error("Volume group \"%s\" not found", vg_name);
+		unlock_vg(cmd, vg_name);
+		return NULL;
+	}
+
+	if (!vg_check_status(vg, status_flags)) {
+		unlock_vg(cmd, vg_name);
+		return NULL;
+	}
+	return vg;
+}
+
 
 /*
  * Gets/Sets for external LVM library
--- LVM2/tools/pvmove.c	2007/06/15 22:16:55	1.38
+++ LVM2/tools/pvmove.c	2007/07/23 17:27:55	1.39
@@ -50,26 +50,13 @@
 
 static struct volume_group *_get_vg(struct cmd_context *cmd, const char *vgname)
 {
-	int consistent = 1;
 	struct volume_group *vg;
 
 	dev_close_all();
 
-	if (!lock_vol(cmd, vgname, LCK_VG_WRITE)) {
-		log_error("Can't get lock for %s", vgname);
-		return NULL;
-	}
-
-	if (!(vg = vg_read(cmd, vgname, NULL, &consistent)) || !consistent) {
-		log_error("Volume group \"%s\" doesn't exist", vgname);
-		unlock_vg(cmd, vgname);
-		return NULL;
-	}
-
-	if (!vg_check_status(vg, CLUSTERED | EXPORTED_VG | LVM_WRITE)) {
-		unlock_vg(cmd, vgname);
-		return NULL;
-	}
+	if (!(vg = vg_lock_and_read(cmd, vgname, LCK_VG_WRITE,
+				    CLUSTERED | EXPORTED_VG | LVM_WRITE)))
+		 return NULL;
 
 	return vg;
 }
--- LVM2/tools/vgextend.c	2007/06/19 00:33:43	1.31
+++ LVM2/tools/vgextend.c	2007/07/23 17:27:55	1.32
@@ -19,7 +19,6 @@
 {
 	char *vg_name;
 	struct volume_group *vg = NULL;
-	int consistent = 1;
 
 	if (!argc) {
 		log_error("Please enter volume group name and "
@@ -48,21 +47,12 @@
 	}
 
 	log_verbose("Checking for volume group \"%s\"", vg_name);
-	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE | LCK_NONBLOCK)) {
-		unlock_vg(cmd, ORPHAN);
-		log_error("Can't get lock for %s", vg_name);
-		goto error;
-	}
-
-	if (!(vg = vg_read(cmd, vg_name, NULL, &consistent)) || !consistent) {
-		log_error("Volume group \"%s\" not found.", vg_name);
-		goto error;
-	}
-
-	if (!vg_check_status(vg, CLUSTERED | EXPORTED_VG |
-				 LVM_WRITE | RESIZEABLE_VG))
-		goto error;
-
+	if (!(vg = vg_lock_and_read(cmd, vg_name, LCK_VG_WRITE | LCK_NONBLOCK,
+				    CLUSTERED | EXPORTED_VG | 
+				    LVM_WRITE | RESIZEABLE_VG))) {
+		 unlock_vg(cmd, ORPHAN);
+		return ECMD_FAILED;
+	 }
 /********** FIXME
 	log_print("maximum logical volume size is %s",
 		  (dummy = lvm_show_size(LVM_LV_SIZE_MAX(vg) / 2, LONG)));
--- LVM2/tools/vgmerge.c	2007/06/06 19:40:28	1.37
+++ LVM2/tools/vgmerge.c	2007/07/23 17:27:55	1.38
@@ -22,7 +22,6 @@
 	struct lv_list *lvl1, *lvl2;
 	struct pv_list *pvl;
 	int active;
-	int consistent = 1;
 
 	if (!strcmp(vg_name_to, vg_name_from)) {
 		log_error("Duplicate volume group name \"%s\"", vg_name_from);
@@ -30,38 +29,18 @@
 	}
 
 	log_verbose("Checking for volume group \"%s\"", vg_name_to);
-	if (!lock_vol(cmd, vg_name_to, LCK_VG_WRITE)) {
-		log_error("Can't get lock for %s", vg_name_to);
-		return ECMD_FAILED;
-	}
-
-	if (!(vg_to = vg_read(cmd, vg_name_to, NULL, &consistent)) || !consistent) {
-		log_error("Volume group \"%s\" doesn't exist", vg_name_to);
-		unlock_vg(cmd, vg_name_to);
-		return ECMD_FAILED;
-	}
-
-	if (!vg_check_status(vg_to, CLUSTERED | EXPORTED_VG | LVM_WRITE)) {
-		unlock_vg(cmd, vg_name_to);
-		return ECMD_FAILED;
-	}
+	if (!(vg_to = vg_lock_and_read(cmd, vg_name_to, LCK_VG_WRITE,
+				    CLUSTERED | EXPORTED_VG | LVM_WRITE)))
+		 return ECMD_FAILED;
 
 	log_verbose("Checking for volume group \"%s\"", vg_name_from);
-	if (!lock_vol(cmd, vg_name_from, LCK_VG_WRITE | LCK_NONBLOCK)) {
-		log_error("Can't get lock for %s", vg_name_from);
+	if (!(vg_from = vg_lock_and_read(cmd, vg_name_from,
+					 LCK_VG_WRITE | LCK_NONBLOCK,
+					 CLUSTERED | EXPORTED_VG | LVM_WRITE))) {
 		unlock_vg(cmd, vg_name_to);
 		return ECMD_FAILED;
 	}
 
-	consistent = 1;
-	if (!(vg_from = vg_read(cmd, vg_name_from, NULL, &consistent)) || !consistent) {
-		log_error("Volume group \"%s\" doesn't exist", vg_name_from);
-		goto error;
-	}
-
-	if (!vg_check_status(vg_from, CLUSTERED | EXPORTED_VG | LVM_WRITE))
-                goto error;
-
 	if ((active = lvs_in_vg_activated(vg_from))) {
 		log_error("Logical volumes in \"%s\" must be inactive",
 			  vg_name_from);
--- LVM2/tools/vgsplit.c	2007/06/28 17:59:34	1.31
+++ LVM2/tools/vgsplit.c	2007/07/23 17:27:55	1.32
@@ -240,22 +240,10 @@
 	}
 
 	log_verbose("Checking for volume group \"%s\"", vg_name_from);
-	if (!lock_vol(cmd, vg_name_from, LCK_VG_WRITE)) {
-		log_error("Can't get lock for %s", vg_name_from);
-		return ECMD_FAILED;
-	}
-
-	if (!(vg_from = vg_read(cmd, vg_name_from, NULL, &consistent)) || !consistent) {
-		log_error("Volume group \"%s\" doesn't exist", vg_name_from);
-		unlock_vg(cmd, vg_name_from);
-		return ECMD_FAILED;
-	}
-
-	if (!vg_check_status(vg_from, CLUSTERED | EXPORTED_VG |
-				      RESIZEABLE_VG | LVM_WRITE)) {
-		unlock_vg(cmd, vg_name_from);
-		return ECMD_FAILED;
-	}
+	if (!(vg_to = vg_lock_and_read(cmd, vg_name_from, LCK_VG_WRITE,
+				       CLUSTERED | EXPORTED_VG |
+				       RESIZEABLE_VG | LVM_WRITE)))
+		 return ECMD_FAILED;
 
 	log_verbose("Checking for volume group \"%s\"", vg_name_to);
 	if (!lock_vol(cmd, vg_name_to, LCK_VG_WRITE | LCK_NONBLOCK)) {



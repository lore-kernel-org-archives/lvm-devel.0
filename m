From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 23 Jul 2007 21:03:43 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20070723210343.7626.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-07-23 21:03:42

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : pvmove.c vgextend.c vgmerge.c vgsplit.c 

Log message:
	Add CORRECT_INCONSISTENT and FAIL_INCONSISTENT flags to vg_lock_and_read

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.128&r2=1.129
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33

--- LVM2/lib/metadata/metadata-exported.h	2007/07/23 17:27:54	1.2
+++ LVM2/lib/metadata/metadata-exported.h	2007/07/23 21:03:42	1.3
@@ -83,6 +83,10 @@
 #define FMT_RESIZE_PV		0x00000080U	/* Supports pvresize? */
 #define FMT_UNLIMITED_STRIPESIZE 0x00000100U	/* Unlimited stripe size? */
 
+/* LVM2 external library flags */
+#define CORRECT_INCONSISTENT    0x00000001U /* Correct inconsistent metadata */
+#define FAIL_INCONSISTENT       0x00000002U /* Fail if metadata inconsistent */
+
 /* Ordered list - see lv_manip.c */
 typedef enum {
 	ALLOC_INVALID,
@@ -293,7 +297,8 @@
 	     struct list *mdas, int64_t label_sector);
 int is_orphan(pv_t *pv);
 vg_t *vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
-		       uint32_t lock_flags, uint32_t status_flags);
+		       uint32_t lock_flags, uint32_t status_flags,
+		       uint32_t misc_flags);
 
 /* pe_start and pe_end relate to any existing data so that new metadata
 * areas can avoid overlap */
--- LVM2/lib/metadata/metadata.c	2007/07/23 17:27:54	1.128
+++ LVM2/lib/metadata/metadata.c	2007/07/23 21:03:42	1.129
@@ -1798,23 +1798,29 @@
  * @vg_name - name of the volume group to lock and read
  * @lock_flags - locking flags to use
  * @status_flags - status flags to check
+ * @misc_flags - function modifier flags
  *
  * Returns:
  * NULL - failure
  * non-NULL - success; volume group handle
  */
 vg_t *vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
-		       uint32_t lock_flags, uint32_t status_flags)
+		       uint32_t lock_flags, uint32_t status_flags,
+		       uint32_t misc_flags)
 {
 	struct volume_group *vg;
 	int consistent = 1;
-	
+
+	if (!(misc_flags & CORRECT_INCONSISTENT))
+		consistent = 0;
+
 	if (!lock_vol(cmd, vg_name, lock_flags)) {
 		log_error("Can't get lock for %s", vg_name);
 		return NULL;
 	}
 
-	if (!(vg = vg_read(cmd, vg_name, NULL, &consistent)) || !consistent) {
+	if (!(vg = vg_read(cmd, vg_name, NULL, &consistent)) ||
+	    ((misc_flags & FAIL_INCONSISTENT) && !consistent)) {
 		log_error("Volume group \"%s\" not found", vg_name);
 		unlock_vg(cmd, vg_name);
 		return NULL;
--- LVM2/tools/pvmove.c	2007/07/23 17:27:55	1.39
+++ LVM2/tools/pvmove.c	2007/07/23 21:03:42	1.40
@@ -55,7 +55,8 @@
 	dev_close_all();
 
 	if (!(vg = vg_lock_and_read(cmd, vgname, LCK_VG_WRITE,
-				    CLUSTERED | EXPORTED_VG | LVM_WRITE)))
+				    CLUSTERED | EXPORTED_VG | LVM_WRITE,
+				    CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
 		 return NULL;
 
 	return vg;
--- LVM2/tools/vgextend.c	2007/07/23 17:27:55	1.32
+++ LVM2/tools/vgextend.c	2007/07/23 21:03:42	1.33
@@ -49,7 +49,8 @@
 	log_verbose("Checking for volume group \"%s\"", vg_name);
 	if (!(vg = vg_lock_and_read(cmd, vg_name, LCK_VG_WRITE | LCK_NONBLOCK,
 				    CLUSTERED | EXPORTED_VG | 
-				    LVM_WRITE | RESIZEABLE_VG))) {
+				    LVM_WRITE | RESIZEABLE_VG,
+				    CORRECT_INCONSISTENT | FAIL_INCONSISTENT))) {
 		 unlock_vg(cmd, ORPHAN);
 		return ECMD_FAILED;
 	 }
--- LVM2/tools/vgmerge.c	2007/07/23 17:27:55	1.38
+++ LVM2/tools/vgmerge.c	2007/07/23 21:03:42	1.39
@@ -30,13 +30,15 @@
 
 	log_verbose("Checking for volume group \"%s\"", vg_name_to);
 	if (!(vg_to = vg_lock_and_read(cmd, vg_name_to, LCK_VG_WRITE,
-				    CLUSTERED | EXPORTED_VG | LVM_WRITE)))
+				       CLUSTERED | EXPORTED_VG | LVM_WRITE,
+				       CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
 		 return ECMD_FAILED;
 
 	log_verbose("Checking for volume group \"%s\"", vg_name_from);
 	if (!(vg_from = vg_lock_and_read(cmd, vg_name_from,
 					 LCK_VG_WRITE | LCK_NONBLOCK,
-					 CLUSTERED | EXPORTED_VG | LVM_WRITE))) {
+					 CLUSTERED | EXPORTED_VG | LVM_WRITE,
+					 CORRECT_INCONSISTENT | FAIL_INCONSISTENT))) {
 		unlock_vg(cmd, vg_name_to);
 		return ECMD_FAILED;
 	}
--- LVM2/tools/vgsplit.c	2007/07/23 17:27:55	1.32
+++ LVM2/tools/vgsplit.c	2007/07/23 21:03:42	1.33
@@ -242,7 +242,8 @@
 	log_verbose("Checking for volume group \"%s\"", vg_name_from);
 	if (!(vg_to = vg_lock_and_read(cmd, vg_name_from, LCK_VG_WRITE,
 				       CLUSTERED | EXPORTED_VG |
-				       RESIZEABLE_VG | LVM_WRITE)))
+				       RESIZEABLE_VG | LVM_WRITE,
+				       CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
 		 return ECMD_FAILED;
 
 	log_verbose("Checking for volume group \"%s\"", vg_name_to);



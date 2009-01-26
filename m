From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Jan 2009 19:01:34 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c ...
Message-ID: <20090126190134.25101.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-01-26 19:01:32

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 
	lib/metadata   : metadata-exported.h metadata.c metadata.h 
	tools          : pvdisplay.c pvresize.c reporter.c toollib.c 
	                 vgreduce.c vgrename.c vgsplit.c 

Log message:
	Rename vg_read() to vg_read_internal(). (mornfall)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1028&r2=1.1029
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.56&r2=1.57
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.196&r2=1.197
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.187&r2=1.188
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvdisplay.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.140&r2=1.141
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.85&r2=1.86
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.68&r2=1.69

--- LVM2/WHATS_NEW	2009/01/26 14:46:09	1.1028
+++ LVM2/WHATS_NEW	2009/01/26 19:01:32	1.1029
@@ -1,5 +1,6 @@
 Version 2.02.45 - 
 ===================================
+  Rename vg_read() to vg_read_internal().
 
 Version 2.02.44 - 26th January 2009
 ===================================
--- LVM2/daemons/clvmd/lvm-functions.c	2008/12/18 05:27:17	1.55
+++ LVM2/daemons/clvmd/lvm-functions.c	2009/01/26 19:01:32	1.56
@@ -711,7 +711,7 @@
 
 	DEBUGLOG("Triggering backup of VG metadata for %s. suspended=%d\n", vgname, suspended);
 
-	vg = vg_read(cmd, vgname, NULL /*vgid*/, &consistent);
+	vg = vg_read_internal(cmd, vgname, NULL /*vgid*/, &consistent);
 	if (vg) {
 		if (consistent)
 			check_current_backup(vg);
--- LVM2/lib/metadata/metadata-exported.h	2008/12/04 15:54:27	1.56
+++ LVM2/lib/metadata/metadata-exported.h	2009/01/26 19:01:32	1.57
@@ -76,7 +76,7 @@
 						   written out in metadata*/
 
 //#define POSTORDER_FLAG	0x02000000U /* Not real flags, reserved for
-//#define POSTORDER_OPEN_FLAG	0x04000000U    temporary use inside vg_read. */
+//#define POSTORDER_OPEN_FLAG	0x04000000U    temporary use inside vg_read_internal. */
 
 #define LVM_READ              	0x00000100U	/* LV VG */
 #define LVM_WRITE             	0x00000200U	/* LV VG */
@@ -328,7 +328,7 @@
 int vg_write(struct volume_group *vg);
 int vg_commit(struct volume_group *vg);
 int vg_revert(struct volume_group *vg);
-struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name,
+struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vg_name,
 			     const char *vgid, int *consistent);
 struct physical_volume *pv_read(struct cmd_context *cmd, const char *pv_name,
 				struct dm_list *mdas, uint64_t *label_sector,
--- LVM2/lib/metadata/metadata.c	2008/12/04 15:54:27	1.196
+++ LVM2/lib/metadata/metadata.c	2009/01/26 19:01:32	1.197
@@ -224,8 +224,8 @@
 	struct pv_list *pvl;
 	int consistent = 0;
 
-	if (!(vg = vg_read(fmt->cmd, vg_name, vgid, &consistent))) {
-		log_error("get_pv_from_vg_by_id: vg_read failed to read VG %s",
+	if (!(vg = vg_read_internal(fmt->cmd, vg_name, vgid, &consistent))) {
+		log_error("get_pv_from_vg_by_id: vg_read_internal failed to read VG %s",
 			  vg_name);
 		return 0;
 	}
@@ -503,7 +503,7 @@
 		return_NULL;
 
 	/* is this vg name already in use ? */
-	if (vg_read(cmd, vg_name, NULL, &consistent)) {
+	if (vg_read_internal(cmd, vg_name, NULL, &consistent)) {
 		log_err("A volume group called '%s' already exists.", vg_name);
 		goto bad;
 	}
@@ -1684,12 +1684,12 @@
 	return ret;
 }
 
-/* Caller sets consistent to 1 if it's safe for vg_read to correct
+/* Caller sets consistent to 1 if it's safe for vg_read_internal to correct
  * inconsistent metadata on disk (i.e. the VG write lock is held).
  * This guarantees only consistent metadata is returned.
  * If consistent is 0, caller must check whether consistent == 1 on return
  * and take appropriate action if it isn't (e.g. abort; get write lock
- * and call vg_read again).
+ * and call vg_read_internal again).
  *
  * If precommitted is set, use precommitted metadata if present.
  *
@@ -1716,7 +1716,7 @@
 
 	if (is_orphan_vg(vgname)) {
 		if (use_precommitted) {
-			log_error("Internal error: vg_read requires vgname "
+			log_error("Internal error: vg_read_internal requires vgname "
 				  "with pre-commit.");
 			return NULL;
 		}
@@ -1974,7 +1974,7 @@
 	return correct_vg;
 }
 
-struct volume_group *vg_read(struct cmd_context *cmd, const char *vgname,
+struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vgname,
 			     const char *vgid, int *consistent)
 {
 	struct volume_group *vg;
@@ -2002,7 +2002,7 @@
 
 /* This is only called by lv_from_lvid, which is only called from
  * activate.c so we know the appropriate VG lock is already held and
- * the vg_read is therefore safe.
+ * the vg_read_internal is therefore safe.
  */
 static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
 					    const char *vgid,
@@ -2034,7 +2034,7 @@
 	if (memlock())
 		return NULL;
 
-	/* FIXME Need a genuine read by ID here - don't vg_read by name! */
+	/* FIXME Need a genuine read by ID here - don't vg_read_internal by name! */
 	/* FIXME Disabled vgrenames while active for now because we aren't
 	 *       allowed to do a full scan here any more. */
 
@@ -2218,7 +2218,7 @@
 			stack;
 			continue;
 		}
-		if (!(vg = vg_read(cmd, vgname, vgid, &consistent))) {
+		if (!(vg = vg_read_internal(cmd, vgname, vgid, &consistent))) {
 			stack;
 			continue;
 		}
@@ -2446,7 +2446,7 @@
 		return NULL;
 	}
 
-	if (!(vg = vg_read(cmd, vg_name, vgid, &consistent)) ||
+	if (!(vg = vg_read_internal(cmd, vg_name, vgid, &consistent)) ||
 	    ((misc_flags & FAIL_INCONSISTENT) && !consistent)) {
 		log_error("Volume group \"%s\" not found", vg_name);
 		unlock_vg(cmd, vg_name);
--- LVM2/lib/metadata/metadata.h	2009/01/09 22:44:33	1.187
+++ LVM2/lib/metadata/metadata.h	2009/01/26 19:01:32	1.188
@@ -79,7 +79,7 @@
 //						   written out in metadata*/
 
 #define POSTORDER_FLAG		0x02000000U /* Not real flags, reserved for  */
-#define POSTORDER_OPEN_FLAG	0x04000000U /* temporary use inside vg_read. */
+#define POSTORDER_OPEN_FLAG	0x04000000U /* temporary use inside vg_read_internal. */
 
 //#define LVM_READ              	0x00000100U	/* LV VG */
 //#define LVM_WRITE             	0x00000200U	/* LV VG */
--- LVM2/tools/pvdisplay.c	2008/01/30 14:00:02	1.46
+++ LVM2/tools/pvdisplay.c	2009/01/26 19:01:32	1.47
@@ -37,7 +37,7 @@
 
 	 	/*
 		 * Replace possibly incomplete PV structure with new one
-		 * allocated in vg_read() path.
+		 * allocated in vg_read_internal() path.
 		 */
 		 if (!(pvl = find_pv_in_vg(vg, pv_name))) {
 			 log_error("Unable to find \"%s\" in volume group \"%s\"",
--- LVM2/tools/pvresize.c	2008/11/03 22:14:30	1.23
+++ LVM2/tools/pvresize.c	2009/01/26 19:01:32	1.24
@@ -62,7 +62,7 @@
 			return 0;
 		}
 
-		if (!(vg = vg_read(cmd, vg_name, NULL, &consistent))) {
+		if (!(vg = vg_read_internal(cmd, vg_name, NULL, &consistent))) {
 			unlock_vg(cmd, vg_name);
 			log_error("Unable to find volume group of \"%s\"",
 				  pv_name);
--- LVM2/tools/reporter.c	2009/01/10 17:21:17	1.43
+++ LVM2/tools/reporter.c	2009/01/26 19:01:32	1.44
@@ -136,7 +136,7 @@
 
 		/*
 		 * Replace possibly incomplete PV structure with new one
-		 * allocated in vg_read() path.
+		 * allocated in vg_read_internal() path.
 		*/
 		if (!(pvl = find_pv_in_vg(vg, pv_dev_name(pv)))) {
 			log_error("Unable to find \"%s\" in volume group \"%s\"",
--- LVM2/tools/toollib.c	2008/12/22 09:00:51	1.140
+++ LVM2/tools/toollib.c	2009/01/26 19:01:32	1.141
@@ -291,7 +291,7 @@
 			consistent = 1;
 		else
 			consistent = 0;
-		if (!(vg = vg_read(cmd, vgname, NULL, &consistent)) || !consistent) {
+		if (!(vg = vg_read_internal(cmd, vgname, NULL, &consistent)) || !consistent) {
 			unlock_vg(cmd, vgname);
 			if (!vg)
 				log_error("Volume group \"%s\" "
@@ -433,7 +433,7 @@
 	}
 
 	log_verbose("Finding volume group \"%s\"", vg_name);
-	if (!(vg = vg_read(cmd, vg_name, vgid, &consistent))) {
+	if (!(vg = vg_read_internal(cmd, vg_name, vgid, &consistent))) {
 		log_error("Volume group \"%s\" not found", vg_name);
 		unlock_vg(cmd, vg_name);
 		return ECMD_FAILED;
@@ -720,7 +720,7 @@
 					log_error("Can't lock %s: skipping", sll->str);
 					continue;
 				}
-				if (!(vg = vg_read(cmd, sll->str, NULL, &consistent))) {
+				if (!(vg = vg_read_internal(cmd, sll->str, NULL, &consistent))) {
 					log_error("Volume group \"%s\" not found", sll->str);
 					unlock_vg(cmd, sll->str);
 					ret_max = ECMD_FAILED;
@@ -1143,7 +1143,7 @@
 		return NULL;
 	}
 
-	return vg_read(cmd, vgname, NULL, &consistent);
+	return vg_read_internal(cmd, vgname, NULL, &consistent);
 }
 
 int apply_lvname_restrictions(const char *name)
--- LVM2/tools/vgreduce.c	2008/11/03 22:14:30	1.85
+++ LVM2/tools/vgreduce.c	2009/01/26 19:01:32	1.86
@@ -426,7 +426,7 @@
 	vg->free_count -= pv_pe_count(pv) - pv_pe_alloc_count(pv);
 	vg->extent_count -= pv_pe_count(pv);
 
-	if(!(orphan_vg = vg_read(cmd, vg->fid->fmt->orphan_vg_name, NULL, &consistent)) ||
+	if(!(orphan_vg = vg_read_internal(cmd, vg->fid->fmt->orphan_vg_name, NULL, &consistent)) ||
 	   !consistent) {
 		log_error("Unable to read existing orphan PVs");
 		unlock_vg(cmd, VG_ORPHANS);
@@ -520,7 +520,7 @@
 		return ECMD_FAILED;
 	}
 
-	if ((!(vg = vg_read(cmd, vg_name, NULL, &consistent)) || !consistent)
+	if ((!(vg = vg_read_internal(cmd, vg_name, NULL, &consistent)) || !consistent)
 	    && !repairing) {
 		log_error("Volume group \"%s\" doesn't exist", vg_name);
 		unlock_vg(cmd, vg_name);
@@ -541,7 +541,7 @@
 		}
 
 		consistent = !arg_count(cmd, force_ARG);
-		if (!(vg = vg_read(cmd, vg_name, NULL, &consistent))) {
+		if (!(vg = vg_read_internal(cmd, vg_name, NULL, &consistent))) {
 			log_error("Volume group \"%s\" not found", vg_name);
 			unlock_vg(cmd, vg_name);
 			return ECMD_FAILED;
--- LVM2/tools/vgrename.c	2008/12/22 09:00:51	1.57
+++ LVM2/tools/vgrename.c	2009/01/26 19:01:32	1.58
@@ -75,7 +75,7 @@
 		return 0;
 	}
 
-	if (!(vg = vg_read(cmd, vg_name_old, vgid, &consistent)) || !consistent) {
+	if (!(vg = vg_read_internal(cmd, vg_name_old, vgid, &consistent)) || !consistent) {
 		log_error("Volume group %s %s%s%snot found.", vg_name_old,
 		vgid ? "(" : "", vgid ? vgid : "", vgid ? ") " : "");
 		unlock_vg(cmd, vg_name_old);
@@ -107,7 +107,7 @@
 	}
 
 	consistent = 0;
-	if ((vg_new = vg_read(cmd, vg_name_new, NULL, &consistent))) {
+	if ((vg_new = vg_read_internal(cmd, vg_name_new, NULL, &consistent))) {
 		log_error("New volume group \"%s\" already exists",
 			  vg_name_new);
 		goto error;
--- LVM2/tools/vgsplit.c	2008/11/03 22:14:30	1.68
+++ LVM2/tools/vgsplit.c	2009/01/26 19:01:32	1.69
@@ -334,7 +334,7 @@
 	}
 
 	consistent = 0;
-	if ((vg_to = vg_read(cmd, vg_name_to, NULL, &consistent))) {
+	if ((vg_to = vg_read_internal(cmd, vg_name_to, NULL, &consistent))) {
 		existing_vg = 1;
 		if (new_vg_option_specified(cmd)) {
 			log_error("Volume group \"%s\" exists, but new VG "
@@ -451,7 +451,7 @@
 	 */
 	consistent = 1;
 	if (!test_mode() &&
-	    (!(vg_to = vg_read(cmd, vg_name_to, NULL, &consistent)) ||
+	    (!(vg_to = vg_read_internal(cmd, vg_name_to, NULL, &consistent)) ||
 	     !consistent)) {
 		log_error("Volume group \"%s\" became inconsistent: please "
 			  "fix manually", vg_name_to);



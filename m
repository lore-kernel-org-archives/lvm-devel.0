From: Petr Rockai <prockai@redhat.com>
Date: Mon, 12 Jan 2009 17:48:10 +0100
Subject: Re: [PATCH 1/11] Move vg_read out of the way, renaming it to vg_read_internal.
In-Reply-To: <1231769286-15534-2-git-send-email-prockai@redhat.com> (Petr
	Rockai's message of "Mon, 12 Jan 2009 15:07:56 +0100")
References: <1231769286-15534-1-git-send-email-prockai@redhat.com>
	<1231769286-15534-2-git-send-email-prockai@redhat.com>
Message-ID: <87fxjo4gj9.fsf_-_@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Sorry for the mismatched patch that renames more than needed (and also in files
that are apparently no longer in repo. Gotta fix that...).

Anyhow, amended patch follows (hopefully better this time):

Mon Jan 12 17:38:59 CET 2009  Petr Rockai <me@mornfall.net>
  * Move vg_read out of the way, renaming it to vg_read_internal.
diff -rN -u -p old-lvmlib_apply/daemons/clvmd/lvm-functions.c new-lvmlib_apply/daemons/clvmd/lvm-functions.c
--- old-lvmlib_apply/daemons/clvmd/lvm-functions.c	2009-01-12 17:42:07.527013017 +0100
+++ new-lvmlib_apply/daemons/clvmd/lvm-functions.c	2009-01-12 17:42:07.555019160 +0100
@@ -711,7 +711,7 @@ void lvm_do_backup(const char *vgname)
 
 	DEBUGLOG("Triggering backup of VG metadata for %s. suspended=%d\n", vgname, suspended);
 
-	vg = vg_read(cmd, vgname, NULL /*vgid*/, &consistent);
+	vg = vg_read_internal(cmd, vgname, NULL /*vgid*/, &consistent);
 	if (vg) {
 		if (consistent)
 			check_current_backup(vg);
diff -rN -u -p old-lvmlib_apply/lib/metadata/metadata.c new-lvmlib_apply/lib/metadata/metadata.c
--- old-lvmlib_apply/lib/metadata/metadata.c	2009-01-12 17:42:07.527013017 +0100
+++ new-lvmlib_apply/lib/metadata/metadata.c	2009-01-12 17:42:07.575017931 +0100
@@ -224,8 +224,8 @@ int get_pv_from_vg_by_id(const struct fo
 	struct pv_list *pvl;
 	int consistent = 0;
 
-	if (!(vg = vg_read(fmt->cmd, vg_name, vgid, &consistent))) {
-		log_error("get_pv_from_vg_by_id: vg_read failed to read VG %s",
+	if (!(vg = vg_read_internal(fmt->cmd, vg_name, vgid, &consistent))) {
+		log_error("get_pv_from_vg_by_id: vg_read_internal failed to read VG %s",
 			  vg_name);
 		return 0;
 	}
@@ -503,7 +503,7 @@ struct volume_group *vg_create(struct cm
 		return_NULL;
 
 	/* is this vg name already in use ? */
-	if (vg_read(cmd, vg_name, NULL, &consistent)) {
+	if (vg_read_internal(cmd, vg_name, NULL, &consistent)) {
 		log_err("A volume group called '%s' already exists.", vg_name);
 		goto bad;
 	}
@@ -1684,12 +1684,12 @@ int vg_missing_pv_count(const vg_t *vg)
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
@@ -1716,7 +1716,7 @@ static struct volume_group *_vg_read(str
 
 	if (is_orphan_vg(vgname)) {
 		if (use_precommitted) {
-			log_error("Internal error: vg_read requires vgname "
+			log_error("Internal error: vg_read_internal requires vgname "
 				  "with pre-commit.");
 			return NULL;
 		}
@@ -1974,7 +1974,7 @@ static struct volume_group *_vg_read(str
 	return correct_vg;
 }
 
-struct volume_group *vg_read(struct cmd_context *cmd, const char *vgname,
+struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vgname,
 			     const char *vgid, int *consistent)
 {
 	struct volume_group *vg;
@@ -2002,7 +2002,7 @@ struct volume_group *vg_read(struct cmd_
 
 /* This is only called by lv_from_lvid, which is only called from
  * activate.c so we know the appropriate VG lock is already held and
- * the vg_read is therefore safe.
+ * the vg_read_internal is therefore safe.
  */
 static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
 					    const char *vgid,
@@ -2034,7 +2034,7 @@ static struct volume_group *_vg_read_by_
 	if (memlock())
 		return NULL;
 
-	/* FIXME Need a genuine read by ID here - don't vg_read by name! */
+	/* FIXME Need a genuine read by ID here - don't vg_read_internal by name! */
 	/* FIXME Disabled vgrenames while active for now because we aren't
 	 *       allowed to do a full scan here any more. */
 
@@ -2218,7 +2218,7 @@ static int _get_pvs(struct cmd_context *
 			stack;
 			continue;
 		}
-		if (!(vg = vg_read(cmd, vgname, vgid, &consistent))) {
+		if (!(vg = vg_read_internal(cmd, vgname, vgid, &consistent))) {
 			stack;
 			continue;
 		}
@@ -2446,7 +2446,7 @@ vg_t *vg_lock_and_read(struct cmd_contex
 		return NULL;
 	}
 
-	if (!(vg = vg_read(cmd, vg_name, vgid, &consistent)) ||
+	if (!(vg = vg_read_internal(cmd, vg_name, vgid, &consistent)) ||
 	    ((misc_flags & FAIL_INCONSISTENT) && !consistent)) {
 		log_error("Volume group \"%s\" not found", vg_name);
 		unlock_vg(cmd, vg_name);
diff -rN -u -p old-lvmlib_apply/lib/metadata/metadata-exported.h new-lvmlib_apply/lib/metadata/metadata-exported.h
--- old-lvmlib_apply/lib/metadata/metadata-exported.h	2009-01-12 17:42:07.527013017 +0100
+++ new-lvmlib_apply/lib/metadata/metadata-exported.h	2009-01-12 17:42:07.575017931 +0100
@@ -76,7 +76,7 @@ struct pv_segment;
 						   written out in metadata*/
 
 //#define POSTORDER_FLAG	0x02000000U /* Not real flags, reserved for
-//#define POSTORDER_OPEN_FLAG	0x04000000U    temporary use inside vg_read. */
+//#define POSTORDER_OPEN_FLAG	0x04000000U    temporary use inside vg_read_internal. */
 
 #define LVM_READ              	0x00000100U	/* LV VG */
 #define LVM_WRITE             	0x00000200U	/* LV VG */
@@ -328,7 +328,7 @@ struct lv_list {
 int vg_write(struct volume_group *vg);
 int vg_commit(struct volume_group *vg);
 int vg_revert(struct volume_group *vg);
-struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name,
+struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vg_name,
 			     const char *vgid, int *consistent);
 struct physical_volume *pv_read(struct cmd_context *cmd, const char *pv_name,
 				struct dm_list *mdas, uint64_t *label_sector,
diff -rN -u -p old-lvmlib_apply/lib/metadata/metadata.h new-lvmlib_apply/lib/metadata/metadata.h
--- old-lvmlib_apply/lib/metadata/metadata.h	2009-01-12 17:42:07.519016679 +0100
+++ new-lvmlib_apply/lib/metadata/metadata.h	2009-01-12 17:42:07.575017931 +0100
@@ -79,7 +79,7 @@
 //						   written out in metadata*/
 
 #define POSTORDER_FLAG		0x02000000U /* Not real flags, reserved for  */
-#define POSTORDER_OPEN_FLAG	0x04000000U /* temporary use inside vg_read. */
+#define POSTORDER_OPEN_FLAG	0x04000000U /* temporary use inside vg_read_internal. */
 
 //#define LVM_READ              	0x00000100U	/* LV VG */
 //#define LVM_WRITE             	0x00000200U	/* LV VG */
diff -rN -u -p old-lvmlib_apply/tools/pvdisplay.c new-lvmlib_apply/tools/pvdisplay.c
--- old-lvmlib_apply/tools/pvdisplay.c	2009-01-12 17:42:07.519016679 +0100
+++ new-lvmlib_apply/tools/pvdisplay.c	2009-01-12 17:42:07.615018336 +0100
@@ -37,7 +37,7 @@ static int _pvdisplay_single(struct cmd_
 
 	 	/*
 		 * Replace possibly incomplete PV structure with new one
-		 * allocated in vg_read() path.
+		 * allocated in vg_read_internal() path.
 		 */
 		 if (!(pvl = find_pv_in_vg(vg, pv_name))) {
 			 log_error("Unable to find \"%s\" in volume group \"%s\"",
diff -rN -u -p old-lvmlib_apply/tools/pvresize.c new-lvmlib_apply/tools/pvresize.c
--- old-lvmlib_apply/tools/pvresize.c	2009-01-12 17:42:07.519016679 +0100
+++ new-lvmlib_apply/tools/pvresize.c	2009-01-12 17:42:07.615018336 +0100
@@ -62,7 +62,7 @@ static int _pv_resize_single(struct cmd_
 			return 0;
 		}
 
-		if (!(vg = vg_read(cmd, vg_name, NULL, &consistent))) {
+		if (!(vg = vg_read_internal(cmd, vg_name, NULL, &consistent))) {
 			unlock_vg(cmd, vg_name);
 			log_error("Unable to find volume group of \"%s\"",
 				  pv_name);
diff -rN -u -p old-lvmlib_apply/tools/reporter.c new-lvmlib_apply/tools/reporter.c
--- old-lvmlib_apply/tools/reporter.c	2009-01-12 17:42:07.519016679 +0100
+++ new-lvmlib_apply/tools/reporter.c	2009-01-12 17:42:07.619019054 +0100
@@ -136,7 +136,7 @@ static int _pvs_single(struct cmd_contex
 
 		/*
 		 * Replace possibly incomplete PV structure with new one
-		 * allocated in vg_read() path.
+		 * allocated in vg_read_internal() path.
 		*/
 		if (!(pvl = find_pv_in_vg(vg, pv_dev_name(pv)))) {
 			log_error("Unable to find \"%s\" in volume group \"%s\"",
diff -rN -u -p old-lvmlib_apply/tools/toollib.c new-lvmlib_apply/tools/toollib.c
--- old-lvmlib_apply/tools/toollib.c	2009-01-12 17:42:07.519016679 +0100
+++ new-lvmlib_apply/tools/toollib.c	2009-01-12 17:42:07.619019054 +0100
@@ -291,7 +291,7 @@ int process_each_lv(struct cmd_context *
 			consistent = 1;
 		else
 			consistent = 0;
-		if (!(vg = vg_read(cmd, vgname, NULL, &consistent)) || !consistent) {
+		if (!(vg = vg_read_internal(cmd, vgname, NULL, &consistent)) || !consistent) {
 			unlock_vg(cmd, vgname);
 			if (!vg)
 				log_error("Volume group \"%s\" "
@@ -433,7 +433,7 @@ static int _process_one_vg(struct cmd_co
 	}
 
 	log_verbose("Finding volume group \"%s\"", vg_name);
-	if (!(vg = vg_read(cmd, vg_name, vgid, &consistent))) {
+	if (!(vg = vg_read_internal(cmd, vg_name, vgid, &consistent))) {
 		log_error("Volume group \"%s\" not found", vg_name);
 		unlock_vg(cmd, vg_name);
 		return ECMD_FAILED;
@@ -720,7 +720,7 @@ int process_each_pv(struct cmd_context *
 					log_error("Can't lock %s: skipping", sll->str);
 					continue;
 				}
-				if (!(vg = vg_read(cmd, sll->str, NULL, &consistent))) {
+				if (!(vg = vg_read_internal(cmd, sll->str, NULL, &consistent))) {
 					log_error("Volume group \"%s\" not found", sll->str);
 					unlock_vg(cmd, sll->str);
 					ret_max = ECMD_FAILED;
@@ -1143,7 +1143,7 @@ struct volume_group *recover_vg(struct c
 		return NULL;
 	}
 
-	return vg_read(cmd, vgname, NULL, &consistent);
+	return vg_read_internal(cmd, vgname, NULL, &consistent);
 }
 
 int apply_lvname_restrictions(const char *name)
diff -rN -u -p old-lvmlib_apply/tools/vgreduce.c new-lvmlib_apply/tools/vgreduce.c
--- old-lvmlib_apply/tools/vgreduce.c	2009-01-12 17:42:07.515017987 +0100
+++ new-lvmlib_apply/tools/vgreduce.c	2009-01-12 17:42:07.619019054 +0100
@@ -426,7 +426,7 @@ static int _vgreduce_single(struct cmd_c
 	vg->free_count -= pv_pe_count(pv) - pv_pe_alloc_count(pv);
 	vg->extent_count -= pv_pe_count(pv);
 
-	if(!(orphan_vg = vg_read(cmd, vg->fid->fmt->orphan_vg_name, NULL, &consistent)) ||
+	if(!(orphan_vg = vg_read_internal(cmd, vg->fid->fmt->orphan_vg_name, NULL, &consistent)) ||
 	   !consistent) {
 		log_error("Unable to read existing orphan PVs");
 		unlock_vg(cmd, VG_ORPHANS);
@@ -520,7 +520,7 @@ int vgreduce(struct cmd_context *cmd, in
 		return ECMD_FAILED;
 	}
 
-	if ((!(vg = vg_read(cmd, vg_name, NULL, &consistent)) || !consistent)
+	if ((!(vg = vg_read_internal(cmd, vg_name, NULL, &consistent)) || !consistent)
 	    && !repairing) {
 		log_error("Volume group \"%s\" doesn't exist", vg_name);
 		unlock_vg(cmd, vg_name);
@@ -541,7 +541,7 @@ int vgreduce(struct cmd_context *cmd, in
 		}
 
 		consistent = !arg_count(cmd, force_ARG);
-		if (!(vg = vg_read(cmd, vg_name, NULL, &consistent))) {
+		if (!(vg = vg_read_internal(cmd, vg_name, NULL, &consistent))) {
 			log_error("Volume group \"%s\" not found", vg_name);
 			unlock_vg(cmd, vg_name);
 			return ECMD_FAILED;
diff -rN -u -p old-lvmlib_apply/tools/vgrename.c new-lvmlib_apply/tools/vgrename.c
--- old-lvmlib_apply/tools/vgrename.c	2009-01-12 17:42:07.515017987 +0100
+++ new-lvmlib_apply/tools/vgrename.c	2009-01-12 17:42:07.619019054 +0100
@@ -75,7 +75,7 @@ static int vg_rename_path(struct cmd_con
 		return 0;
 	}
 
-	if (!(vg = vg_read(cmd, vg_name_old, vgid, &consistent)) || !consistent) {
+	if (!(vg = vg_read_internal(cmd, vg_name_old, vgid, &consistent)) || !consistent) {
 		log_error("Volume group %s %s%s%snot found.", vg_name_old,
 		vgid ? "(" : "", vgid ? vgid : "", vgid ? ") " : "");
 		unlock_vg(cmd, vg_name_old);
@@ -107,7 +107,7 @@ static int vg_rename_path(struct cmd_con
 	}
 
 	consistent = 0;
-	if ((vg_new = vg_read(cmd, vg_name_new, NULL, &consistent))) {
+	if ((vg_new = vg_read_internal(cmd, vg_name_new, NULL, &consistent))) {
 		log_error("New volume group \"%s\" already exists",
 			  vg_name_new);
 		goto error;
diff -rN -u -p old-lvmlib_apply/tools/vgsplit.c new-lvmlib_apply/tools/vgsplit.c
--- old-lvmlib_apply/tools/vgsplit.c	2009-01-12 17:42:07.515017987 +0100
+++ new-lvmlib_apply/tools/vgsplit.c	2009-01-12 17:42:07.619019054 +0100
@@ -334,7 +334,7 @@ int vgsplit(struct cmd_context *cmd, int
 	}
 
 	consistent = 0;
-	if ((vg_to = vg_read(cmd, vg_name_to, NULL, &consistent))) {
+	if ((vg_to = vg_read_internal(cmd, vg_name_to, NULL, &consistent))) {
 		existing_vg = 1;
 		if (new_vg_option_specified(cmd)) {
 			log_error("Volume group \"%s\" exists, but new VG "
@@ -451,7 +451,7 @@ int vgsplit(struct cmd_context *cmd, int
 	 */
 	consistent = 1;
 	if (!test_mode() &&
-	    (!(vg_to = vg_read(cmd, vg_name_to, NULL, &consistent)) ||
+	    (!(vg_to = vg_read_internal(cmd, vg_name_to, NULL, &consistent)) ||
 	     !consistent)) {
 		log_error("Volume group \"%s\" became inconsistent: please "
 			  "fix manually", vg_name_to);




-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation



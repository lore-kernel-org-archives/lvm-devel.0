From: David Teigland <teigland@sourceware.org>
Date: Wed, 10 Nov 2021 23:39:16 +0000 (GMT)
Subject: main - vgchange: move autoactivation setup code
Message-ID: <20211110233916.F22F33858D35@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=92e741eda060b4712fab5b37e0bee2cc5e155a57
Commit:        92e741eda060b4712fab5b37e0bee2cc5e155a57
Parent:        d608837b2a88d0ed0c7ef7d8e6135e2d37687ff1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Nov 10 14:44:11 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Nov 10 14:44:11 2021 -0600

vgchange: move autoactivation setup code

into its own function, no functional change.
---
 tools/vgchange.c | 159 +++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 102 insertions(+), 57 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index acdde97a8..bbb565643 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -735,12 +735,18 @@ static int _vgchange_single(struct cmd_context *cmd, const char *vg_name,
 	return ret;
 }
 
-static int _check_autoactivation(struct cmd_context *cmd, struct vgchange_params *vp, int *skip_command)
+static int _vgchange_autoactivation_setup(struct cmd_context *cmd,
+					  struct vgchange_params *vp,
+					  int *skip_command,
+					  const char **vgname_ret,
+					  uint32_t *flags)
 {
 	const char *aa;
+	char *vgname = NULL;
+	int found_none = 0, found_all = 0, found_incomplete = 0;
 
 	if (!(aa = arg_str_value(cmd, autoactivation_ARG, NULL)))
-		return 1;
+		return_0;
 
 	if (strcmp(aa, "event")) {
 		log_print("Skip vgchange for unknown autoactivation value.");
@@ -755,9 +761,99 @@ static int _check_autoactivation(struct cmd_context *cmd, struct vgchange_params
 	}
 
 	vp->vg_complete_to_activate = 1;
-
 	cmd->use_hints = 0;
 
+	get_single_vgname_cmd_arg(cmd, NULL, &vgname);
+
+	/*
+	 * Special label scan optimized for autoactivation that is based on
+	 * info read from /run/lvm/ files created by pvscan --cache during
+	 * autoactivation.  Add an option to disable this optimization?  e.g.
+	 * "online_skip" in --autoactivation / auto_activation_settings
+	 *
+	 * In some cases it might be useful to strictly follow the online
+	 * files, and not fall back to a standard label scan when no pvs or
+	 * incomplete pvs are found from the online files.  Add option for
+	 * that?  e.g.
+	 * "online_only" in --autoactivation / auto_activation_settings
+	 *
+	 * Generally the way that vgchange -aay --autoactivation event is
+	 * currently used, it will not be called until pvscan --cache has found
+	 * the VG is complete, so it will not generally be following the paths
+	 * that fall back to standard label_scan.
+	 *
+	 * TODO: Like pvscan_aa_quick, this could do lock_vol(vgname) before
+	 * label_scan_vg_online, then set cmd->can_use_one_scan=1 to avoid
+	 * rescanning in _vg_read called by process_each_vg.
+	 */
+
+	/*
+	 * Perform label_scan on PVs that are online (per /run/lvm files)
+	 * for the given VG (or when no VG name is given, all online PVs.)
+	 * If this fails, the caller will do a normal process_each_vg without
+	 * optimizations (which will do a full label_scan.)
+	 */
+	if (!label_scan_vg_online(cmd, vgname, &found_none, &found_all, &found_incomplete)) {
+		log_print("PVs online error%s%s, using all devices.", vgname ? " for VG " : "", vgname ?: "");
+		return 1;
+	}
+
+	/*
+	 * Not the expected usage, activate any VGs that are complete based on
+	 * pvs_online.  Only online pvs are used.
+	 */
+	if (!vgname) {
+		*flags |= PROCESS_SKIP_SCAN;
+		return 1;
+	}
+
+	/*
+	 * The expected and optimal usage, because the udev rule calls
+	 * vgchange -aay --autoactivation event vgname when all PVs
+	 * for vgname are found online.  Only online pvs are used.
+	 */
+	if (found_all) {
+		*flags |= PROCESS_SKIP_SCAN;
+		*vgname_ret = vgname;
+		return 1;
+	}
+
+	/*
+	 * Possible option to only activate from only online pvs even if they
+	 * are not all found, and not fall back to a full label_scan.
+	 */
+	/*
+	if (online_only) {
+		log_print("PVs online %s.", found_none ? "not found" : "incomplete");
+		return vgname ? 0 : 1;
+	}
+	*/
+
+	/*
+	 * Not expected usage, no online pvs for the vgname were found.  The
+	 * caller will fall back to process_each doing a full label_scan to
+	 * look for the VG.  (No optimization used.)
+	 */
+	if (found_none) {
+		log_print("PVs online not found for VG %s, using all devices.", vgname);
+		return 1;
+	}
+
+	/*
+	 * Not expected usage, only some online pvs for the vgname were found.
+	 * The caller will fall back to process_each doing a full label_scan to
+	 * look for all PVs in the VG.  (No optimization used.)
+	 */
+	if (found_incomplete) {
+		log_print("PVs online incomplete for VG %s, using all devicess.", vgname);
+		return 1;
+	}
+
+	/*
+	 * Shouldn't happen, the caller will fall back to standard
+	 * process_each.  (No optimization used.)
+	 */
+	log_print("PVs online unknown for VG %s, using all devices.", vgname);
 	return 1;
 }
 
@@ -765,7 +861,7 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct vgchange_params vp = { 0 };
 	struct processing_handle *handle;
-	char *vgname = NULL;
+	const char *vgname = NULL;
 	uint32_t flags = 0;
 	int ret;
 
@@ -879,62 +975,11 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	if (arg_is_set(cmd, autoactivation_ARG)) {
-		int found_none = 0, found_all = 0, found_incomplete = 0;
 		int skip_command = 0;
-
-		if (!_check_autoactivation(cmd, &vp, &skip_command))
+		if (!_vgchange_autoactivation_setup(cmd, &vp, &skip_command, &vgname, &flags))
 			return ECMD_FAILED;
 		if (skip_command)
 			return ECMD_PROCESSED;
-
-		/*
-		 * Special label scan optimized for autoactivation
-		 * that is based on info read from /run/lvm/ files
-		 * created by pvscan --cache during autoactivation.
-		 * Add an option to disable this optimization?  e.g.
-		 * "online_skip" in --autoactivation / auto_activation_settings
-		 *
-		 * In some cases it might be useful to strictly follow
-		 * the online files, and not fall back to a standard
-		 * label scan when no pvs or incomplete pvs are found
-		 * from the online files.  Add option for that?  e.g.
-		 * "online_only" in --autoactivation / auto_activation_settings
-		 *
-		 * Generally the way that vgchange -aay --autoactivation event
-		 * is currently used, it will not be called until pvscan --cache
-		 * has found the VG is complete, so it will not generally be
-		 * following the paths that fall back to standard label_scan.
-		 *
-		 * TODO: Like pvscan_aa_quick, this could do lock_vol(vgname)
-		 * before label_scan_vg_online, then set cmd->can_use_one_scan=1
-		 * to avoid rescanning in _vg_read called by process_each_vg.
-		 */
-		get_single_vgname_cmd_arg(cmd, NULL, &vgname);
-		if (!label_scan_vg_online(cmd, vgname, &found_none, &found_all, &found_incomplete)) {
-			log_print("PVs online error%s%s, using all devices.", vgname ? " for VG " : "", vgname ?: "");
-		} else {
-			if (!vgname) {
-				/* Not expected usage, activate any VGs that are complete based on pvs_online. */
-				flags |= PROCESS_SKIP_SCAN;
-			} else if (found_all) {
-				/* The expected and optimal usage, only online PVs are read. */
-				flags |= PROCESS_SKIP_SCAN;
-			/*
-			} else if (online_only) {
-				log_print("PVs online %s.", found_none ? "not found" : "incomplete");
-				return vgname ? ECMD_FAILED : ECMD_PROCESSED;
-			*/
-			} else if (found_none) {
-				/* Not expected usage, use full label_scan in process_each */
-				log_print("PVs online not found for VG %s, using all devices.", vgname);
-			} else if (found_incomplete) {
-				/* Not expected usage, use full label_scan in process_each */
-				log_print("PVs online incomplete for VG %s, using all devicess.", vgname);
-			} else {
-				/* Shouldn't happen */
-				log_print("PVs online unknown for VG %s, using all devices.", vgname);
-			}
-		}
 	}
 
 	if (update)
@@ -949,7 +994,7 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 
 	handle->custom_handle = &vp;
 
-	ret = process_each_vg(cmd, argc, argv, NULL, NULL, flags, 0, handle, &_vgchange_single);
+	ret = process_each_vg(cmd, argc, argv, vgname, NULL, flags, 0, handle, &_vgchange_single);
 
 	destroy_processing_handle(cmd, handle);
 	return ret;



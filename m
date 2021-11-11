From: David Teigland <teigland@sourceware.org>
Date: Thu, 11 Nov 2021 22:59:19 +0000 (GMT)
Subject: main - vgchange autoactivation: lock vg early to avoid second label scan
Message-ID: <20211111225919.550A6385840E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0e0faf30e01f78828b7e240f57217755b62650bb
Commit:        0e0faf30e01f78828b7e240f57217755b62650bb
Parent:        92e741eda060b4712fab5b37e0bee2cc5e155a57
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Nov 10 16:43:21 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Nov 10 16:50:50 2021 -0600

vgchange autoactivation: lock vg early to avoid second label scan

Copy another optimization from pvscan -aay to vgchange -aay.
When using the optimized label scan for only one VG, acquire the
VG lock prior to the scan.  This allows vg_read to then skip the
repeated label scan that normally happens after locking the vg.
---
 lib/label/label.c                 |  4 ---
 test/shell/vgchange-pvs-online.sh |  4 ++-
 tools/vgchange.c                  | 58 +++++++++++++++++++++------------------
 3 files changed, 35 insertions(+), 31 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 324cfd034..d506b81e3 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1044,10 +1044,6 @@ int label_scan_vg_online(struct cmd_context *cmd, const char *vgname,
 
 	log_debug_devs("Finding online devices to scan");
 
-	/* reads devices file, does not populate dev-cache */
-	if (!setup_devices_for_online_autoactivation(cmd))
-		return 0;
-
 	/*
 	 * First attempt to use /run/lvm/pvs_lookup/vgname which should be
 	 * used in cases where all PVs in a VG do not contain metadata.
diff --git a/test/shell/vgchange-pvs-online.sh b/test/shell/vgchange-pvs-online.sh
index c2ebe7327..1e9c37db8 100644
--- a/test/shell/vgchange-pvs-online.sh
+++ b/test/shell/vgchange-pvs-online.sh
@@ -56,13 +56,14 @@ check lv_field $vg2/$lv1 lv_active "active"
 # Count io to check the pvs_online optimization 
 # is working to limit scanning.
 
+if which strace; then
 vgchange -an
 _clear_online_files
 
 pvscan --cache "$dev1"
 pvscan --cache "$dev2"
 strace -e io_submit vgchange -aay --autoactivation event $vg1 2>&1|tee trace.out
-test "$(grep io_submit trace.out | wc -l)" -eq 4
+test "$(grep io_submit trace.out | wc -l)" -eq 3
 rm trace.out
 
 strace -e io_submit pvscan --cache "$dev3" 2>&1|tee trace.out
@@ -72,6 +73,7 @@ rm trace.out
 strace -e io_submit vgchange -aay --autoactivation event $vg2 2>&1|tee trace.out
 test "$(grep io_submit trace.out | wc -l)" -eq 2
 rm trace.out
+fi
 
 # non-standard usage: no VG name arg, vgchange will only used pvs_online files
 
diff --git a/tools/vgchange.c b/tools/vgchange.c
index bbb565643..5eebc9ae9 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -743,6 +743,7 @@ static int _vgchange_autoactivation_setup(struct cmd_context *cmd,
 {
 	const char *aa;
 	char *vgname = NULL;
+	int vg_locked = 0;
 	int found_none = 0, found_all = 0, found_incomplete = 0;
 
 	if (!(aa = arg_str_value(cmd, autoactivation_ARG, NULL)))
@@ -763,29 +764,35 @@ static int _vgchange_autoactivation_setup(struct cmd_context *cmd,
 	vp->vg_complete_to_activate = 1;
 	cmd->use_hints = 0;
 
-	get_single_vgname_cmd_arg(cmd, NULL, &vgname);
-
 	/*
-	 * Special label scan optimized for autoactivation that is based on
-	 * info read from /run/lvm/ files created by pvscan --cache during
-	 * autoactivation.  Add an option to disable this optimization?  e.g.
+	 * Add an option to skip the pvs_online optimization? e.g.
 	 * "online_skip" in --autoactivation / auto_activation_settings
 	 *
-	 * In some cases it might be useful to strictly follow the online
-	 * files, and not fall back to a standard label scan when no pvs or
-	 * incomplete pvs are found from the online files.  Add option for
-	 * that?  e.g.
-	 * "online_only" in --autoactivation / auto_activation_settings
-	 *
-	 * Generally the way that vgchange -aay --autoactivation event is
-	 * currently used, it will not be called until pvscan --cache has found
-	 * the VG is complete, so it will not generally be following the paths
-	 * that fall back to standard label_scan.
-	 *
-	 * TODO: Like pvscan_aa_quick, this could do lock_vol(vgname) before
-	 * label_scan_vg_online, then set cmd->can_use_one_scan=1 to avoid
-	 * rescanning in _vg_read called by process_each_vg.
+	 * if (online_skip)
+	 *	return 1;
+	 */
+
+	/* reads devices file, does not populate dev-cache */
+	if (!setup_devices_for_online_autoactivation(cmd))
+		return_0;
+
+	get_single_vgname_cmd_arg(cmd, NULL, &vgname);
+
+	/*
+	 * Lock the VG before scanning the PVs so _vg_read can avoid the normal
+	 * lock_vol+rescan (READ_WITHOUT_LOCK avoids the normal lock_vol and
+	 * can_use_one_scan avoids the normal rescan.)  If this early lock_vol
+	 * fails, continue and use the normal lock_vol in _vg_read.
 	 */
+	if (vgname) {
+		if (!lock_vol(cmd, vgname, LCK_VG_WRITE, NULL)) {
+			log_debug("Failed early VG locking for autoactivation.");
+		} else {
+			*flags |= READ_WITHOUT_LOCK;
+			cmd->can_use_one_scan = 1;
+			vg_locked = 1;
+		}
+	}
 
 	/*
 	 * Perform label_scan on PVs that are online (per /run/lvm files)
@@ -819,15 +826,14 @@ static int _vgchange_autoactivation_setup(struct cmd_context *cmd,
 	}
 
 	/*
-	 * Possible option to only activate from only online pvs even if they
-	 * are not all found, and not fall back to a full label_scan.
+	 * The online scanning optimiziation didn't work, so undo the vg
+	 * locking optimization before falling back to normal processing.
 	 */
-	/*
-	if (online_only) {
-		log_print("PVs online %s.", found_none ? "not found" : "incomplete");
-		return vgname ? 0 : 1;
+	if (vg_locked) {
+		unlock_vg(cmd, NULL, vgname);
+		*flags &= ~READ_WITHOUT_LOCK;
+		cmd->can_use_one_scan = 0;
 	}
-	*/
 
 	/*
 	 * Not expected usage, no online pvs for the vgname were found.  The



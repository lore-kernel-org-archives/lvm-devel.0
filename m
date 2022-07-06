From: David Teigland <teigland@sourceware.org>
Date: Wed,  6 Jul 2022 15:23:11 +0000 (GMT)
Subject: rhel-8.7.0 - exit with error when --devicesfile name doesn't exist
Message-ID: <20220706152311.54EE13858C39@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=73b9a2805ca2f2c70f6f631b405f8fea3f72f23b
Commit:        73b9a2805ca2f2c70f6f631b405f8fea3f72f23b
Parent:        e60d7ce8e748cb6d51552879c162d01aafa17160
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jul 5 17:08:00 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jul 6 10:22:28 2022 -0500

exit with error when --devicesfile name doesn't exist

---
 lib/cache/lvmcache.c            |  3 ++-
 lib/label/label.c               |  4 ++--
 test/shell/devicesfile-basic.sh |  1 +
 tools/pvcreate.c                |  3 ++-
 tools/pvremove.c                |  3 ++-
 tools/pvscan.c                  |  3 ++-
 tools/toollib.c                 | 27 +++++++++++++++++++++------
 tools/vgcfgrestore.c            |  5 ++++-
 tools/vgcreate.c                |  5 ++++-
 tools/vgextend.c                |  3 ++-
 tools/vgmerge.c                 |  3 ++-
 tools/vgsplit.c                 |  3 ++-
 12 files changed, 46 insertions(+), 17 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 0e62cd267..61a2fee6d 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1600,7 +1600,8 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 	 * with infos/vginfos based on reading headers from
 	 * each device, and a vg summary from each mda.
 	 */
-	label_scan(cmd);
+	if (!label_scan(cmd))
+		return_0;
 
 	/*
 	 * When devnames are used as device ids (which is dispreferred),
diff --git a/lib/label/label.c b/lib/label/label.c
index 06958b502..00ede2b76 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -800,7 +800,7 @@ static int _setup_bcache(void)
 	}
 
 	if (!(scan_bcache = bcache_create(BCACHE_BLOCK_SIZE_IN_SECTORS, cache_blocks, ioe))) {
-		log_error("Failed to create bcache with %d cache blocks.", cache_blocks);
+		log_error("Failed to set up io layer with %d blocks.", cache_blocks);
 		return 0;
 	}
 
@@ -1015,7 +1015,7 @@ int label_scan(struct cmd_context *cmd)
 	 * data to invalidate.)
 	 */
 	if (!(iter = dev_iter_create(NULL, 0))) {
-		log_error("Scanning failed to get devices.");
+		log_error("Failed to get device list.");
 		return 0;
 	}
 	while ((dev = dev_iter_get(cmd, iter))) {
diff --git a/test/shell/devicesfile-basic.sh b/test/shell/devicesfile-basic.sh
index d1cfb6a35..2d197a73a 100644
--- a/test/shell/devicesfile-basic.sh
+++ b/test/shell/devicesfile-basic.sh
@@ -107,6 +107,7 @@ not vgs --devicesfile test.devices $vg2
 # misspelled override name fails
 not vgs --devicesfile doesnotexist $vg1
 not vgs --devicesfile doesnotexist $vg2
+not vgs --devicesfile doesnotexist
 
 # devicesfile and devices cannot be used together
 not vgs --devicesfile test.devices --devices "$dev1","$dev1" $vg1
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index 71eb060a3..a1ef0e9e1 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -144,7 +144,8 @@ int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 
 	cmd->create_edit_devices_file = 1;
 
-	lvmcache_label_scan(cmd);
+	if (!lvmcache_label_scan(cmd))
+		return_ECMD_FAILED;
 
 	if (!(handle = init_processing_handle(cmd, NULL))) {
 		log_error("Failed to initialize processing handle.");
diff --git a/tools/pvremove.c b/tools/pvremove.c
index 2dfdbd016..5c39ee0c7 100644
--- a/tools/pvremove.c
+++ b/tools/pvremove.c
@@ -45,7 +45,8 @@ int pvremove(struct cmd_context *cmd, int argc, char **argv)
 
 	clear_hint_file(cmd);
 
-	lvmcache_label_scan(cmd);
+	if (!lvmcache_label_scan(cmd))
+		return_ECMD_FAILED;
 
 	/* When forcibly clearing a PV we don't care about a VG lock. */
 	if (pp.force == DONT_PROMPT_OVERRIDE)
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 50d46051a..bce1fbb40 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -1626,7 +1626,8 @@ static int _pvscan_cache_all(struct cmd_context *cmd, int argc, char **argv,
 	 * which we want 'pvscan --cache' to do, and that uses
 	 * info from lvmcache, e.g. duplicate pv info.
 	 */
-	lvmcache_label_scan(cmd);
+	if (!lvmcache_label_scan(cmd))
+		return_0;
 
 	cmd->pvscan_recreate_hints = 0;
 	cmd->use_hints = 0;
diff --git a/tools/toollib.c b/tools/toollib.c
index 01ba03658..210b3dca5 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1601,7 +1601,10 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv,
 
 	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_LABEL);
 
-	lvmcache_label_scan(cmd);
+	if (!lvmcache_label_scan(cmd)) {
+		ret_max = ECMD_FAILED;
+		goto_out;
+	}
 
 	if (argc) {
 		for (; opt < argc; opt++) {
@@ -2381,8 +2384,13 @@ int process_each_vg(struct cmd_context *cmd,
 	 * Scan all devices to populate lvmcache with initial
 	 * list of PVs and VGs.
 	 */
-	if (!(read_flags & PROCESS_SKIP_SCAN))
-		lvmcache_label_scan(cmd);
+	if (!(read_flags & PROCESS_SKIP_SCAN)) {
+		if (!lvmcache_label_scan(cmd)) {
+			ret_max = ECMD_FAILED;
+			goto_out;
+		}
+	}
+
 
 	/*
 	 * A list of all VGs on the system is needed when:
@@ -3932,7 +3940,10 @@ int process_each_lv(struct cmd_context *cmd,
 	 * Scan all devices to populate lvmcache with initial
 	 * list of PVs and VGs.
 	 */
-	lvmcache_label_scan(cmd);
+	if (!lvmcache_label_scan(cmd)) {
+		ret_max = ECMD_FAILED;
+		goto_out;
+	}
 
 	/*
 	 * A list of all VGs on the system is needed when:
@@ -4568,8 +4579,12 @@ int process_each_pv(struct cmd_context *cmd,
 		goto_out;
 	}
 
-	if (!(read_flags & PROCESS_SKIP_SCAN))
-		lvmcache_label_scan(cmd);
+	if (!(read_flags & PROCESS_SKIP_SCAN)) {
+		if (!lvmcache_label_scan(cmd)) {
+			ret_max = ECMD_FAILED;
+			goto_out;
+		}
+	}
 
 	if (!lvmcache_get_vgnameids(cmd, &all_vgnameids, only_this_vgname, 1)) {
 		ret_max = ret;
diff --git a/tools/vgcfgrestore.c b/tools/vgcfgrestore.c
index e49313d14..9fcba89d4 100644
--- a/tools/vgcfgrestore.c
+++ b/tools/vgcfgrestore.c
@@ -132,7 +132,10 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 
 	clear_hint_file(cmd);
 
-	lvmcache_label_scan(cmd);
+	if (!lvmcache_label_scan(cmd)) {
+		unlock_vg(cmd, NULL, vg_name);
+		return_ECMD_FAILED;
+	}
 
 	cmd->handles_unknown_segments = 1;
 
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index dde3f1eac..14608777f 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -84,7 +84,10 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 
 	cmd->create_edit_devices_file = 1;
 
-	lvmcache_label_scan(cmd);
+	if (!lvmcache_label_scan(cmd)) {
+		unlock_vg(cmd, NULL, vp_new.vg_name);
+		return_ECMD_FAILED;
+	}
 
 	if (lvmcache_vginfo_from_vgname(vp_new.vg_name, NULL)) {
 		unlock_vg(cmd, NULL, vp_new.vg_name);
diff --git a/tools/vgextend.c b/tools/vgextend.c
index 0856b4c78..fecd6bdd5 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -160,7 +160,8 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 
 	cmd->edit_devices_file = 1;
 
-	lvmcache_label_scan(cmd);
+	if (!lvmcache_label_scan(cmd))
+		return_ECMD_FAILED;
 
 	if (!(handle = init_processing_handle(cmd, NULL))) {
 		log_error("Failed to initialize processing handle.");
diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index 08615cd62..4ed4a8f0b 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -72,7 +72,8 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 		return ECMD_FAILED;
 	}
 
-	lvmcache_label_scan(cmd);
+	if (!lvmcache_label_scan(cmd))
+		return_ECMD_FAILED;
 
 	if (strcmp(vg_name_to, vg_name_from) > 0)
 		lock_vg_from_first = 1;
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index a085ac2ba..9d6534e89 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -559,7 +559,8 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
-	lvmcache_label_scan(cmd);
+	if (!lvmcache_label_scan(cmd))
+		return_ECMD_FAILED;
 
 	if (!(vginfo_to = lvmcache_vginfo_from_vgname(vg_name_to, NULL))) {
 		if (!validate_name(vg_name_to)) {


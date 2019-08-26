From: David Teigland <teigland@sourceware.org>
Date: Mon, 26 Aug 2019 17:26:28 -0400
Subject: stable-2.02 - pvscan: avoid redundant activation
Message-ID: <201908262126.x7QLQSGs021481@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8bcd482cc5fc58c9d5ff5305f1f1bff5d80eaa92
Commit:        8bcd482cc5fc58c9d5ff5305f1f1bff5d80eaa92
Parent:        93de9b59c21e6a3b29ccaa6425fde50a9053bdc2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Aug 19 14:22:01 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Aug 26 16:25:18 2019 -0500

pvscan: avoid redundant activation

Use temp files in /run/lvm/vgs_online/ to keep track of when
a VG has been autoactivated by pvscan.  When pvscan autoactivates
a VG, it creates a temp file with the VG's name.  Before a
subsequent pvscan tries to autoactivate the same VG, it checks
if a temp file exists for the VG name, and if so it skips it.

This can commonly happen when many devices appear on the system
at once, which generates several concurrent pvscans.  In this case
the first pvscan does initialization by scanning all devices and
activating any complete VGs.  The other pvscans would attempt to
activate the same complete VGs again.  This extra work could
create a bottleneck of pvscan commands.

If a VG is deactivated by vgchange, the vg online file is removed.
If PVs are then disconnected/reconnected, pvscan will again
autoactivate the VG.

Also, this patch disables the VG refresh that could be called from
pvscan --cache -aay if lvmetad detects metadata inconsistencies.
The role of pvscan should be limited to basic autoactivation, and
any refresh scenarios are special cases that are not appropriate
for automation.

The warning printed by commands retrying an lvmetad connection
has been reduced to once every 10 seconds.  New output messages
have been added to pvscan to record when pvscan is falling back
to direct activation of all VGs.
---
 lib/cache/lvmetad.c |   11 +++--
 tools/pvscan.c      |  108 ++++++++++++++++++++++++++++++++++++++++++++++++--
 tools/vgchange.c    |   13 ++++++
 3 files changed, 123 insertions(+), 9 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 86a880a..d7e798d 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -248,7 +248,7 @@ int lvmetad_token_matches(struct cmd_context *cmd)
 	const char *daemon_token;
 	unsigned int delay_usec = 0;
 	unsigned int wait_sec = 0;
-	uint64_t now = 0, wait_start = 0;
+	uint64_t now = 0, wait_start = 0, last_warn = 0;
 	int ret = 1;
 
 	wait_sec = (unsigned int)_lvmetad_update_timeout;
@@ -294,12 +294,15 @@ retry:
 			wait_start = now;
 
 		if (now - wait_start > wait_sec) {
-			log_warn("WARNING: Not using lvmetad after %u sec lvmetad_update_wait_time.", wait_sec);
+			log_warn("pvscan[%d] WARNING: Not using lvmetad after %u sec lvmetad_update_wait_time.", getpid(), wait_sec);
 			goto fail;
 		}
 
-		log_warn("WARNING: lvmetad is being updated, retrying (setup) for %u more seconds.",
-			 wait_sec - (unsigned int)(now - wait_start));
+		if (now - last_warn >= 10) {
+			last_warn = now;
+			log_warn("pvscan[%d] WARNING: lvmetad is being updated, retrying (setup) for %u more seconds.",
+				 getpid(), wait_sec - (unsigned int)(now - wait_start));
+		}
 
 		/* Delay a random period between 1 and 2 seconds. */
 		delay_usec = 1000000 + lvm_even_rand(&_lvmetad_cmd->rand_seed, 1000000);
diff --git a/tools/pvscan.c b/tools/pvscan.c
index daac88f..c21845c 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -18,8 +18,13 @@
 #include "lvmetad.h"
 #include "lvmcache.h"
 
+#include <dirent.h>
+#include <sys/file.h>
+
 extern int use_full_md_check;
 
+void online_vg_file_remove(const char *vgname);
+
 struct pvscan_params {
 	int new_pvs_found;
 	int pvs_found;
@@ -142,6 +147,82 @@ static int _lvmetad_clear_dev(dev_t devno, int32_t major, int32_t minor)
 	return 1;
 }
 
+static const char *_vgs_online_dir = DEFAULT_RUN_DIR "/vgs_online";
+
+static void _online_dir_setup(void)
+{
+	struct stat st;
+	int rv;
+
+	if (!stat(DEFAULT_RUN_DIR, &st))
+		goto do_vgs;
+
+	log_debug("Creating run_dir.");
+	dm_prepare_selinux_context(DEFAULT_RUN_DIR, S_IFDIR);
+	rv = mkdir(DEFAULT_RUN_DIR, 0755);
+	dm_prepare_selinux_context(NULL, 0);
+
+	if ((rv < 0) && stat(DEFAULT_RUN_DIR, &st))
+		log_error("Failed to create %s %d", DEFAULT_RUN_DIR, errno);
+
+do_vgs:
+	if (!stat(_vgs_online_dir, &st))
+		return;
+
+	log_debug("Creating vgs_online_dir.");
+	dm_prepare_selinux_context(_vgs_online_dir, S_IFDIR);
+	rv = mkdir(_vgs_online_dir, 0755);
+	dm_prepare_selinux_context(NULL, 0);
+
+	if ((rv < 0) && stat(_vgs_online_dir, &st))
+		log_error("Failed to create %s %d", _vgs_online_dir, errno);
+}
+
+static int _online_vg_file_create(struct cmd_context *cmd, const char *vgname)
+{
+	char path[PATH_MAX];
+	int fd;
+
+	if (dm_snprintf(path, sizeof(path), "%s/%s", _vgs_online_dir, vgname) < 0) {
+		log_error("Path %s/%s is too long.", _vgs_online_dir, vgname);
+		return 0;
+	}
+
+	log_debug("Create vg online: %s", path);
+
+	fd = open(path, O_CREAT | O_EXCL | O_TRUNC | O_RDWR, S_IRUSR | S_IWUSR);
+	if (fd < 0) {
+		log_debug("Failed to create %s: %d", path, errno);
+		return 0;
+	}
+
+	/* We don't care about syncing, these files are not even persistent. */
+
+	if (close(fd))
+		log_sys_debug("close", path);
+
+	return 1;
+}
+
+void online_vg_file_remove(const char *vgname)
+{
+	char path[PATH_MAX];
+
+	if (dm_snprintf(path, sizeof(path), "%s/%s", _vgs_online_dir, vgname) < 0) {
+		log_error("Path %s/%s is too long.", _vgs_online_dir, vgname);
+		return;
+	}
+
+	log_debug("Unlink vg online: %s", path);
+
+	/*
+	 * There will only be an online file for the vg if it was
+	 * autoactivated, so in many cases there will not be one.
+	 */
+
+	unlink(path);
+}
+
 /*
  * pvscan --cache does not perform any lvmlockd locking, and
  * pvscan --cache -aay skips autoactivation in lockd VGs.
@@ -190,8 +271,6 @@ static int _pvscan_autoactivate_single(struct cmd_context *cmd, const char *vg_n
 				       struct volume_group *vg, struct processing_handle *handle)
 {
 	struct pvscan_aa_params *pp = (struct pvscan_aa_params *)handle->custom_handle;
-	unsigned int refresh_retries = REFRESH_BEFORE_AUTOACTIVATION_RETRIES;
-	int refresh_done = 0;
 
 	if (vg_is_clustered(vg))
 		return ECMD_PROCESSED;
@@ -204,6 +283,10 @@ static int _pvscan_autoactivate_single(struct cmd_context *cmd, const char *vg_n
 
 	log_debug("pvscan autoactivating VG %s.", vg_name);
 
+#if 0
+	unsigned int refresh_retries = REFRESH_BEFORE_AUTOACTIVATION_RETRIES;
+	int refresh_done = 0;
+
 	/*
 	 * Refresh LVs in a VG that has "changed" from finding a PV.
 	 * The meaning of "changed" is determined in lvmetad, and is
@@ -241,8 +324,14 @@ static int _pvscan_autoactivate_single(struct cmd_context *cmd, const char *vg_n
 		if (!refresh_done)
 			log_warn("%s: refresh before autoactivation failed.", vg->name);
 	}
+#endif
 
-	log_debug_activation("Autoactivating VG %s.", vg_name);
+	if (!_online_vg_file_create(cmd, vg->name)) {
+		log_print("pvscan[%d] VG %s skip autoactivation.", getpid(), vg->name);
+		return ECMD_PROCESSED;
+	}
+
+	log_print("pvscan[%d] VG %s run autoactivation.", getpid(), vg->name);
 
 	if (!vgchange_activate(cmd, vg, CHANGE_AAY)) {
 		log_error("%s: autoactivation failed.", vg->name);
@@ -307,6 +396,7 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 	struct dev_iter *iter;
 	const char *pv_name;
 	const char *reason = NULL;
+	const char *dev_arg = NULL;
 	int32_t major = -1;
 	int32_t minor = -1;
 	int devno_args = 0;
@@ -346,7 +436,12 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 		log_error("Both --major and --minor required to identify devices.");
 		return EINVALID_CMD_LINE;
 	}
-	
+
+	if (!devno_args && argc)
+		dev_arg = *argv;
+
+	_online_dir_setup();
+
 	if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_READ, NULL)) {
 		log_error("Unable to obtain global lock.");
 		return ECMD_FAILED;
@@ -358,7 +453,7 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 	 * still activate LVs even though it's not updating the cache.
 	 */
 	if (do_activate && !lvmetad_used()) {
-		log_verbose("Activating all VGs without lvmetad.");
+		log_print("pvscan[%d] activating all directly (lvmetad unused) %s", getpid(), dev_arg ?: "");
 		all_vgs = 1;
 		devno_args = 0;
 		goto activate;
@@ -399,6 +494,7 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 			log_warn("WARNING: Not using lvmetad because %s.", reason);
 			lvmetad_make_unused(cmd);
 		}
+		log_print("pvscan[%d] activating all directly (lvmetad token) %s", getpid(), dev_arg ?: "");
 		all_vgs = 1;
 		goto activate;
 	}
@@ -415,6 +511,7 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 	if (lvmetad_is_disabled(cmd, &reason)) {
 		log_warn("WARNING: Not using lvmetad because %s.", reason);
 		lvmetad_make_unused(cmd);
+		log_print("pvscan[%d] activating all directly (lvmetad disabled) %s", getpid(), dev_arg ?: "");
 		all_vgs = 1;
 		goto activate;
 	}
@@ -610,6 +707,7 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 	 */
 	if (lvmetad_used() && lvmetad_is_disabled(cmd, &reason)) {
 		log_warn("WARNING: Not using lvmetad because %s.", reason);
+		log_print("pvscan[%d] activating directly (lvmetad disabled in scan) %s", getpid(), dev_arg ?: "");
 		lvmetad_make_unused(cmd);
 	}
 
diff --git a/tools/vgchange.c b/tools/vgchange.c
index e15fca7..52abc11 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -20,6 +20,8 @@ struct vgchange_params {
 	unsigned int lock_start_sanlock : 1;
 };
 
+extern void online_vg_file_remove(const char *vgname);
+
 /*
  * Increments *count by the number of _new_ monitored devices.
  */
@@ -259,6 +261,17 @@ int vgchange_activate(struct cmd_context *cmd, struct volume_group *vg,
 		r = 0;
 	}
 
+	if (!do_activate && r) {
+		/*
+		 * While the VG is inactive, the PVs may go offline.
+		 * If the PVs then come back online, pvscan --cache -aay
+		 * which should autoactivate the VG again.  We need
+		 * to remove the vg online file in order for the pvscan
+		 * to autoactivate the VG again.
+		 */
+		online_vg_file_remove(vg->name);
+	}
+
 	/* Print message only if there was not found a missing VG */
 	log_print_unless_silent("%d logical volume(s) in volume group \"%s\" now active",
 				lvs_in_vg_activated(vg), vg->name);



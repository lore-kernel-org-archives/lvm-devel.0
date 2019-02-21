From: David Teigland <teigland@sourceware.org>
Date: Thu, 21 Feb 2019 16:31:50 -0500
Subject: master - pvscan: fix autoactivation from concurrent pvscans
Message-ID: <201902212131.x1LLVosA001227@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f0089472e7fd679acbc004daf4b35e9a86fc11a9
Commit:        f0089472e7fd679acbc004daf4b35e9a86fc11a9
Parent:        71a302effe82f1cc89f0b26b358493cfaaed7de7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 13 13:35:24 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 20 16:33:59 2019 -0600

pvscan: fix autoactivation from concurrent pvscans

Use a file lock to ensure that only one pvscan will do
initialization of pvs_online, otherwise multiple concurrent
pvscans may all see an empty pvs_online directory and
do initialization.

The pvscan that is doing initialization should also only
attempt to activate complete VGs.
---
 tools/pvscan.c |  144 ++++++++++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 120 insertions(+), 24 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 55b6f5f..5928f7e 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -20,6 +20,7 @@
 #include "lib/label/hints.h"
 
 #include <dirent.h>
+#include <sys/file.h>
 
 struct pvscan_params {
 	int new_pvs_found;
@@ -33,10 +34,61 @@ struct pvscan_params {
 };
 
 struct pvscan_aa_params {
-	int refresh_all;
 	unsigned int activate_errors;
 };
 
+static const char *_online_file = DEFAULT_RUN_DIR "/pvs_online_lock";
+static int _online_fd = -1;
+
+static int _lock_online(int mode, int nonblock)
+{
+	int fd;
+	int op = mode;
+	int ret;
+
+	if (nonblock)
+		op |= LOCK_NB;
+
+	if (_online_fd != -1) {
+		log_warn("lock_online existing fd %d", _online_fd);
+		return 0;
+	}
+
+	fd = open(_online_file, O_RDWR | S_IRUSR | S_IWUSR);
+	if (fd < 0) {
+		log_debug("lock_online open errno %d", errno);
+		return 0;
+	}
+
+	ret = flock(fd, op);
+	if (!ret) {
+		_online_fd = fd;
+		return 1;
+	}
+
+	if (close(fd))
+		stack;
+	return 0;
+}
+
+static void _unlock_online(void)
+{
+	int ret;
+
+	if (_online_fd == -1) {
+		log_warn("unlock_online no existing fd");
+		return;
+	}
+
+	ret = flock(_online_fd, LOCK_UN);
+	if (ret)
+		log_warn("unlock_online flock errno %d", errno);
+
+	if (close(_online_fd))
+		stack;
+	_online_fd = -1;
+}
+
 static int _pvscan_display_pv(struct cmd_context *cmd,
 				  struct physical_volume *pv,
 				  struct pvscan_params *params)
@@ -344,6 +396,20 @@ static void _online_pvid_dir_setup(void)
 		log_debug("Failed to create %s", _pvs_online_dir);
 }
 
+static void _online_file_setup(void)
+{
+	FILE *fp;
+	struct stat st;
+
+	if (!stat(_online_file, &st))
+		return;
+
+	if (!(fp = fopen(_online_file, "w")))
+		return;
+	if (fclose(fp))
+		stack;
+}
+
 static int _online_pvid_files_missing(void)
 {
 	DIR *dir;
@@ -587,12 +653,12 @@ static int _pvscan_aa_single(struct cmd_context *cmd, const char *vg_name,
 }
 
 static int _pvscan_aa(struct cmd_context *cmd, struct pvscan_aa_params *pp,
-		      int all_vgs, struct dm_list *vgnames)
+		      struct dm_list *vgnames)
 {
 	struct processing_handle *handle = NULL;
 	int ret;
 
-	if (!all_vgs && dm_list_empty(vgnames)) {
+	if (dm_list_empty(vgnames)) {
 		log_debug("No VGs to autoactivate.");
 		return ECMD_PROCESSED;
 	}
@@ -604,11 +670,6 @@ static int _pvscan_aa(struct cmd_context *cmd, struct pvscan_aa_params *pp,
 
 	handle->custom_handle = pp;
 
-	if (all_vgs) {
-		cmd->cname->flags |= ALL_VGS_IS_DEFAULT;
-		pp->refresh_all = 1;
-	}
-
 	ret = process_each_vg(cmd, 0, NULL, NULL, vgnames, READ_FOR_UPDATE, 0, handle, _pvscan_aa_single);
 
 	destroy_processing_handle(cmd, handle);
@@ -620,7 +681,8 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct pvscan_aa_params pp = { 0 };
 	struct dm_list single_devs;
-	struct dm_list found_vgnames;
+	struct dm_list vgnames;
+	struct dm_list *complete_vgnames = NULL;
 	struct device *dev;
 	struct device_list *devl;
 	const char *pv_name;
@@ -631,13 +693,15 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 	struct arg_value_group_list *current_group;
 	dev_t devno;
 	int do_activate = arg_is_set(cmd, activate_ARG);
-	int all_vgs = 0;
 	int add_errors = 0;
 	int add_single_count = 0;
 	int ret = ECMD_PROCESSED;
 
 	dm_list_init(&single_devs);
-	dm_list_init(&found_vgnames);
+	dm_list_init(&vgnames);
+
+	if (do_activate)
+		complete_vgnames = &vgnames;
 
 	if (arg_is_set(cmd, major_ARG) + arg_is_set(cmd, minor_ARG))
 		devno_args = 1;
@@ -648,6 +712,7 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	_online_pvid_dir_setup();
+	_online_file_setup();
 	
 	if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_READ, NULL)) {
 		log_error("Unable to obtain global lock.");
@@ -667,22 +732,53 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 		cmd->pvscan_recreate_hints = 1;
 		pvscan_recreate_hints_begin(cmd);
 
-		log_verbose("pvscan all devices.");
+		_lock_online(LOCK_EX, 0);
+		log_verbose("pvscan all devices for requested refresh.");
 		_online_pvid_files_remove();
-		_online_pvscan_all_devs(cmd, NULL, NULL);
-		all_vgs = 1;
-
-		cmd->pvscan_recreate_hints = 0;
-		cmd->use_hints = 0;
+		/* identify complete vgs, and only activate those vgs */
+		_online_pvscan_all_devs(cmd, complete_vgnames, NULL);
+		_unlock_online();
 		goto activate;
 	}
 
+	/*
+	 * Initialization case:
+	 * lock_online ex
+	 * if empty
+	 * pvscan all
+	 * create pvid files
+	 * identify complete vgs
+	 * unlock_online
+	 * activate complete vgs
+	 *
+	 * Non-initialization case:
+	 * lock_online ex
+	 * if not empty
+	 * unlock_unlock
+	 * pvscan devs
+	 * create pvid files
+	 * identify complete vgs
+	 * activate complete vgs
+	 *
+	 * In the non-init case, a VG with two PVs, where both PVs appear at once,
+	 * two parallel pvscans for each PV create the pvid files for each PV in
+	 * parallel, then both pvscans see the vg has completed, and both pvscans
+	 * activate the VG in parallel.  The activations should be serialized by
+	 * the VG lock.
+	 */
+
+	_lock_online(LOCK_EX, 0);
+
 	if (_online_pvid_files_missing()) {
 		log_verbose("pvscan all devices to initialize available PVs.");
 		_online_pvid_files_remove();
-		_online_pvscan_all_devs(cmd, NULL, NULL);
-		all_vgs = 1;
+		/* identify complete vgs, and only activate those vgs */
+		_online_pvscan_all_devs(cmd, complete_vgnames, NULL);
+		_unlock_online();
 		goto activate;
+	} else {
+		log_verbose("pvscan only specific devices.");
+		_unlock_online();
 	}
 
 	if (argc || devno_args) {
@@ -761,7 +857,7 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 			 * Devices that exist and pass the lvmetad filter
 			 * are online.
 			 */
-			if (!_online_pvscan_one(cmd, dev, NULL, &found_vgnames, 0, &pvid_without_metadata))
+			if (!_online_pvscan_one(cmd, dev, NULL, complete_vgnames, 0, &pvid_without_metadata))
 				add_errors++;
 		}
 	}
@@ -814,7 +910,7 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 			 * Devices that exist and pass the lvmetad filter
 			 * are online.
 			 */
-			if (!_online_pvscan_one(cmd, devl->dev, NULL, &found_vgnames, 0, &pvid_without_metadata))
+			if (!_online_pvscan_one(cmd, devl->dev, NULL, complete_vgnames, 0, &pvid_without_metadata))
 				add_errors++;
 		}
 	}
@@ -839,10 +935,10 @@ activate:
 	 * scan all devs and pick out the complete VG holding this
 	 * device so we can then autoactivate that VG.
 	 */
-	if (!dm_list_empty(&single_devs) && dm_list_empty(&found_vgnames) &&
+	if (!dm_list_empty(&single_devs) && complete_vgnames && dm_list_empty(complete_vgnames) &&
 	    pvid_without_metadata && do_activate) {
 		log_verbose("pvscan all devices for PV without metadata: %s.", pvid_without_metadata);
-		_online_pvscan_all_devs(cmd, &found_vgnames, &single_devs);
+		_online_pvscan_all_devs(cmd, complete_vgnames, &single_devs);
 	}
 
 	/*
@@ -851,7 +947,7 @@ activate:
 	 * list, and we can attempt to autoactivate LVs in the VG.
 	 */
 	if (do_activate)
-		ret = _pvscan_aa(cmd, &pp, all_vgs, &found_vgnames);
+		ret = _pvscan_aa(cmd, &pp, complete_vgnames);
 
 out:
 	if (add_errors || pp.activate_errors)



From: David Teigland <teigland@sourceware.org>
Date: Mon, 8 Apr 2019 11:39:37 -0400
Subject: master - pvscan: remove initialization case
Message-ID: <201904081539.x38FdbJj023007@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0ba316f102ac3fcea48a6e60dfb8c0ddef8d197e
Commit:        0ba316f102ac3fcea48a6e60dfb8c0ddef8d197e
Parent:        6b89c0d4b78d11b50328a6df73234524699eabb1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 26 16:48:29 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 5 14:04:02 2019 -0500

pvscan: remove initialization case

In the past, the first 'pvscan --cache -aay dev' command
to run on the system would initialize the pvs_online dir
by scanning all devs and creating online files for all pvs
it found, and then autoactivating the VG (if complete) for
the named dev.  The idea was that the system may not have
been able to run pvscan commands for early devices, so the
first pvscan to run would need to "make up" for any devices
that had appeared previously, which the system was unable to
scan.  The problem or idea of making up for missed scans is
historical and should no longer be needed, so remove this
special init case.
---
 tools/pvscan.c |  128 --------------------------------------------------------
 1 files changed, 0 insertions(+), 128 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 74e0b96..e3fd53a 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -40,57 +40,6 @@ struct pvscan_aa_params {
 
 static const char *_pvs_online_dir = DEFAULT_RUN_DIR "/pvs_online";
 static const char *_vgs_online_dir = DEFAULT_RUN_DIR "/vgs_online";
-static const char *_online_file = DEFAULT_RUN_DIR "/pvs_online_lock";
-static int _online_fd = -1;
-
-static int _lock_online(int mode, int nonblock)
-{
-	int fd;
-	int op = mode;
-	int ret;
-
-	if (nonblock)
-		op |= LOCK_NB;
-
-	if (_online_fd != -1) {
-		log_warn("lock_online existing fd %d", _online_fd);
-		return 0;
-	}
-
-	fd = open(_online_file, O_RDWR | S_IRUSR | S_IWUSR);
-	if (fd < 0) {
-		log_debug("lock_online open errno %d", errno);
-		return 0;
-	}
-
-	ret = flock(fd, op);
-	if (!ret) {
-		_online_fd = fd;
-		return 1;
-	}
-
-	if (close(fd))
-		stack;
-	return 0;
-}
-
-static void _unlock_online(void)
-{
-	int ret;
-
-	if (_online_fd == -1) {
-		log_warn("unlock_online no existing fd");
-		return;
-	}
-
-	ret = flock(_online_fd, LOCK_UN);
-	if (ret)
-		log_warn("unlock_online flock errno %d", errno);
-
-	if (close(_online_fd))
-		stack;
-	_online_fd = -1;
-}
 
 static int _pvscan_display_pv(struct cmd_context *cmd,
 				  struct physical_volume *pv,
@@ -492,44 +441,6 @@ do_vgs:
 		log_error("Failed to create %s %d", _vgs_online_dir, errno);
 }
 
-static void _online_file_setup(void)
-{
-	FILE *fp;
-	struct stat st;
-
-	if (!stat(_online_file, &st))
-		return;
-
-	if (!(fp = fopen(_online_file, "w"))) {
-		log_error("Failed to create %s %d", _online_file, errno);
-		return;
-	}
-	if (fclose(fp))
-		stack;
-}
-
-static int _online_pvid_files_missing(void)
-{
-	DIR *dir;
-	struct dirent *de;
-
-	if (!(dir = opendir(_pvs_online_dir))) {
-		log_debug("Failed to open %s", _pvs_online_dir);
-		return 1;
-	}
-
-	while ((de = readdir(dir))) {
-		if (de->d_name[0] == '.')
-			continue;
-		if (closedir(dir))
-			log_sys_debug("closedir", _pvs_online_dir);
-		return 0;
-	}
-	if (closedir(dir))
-		log_sys_debug("closedir", _pvs_online_dir);
-	return 1;
-}
-
 static int _online_pv_found(struct cmd_context *cmd,
 			    struct device *dev, struct dm_list *dev_args,
 			    struct volume_group *vg,
@@ -908,7 +819,6 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	_online_dir_setup();
-	_online_file_setup();
 
 	/* Creates a list of dev names from /dev, sysfs, etc; does not read any. */
 	dev_cache_scan();
@@ -1024,54 +934,16 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 		cmd->pvscan_recreate_hints = 1;
 		pvscan_recreate_hints_begin(cmd);
 
-		_lock_online(LOCK_EX, 0);
 		log_verbose("pvscan all devices for requested refresh.");
 		_online_files_remove(_pvs_online_dir);
 		_online_files_remove(_vgs_online_dir);
 		_online_pvscan_all_devs(cmd, complete_vgnames, NULL);
-		_unlock_online();
 
 		cmd->pvscan_recreate_hints = 0;
 		cmd->use_hints = 0;
 		goto activate;
 	}
 
-	/*
-	 * Initialization case:
-	 * lock_online ex
-	 * if empty
-	 * pvscan all
-	 * create pvid files
-	 * identify complete vgs
-	 * unlock_online
-	 * activate complete vgs
-	 *
-	 * Non-initialization case:
-	 * lock_online ex
-	 * if not empty
-	 * unlock_unlock
-	 * pvscan devs
-	 * create pvid files
-	 * identify complete vgs
-	 * activate complete vgs
-	 *
-	 * In the non-init case, a VG with two PVs, where both PVs appear at once,
-	 * two parallel pvscans for each PV create the pvid files for each PV in
-	 * parallel, then both pvscans see the vg has completed, and both pvscans
-	 * activate the VG in parallel.  The first pvscan to create the vgname
-	 * file in vgs_online will do the activation, any others will skip it.
-	 */
-
-	_lock_online(LOCK_EX, 0);
-
-	if (_online_pvid_files_missing()) {
-		log_verbose("pvscan all devices to initialize available PVs.");
-		_online_pvscan_all_devs(cmd, complete_vgnames, &add_devs);
-		_unlock_online();
-		goto activate;
-	}
-
-	_unlock_online();
 	log_verbose("pvscan only specific devices add %d rem %d.",
 		    dm_list_size(&add_devs), dm_list_size(&rem_devs));
 



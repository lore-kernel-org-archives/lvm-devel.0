From: David Teigland <teigland@sourceware.org>
Date: Fri, 20 Aug 2021 19:51:32 +0000 (GMT)
Subject: main - devices: apply ignorelockingfailure to devices file lock
Message-ID: <20210820195132.E4845385801E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6cd4470e6d88047ceefd4ecaaf00384d85dd2dad
Commit:        6cd4470e6d88047ceefd4ecaaf00384d85dd2dad
Parent:        4df6931c4cb49af27aa5298b95736a53e83860a9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Aug 19 12:57:31 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Aug 20 14:07:00 2021 -0500

devices: apply ignorelockingfailure to devices file lock

---
 lib/commands/toolcontext.h | 1 +
 lib/device/device_id.c     | 4 ++--
 tools/lvmcmdline.c         | 4 +++-
 3 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index a19a9dea2..8f11a7714 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -193,6 +193,7 @@ struct cmd_context {
 	unsigned filter_nodata_only:1;          /* only use filters that do not require data from the dev */
 	unsigned run_by_dmeventd:1;		/* command is being run by dmeventd */
 	unsigned sysinit:1;			/* --sysinit is used */
+	unsigned ignorelockingfailure:1;	/* --ignorelockingfailure is used */
 	unsigned check_devs_used:1;		/* check devs used by LVs */
 	unsigned print_device_id_not_found:1;	/* print devices file entries not found */
 	unsigned ignore_device_name_mismatch:1; /* skip updating devices file names */
diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index bca6b4f1f..391309ccd 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -2268,7 +2268,7 @@ static int _lock_devices_file(struct cmd_context *cmd, int mode, int nonblock, i
 	fd = open(_devices_lockfile, O_CREAT|O_RDWR, S_IRUSR | S_IWUSR);
 	if (fd < 0) {
 		log_debug("lock_devices_file open errno %d", errno);
-		if (cmd->sysinit)
+		if (cmd->sysinit || cmd->ignorelockingfailure)
 			return 1;
 		return 0;
 	}
@@ -2284,7 +2284,7 @@ static int _lock_devices_file(struct cmd_context *cmd, int mode, int nonblock, i
 
 	if (close(fd))
 		stack;
-	if (cmd->sysinit)
+	if (cmd->sysinit || cmd->ignorelockingfailure)
 		return 1;
 	return 0;
 }
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 47ab2f3d8..12105423c 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -3190,6 +3190,8 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		goto out;
 	}
 
+	cmd->ignorelockingfailure = arg_is_set(cmd, ignorelockingfailure_ARG);
+
 	/* Defaults to 1 if not set. */
 	locking_type = find_config_tree_int(cmd, global_locking_type_CFG, NULL);
 
@@ -3224,7 +3226,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		if (!_cmd_no_meta_proc(cmd))
 			log_warn("WARNING: File locking is disabled.");
 	} else {
-		if (!init_locking(cmd, sysinit, readonly, arg_is_set(cmd, ignorelockingfailure_ARG))) {
+		if (!init_locking(cmd, sysinit, readonly, cmd->ignorelockingfailure)) {
 			ret = ECMD_FAILED;
 			goto_out;
 		}



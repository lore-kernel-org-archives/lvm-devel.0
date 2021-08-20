From: David Teigland <teigland@sourceware.org>
Date: Fri, 20 Aug 2021 19:51:35 +0000 (GMT)
Subject: main - devices file: recognize old locking_type 0
Message-ID: <20210820195135.39B963858024@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8b723139363a6b55e57ba4e9d599ff2efbae7d23
Commit:        8b723139363a6b55e57ba4e9d599ff2efbae7d23
Parent:        9e79a022ea391a3cfb9e9f95f10ecfe7a277e794
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Aug 20 10:32:16 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Aug 20 14:51:13 2021 -0500

devices file: recognize old locking_type 0

if the old locking_type is 0, set cmd->nolocking so that
it will be applied to the devices file lock.
---
 tools/lvmcmdline.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 12105423c..27c41412d 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -3026,7 +3026,6 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	struct dm_config_tree *config_string_cft, *config_profile_command_cft, *config_profile_metadata_cft;
 	int ret = 0;
 	int locking_type;
-	int nolocking = 0;
 	int readonly = 0;
 	int sysinit = 0;
 	int monitoring;
@@ -3191,6 +3190,10 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	cmd->ignorelockingfailure = arg_is_set(cmd, ignorelockingfailure_ARG);
+	cmd->nolocking = arg_is_set(cmd, nolocking_ARG);
+
+	if (_cmd_no_meta_proc(cmd))
+		cmd->nolocking = 1;
 
 	/* Defaults to 1 if not set. */
 	locking_type = find_config_tree_int(cmd, global_locking_type_CFG, NULL);
@@ -3200,7 +3203,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 
 	if ((locking_type == 0) || (locking_type == 5)) {
 		log_warn("WARNING: locking_type (%d) is deprecated, using --nolocking.", locking_type);
-		nolocking = 1;
+		cmd->nolocking = 1;
 
 	} else if (locking_type == 4) {
 		log_warn("WARNING: locking_type (%d) is deprecated, using --sysinit --readonly.", locking_type);
@@ -3211,18 +3214,13 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		log_warn("WARNING: locking_type (%d) is deprecated, using file locking.", locking_type);
 	}
 
-	cmd->nolocking = arg_is_set(cmd, nolocking_ARG);
-
-	if (cmd->nolocking || _cmd_no_meta_proc(cmd))
-		nolocking = 1;
-
 	if ((cmd->sysinit = arg_is_set(cmd, sysinit_ARG)))
 		sysinit = 1;
 
 	if (arg_is_set(cmd, readonly_ARG))
 		readonly = 1;
 
-	if (nolocking) {
+	if (cmd->nolocking) {
 		if (!_cmd_no_meta_proc(cmd))
 			log_warn("WARNING: File locking is disabled.");
 	} else {



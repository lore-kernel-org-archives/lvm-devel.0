From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 26 Feb 2015 22:42:20 +0000 (UTC)
Subject: master - system_id: remove unwanted foreign error for some commands
Message-ID: <20150226224220.49761611C9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0a19238aa30a3a594abaa544c4972c880cefafe1
Commit:        0a19238aa30a3a594abaa544c4972c880cefafe1
Parent:        a432066c7c52f59b1d38fbef3896b3ff0c50100f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 26 16:06:32 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 26 16:33:36 2015 -0600

system_id: remove unwanted foreign error for some commands

Commands that can never use foreign VGs begin with
cmd->error_foreign_vgs = 1.  This tells the vg_read
lib layer to print an error as soon as a foreign VG
is read.

The toollib process_each layer also prints an error if a
foreign VG is read, but is more selective about it.  It
won't print an error if the command did not explicitly
name the foreign VG.  We want to silently ignore foreign VGs
unless a command attempts to use one explicitly.

So, foreign VG errors are printed from two different layers:
vg_read (lower layer) and process_each (upper layer).

Commands that use toollib process_each, only want errors from
the process_each layer, not from both layers.  So, process_each
disables the lower layer vg_read error message by setting
error_foreign_vgs = 0.

Commands that do not use toollib process_each, want errors
from the vg_read layer, otherwise they would get no error
message.  The original cmd->error_foreign_vgs setting
enables this error.

(Commands that are allowed to operate on foreign VGs always
begin with cmd->error_foreign_vgs = 0, and all the commands
in this group use toollib process_each with the selective
error reporting.)
---
 tools/toollib.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 8b750d8..7d1c380 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -200,8 +200,8 @@ static int _ignore_vg(struct volume_group *vg, const char *vg_name,
 	 */
 	if (read_error & FAILED_SYSTEMID) {
 		if (arg_vgnames && str_list_match_item(arg_vgnames, vg->name)) {
-			log_error("Skipping volume group %s with system ID %s",
-				  vg->name, vg->system_id ? : vg->lvm1_system_id ? : "");
+			log_error("Cannot access VG %s with system id \"%s\" with local system ID %s.",
+				  vg->name, vg->system_id, vg->cmd->system_id);
 			return 1;
 		} else {
 			read_error &= ~FAILED_SYSTEMID; /* Check for other errors */
@@ -1877,6 +1877,8 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 	unsigned one_vgname_arg = (flags & ONE_VGNAME_ARG);
 	int ret;
 
+	cmd->error_foreign_vgs = 0;
+
 	dm_list_init(&arg_tags);
 	dm_list_init(&arg_vgnames);
 	dm_list_init(&vgnameids_on_system);
@@ -2277,6 +2279,8 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv, uint32_t fla
 	int enable_all_vgs = (cmd->command->flags & ALL_VGS_IS_DEFAULT);
 	int ret;
 
+	cmd->error_foreign_vgs = 0;
+
 	dm_list_init(&arg_tags);
 	dm_list_init(&arg_vgnames);
 	dm_list_init(&arg_lvnames);
@@ -2761,6 +2765,8 @@ int process_each_pv(struct cmd_context *cmd,
 	int ret_max = ECMD_PROCESSED;
 	int ret;
 
+	cmd->error_foreign_vgs = 0;
+
 	dm_list_init(&arg_tags);
 	dm_list_init(&arg_pvnames);
 	dm_list_init(&arg_devices);



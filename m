From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 27 Aug 2010 14:53:18 +0200
Subject: [PATCH] Reinitialize backup settings on toolcontext refresh
Message-ID: <4C77B53E.2060707@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This seems to be pretty obvious, but sending it here for a quick check
if anyone sees a problem with this I can't see :)

For example, the bug appears when somone uses '--config "backup { ... }"'.
The values from lvm.conf (or default values) should be overridden but
they're not.

Peter
---
 lib/commands/toolcontext.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 0cf5b8c..20e91b5 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1055,6 +1055,7 @@ static int _init_backup(struct cmd_context *cmd)
 	dir = find_config_tree_str(cmd, "backup/archive_dir",
 			      default_dir);
 
+	archive_exit(cmd);
 	if (!archive_init(cmd, dir, days, min,
 			  cmd->default_settings.archive)) {
 		log_debug("archive_init failed.");
@@ -1076,6 +1077,7 @@ static int _init_backup(struct cmd_context *cmd)
 
 	dir = find_config_tree_str(cmd, "backup/backup_dir", default_dir);
 
+	backup_exit(cmd);
 	if (!backup_init(cmd, dir, cmd->default_settings.backup)) {
 		log_debug("backup_init failed.");
 		return 0;
@@ -1343,6 +1345,9 @@ int refresh_toolcontext(struct cmd_context *cmd)
 	if (!_init_segtypes(cmd))
 		return 0;
 
+	if (!_init_backup(cmd))
+		return 0;
+
 	cmd->config_valid = 1;
 
 	reset_lvm_errno(1);



From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 10 Dec 2008 13:10:51 -0500
Subject: [PATCH 01/11] Replace _apply_settings() after create_toolcontext() with equivalent inline.
Message-ID: <1228932661-15662-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Subsequent patches will refactor / remove each of these lines, as many of
them are redundant when called immediately after create_toolcontext().

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/lvmcmdline.c |   18 +++++++++++++++++-
 1 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 29b4c15..37ae834 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1091,7 +1091,23 @@ struct cmd_context *init_lvm(unsigned is_static)
 	if (!(cmd = create_toolcontext(_cmdline.the_args, is_static, 0)))
 		return_NULL;
 
-	_apply_settings(cmd);
+	init_debug(cmd->current_settings.debug);
+	init_verbose(cmd->current_settings.verbose + VERBOSE_BASE_LEVEL);
+	init_test(cmd->current_settings.test);
+	init_full_scan_done(0);
+	init_mirror_in_sync(0);
+
+	init_msg_prefix(cmd->default_settings.msg_prefix);
+	init_cmd_name(cmd->default_settings.cmd_name);
+
+	archive_enable(cmd, cmd->current_settings.archive);
+	backup_enable(cmd, cmd->current_settings.backup);
+
+	set_activation(cmd->current_settings.activation);
+
+	cmd->fmt = arg_ptr_value(cmd, metadatatype_ARG,
+				 cmd->current_settings.fmt);
+	cmd->handles_missing_pvs = 0;
 
 	return cmd;
 }
-- 
1.5.5.1



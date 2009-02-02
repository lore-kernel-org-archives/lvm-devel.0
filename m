From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon,  2 Feb 2009 15:49:57 -0500
Subject: [PATCH 01/13] Add system_dir to create_toolcontext().
In-Reply-To: <1233607809-1087-1-git-send-email-dwysocha@redhat.com>
References: <1233607809-1087-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1233607809-1087-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Thomas Woerner <twoerner@redhat.com>
Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 daemons/clvmd/lvm-functions.c |    2 +-
 lib/commands/toolcontext.c    |    6 +++++-
 lib/commands/toolcontext.h    |    2 +-
 tools/lvmcmdline.c            |    2 +-
 4 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 5cf7eff..3db2756 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -724,7 +724,7 @@ void lvm_do_backup(const char *vgname)
 /* Called to initialise the LVM context of the daemon */
 int init_lvm(int using_gulm)
 {
-	if (!(cmd = create_toolcontext(1))) {
+	if (!(cmd = create_toolcontext(1, NULL))) {
 		log_error("Failed to allocate command context");
 		return 0;
 	}
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 0a98325..c481a2b 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -998,7 +998,8 @@ static void _init_globals(struct cmd_context *cmd)
 }
 
 /* Entry point */
-struct cmd_context *create_toolcontext(unsigned is_long_lived)
+struct cmd_context *create_toolcontext(unsigned is_long_lived,
+				       const char *system_dir)
 {
 	struct cmd_context *cmd;
 
@@ -1030,6 +1031,9 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived)
 
 	strcpy(cmd->sys_dir, DEFAULT_SYS_DIR);
 
+        if (system_dir)
+                strncpy(cmd->sys_dir, system_dir, PATH_MAX);
+
 	if (!_get_env_vars(cmd))
 		goto error;
 
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 7d2aef9..ba6f1ed 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -94,7 +94,7 @@ struct cmd_context {
 	char sysfs_dir[PATH_MAX];
 };
 
-struct cmd_context *create_toolcontext(unsigned is_long_lived);
+struct cmd_context *create_toolcontext(unsigned is_long_lived, const char *system_dir);
 void destroy_toolcontext(struct cmd_context *cmd);
 int refresh_toolcontext(struct cmd_context *cmd);
 int config_files_changed(struct cmd_context *cmd);
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 0b12750..2dabe64 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1159,7 +1159,7 @@ struct cmd_context *init_lvm(void)
 
 	_cmdline.the_args = &_the_args[0];
 
-	if (!(cmd = create_toolcontext(0)))
+	if (!(cmd = create_toolcontext(0, NULL)))
 		return_NULL;
 
 	return cmd;
-- 
1.5.5.1



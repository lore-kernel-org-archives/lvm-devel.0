From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 17 Dec 2008 11:21:48 -0500
Subject: [PATCH 2/2] Remove struct arg * from struct cmd_context and create_toolcontext().
In-Reply-To: <1229530908-1543-1-git-send-email-dwysocha@redhat.com>
References: <1229530908-1543-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1229530908-1543-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This allows us to remove one argument from create_toolcontext() and
moves it closer to a generic library init function.

In the arg_*() functions, we just use _the_args() directly.
For now we leave the first parameter to these
arg_*() functions (struct cmd_context *) because
of the number of files involved in removing the
parameter.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 daemons/clvmd/lvm-functions.c |    2 +-
 lib/commands/toolcontext.c    |    3 +--
 lib/commands/toolcontext.h    |    3 +--
 tools/lvmcmdline.c            |   25 +++++++++++++------------
 4 files changed, 16 insertions(+), 17 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 8225df6..7250e04 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -724,7 +724,7 @@ void lvm_do_backup(const char *vgname)
 /* Called to initialise the LVM context of the daemon */
 int init_lvm(int using_gulm)
 {
-	if (!(cmd = create_toolcontext(NULL, 0, 1))) {
+	if (!(cmd = create_toolcontext(0, 1))) {
 		log_error("Failed to allocate command context");
 		return 0;
 	}
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 8e31b9d..cda9057 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -998,7 +998,7 @@ static void _init_globals(struct cmd_context *cmd)
 }
 
 /* Entry point */
-struct cmd_context *create_toolcontext(struct arg *the_args, unsigned is_static,
+struct cmd_context *create_toolcontext(unsigned is_static,
 				       unsigned is_long_lived)
 {
 	struct cmd_context *cmd;
@@ -1021,7 +1021,6 @@ struct cmd_context *create_toolcontext(struct arg *the_args, unsigned is_static,
 		return NULL;
 	}
 	memset(cmd, 0, sizeof(*cmd));
-	cmd->args = the_args;
 	cmd->is_static = is_static;
 	cmd->is_long_lived = is_long_lived;
 	cmd->handles_missing_pvs = 0;
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 4ea3486..3c7dfea 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -65,7 +65,6 @@ struct cmd_context {
 	unsigned rand_seed;
 	char *cmd_line;
 	struct command *command;
-	struct arg *args;
 	char **argv;
 	unsigned is_static:1;	/* Static binary? */
 	unsigned is_long_lived:1;	/* Optimises persistent_filter handling */
@@ -96,7 +95,7 @@ struct cmd_context {
 	char sysfs_dir[PATH_MAX];
 };
 
-struct cmd_context *create_toolcontext(struct arg *the_args, unsigned is_static, unsigned is_long_lived);
+struct cmd_context *create_toolcontext(unsigned is_static, unsigned is_long_lived);
 void destroy_toolcontext(struct cmd_context *cmd);
 int refresh_toolcontext(struct cmd_context *cmd);
 int config_files_changed(struct cmd_context *cmd);
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 45191f7..a089651 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -54,59 +54,60 @@ static struct arg _the_args[ARG_COUNT + 1] = {
 static struct cmdline_context _cmdline;
 
 /* Command line args */
+/* FIXME: struct cmd_context * is unnecessary (large # files involved) */
 unsigned arg_count(const struct cmd_context *cmd, int a)
 {
-	return cmd->args[a].count;
+	return _the_args[a].count;
 }
 
 const char *arg_value(struct cmd_context *cmd, int a)
 {
-	return cmd->args[a].value;
+	return _the_args[a].value;
 }
 
 const char *arg_str_value(struct cmd_context *cmd, int a, const char *def)
 {
-	return arg_count(cmd, a) ? cmd->args[a].value : def;
+	return arg_count(cmd, a) ? _the_args[a].value : def;
 }
 
 int32_t arg_int_value(struct cmd_context *cmd, int a, const int32_t def)
 {
-	return arg_count(cmd, a) ? cmd->args[a].i_value : def;
+	return arg_count(cmd, a) ? _the_args[a].i_value : def;
 }
 
 uint32_t arg_uint_value(struct cmd_context *cmd, int a, const uint32_t def)
 {
-	return arg_count(cmd, a) ? cmd->args[a].ui_value : def;
+	return arg_count(cmd, a) ? _the_args[a].ui_value : def;
 }
 
 int64_t arg_int64_value(struct cmd_context *cmd, int a, const int64_t def)
 {
-	return arg_count(cmd, a) ? cmd->args[a].i64_value : def;
+	return arg_count(cmd, a) ? _the_args[a].i64_value : def;
 }
 
 uint64_t arg_uint64_value(struct cmd_context *cmd, int a, const uint64_t def)
 {
-	return arg_count(cmd, a) ? cmd->args[a].ui64_value : def;
+	return arg_count(cmd, a) ? _the_args[a].ui64_value : def;
 }
 
 const void *arg_ptr_value(struct cmd_context *cmd, int a, const void *def)
 {
-	return arg_count(cmd, a) ? cmd->args[a].ptr : def;
+	return arg_count(cmd, a) ? _the_args[a].ptr : def;
 }
 
 sign_t arg_sign_value(struct cmd_context *cmd, int a, const sign_t def)
 {
-	return arg_count(cmd, a) ? cmd->args[a].sign : def;
+	return arg_count(cmd, a) ? _the_args[a].sign : def;
 }
 
 percent_t arg_percent_value(struct cmd_context *cmd, int a, const percent_t def)
 {
-	return arg_count(cmd, a) ? cmd->args[a].percent : def;
+	return arg_count(cmd, a) ? _the_args[a].percent : def;
 }
 
 int arg_count_increment(struct cmd_context *cmd, int a)
 {
-	return cmd->args[a].count++;
+	return _the_args[a].count++;
 }
 
 int yes_no_arg(struct cmd_context *cmd __attribute((unused)), struct arg *a)
@@ -1144,7 +1145,7 @@ struct cmd_context *init_lvm(unsigned is_static)
 
 	_cmdline.the_args = &_the_args[0];
 
-	if (!(cmd = create_toolcontext(_cmdline.the_args, is_static, 0)))
+	if (!(cmd = create_toolcontext(is_static, 0)))
 		return_NULL;
 
 	return cmd;
-- 
1.5.5.1



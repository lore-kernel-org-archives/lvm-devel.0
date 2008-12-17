From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 17 Dec 2008 11:21:47 -0500
Subject: [PATCH 1/2] Move arg_* functions from toollib.c to lvmcmdline.c.
Message-ID: <1229530908-1543-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

In preparation for removing cmd->args.
IMO, it makes more sense to put these accessor functions
in the same location as the static array _the_args.
Next patch will update arg_* functions to use _the_args[]
directly and remove cmd->args.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/lvmcmdline.c |   56 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 tools/toollib.c    |   56 ----------------------------------------------------
 2 files changed, 56 insertions(+), 56 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index e1e9826..45191f7 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -53,6 +53,62 @@ static struct arg _the_args[ARG_COUNT + 1] = {
 
 static struct cmdline_context _cmdline;
 
+/* Command line args */
+unsigned arg_count(const struct cmd_context *cmd, int a)
+{
+	return cmd->args[a].count;
+}
+
+const char *arg_value(struct cmd_context *cmd, int a)
+{
+	return cmd->args[a].value;
+}
+
+const char *arg_str_value(struct cmd_context *cmd, int a, const char *def)
+{
+	return arg_count(cmd, a) ? cmd->args[a].value : def;
+}
+
+int32_t arg_int_value(struct cmd_context *cmd, int a, const int32_t def)
+{
+	return arg_count(cmd, a) ? cmd->args[a].i_value : def;
+}
+
+uint32_t arg_uint_value(struct cmd_context *cmd, int a, const uint32_t def)
+{
+	return arg_count(cmd, a) ? cmd->args[a].ui_value : def;
+}
+
+int64_t arg_int64_value(struct cmd_context *cmd, int a, const int64_t def)
+{
+	return arg_count(cmd, a) ? cmd->args[a].i64_value : def;
+}
+
+uint64_t arg_uint64_value(struct cmd_context *cmd, int a, const uint64_t def)
+{
+	return arg_count(cmd, a) ? cmd->args[a].ui64_value : def;
+}
+
+const void *arg_ptr_value(struct cmd_context *cmd, int a, const void *def)
+{
+	return arg_count(cmd, a) ? cmd->args[a].ptr : def;
+}
+
+sign_t arg_sign_value(struct cmd_context *cmd, int a, const sign_t def)
+{
+	return arg_count(cmd, a) ? cmd->args[a].sign : def;
+}
+
+percent_t arg_percent_value(struct cmd_context *cmd, int a, const percent_t def)
+{
+	return arg_count(cmd, a) ? cmd->args[a].percent : def;
+}
+
+int arg_count_increment(struct cmd_context *cmd, int a)
+{
+	return cmd->args[a].count++;
+}
+
 int yes_no_arg(struct cmd_context *cmd __attribute((unused)), struct arg *a)
 {
 	a->sign = SIGN_NONE;
diff --git a/tools/toollib.c b/tools/toollib.c
index ef4ee0e..511a93f 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -20,62 +20,6 @@
 #include <sys/stat.h>
 #include <sys/wait.h>
 
-/* Command line args */
-unsigned arg_count(const struct cmd_context *cmd, int a)
-{
-	return cmd->args[a].count;
-}
-
-const char *arg_value(struct cmd_context *cmd, int a)
-{
-	return cmd->args[a].value;
-}
-
-const char *arg_str_value(struct cmd_context *cmd, int a, const char *def)
-{
-	return arg_count(cmd, a) ? cmd->args[a].value : def;
-}
-
-int32_t arg_int_value(struct cmd_context *cmd, int a, const int32_t def)
-{
-	return arg_count(cmd, a) ? cmd->args[a].i_value : def;
-}
-
-uint32_t arg_uint_value(struct cmd_context *cmd, int a, const uint32_t def)
-{
-	return arg_count(cmd, a) ? cmd->args[a].ui_value : def;
-}
-
-int64_t arg_int64_value(struct cmd_context *cmd, int a, const int64_t def)
-{
-	return arg_count(cmd, a) ? cmd->args[a].i64_value : def;
-}
-
-uint64_t arg_uint64_value(struct cmd_context *cmd, int a, const uint64_t def)
-{
-	return arg_count(cmd, a) ? cmd->args[a].ui64_value : def;
-}
-
-const void *arg_ptr_value(struct cmd_context *cmd, int a, const void *def)
-{
-	return arg_count(cmd, a) ? cmd->args[a].ptr : def;
-}
-
-sign_t arg_sign_value(struct cmd_context *cmd, int a, const sign_t def)
-{
-	return arg_count(cmd, a) ? cmd->args[a].sign : def;
-}
-
-percent_t arg_percent_value(struct cmd_context *cmd, int a, const percent_t def)
-{
-	return arg_count(cmd, a) ? cmd->args[a].percent : def;
-}
-
-int arg_count_increment(struct cmd_context *cmd, int a)
-{
-	return cmd->args[a].count++;
-}
-
 const char *command_name(struct cmd_context *cmd)
 {
 	return cmd->command->name;
-- 
1.5.5.1



From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 17 Dec 2008 16:45:33 -0000
Subject: LVM2/tools lvmcmdline.c toollib.c
Message-ID: <20081217164533.5778.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-12-17 16:45:32

Modified files:
	tools          : lvmcmdline.c toollib.c 

Log message:
	Move arg_* functions from toollib.c to lvmcmdline.c.
	
	In preparation for removing cmd->args.
	IMO, it makes more sense to put these accessor functions
	in the same location as the static array _the_args.
	Next patch will update arg_* functions to use _the_args[]
	directly and remove cmd->args.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.87&r2=1.88
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.137&r2=1.138

--- LVM2/tools/lvmcmdline.c	2008/12/12 03:30:41	1.87
+++ LVM2/tools/lvmcmdline.c	2008/12/17 16:45:32	1.88
@@ -53,6 +53,62 @@
 
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
--- LVM2/tools/toollib.c	2008/11/03 22:14:30	1.137
+++ LVM2/tools/toollib.c	2008/12/17 16:45:32	1.138
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



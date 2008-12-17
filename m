From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 17 Dec 2008 16:46:46 -0000
Subject: LVM2 daemons/clvmd/lvm-functions.c lib/command ...
Message-ID: <20081217164646.6109.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-12-17 16:46:45

Modified files:
	daemons/clvmd  : lvm-functions.c 
	lib/commands   : toolcontext.c toolcontext.h 
	lib            : lvm2.h 
	tools          : lvmcmdline.c 

Log message:
	Remove struct arg * from struct cmd_context and create_toolcontext().
	
	This allows us to remove one argument from create_toolcontext() and
	moves it closer to a generic library init function.
	
	In the arg_*() functions, we just use _the_args() directly.
	For now we leave the first parameter to these
	arg_*() functions (struct cmd_context *) because
	of the number of files involved in removing the
	parameter.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.70&r2=1.71
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.h.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/lvm2.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.88&r2=1.89

--- LVM2/daemons/clvmd/lvm-functions.c	2008/12/11 03:34:12	1.53
+++ LVM2/daemons/clvmd/lvm-functions.c	2008/12/17 16:46:45	1.54
@@ -724,7 +724,7 @@
 /* Called to initialise the LVM context of the daemon */
 int init_lvm(int using_gulm)
 {
-	if (!(cmd = create_toolcontext(NULL, 0, 1))) {
+	if (!(cmd = create_toolcontext(0, 1))) {
 		log_error("Failed to allocate command context");
 		return 0;
 	}
--- LVM2/lib/commands/toolcontext.c	2008/12/12 03:30:41	1.70
+++ LVM2/lib/commands/toolcontext.c	2008/12/17 16:46:45	1.71
@@ -998,7 +998,7 @@
 }
 
 /* Entry point */
-struct cmd_context *create_toolcontext(struct arg *the_args, unsigned is_static,
+struct cmd_context *create_toolcontext(unsigned is_static,
 				       unsigned is_long_lived)
 {
 	struct cmd_context *cmd;
@@ -1021,7 +1021,6 @@
 		return NULL;
 	}
 	memset(cmd, 0, sizeof(*cmd));
-	cmd->args = the_args;
 	cmd->is_static = is_static;
 	cmd->is_long_lived = is_long_lived;
 	cmd->handles_missing_pvs = 0;
--- LVM2/lib/commands/toolcontext.h	2008/12/07 04:27:56	1.28
+++ LVM2/lib/commands/toolcontext.h	2008/12/17 16:46:45	1.29
@@ -65,7 +65,6 @@
 	unsigned rand_seed;
 	char *cmd_line;
 	struct command *command;
-	struct arg *args;
 	char **argv;
 	unsigned is_static:1;	/* Static binary? */
 	unsigned is_long_lived:1;	/* Optimises persistent_filter handling */
@@ -96,7 +95,7 @@
 	char sysfs_dir[PATH_MAX];
 };
 
-struct cmd_context *create_toolcontext(struct arg *the_args, unsigned is_static, unsigned is_long_lived);
+struct cmd_context *create_toolcontext(unsigned is_static, unsigned is_long_lived);
 void destroy_toolcontext(struct cmd_context *cmd);
 int refresh_toolcontext(struct cmd_context *cmd);
 int config_files_changed(struct cmd_context *cmd);
--- LVM2/lib/lvm2.h	2008/12/07 19:37:07	1.1
+++ LVM2/lib/lvm2.h	2008/12/17 16:46:45	1.2
@@ -24,7 +24,7 @@
  */
 struct arg;
 struct cmd_context;
-struct cmd_context *create_toolcontext(struct arg *the_args, unsigned is_static, unsigned is_long_lived);
+struct cmd_context *create_toolcontext(unsigned is_static, unsigned is_long_lived);
 void destroy_toolcontext(struct cmd_context *cmd);
 
 /*
@@ -37,7 +37,7 @@
  * NULL: Fail - unable to initialise handle.
  * non-NULL: Success - valid LVM2 handle returned
  */
-#define lvm2_create(X) create_toolcontext(NULL,0,1)
+#define lvm2_create(X) create_toolcontext(0,1)
 
 /*
  * lvm2_destroy
--- LVM2/tools/lvmcmdline.c	2008/12/17 16:45:32	1.88
+++ LVM2/tools/lvmcmdline.c	2008/12/17 16:46:45	1.89
@@ -54,59 +54,68 @@
 static struct cmdline_context _cmdline;
 
 /* Command line args */
-unsigned arg_count(const struct cmd_context *cmd, int a)
+/* FIXME: struct cmd_context * is unnecessary (large # files ) */
+unsigned arg_count(const struct cmd_context *cmd __attribute((unused)), int a)
 {
-	return cmd->args[a].count;
+	return _the_args[a].count;
 }
 
-const char *arg_value(struct cmd_context *cmd, int a)
+const char *arg_value(struct cmd_context *cmd __attribute((unused)), int a)
 {
-	return cmd->args[a].value;
+	return _the_args[a].value;
 }
 
-const char *arg_str_value(struct cmd_context *cmd, int a, const char *def)
+const char *arg_str_value(struct cmd_context *cmd __attribute((unused)),
+			  int a, const char *def)
 {
-	return arg_count(cmd, a) ? cmd->args[a].value : def;
+	return arg_count(cmd, a) ? _the_args[a].value : def;
 }
 
-int32_t arg_int_value(struct cmd_context *cmd, int a, const int32_t def)
+int32_t arg_int_value(struct cmd_context *cmd __attribute((unused)),
+		      int a, const int32_t def)
 {
-	return arg_count(cmd, a) ? cmd->args[a].i_value : def;
+	return arg_count(cmd, a) ? _the_args[a].i_value : def;
 }
 
-uint32_t arg_uint_value(struct cmd_context *cmd, int a, const uint32_t def)
+uint32_t arg_uint_value(struct cmd_context *cmd __attribute((unused)),
+			int a, const uint32_t def)
 {
-	return arg_count(cmd, a) ? cmd->args[a].ui_value : def;
+	return arg_count(cmd, a) ? _the_args[a].ui_value : def;
 }
 
-int64_t arg_int64_value(struct cmd_context *cmd, int a, const int64_t def)
+int64_t arg_int64_value(struct cmd_context *cmd __attribute((unused)),
+			int a, const int64_t def)
 {
-	return arg_count(cmd, a) ? cmd->args[a].i64_value : def;
+	return arg_count(cmd, a) ? _the_args[a].i64_value : def;
 }
 
-uint64_t arg_uint64_value(struct cmd_context *cmd, int a, const uint64_t def)
+uint64_t arg_uint64_value(struct cmd_context *cmd __attribute((unused)),
+			  int a, const uint64_t def)
 {
-	return arg_count(cmd, a) ? cmd->args[a].ui64_value : def;
+	return arg_count(cmd, a) ? _the_args[a].ui64_value : def;
 }
 
-const void *arg_ptr_value(struct cmd_context *cmd, int a, const void *def)
+const void *arg_ptr_value(struct cmd_context *cmd __attribute((unused)),
+			  int a, const void *def)
 {
-	return arg_count(cmd, a) ? cmd->args[a].ptr : def;
+	return arg_count(cmd, a) ? _the_args[a].ptr : def;
 }
 
-sign_t arg_sign_value(struct cmd_context *cmd, int a, const sign_t def)
+sign_t arg_sign_value(struct cmd_context *cmd __attribute((unused)),
+		      int a, const sign_t def)
 {
-	return arg_count(cmd, a) ? cmd->args[a].sign : def;
+	return arg_count(cmd, a) ? _the_args[a].sign : def;
 }
 
-percent_t arg_percent_value(struct cmd_context *cmd, int a, const percent_t def)
+percent_t arg_percent_value(struct cmd_context *cmd __attribute((unused)),
+			    int a, const percent_t def)
 {
-	return arg_count(cmd, a) ? cmd->args[a].percent : def;
+	return arg_count(cmd, a) ? _the_args[a].percent : def;
 }
 
-int arg_count_increment(struct cmd_context *cmd, int a)
+int arg_count_increment(struct cmd_context *cmd __attribute((unused)), int a)
 {
-	return cmd->args[a].count++;
+	return _the_args[a].count++;
 }
 
 int yes_no_arg(struct cmd_context *cmd __attribute((unused)), struct arg *a)
@@ -1144,7 +1153,7 @@
 
 	_cmdline.the_args = &_the_args[0];
 
-	if (!(cmd = create_toolcontext(_cmdline.the_args, is_static, 0)))
+	if (!(cmd = create_toolcontext(is_static, 0)))
 		return_NULL;
 
 	return cmd;



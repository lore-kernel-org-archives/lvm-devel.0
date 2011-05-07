From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 7 May 2011 13:50:19 -0000
Subject: LVM2 tools/lvmcmdline.c liblvm/lvm_base.c lib/ ...
Message-ID: <20110507135019.1909.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-05-07 13:50:13

Modified files:
	tools          : lvmcmdline.c 
	liblvm         : lvm_base.c 
	lib/commands   : toolcontext.c toolcontext.h 
	daemons/clvmd  : lvm-functions.c 

Log message:
	When glibc needs buffers for line buffering of input and output buffers, it
	allocates these buffers in such way it adds memory page for each such buffer
	and size of unlock memory check will mismatch by 1 or 2 pages.
	
	This happens when we print or read lines without '\n' so these buffers are
	used. To avoid this extra allocation, use setvbuf to set these bufffers ahead.
	
	Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
	Reviewed-by: Milan Broz <mbroz@redhat.com>
	Reviewed-by: Petr Rockai <prockai@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.141&r2=1.142
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_base.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.118&r2=1.119
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.h.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.115&r2=1.116

--- LVM2/tools/lvmcmdline.c	2011/04/22 12:07:35	1.141
+++ LVM2/tools/lvmcmdline.c	2011/05/07 13:50:11	1.142
@@ -1282,7 +1282,7 @@
 	if (!udev_init_library_context())
 		stack;
 
-	if (!(cmd = create_toolcontext(0, NULL)))
+	if (!(cmd = create_toolcontext(0, NULL, 1)))
 		return_NULL;
 
 	_cmdline.arg_props = &_arg_props[0];
--- LVM2/liblvm/lvm_base.c	2010/12/20 13:28:04	1.20
+++ LVM2/liblvm/lvm_base.c	2011/05/07 13:50:11	1.21
@@ -34,7 +34,7 @@
 	/* create context */
 	/* FIXME: split create_toolcontext */
 	/* FIXME: make all globals configurable */
-	cmd = create_toolcontext(0, system_dir);
+	cmd = create_toolcontext(0, system_dir, 1);
 	if (!cmd)
 		return NULL;
 
--- LVM2/lib/commands/toolcontext.c	2011/04/29 16:23:39	1.118
+++ LVM2/lib/commands/toolcontext.c	2011/05/07 13:50:12	1.119
@@ -58,6 +58,8 @@
 #  include <malloc.h>
 #endif
 
+static const size_t linebuffer_size = 4096;
+
 static int _get_env_vars(struct cmd_context *cmd)
 {
 	const char *e;
@@ -1148,7 +1150,8 @@
 
 /* Entry point */
 struct cmd_context *create_toolcontext(unsigned is_long_lived,
-				       const char *system_dir)
+				       const char *system_dir,
+				       unsigned set_buffering)
 {
 	struct cmd_context *cmd;
 
@@ -1183,6 +1186,22 @@
 	/* FIXME Make this configurable? */
 	reset_lvm_errno(1);
 
+	/* Set in/out stream buffering before glibc */
+	if (set_buffering) {
+		/* Allocate 2 buffers */
+		if (!(cmd->linebuffer = dm_malloc(2 * linebuffer_size))) {
+			log_error("Failed to allocate line buffer.");
+			goto out;
+		}
+		if ((setvbuf(stdin, cmd->linebuffer, _IOLBF, linebuffer_size) ||
+		     setvbuf(stdout, cmd->linebuffer + linebuffer_size,
+			     _IOLBF, linebuffer_size))) {
+			log_sys_error("setvbuf", "");
+			goto out;
+		}
+		/* Buffers are used for lines without '\n' */
+	}
+
 	/*
 	 * Environment variable LVM_SYSTEM_DIR overrides this below.
 	 */
@@ -1419,6 +1438,15 @@
 	_destroy_tag_configs(cmd);
 	if (cmd->libmem)
 		dm_pool_destroy(cmd->libmem);
+
+	if (cmd->linebuffer) {
+		/* Reset stream buffering to defaults */
+		setlinebuf(stdin);
+		fflush(stdout);
+		setlinebuf(stdout);
+		dm_free(cmd->linebuffer);
+	}
+
 	dm_free(cmd);
 
 	release_log_memory();
--- LVM2/lib/commands/toolcontext.h	2010/12/10 22:39:54	1.42
+++ LVM2/lib/commands/toolcontext.h	2011/05/07 13:50:12	1.43
@@ -66,6 +66,7 @@
 	const char *kernel_vsn;
 
 	unsigned rand_seed;
+	char *linebuffer;
 	const char *cmd_line;
 	struct command *command;
 	char **argv;
@@ -109,7 +110,8 @@
  * The environment variable LVM_SYSTEM_DIR always takes precedence.
  */
 struct cmd_context *create_toolcontext(unsigned is_long_lived,
-				       const char *system_dir);
+				       const char *system_dir,
+				       unsigned set_buffering);
 void destroy_toolcontext(struct cmd_context *cmd);
 int refresh_toolcontext(struct cmd_context *cmd);
 int refresh_filters(struct cmd_context *cmd);
--- LVM2/daemons/clvmd/lvm-functions.c	2011/03/29 20:30:06	1.115
+++ LVM2/daemons/clvmd/lvm-functions.c	2011/05/07 13:50:13	1.116
@@ -919,7 +919,7 @@
 	init_syslog(LOG_DAEMON);
 	openlog("clvmd", LOG_PID, LOG_DAEMON);
 
-	if (!(cmd = create_toolcontext(1, NULL))) {
+	if (!(cmd = create_toolcontext(1, NULL, 0))) {
 		log_error("Failed to allocate command context");
 		return 0;
 	}



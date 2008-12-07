From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 7 Dec 2008 04:27:58 -0000
Subject: LVM2 ./WHATS_NEW lib/commands/toolcontext.c li ...
Message-ID: <20081207042758.31494.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-12-07 04:27:57

Modified files:
	.              : WHATS_NEW 
	lib/commands   : toolcontext.c toolcontext.h 
	lib/format_text: archive.c format-text.c 
	lib/misc       : lvm-file.c lvm-file.h 
	tools          : lvmcmdline.c 

Log message:
	Make _init_rand() thread safe - use rand_r() instead of rand().
	
	Use good entropy for seed value if possible.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1005&r2=1.1006
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.64&r2=1.65
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.h.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archive.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.98&r2=1.99
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-file.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-file.h.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.75&r2=1.76

--- LVM2/WHATS_NEW	2008/12/07 04:23:37	1.1005
+++ LVM2/WHATS_NEW	2008/12/07 04:27:56	1.1006
@@ -1,5 +1,6 @@
 Version 2.02.44 - 
 ====================================
+  Use better random seed value in temp file creation.
   Add generic function to read /dev/urandom, used in uuid calculation.
   Use displayable_lvs_in_vg and lv_is_displayable for consistency throughout.
   Fix race in vgcreate that would result in second caller overwriting first.
--- LVM2/lib/commands/toolcontext.c	2008/11/03 22:14:27	1.64
+++ LVM2/lib/commands/toolcontext.c	2008/12/07 04:27:56	1.65
@@ -979,6 +979,14 @@
 	return 1;
 }
 
+static void _init_rand(struct cmd_context *cmd)
+{
+	if (read_urandom(&cmd->rand_seed, sizeof(cmd->rand_seed)))
+		return;
+
+	cmd->rand_seed = (unsigned) time(NULL) + (unsigned) getpid();
+}
+
 /* Entry point */
 struct cmd_context *create_toolcontext(struct arg *the_args, unsigned is_static,
 				       unsigned is_long_lived)
@@ -1077,6 +1085,8 @@
 	if (!_init_backup(cmd))
 		goto error;
 
+	_init_rand(cmd);
+
 	cmd->default_settings.cache_vgmetadata = 1;
 	cmd->current_settings = cmd->default_settings;
 
--- LVM2/lib/commands/toolcontext.h	2008/11/03 22:14:27	1.27
+++ LVM2/lib/commands/toolcontext.h	2008/12/07 04:27:56	1.28
@@ -62,6 +62,7 @@
 	const char *hostname;
 	const char *kernel_vsn;
 
+	unsigned rand_seed;
 	char *cmd_line;
 	struct command *command;
 	struct arg *args;
--- LVM2/lib/format_text/archive.c	2008/11/03 22:14:28	1.32
+++ LVM2/lib/format_text/archive.c	2008/12/07 04:27:56	1.33
@@ -236,7 +236,8 @@
 	/*
 	 * Write the vg out to a temporary file.
 	 */
-	if (!create_temp_name(dir, temp_file, sizeof(temp_file), &fd)) {
+	if (!create_temp_name(dir, temp_file, sizeof(temp_file), &fd,
+			      &vg->cmd->rand_seed)) {
 		log_err("Couldn't create temporary archive name.");
 		return 0;
 	}
--- LVM2/lib/format_text/format-text.c	2008/11/03 22:14:28	1.98
+++ LVM2/lib/format_text/format-text.c	2008/12/07 04:27:57	1.99
@@ -848,7 +848,8 @@
 		return 0;
 	}
 
-	if (!create_temp_name(temp_dir, temp_file, sizeof(temp_file), &fd)) {
+	if (!create_temp_name(temp_dir, temp_file, sizeof(temp_file), &fd,
+			      &vg->cmd->rand_seed)) {
 		log_err("Couldn't create temporary text file name.");
 		return 0;
 	}
--- LVM2/lib/misc/lvm-file.c	2008/01/30 14:00:00	1.25
+++ LVM2/lib/misc/lvm-file.c	2008/12/07 04:27:57	1.26
@@ -29,7 +29,8 @@
  * rename the file after successfully writing it.  Grab
  * NFS-supported exclusive fcntl discretionary lock.
  */
-int create_temp_name(const char *dir, char *buffer, size_t len, int *fd)
+int create_temp_name(const char *dir, char *buffer, size_t len, int *fd,
+		     unsigned *seed)
 {
 	int i, num;
 	pid_t pid;
@@ -41,7 +42,7 @@
 		.l_len = 0
 	};
 
-	num = rand();
+	num = rand_r(seed);
 	pid = getpid();
 	if (gethostname(hostname, sizeof(hostname)) < 0) {
 		log_sys_error("gethostname", "");
--- LVM2/lib/misc/lvm-file.h	2007/08/20 20:55:27	1.12
+++ LVM2/lib/misc/lvm-file.h	2008/12/07 04:27:57	1.13
@@ -19,7 +19,8 @@
 /*
  * Create a temporary filename, and opens a descriptor to the file.
  */
-int create_temp_name(const char *dir, char *buffer, size_t len, int *fd);
+int create_temp_name(const char *dir, char *buffer, size_t len, int *fd,
+		     unsigned *seed);
 
 /*
  * NFS-safe rename of a temporary file to a common name, designed
--- LVM2/tools/lvmcmdline.c	2008/11/18 10:13:23	1.75
+++ LVM2/tools/lvmcmdline.c	2008/12/07 04:27:57	1.76
@@ -997,11 +997,6 @@
 	return *argc;
 }
 
-static void _init_rand(void)
-{
-	srand((unsigned) time(NULL) + (unsigned) getpid());
-}
-
 static const char *_get_cmdline(pid_t pid)
 {
 	static char _proc_cmdline[32];
@@ -1096,8 +1091,6 @@
 	if (!(cmd = create_toolcontext(_cmdline.the_args, is_static, 0)))
 		return_NULL;
 
-	_init_rand();
-
 	_apply_settings(cmd);
 
 	return cmd;



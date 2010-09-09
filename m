From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 9 Sep 2010 13:07:15 -0000
Subject: LVM2 ./WHATS_NEW lib/commands/toolcontext.c li ...
Message-ID: <20100909130715.9657.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-09-09 13:07:15

Modified files:
	.              : WHATS_NEW 
	lib/commands   : toolcontext.c 
	lib/format_text: archiver.c 

Log message:
	Reinitialize archive and backup handling on toolcontext refresh.
	
	For example, when using '--config "backup { ... }"' line, the values from
	lvm.conf (or default values) should be overridden. This patch adds
	reinitialisation of archive and backup handling on toolcontext refresh
	which makes these settings to be applied.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1727&r2=1.1728
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.103&r2=1.104
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34

--- LVM2/WHATS_NEW	2010/08/30 18:37:42	1.1727
+++ LVM2/WHATS_NEW	2010/09/09 13:07:13	1.1728
@@ -1,5 +1,6 @@
 Version 2.02.74 - 
 ==================================
+  Reinitialize archive and backup handling on toolcontext refresh.
   Fix opprobriously slow I/O to cluster mirrors created with --nosync.
   Make poll_mirror_progress report PROGRESS_CHECK_FAILED if LV is not a mirror.
   Like mirrors, don't scan origins if ignore_suspended_devices() is set.
--- LVM2/lib/commands/toolcontext.c	2010/08/11 12:14:23	1.103
+++ LVM2/lib/commands/toolcontext.c	2010/09/09 13:07:14	1.104
@@ -1343,6 +1343,9 @@
 	if (!_init_segtypes(cmd))
 		return 0;
 
+	if (!_init_backup(cmd))
+		return 0;
+
 	cmd->config_valid = 1;
 
 	reset_lvm_errno(1);
--- LVM2/lib/format_text/archiver.c	2010/07/08 18:24:29	1.33
+++ LVM2/lib/format_text/archiver.c	2010/09/09 13:07:14	1.34
@@ -40,6 +40,8 @@
 		 unsigned int keep_days, unsigned int keep_min,
 		 int enabled)
 {
+	archive_exit(cmd);
+
 	if (!(cmd->archive_params = dm_pool_zalloc(cmd->libmem,
 						sizeof(*cmd->archive_params)))) {
 		log_error("archive_params alloc failed");
@@ -156,6 +158,8 @@
 int backup_init(struct cmd_context *cmd, const char *dir,
 		int enabled)
 {
+	backup_exit(cmd);
+
 	if (!(cmd->backup_params = dm_pool_zalloc(cmd->libmem,
 					       sizeof(*cmd->backup_params)))) {
 		log_error("backup_params alloc failed");



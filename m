From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 18 Feb 2011 14:08:23 -0000
Subject: LVM2 ./WHATS_NEW lib/config/config.c lib/confi ...
Message-ID: <20110218140823.630.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-02-18 14:08:23

Modified files:
	.              : WHATS_NEW 
	lib/config     : config.c config.h 

Log message:
	Support 64bit ints in config

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1913&r2=1.1914
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.88&r2=1.89
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.h.diff?cvsroot=lvm2&r1=1.32&r2=1.33

--- LVM2/WHATS_NEW	2011/02/18 00:36:04	1.1913
+++ LVM2/WHATS_NEW	2011/02/18 14:08:22	1.1914
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Add function to read 64bit ints from config find_config_tree_int64.
   Fix to make resuming exclusive cluster mirror use local target type.
 
 Version 2.02.84 - 9th February 2011
--- LVM2/lib/config/config.c	2011/01/28 10:19:00	1.88
+++ LVM2/lib/config/config.c	2011/02/18 14:08:22	1.89
@@ -1049,6 +1049,12 @@
 	return (int) _find_config_int64(cmd->cft_override ? cmd->cft_override->root : NULL, cmd->cft->root, path, (int64_t) fail);
 }
 
+int64_t find_config_tree_int64(struct cmd_context *cmd, const char *path, int64_t fail)
+{
+	return _find_config_int64(cmd->cft_override ? cmd->cft_override->root : NULL,
+				  cmd->cft->root, path, fail);
+}
+
 float find_config_tree_float(struct cmd_context *cmd, const char *path,
 			     float fail)
 {
--- LVM2/lib/config/config.h	2010/12/20 13:12:56	1.32
+++ LVM2/lib/config/config.h	2011/02/18 14:08:23	1.33
@@ -95,6 +95,8 @@
 				 const char *path, const char *fail);
 int find_config_tree_int(struct cmd_context *cmd, const char *path,
 			 int fail);
+int64_t find_config_tree_int64(struct cmd_context *cmd, const char *path,
+			     int64_t fail);
 float find_config_tree_float(struct cmd_context *cmd, const char *path,
 			     float fail);
 



From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 11 Jan 2010 15:40:05 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/fs.c lib/misc/lv ...
Message-ID: <20100111154005.1810.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-01-11 15:40:04

Modified files:
	.              : WHATS_NEW 
	lib/activate   : fs.c 
	lib/misc       : lvm-globals.c lvm-globals.h 
	tools          : lvmcmdline.c 

Log message:
	Add support to disable udev checking: LVM_UDEV_DISABLE_CHECKING=1 env. var.
	
	LVM_UDEV_DISABLE_CHECKING=1 applies for /dev/<vgname> content only.
	We still need to define DM_UDEV_DISABLE_CHECKING=1 for /dev/mapper content.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1377&r2=1.1378
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-globals.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-globals.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.109&r2=1.110

--- LVM2/WHATS_NEW	2010/01/08 22:32:35	1.1377
+++ LVM2/WHATS_NEW	2010/01/11 15:40:03	1.1378
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Add support to disable udev checking: LVM_UDEV_DISABLE_CHECKING=1 env. var.
   Add redundant mirror log option.
   Add capability to split off and keep mirror legs to lvconvert.
   Change background polldaemon's process name to "(lvm2)".
--- LVM2/lib/activate/fs.c	2010/01/07 19:54:21	1.50
+++ LVM2/lib/activate/fs.c	2010/01/11 15:40:03	1.51
@@ -166,7 +166,7 @@
 			return 0;
 		}
 
-		if (dm_udev_get_sync_support() && check_udev) {
+		if (dm_udev_get_sync_support() && udev_checking() && check_udev) {
 			/* Check udev created the correct link. */
 			if (!stat(link_path, &buf_lp) &&
 			    !stat(lv_path, &buf)) {
@@ -190,7 +190,7 @@
 			log_sys_error("unlink", lv_path);
 			return 0;
 		}
-	} else if (dm_udev_get_sync_support() && check_udev)
+	} else if (dm_udev_get_sync_support() && udev_checking() && check_udev)
 		log_warn("The link %s should had been created by udev "
 			  "but it was not found. Falling back to "
 			  "direct link creation.", lv_path);
@@ -221,7 +221,7 @@
 
 	if (lstat(lv_path, &buf) && errno == ENOENT)
 		return 1;
-	else if (dm_udev_get_sync_support() && check_udev)
+	else if (dm_udev_get_sync_support() && udev_checking() && check_udev)
 		log_warn("The link %s should have been removed by udev "
 			 "but it is still present. Falling back to "
 			 "direct link removal.", lv_path);
--- LVM2/lib/misc/lvm-globals.c	2010/01/05 20:56:51	1.4
+++ LVM2/lib/misc/lvm-globals.c	2010/01/11 15:40:04	1.5
@@ -39,6 +39,7 @@
 static int _ignore_suspended_devices = 0;
 static int _error_message_produced = 0;
 static unsigned _is_static = 0;
+static int _udev_checking = 1;
 
 void init_verbose(int level)
 {
@@ -112,6 +113,14 @@
 	_is_static = value;
 }
 
+void init_udev_checking(int checking)
+{
+	if ((_udev_checking = checking))
+		log_debug("LVM udev checking enabled");
+	else
+		log_debug("LVM udev checking disabled");
+}
+
 void set_cmd_name(const char *cmd)
 {
 	strncpy(_cmd_name, cmd, sizeof(_cmd_name));
@@ -210,3 +219,8 @@
 {
 	return _is_static;
 }
+
+int udev_checking(void)
+{
+	return _udev_checking;
+}
--- LVM2/lib/misc/lvm-globals.h	2010/01/05 20:56:51	1.5
+++ LVM2/lib/misc/lvm-globals.h	2010/01/11 15:40:04	1.6
@@ -36,6 +36,7 @@
 void init_ignore_suspended_devices(int ignore);
 void init_error_message_produced(int produced);
 void init_is_static(unsigned value);
+void init_udev_checking(int checking);
 
 void set_cmd_name(const char *cmd_name);
 
@@ -54,6 +55,7 @@
 int ignore_suspended_devices(void);
 const char *log_command_name(void);
 unsigned is_static(void);
+int udev_checking(void);
 
 #define DMEVENTD_MONITOR_IGNORE -1
 int dmeventd_monitor_mode(void);
--- LVM2/tools/lvmcmdline.c	2009/12/16 19:22:13	1.109
+++ LVM2/tools/lvmcmdline.c	2010/01/11 15:40:04	1.110
@@ -909,6 +909,19 @@
 	cmd->handles_missing_pvs = 0;
 }
 
+static void _set_udev_checking()
+{
+	const char *e;
+
+	if ((e = getenv("DM_UDEV_DISABLE_CHECKING")) &&
+		!strcmp(e, "1"))
+		dm_udev_set_checking(0);
+
+	if ((e = getenv("LVM_UDEV_DISABLE_CHECKING")) &&
+		!strcmp(e, "1"))
+		init_udev_checking(0);
+}
+
 static const char *_copy_command_line(struct cmd_context *cmd, int argc, char **argv)
 {
 	int i, space;
@@ -1003,6 +1016,8 @@
 	log_debug("O_DIRECT will be used");
 #endif
 
+	_set_udev_checking();
+
 	if ((ret = _process_common_commands(cmd)))
 		goto_out;
 



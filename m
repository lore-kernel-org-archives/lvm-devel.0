From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 11 Aug 2010 12:14:26 -0000
Subject: LVM2 ./WHATS_NEW lib/commands/toolcontext.c li ...
Message-ID: <20100811121426.8017.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-08-11 12:14:24

Modified files:
	.              : WHATS_NEW 
	lib/commands   : toolcontext.c toolcontext.h 
	lib/device     : device.c device.h 
	lib/filters    : filter.c 
	lib/misc       : lvm-globals.c lvm-globals.h 

Log message:
	Recognise and give preference to md device partitions (blkext major).
	
	We can already detect MD devices internally. But when using MD partitions,
	these have "block extended major" (blkext) assigned (259). Blkext major
	is also used in general, so we need to check whether the original device
	is an MD device actually.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1698&r2=1.1699
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.102&r2=1.103
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.h.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/device.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/device.h.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-globals.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-globals.h.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/WHATS_NEW	2010/08/09 14:06:03	1.1698
+++ LVM2/WHATS_NEW	2010/08/11 12:14:23	1.1699
@@ -1,5 +1,6 @@
 Version 2.02.73 - 
 ================================
+  Recognise and give preference to md device partitions (blkext major).
   Never scan internal LVM devices.
   Split-mirror operations were ignoring user-specified PVs.
   Fix data corruption bug in cluster mirrors.
--- LVM2/lib/commands/toolcontext.c	2010/07/02 10:25:16	1.102
+++ LVM2/lib/commands/toolcontext.c	2010/08/11 12:14:23	1.103
@@ -240,7 +240,9 @@
 		cmd->proc_dir[0] = '\0';
 	}
 
+	/* FIXME Use global value of sysfs_dir everywhere instead cmd->sysfs_dir. */
 	_get_sysfs_dir(cmd);
+	set_sysfs_dir_path(cmd->sysfs_dir);
 
 	/* activation? */
 	cmd->default_settings.activation = find_config_tree_int(cmd,
--- LVM2/lib/commands/toolcontext.h	2010/04/29 01:38:14	1.38
+++ LVM2/lib/commands/toolcontext.h	2010/08/11 12:14:23	1.39
@@ -95,7 +95,7 @@
 	char system_dir[PATH_MAX];
 	char dev_dir[PATH_MAX];
 	char proc_dir[PATH_MAX];
-	char sysfs_dir[PATH_MAX];
+	char sysfs_dir[PATH_MAX]; /* FIXME Use global value instead. */
 };
 
 /*
--- LVM2/lib/device/device.c	2010/04/06 17:36:42	1.33
+++ LVM2/lib/device/device.c	2010/08/11 12:14:24	1.34
@@ -278,7 +278,7 @@
 #ifdef linux
 
 int get_primary_dev(const char *sysfs_dir,
-		    struct device *dev, dev_t *result)
+		    const struct device *dev, dev_t *result)
 {
 	char path[PATH_MAX+1];
 	char temp_path[PATH_MAX+1];
--- LVM2/lib/device/device.h	2009/08/01 17:11:02	1.43
+++ LVM2/lib/device/device.h	2010/08/11 12:14:24	1.44
@@ -101,7 +101,7 @@
 int is_partitioned_dev(struct device *dev);
 
 int get_primary_dev(const char *sysfs_dir,
-		    struct device *dev, dev_t *result);
+		    const struct device *dev, dev_t *result);
 
 unsigned long dev_alignment_offset(const char *sysfs_dir,
 				   struct device *dev);
--- LVM2/lib/filters/filter.c	2010/07/09 15:34:43	1.55
+++ LVM2/lib/filters/filter.c	2010/08/11 12:14:24	1.56
@@ -59,6 +59,8 @@
 
 int dev_subsystem_part_major(const struct device *dev)
 {
+	dev_t primary_dev;
+
 	if (MAJOR(dev->dev) == -1)
 		return 0;
 
@@ -68,6 +70,11 @@
 	if (MAJOR(dev->dev) == _drbd_major)
 		return 1;
 
+	if ((MAJOR(dev->dev) == _blkext_major) &&
+	    (get_primary_dev(sysfs_dir_path(), dev, &primary_dev)) &&
+	    (MAJOR(primary_dev) == _md_major))
+		return 1;
+
 	return 0;
 }
 
@@ -79,6 +86,9 @@
 	if (MAJOR(dev->dev) == _drbd_major)
 		return "DRBD";
 
+	if (MAJOR(dev->dev) == _blkext_major)
+		return "BLKEXT";
+
 	return "";
 }
 
--- LVM2/lib/misc/lvm-globals.c	2010/01/11 15:40:04	1.5
+++ LVM2/lib/misc/lvm-globals.c	2010/08/11 12:14:24	1.6
@@ -40,6 +40,7 @@
 static int _error_message_produced = 0;
 static unsigned _is_static = 0;
 static int _udev_checking = 1;
+static char _sysfs_dir_path[PATH_MAX] = "";
 
 void init_verbose(int level)
 {
@@ -127,6 +128,12 @@
 	_cmd_name[sizeof(_cmd_name) - 1] = '\0';
 }
 
+void set_sysfs_dir_path(const char *path)
+{
+	strncpy(_sysfs_dir_path, path, sizeof(_sysfs_dir_path));
+	_sysfs_dir_path[sizeof(_sysfs_dir_path) - 1] = '\0';
+}
+
 const char *log_command_name()
 {
 	if (!_log_cmd_name)
@@ -224,3 +231,8 @@
 {
 	return _udev_checking;
 }
+
+const char *sysfs_dir_path()
+{
+	return _sysfs_dir_path;
+}
--- LVM2/lib/misc/lvm-globals.h	2010/01/11 15:40:04	1.6
+++ LVM2/lib/misc/lvm-globals.h	2010/08/11 12:14:24	1.7
@@ -39,6 +39,7 @@
 void init_udev_checking(int checking);
 
 void set_cmd_name(const char *cmd_name);
+void set_sysfs_dir_path(const char *path);
 
 int test_mode(void);
 int md_filtering(void);
@@ -56,6 +57,7 @@
 const char *log_command_name(void);
 unsigned is_static(void);
 int udev_checking(void);
+const char *sysfs_dir_path(void);
 
 #define DMEVENTD_MONITOR_IGNORE -1
 int dmeventd_monitor_mode(void);



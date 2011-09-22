From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 22 Sep 2011 17:39:59 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf.in lib/activ ...
Message-ID: <20110922173959.24717.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-09-22 17:39:58

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf.in 
	lib/activate   : dev_manager.c 
	lib/commands   : toolcontext.c 
	lib/config     : defaults.h 
	lib/misc       : lvm-globals.c lvm-globals.h 

Log message:
	Add activation/retry_deactivation to lvm.conf to retry deactivation of an LV.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2131&r2=1.2132
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.231&r2=1.232
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.136&r2=1.137
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.83&r2=1.84
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-globals.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-globals.h.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/WHATS_NEW	2011/09/22 17:33:50	1.2131
+++ LVM2/WHATS_NEW	2011/09/22 17:39:56	1.2132
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Add activation/retry_deactivation to lvm.conf to retry deactivation of an LV.
   Replace open_count check with holders/mounted_fs check on lvremove path.
   Disallow the creation of mirrors (mirror or raid1 segtype) with only one leg.
   Cleanup restart clvmd code (no memory allocation, debug print passed args).
--- LVM2/doc/example.conf.in	2011/08/12 02:16:46	1.31
+++ LVM2/doc/example.conf.in	2011/09/22 17:39:57	1.32
@@ -465,6 +465,11 @@
     # Useful for diagnosing problems with LVM2/udev interactions.
     verify_udev_operations = 0
 
+    # If set to 1 and if deactivation of an LV fails, perhaps because
+    # a process run from a quick udev rule temporarily opened the device,
+    # retry the operation for a few seconds before failing.
+    retry_deactivation = 1
+
     # How to fill in missing stripes if activating an incomplete volume.
     # Using "error" will make inaccessible parts of the device return
     # I/O errors on access.  You can instead use a device path, in which 
--- LVM2/lib/activate/dev_manager.c	2011/08/30 14:55:16	1.231
+++ LVM2/lib/activate/dev_manager.c	2011/09/22 17:39:57	1.232
@@ -1782,6 +1782,8 @@
 			goto_out;
 		break;
 	case DEACTIVATE:
+		if (retry_deactivation())
+			dm_tree_retry_remove(root);
  		/* Deactivate LV and all devices it references that nothing else has open. */
 		r = dm_tree_deactivate_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1);
 		if (!r)
--- LVM2/lib/commands/toolcontext.c	2011/09/22 17:33:51	1.136
+++ LVM2/lib/commands/toolcontext.c	2011/09/22 17:39:57	1.137
@@ -303,6 +303,9 @@
 								"activation/udev_sync",
 								DEFAULT_UDEV_SYNC);
 
+	init_retry_deactivation(find_config_tree_int(cmd, "activation/retry_deactivation",
+							DEFAULT_RETRY_DEACTIVATION));
+
 	init_activation_checks(find_config_tree_int(cmd, "activation/checks",
 						      DEFAULT_ACTIVATION_CHECKS));
 
--- LVM2/lib/config/defaults.h	2011/09/09 00:54:49	1.83
+++ LVM2/lib/config/defaults.h	2011/09/22 17:39:57	1.84
@@ -81,6 +81,7 @@
 #define DEFAULT_UDEV_RULES 1
 #define DEFAULT_UDEV_SYNC 1
 #define DEFAULT_VERIFY_UDEV_OPERATIONS 0
+#define DEFAULT_RETRY_DEACTIVATION 1
 #define DEFAULT_ACTIVATION_CHECKS 0
 #define DEFAULT_EXTENT_SIZE 4096	/* In KB */
 #define DEFAULT_MAX_PV 0
--- LVM2/lib/misc/lvm-globals.c	2011/09/01 13:30:11	1.14
+++ LVM2/lib/misc/lvm-globals.c	2011/09/22 17:39:57	1.15
@@ -42,6 +42,7 @@
 static int _error_message_produced = 0;
 static unsigned _is_static = 0;
 static int _udev_checking = 1;
+static int _retry_deactivation = DEFAULT_RETRY_DEACTIVATION;
 static int _activation_checks = 0;
 static char _sysfs_dir_path[PATH_MAX] = "";
 static int _dev_disable_after_error_count = DEFAULT_DISABLE_AFTER_ERROR_COUNT;
@@ -134,6 +135,11 @@
 		log_debug("LVM udev checking disabled");
 }
 
+void init_retry_deactivation(int retry)
+{
+	_retry_deactivation = retry;
+}
+
 void init_activation_checks(int checks)
 {
 	if ((_activation_checks = checks))
@@ -272,6 +278,11 @@
 	return _udev_checking;
 }
 
+int retry_deactivation(void)
+{
+	return _retry_deactivation;
+}
+
 int activation_checks(void)
 {
 	return _activation_checks;
--- LVM2/lib/misc/lvm-globals.h	2011/08/11 17:46:14	1.13
+++ LVM2/lib/misc/lvm-globals.h	2011/09/22 17:39:57	1.14
@@ -42,6 +42,7 @@
 void init_pv_min_size(uint64_t sectors);
 void init_activation_checks(int checks);
 void init_detect_internal_vg_cache_corruption(int detect);
+void init_retry_deactivation(int retry);
 
 void set_cmd_name(const char *cmd_name);
 void set_sysfs_dir_path(const char *path);
@@ -67,6 +68,7 @@
 uint64_t pv_min_size(void);
 int activation_checks(void);
 int detect_internal_vg_cache_corruption(void);
+int retry_deactivation(void);
 
 #define DMEVENTD_MONITOR_IGNORE -1
 int dmeventd_monitor_mode(void);



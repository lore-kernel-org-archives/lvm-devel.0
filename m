From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 15 Feb 2010 16:21:35 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/.exported_symbols li ...
Message-ID: <20100215162135.27663.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-02-15 16:21:34

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : .exported_symbols libdevmapper.h libdm-common.c 
	libdm/ioctl    : libdm-iface.c 
	tools          : dmsetup.c 

Log message:
	Several changes in dmsetup and libdevmapper:
	
	- add DM_UDEV_DISABLE_LIBRARY_FALLBACK udev flag to rely on udev only
	
	- export dm_udev_create_cookie function to create new cookies on demand
	
	- add --udevcookie, udevcreatecookie and udevreleasecookie for dmsetup
	(to support "udev transactions" where one cookie value can be used for
	several dmsetup calls)
	
	- don't use DM_UDEV_DISABLE_CHECKING env. var. anymore and set the state
	automatically (based on udev and libdevmapper dev path comparison)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.343&r2=1.344
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/.exported_symbols.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.108&r2=1.109
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.92&r2=1.93
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.66&r2=1.67
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.133&r2=1.134

--- LVM2/WHATS_NEW_DM	2010/02/02 14:09:17	1.343
+++ LVM2/WHATS_NEW_DM	2010/02/15 16:21:33	1.344
@@ -1,5 +1,9 @@
 Version 1.02.44 - 
 ===================================
+  Add DM_UDEV_DISABLE_LIBRARY_FALLBACK udev flag to rely on udev only.
+  Export dm_udev_create_cookie function to create new cookies on demand.
+  Add --udevcookie, udevcreatecookie and udevreleasecookie for dmsetup.
+  Don't use DM_UDEV_DISABLE_CHECKING env. var. anymore and set the state automatically.
 
 Version 1.02.43 - 21st January 2010
 ===================================
--- LVM2/libdm/.exported_symbols	2010/01/13 01:39:45	1.48
+++ LVM2/libdm/.exported_symbols	2010/02/15 16:21:33	1.49
@@ -166,5 +166,6 @@
 dm_udev_get_sync_support
 dm_udev_set_checking
 dm_udev_get_checking
+dm_udev_create_cookie
 dm_udev_complete
 dm_udev_wait
--- LVM2/libdm/libdevmapper.h	2010/01/14 10:15:23	1.108
+++ LVM2/libdm/libdevmapper.h	2010/02/15 16:21:33	1.109
@@ -1084,6 +1084,13 @@
  * snapshot devices.
  */
 #define DM_UDEV_LOW_PRIORITY_FLAG 0x0010
+/*
+ * DM_UDEV_DISABLE_LIBRARY_FALLBACK is set in case we need to disable
+ * libdevmapper's node management. We will rely on udev completely
+ * and there will be no fallback action provided by libdevmapper if
+ * udev does something improperly.
+ */
+#define DM_UDEV_DISABLE_LIBRARY_FALLBACK 0x0020
 
 int dm_cookie_supported(void);
 
@@ -1094,6 +1101,7 @@
 int dm_udev_get_sync_support(void);
 void dm_udev_set_checking(int checking);
 int dm_udev_get_checking(void);
+int dm_udev_create_cookie(uint32_t *cookie);
 int dm_udev_complete(uint32_t cookie);
 int dm_udev_wait(uint32_t cookie);
 
--- LVM2/libdm/libdm-common.c	2010/01/11 15:36:24	1.92
+++ LVM2/libdm/libdm-common.c	2010/02/15 16:21:33	1.93
@@ -1166,6 +1166,16 @@
 	return 0;
 }
 
+int dm_udev_create_cookie(uint32_t *cookie)
+{
+	int semid;
+
+	if (!dm_udev_get_sync_support())
+		return 1;
+
+	return _udev_notify_sem_create(cookie, &semid);
+}
+
 int dm_task_set_cookie(struct dm_task *dmt, uint32_t *cookie, uint16_t flags)
 {
 	int semid;
--- LVM2/libdm/ioctl/libdm-iface.c	2009/11/13 12:43:22	1.66
+++ LVM2/libdm/ioctl/libdm-iface.c	2010/02/15 16:21:34	1.67
@@ -1789,6 +1789,7 @@
 	struct dm_ioctl *dmi;
 	unsigned command;
 	int check_udev;
+	int udev_only;
 
 #ifdef DM_COMPAT
 	if (_dm_version == 1)
@@ -1847,22 +1848,25 @@
 		     !(dmt->event_nr >> DM_UDEV_FLAGS_SHIFT &
 		       DM_UDEV_DISABLE_DM_RULES_FLAG);
 
+	udev_only = dmt->cookie_set ? (dmt->event_nr >> DM_UDEV_FLAGS_SHIFT &
+					DM_UDEV_DISABLE_LIBRARY_FALLBACK) : 0;
+
 	switch (dmt->type) {
 	case DM_DEVICE_CREATE:
-		if (dmt->dev_name && *dmt->dev_name)
+		if (dmt->dev_name && *dmt->dev_name && !udev_only)
 			add_dev_node(dmt->dev_name, MAJOR(dmi->dev),
 				     MINOR(dmi->dev), dmt->uid, dmt->gid,
 				     dmt->mode, check_udev);
 		break;
 	case DM_DEVICE_REMOVE:
 		/* FIXME Kernel needs to fill in dmi->name */
-		if (dmt->dev_name)
+		if (dmt->dev_name && !udev_only)
 			rm_dev_node(dmt->dev_name, check_udev);
 		break;
 
 	case DM_DEVICE_RENAME:
 		/* FIXME Kernel needs to fill in dmi->name */
-		if (dmt->dev_name)
+		if (dmt->dev_name && !udev_only)
 			rename_dev_node(dmt->dev_name, dmt->newname,
 					check_udev);
 		break;
--- LVM2/tools/dmsetup.c	2010/01/14 10:15:23	1.133
+++ LVM2/tools/dmsetup.c	2010/02/15 16:21:34	1.134
@@ -45,6 +45,10 @@
 #  include <sys/types.h>
 #  include <sys/ipc.h>
 #  include <sys/sem.h>
+#ifdef HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE
+#  define LIBUDEV_I_KNOW_THE_API_IS_SUBJECT_TO_CHANGE
+#  include <libudev.h>
+#endif
 #endif
 
 /* FIXME Unused so far */
@@ -96,7 +100,10 @@
 #define ARGS_MAX 256
 #define LOOP_TABLE_SIZE (PATH_MAX + 255)
 
-#define DEFAULT_DM_DEV_DIR "/dev"
+#define DEFAULT_DM_DEV_DIR "/dev/"
+
+#define DM_DEV_DIR_ENV_VAR_NAME "DM_DEV_DIR"
+#define DM_UDEV_COOKIE_ENV_VAR_NAME "DM_UDEV_COOKIE"
 
 /* FIXME Should be imported */
 #ifndef DM_MAX_TYPE_NAME
@@ -127,6 +134,7 @@
 	NOLOCKFS_ARG,
 	NOOPENCOUNT_ARG,
 	NOTABLE_ARG,
+	UDEVCOOKIE_ARG,
 	NOUDEVRULES_ARG,
 	NOUDEVSYNC_ARG,
 	OPTIONS_ARG,
@@ -165,6 +173,8 @@
 static char *_target;
 static char *_command;
 static uint32_t _read_ahead_flags;
+static uint32_t _udev_cookie;
+static int _udev_only;
 static struct dm_tree *_dtree;
 static struct dm_report *_report;
 static report_type_t _report_type;
@@ -611,6 +621,12 @@
 		udev_flags |= DM_UDEV_DISABLE_DM_RULES_FLAG |
 			      DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG;
 
+	if (_udev_cookie) {
+		cookie = _udev_cookie;
+		if (_udev_only)
+			udev_flags |= DM_UDEV_DISABLE_LIBRARY_FALLBACK;
+	}
+
 	if (!dm_task_set_cookie(dmt, &cookie, udev_flags) ||
 	    !dm_task_run(dmt))
 		goto out;
@@ -621,7 +637,8 @@
 		r = _display_info(dmt);
 
       out:
-	(void) dm_udev_wait(cookie);
+	if (!_udev_cookie)
+		(void) dm_udev_wait(cookie);
 	dm_task_destroy(dmt);
 
 	return r;
@@ -654,6 +671,12 @@
 		udev_flags |= DM_UDEV_DISABLE_DM_RULES_FLAG |
 			      DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG;
 
+	if (_udev_cookie) {
+		cookie = _udev_cookie;
+		if (_udev_only)
+			udev_flags |= DM_UDEV_DISABLE_LIBRARY_FALLBACK;
+	}
+
 	if (!dm_task_set_cookie(dmt, &cookie, udev_flags) ||
 	    !dm_task_run(dmt))
 		goto out;
@@ -661,7 +684,8 @@
 	r = 1;
 
       out:
-	(void) dm_udev_wait(cookie);
+	if (!_udev_cookie)
+		(void) dm_udev_wait(cookie);
 	dm_task_destroy(dmt);
 
 	return r;
@@ -791,7 +815,7 @@
 	return r;
 }
 
-static uint32_t _get_cookie_value(char *str_value)
+static uint32_t _get_cookie_value(const char *str_value)
 {
 	unsigned long int value;
 	char *p;
@@ -817,7 +841,8 @@
 					      "DISABLE_DISK_RULES",
 					      "DISABLE_OTHER_RULES",
 					      "LOW_PRIORITY",
-					       0, 0, 0};
+					      "DISABLE_LIBRARY_FALLBACK",
+					       0, 0};
 
 	if (!(cookie = _get_cookie_value(argv[1])))
 		return 0;
@@ -872,6 +897,22 @@
 #ifndef UDEV_SYNC_SUPPORT
 static const char _cmd_not_supported[] = "Command not supported. Recompile with \"--enable-udev-sync\" to enable.";
 
+static int _udevcreatecookie(int argc, char **argv,
+				  void *data __attribute((unused)))
+{
+	log_error(_cmd_not_supported);
+
+	return 0;
+}
+
+static int _udevreleasecookie(int argc, char **argv,
+				void *data __attribute((unused)))
+{
+	log_error(_cmd_not_supported);
+
+	return 0;
+}
+
 static int _udevcomplete_all(int argc __attribute((unused)), char **argv __attribute((unused)), void *data __attribute((unused)))
 {
 	log_error(_cmd_not_supported);
@@ -887,6 +928,102 @@
 }
 
 #else	/* UDEV_SYNC_SUPPORT */
+static int _set_up_udev_support(const char *dev_dir)
+{
+#ifdef HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE
+	struct udev *udev;
+	const char *udev_dev_dir;
+	size_t udev_dev_dir_len;
+	int dirs_diff;
+#endif
+	const char *env;
+
+	if (_switches[NOUDEVSYNC_ARG])
+		dm_udev_set_sync_support(0);
+
+	if (!_udev_cookie) {
+		env = getenv(DM_UDEV_COOKIE_ENV_VAR_NAME);
+		if (env && *env && (_udev_cookie = _get_cookie_value(env)))
+			log_debug("Using udev transaction 0x%08" PRIX32
+				  " defined by %s environment variable.",
+				   _udev_cookie,
+				   DM_UDEV_COOKIE_ENV_VAR_NAME);
+	}
+	else if (_switches[UDEVCOOKIE_ARG])
+		log_debug("Using udev transaction 0x%08" PRIX32
+			  " defined by --udevcookie option.",
+			  _udev_cookie);
+
+#ifdef HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE
+	if (!(udev = udev_new()) ||
+	    !(udev_dev_dir = udev_get_dev_path(udev)) ||
+	    !*udev_dev_dir) {
+		log_error("Could not get udev dev path.");
+		return 0;
+	}
+	udev_dev_dir_len = strlen(udev_dev_dir);
+
+	/*
+	 * Normally, there's always a fallback action by libdevmapper if udev
+	 * has not done its job correctly, e.g. the nodes were not created.
+	 * If using udev transactions by specifying existing cookie value,
+	 * we need to disable node creation by libdevmapper completely,
+	 * disabling any fallback actions, since any synchronisation happens
+	 * at the end of the transaction only. We need to do this to prevent
+	 * races between udev and libdevmapper but only in case udev "dev path"
+	 * is the same as "dev path" used by libdevmapper.
+	 */
+
+	/* There's always a slash at the end of dev_dir. But check udev_dev_dir! */
+	if (udev_dev_dir[udev_dev_dir_len - 1] != '/')
+		dirs_diff = strncmp(dev_dir, udev_dev_dir, udev_dev_dir_len);
+	else
+		dirs_diff = strcmp(dev_dir, udev_dev_dir);
+
+	_udev_only = _udev_cookie && !dirs_diff;
+
+	if (dirs_diff) {
+		log_debug("The path %s used for creating device nodes that is "
+			  "set via DM_DEV_DIR environment variable differs from "
+			  "the path %s that is used by udev. All warnings "
+			  "about udev not working correctly while processing "
+			  "particular nodes will be suppressed. These nodes "
+			  "and symlinks will be managed in each directory "
+			  "separately.", dev_dir, udev_dev_dir);
+		dm_udev_set_checking(0);
+	}
+
+	udev_unref(udev);
+#endif
+	return 1;
+}
+
+static int _udevcreatecookie(int argc, char **argv,
+				  void *data __attribute((unused)))
+{
+	uint32_t cookie;
+
+	if (!dm_udev_create_cookie(&cookie))
+		return 0;
+
+	printf("0x%08" PRIX32 "\n", cookie);
+
+	return 1;
+}
+
+static int _udevreleasecookie(int argc, char **argv,
+				void *data __attribute((unused)))
+{
+	if (argv[1] && !(_udev_cookie = _get_cookie_value(argv[1])))
+		return 0;
+
+	if (!_udev_cookie) {
+		log_error("No udev transaction cookie given.");
+		return 0;
+	}
+
+	return dm_udev_wait(_udev_cookie);
+}
 
 static char _yes_no_prompt(const char *prompt, ...)
 {
@@ -1059,6 +1196,12 @@
 		udev_flags |= DM_UDEV_DISABLE_DM_RULES_FLAG |
 			      DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG;
 
+	if (_udev_cookie) {
+		cookie = _udev_cookie;
+		if (_udev_only)
+			udev_flags |= DM_UDEV_DISABLE_LIBRARY_FALLBACK;
+	}
+
 	if (udev_wait_flag && !dm_task_set_cookie(dmt, &cookie, udev_flags))
 		goto out;
 
@@ -1068,7 +1211,7 @@
 		r = _display_info(dmt);
 
       out:
-	if (udev_wait_flag)
+	if (!_udev_cookie && udev_wait_flag)
 		(void) dm_udev_wait(cookie);
 
 	dm_task_destroy(dmt);
@@ -2559,6 +2702,8 @@
 	{"table", "[<device>] [--target <target_type>] [--showkeys]", 0, 1, _status},
 	{"wait", "<device> [<event_nr>]", 0, 2, _wait},
 	{"mknodes", "[<device>]", 0, 1, _mknodes},
+	{"udevcreatecookie", "", 0, 0, _udevcreatecookie},
+	{"udevreleasecookie", "[<cookie>]", 0, 1, _udevreleasecookie},
 	{"udevflags", "<cookie>", 1, 1, _udevflags},
 	{"udevcomplete", "<cookie>", 1, 1, _udevcomplete},
 	{"udevcomplete_all", "", 0, 0, _udevcomplete_all},
@@ -2577,7 +2722,7 @@
 	fprintf(out, "Usage:\n\n");
 	fprintf(out, "dmsetup [--version] [-v|--verbose [-v|--verbose ...]]\n"
 		"        [-r|--readonly] [--noopencount] [--nolockfs] [--inactive]\n"
-		"        [--noudevrules] [--noudevsync] [-y|--yes]\n"
+		"        [--udevcookie] [--noudevrules] [--noudevsync] [-y|--yes]\n"
 		"        [--readahead [+]<sectors>|auto|none]\n"
 		"        [-c|-C|--columns] [-o <fields>] [-O|--sort <sort_fields>]\n"
 		"        [--nameprefixes] [--noheadings] [--separator <separator>]\n\n");
@@ -2812,6 +2957,8 @@
 	return 0;
 }
 
+
+
 static int _process_losetup_switches(const char *base, int *argc, char ***argv,
 				     const char *dev_dir)
 {
@@ -2946,6 +3093,7 @@
 		{"nolockfs", 0, &ind, NOLOCKFS_ARG},
 		{"noopencount", 0, &ind, NOOPENCOUNT_ARG},
 		{"notable", 0, &ind, NOTABLE_ARG},
+		{"udevcookie", 1, &ind, UDEVCOOKIE_ARG},
 		{"noudevrules", 0, &ind, NOUDEVRULES_ARG},
 		{"noudevsync", 0, &ind, NOUDEVSYNC_ARG},
 		{"options", 1, &ind, OPTIONS_ARG},
@@ -3059,6 +3207,10 @@
 		}
 		if (c == 'y' || ind == YES_ARG)
 			_switches[YES_ARG]++;
+		if (ind == UDEVCOOKIE_ARG) {
+			_switches[UDEVCOOKIE_ARG]++;
+			_udev_cookie = _get_cookie_value(optarg);
+		}
 		if (ind == NOUDEVRULES_ARG)
 			_switches[NOUDEVRULES_ARG]++;
 		if (ind == NOUDEVSYNC_ARG)
@@ -3160,11 +3312,10 @@
 	struct command *c;
 	int r = 1;
 	const char *dev_dir;
-	const char *disable_udev_checking;
 
 	(void) setlocale(LC_ALL, "");
 
-	dev_dir = getenv ("DM_DEV_DIR");
+	dev_dir = getenv (DM_DEV_DIR_ENV_VAR_NAME);
 	if (dev_dir && *dev_dir) {
 		if (!dm_set_dev_dir(dev_dir)) {
 			fprintf(stderr, "Invalid DM_DEV_DIR environment variable value.\n");
@@ -3207,13 +3358,10 @@
 	if (_switches[COLS_ARG] && !_report_init(c))
 		goto out;
 
-	if (_switches[NOUDEVSYNC_ARG])
-		dm_udev_set_sync_support(0);
-
-	disable_udev_checking = getenv("DM_UDEV_DISABLE_CHECKING");
-	if ((disable_udev_checking && *disable_udev_checking) &&
-	    !strcmp(disable_udev_checking, "1"))
-		dm_udev_set_checking(0);
+	#ifdef UDEV_SYNC_SUPPORT
+	if (!_set_up_udev_support(dev_dir))
+		goto out;
+	#endif
 
       doit:
 	if (!c->fn(argc, argv, NULL)) {



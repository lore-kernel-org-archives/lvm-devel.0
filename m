From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 11 Jan 2010 16:14:10 +0100
Subject: [PATCH 1/4] Add support for lvm2 to disable udev checking on request
In-Reply-To: <4B4746C9.1000808@redhat.com>
References: <4B4746C9.1000808@redhat.com>
Message-ID: <4B4B4042.3060609@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

...debug messages added.

Peter


diff --git a/lib/activate/fs.c b/lib/activate/fs.c
index d1691b8..1f75c40 100644
--- a/lib/activate/fs.c
+++ b/lib/activate/fs.c
@@ -166,7 +166,7 @@ static int _mk_link(const char *dev_dir, const char *vg_name,
 			return 0;
 		}
 
-		if (dm_udev_get_sync_support() && check_udev) {
+		if (dm_udev_get_sync_support() && udev_checking() && check_udev) {
 			/* Check udev created the correct link. */
 			if (!stat(link_path, &buf_lp) &&
 			    !stat(lv_path, &buf)) {
@@ -190,7 +190,7 @@ static int _mk_link(const char *dev_dir, const char *vg_name,
 			log_sys_error("unlink", lv_path);
 			return 0;
 		}
-	} else if (dm_udev_get_sync_support() && check_udev)
+	} else if (dm_udev_get_sync_support() && udev_checking() && check_udev)
 		log_warn("The link %s should had been created by udev "
 			  "but it was not found. Falling back to "
 			  "direct link creation.", lv_path);
@@ -221,7 +221,7 @@ static int _rm_link(const char *dev_dir, const char *vg_name,
 
 	if (lstat(lv_path, &buf) && errno == ENOENT)
 		return 1;
-	else if (dm_udev_get_sync_support() && check_udev)
+	else if (dm_udev_get_sync_support() && udev_checking() && check_udev)
 		log_warn("The link %s should have been removed by udev "
 			 "but it is still present. Falling back to "
 			 "direct link removal.", lv_path);
diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index 45a2e35..9d4be4e 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -39,6 +39,7 @@ static int _background_polling = DEFAULT_BACKGROUND_POLLING;
 static int _ignore_suspended_devices = 0;
 static int _error_message_produced = 0;
 static unsigned _is_static = 0;
+static int _udev_checking = 1;
 
 void init_verbose(int level)
 {
@@ -112,6 +113,14 @@ void init_is_static(unsigned value)
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
@@ -210,3 +219,8 @@ unsigned is_static(void)
 {
 	return _is_static;
 }
+
+int udev_checking(void)
+{
+	return _udev_checking;
+}
diff --git a/lib/misc/lvm-globals.h b/lib/misc/lvm-globals.h
index 1ce9c56..0134c32 100644
--- a/lib/misc/lvm-globals.h
+++ b/lib/misc/lvm-globals.h
@@ -36,6 +36,7 @@ void init_background_polling(int polling);
 void init_ignore_suspended_devices(int ignore);
 void init_error_message_produced(int produced);
 void init_is_static(unsigned value);
+void init_udev_checking(int checking);
 
 void set_cmd_name(const char *cmd_name);
 
@@ -54,6 +55,7 @@ int background_polling(void);
 int ignore_suspended_devices(void);
 const char *log_command_name(void);
 unsigned is_static(void);
+int udev_checking(void);
 
 #define DMEVENTD_MONITOR_IGNORE -1
 int dmeventd_monitor_mode(void);
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index d4e7ea4..a33eaaf 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -909,6 +909,19 @@ static void _apply_settings(struct cmd_context *cmd)
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
@@ -1003,6 +1016,8 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	log_debug("O_DIRECT will be used");
 #endif
 
+	_set_udev_checking();
+
 	if ((ret = _process_common_commands(cmd)))
 		goto_out;
 



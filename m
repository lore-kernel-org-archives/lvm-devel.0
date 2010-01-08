From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 08 Jan 2010 15:52:57 +0100
Subject: [PATCH 1/4] Add support for lvm2 to disable udev checking on request
Message-ID: <4B4746C9.1000808@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The same as previous patch, but now for LVM2 where we can use LVM_UDEV_DISABLE_CHECKING=1 env
var for checking VG/LV symlinks (we still use DM_UDEV_DISABLE_CHECKING=1 for /dev/mapper
content).

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
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index a076e93..16d793c 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -72,6 +72,14 @@ static int _get_env_vars(struct cmd_context *cmd)
 		}
 	}
 
+	if ((e = getenv("DM_UDEV_DISABLE_CHECKING")) &&
+	    !strcmp(e, "1"))
+		dm_udev_set_checking(0);
+
+	if ((e = getenv("LVM_UDEV_DISABLE_CHECKING")) &&
+	    !strcmp(e, "1"))
+		init_udev_checking(0);
+
 	return 1;
 }
 
diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index 45a2e35..9c3ac32 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -39,6 +39,7 @@ static int _background_polling = DEFAULT_BACKGROUND_POLLING;
 static int _ignore_suspended_devices = 0;
 static int _error_message_produced = 0;
 static unsigned _is_static = 0;
+static int _udev_checking = 1;
 
 void init_verbose(int level)
 {
@@ -112,6 +113,11 @@ void init_is_static(unsigned value)
 	_is_static = value;
 }
 
+void init_udev_checking(int checking)
+{
+	_udev_checking = checking;
+}
+
 void set_cmd_name(const char *cmd)
 {
 	strncpy(_cmd_name, cmd, sizeof(_cmd_name));
@@ -210,3 +216,8 @@ unsigned is_static(void)
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



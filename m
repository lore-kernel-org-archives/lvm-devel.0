From: David Teigland <teigland@sourceware.org>
Date: Fri, 16 Aug 2019 15:43:26 -0400
Subject: master - pvscan: disable sleeping and retrying for udev
Message-ID: <201908161943.x7GJhQD6008616@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0534cd9cd4066c88a7dd815f2f3206a177169334
Commit:        0534cd9cd4066c88a7dd815f2f3206a177169334
Parent:        61fce72a114d23b98bfd4a9d457e3d55297455ef
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Aug 16 14:35:17 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Aug 16 14:41:26 2019 -0500

pvscan: disable sleeping and retrying for udev

When systemd is running pvscans, udev may not be
entirely initialized, so the pvscan should not
sleep and retry waiting for udev info.
---
 lib/device/dev-type.c  |    3 +++
 lib/misc/lvm-globals.c |   11 +++++++++++
 lib/misc/lvm-globals.h |    2 ++
 tools/pvscan.c         |    7 +++++++
 4 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 4e35220..ebe0f99 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -1118,6 +1118,9 @@ static struct udev_device *_udev_get_dev(struct device *dev)
 			   i + 1, UDEV_DEV_IS_COMPONENT_ITERATION_COUNT,
 			   i * UDEV_DEV_IS_COMPONENT_USLEEP);
 
+		if (!udev_sleeping())
+			break;
+
 		usleep(UDEV_DEV_IS_COMPONENT_USLEEP);
 		i++;
 	}
diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index eb99cf5..06855ff 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -47,6 +47,7 @@ static int _ignore_lvm_mirrors = DEFAULT_IGNORE_LVM_MIRRORS;
 static int _error_message_produced = 0;
 static unsigned _is_static = 0;
 static int _udev_checking = 1;
+static int _udev_sleeping = 1;
 static int _retry_deactivation = DEFAULT_RETRY_DEACTIVATION;
 static int _activation_checks = 0;
 static char _sysfs_dir_path[PATH_MAX] = "";
@@ -186,6 +187,11 @@ void init_udev_checking(int checking)
 		log_debug_activation("LVM udev checking disabled");
 }
 
+void init_udev_sleeping(int sleeping)
+{
+	_udev_sleeping = sleeping;
+}
+
 void init_retry_deactivation(int retry)
 {
 	_retry_deactivation = retry;
@@ -353,6 +359,11 @@ int udev_checking(void)
 	return _udev_checking;
 }
 
+int udev_sleeping(void)
+{
+	return _udev_sleeping;
+}
+
 int retry_deactivation(void)
 {
 	return _retry_deactivation;
diff --git a/lib/misc/lvm-globals.h b/lib/misc/lvm-globals.h
index 921ae7e..a54001c 100644
--- a/lib/misc/lvm-globals.h
+++ b/lib/misc/lvm-globals.h
@@ -46,6 +46,7 @@ void init_ignore_lvm_mirrors(int scan);
 void init_error_message_produced(int produced);
 void init_is_static(unsigned value);
 void init_udev_checking(int checking);
+void init_udev_sleeping(int sleeping);
 void init_pv_min_size(uint64_t sectors);
 void init_activation_checks(int checks);
 void init_retry_deactivation(int retry);
@@ -77,6 +78,7 @@ const char *log_command_info(void);
 const char *log_command_file(void);
 unsigned is_static(void);
 int udev_checking(void);
+int udev_sleeping(void);
 const char *sysfs_dir_path(void);
 uint64_t pv_min_size(void);
 int activation_checks(void);
diff --git a/tools/pvscan.c b/tools/pvscan.c
index ac41500..bfa5a83 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -914,6 +914,13 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 	dm_list_init(&rem_devs);
 	dm_list_init(&vgnames);
 
+	/*
+	 * When systemd/udev run pvscan --cache commands, those commands
+	 * should not wait on udev info since the udev info may not be
+	 * complete until the pvscan --cache command is done.
+	 */
+	init_udev_sleeping(0);
+
 	if (do_activate)
 		complete_vgnames = &vgnames;
 



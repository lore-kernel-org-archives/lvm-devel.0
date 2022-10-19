From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 19 Oct 2022 19:23:12 +0000 (GMT)
Subject: main - lvmnotify.c: Check to see if dbus daemon is running
Message-ID: <20221019192312.D514F3858D3C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0f56c1ad1262857961aff7b5a0ae6593a3de8db3
Commit:        0f56c1ad1262857961aff7b5a0ae6593a3de8db3
Parent:        04097d9f620b5e22ae8fe2884110249116f3dab5
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Oct 19 12:46:45 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 19 14:22:12 2022 -0500

lvmnotify.c: Check to see if dbus daemon is running

The lvm dbus daemon will auto activate on dbus API calls.  To
prevent the dbus daemon starting when lvm command line tools are
being used we will check to see if the daemon is running first.
If the daemon is not running, we will not notify the daemon.

For this check to work it requires the changes done previously
with commit: 3fdf4493481ff8baae2ac5416dce6d05b69e6b28

Reviewed-by: David Teigland <teigland@redhat.com>
---
 lib/notify/lvmnotify.c | 68 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 68 insertions(+)

diff --git a/lib/notify/lvmnotify.c b/lib/notify/lvmnotify.c
index e24b0acb1..7ac74d755 100644
--- a/lib/notify/lvmnotify.c
+++ b/lib/notify/lvmnotify.c
@@ -15,17 +15,79 @@
 #define LVM_DBUS_DESTINATION "com.redhat.lvmdbus1"
 #define LVM_DBUS_PATH        "/com/redhat/lvmdbus1/Manager"
 #define LVM_DBUS_INTERFACE   "com.redhat.lvmdbus1.Manager"
+#define LVM_DBUS_LOCK_FILE   "/var/lock/lvm/lvmdbusd"
+#define LVM_DBUS_LOCK_FILE_ENV_KEY        "LVM_DBUSD_LOCKFILE"
 #define SD_BUS_SYSTEMD_NO_SUCH_UNIT_ERROR "org.freedesktop.systemd1.NoSuchUnit"
 #define SD_BUS_DBUS_SERVICE_UNKNOWN_ERROR "org.freedesktop.DBus.Error.ServiceUnknown"
 
 #ifdef NOTIFYDBUS_SUPPORT
 #include <systemd/sd-bus.h>
+#include <fcntl.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <errno.h>
 
 int lvmnotify_is_supported(void)
 {
 	return 1;
 }
 
+static int lvmdbusd_running(void)
+{
+	int fd = 0;
+	int rc = 0;
+	int errno_cpy = 0;
+	int running = 0;
+	const char *lockfile = NULL;
+
+	/*
+	 * lvm dbusd uses a lock file with a lock on it, thus to determine if the daemon is running
+	 * requires that you attempt to lock the file as well.  Thus the existence of the file does
+	 * not mean it's running, but the absence of the file does indicate it's not running.
+	 *
+	 * See lvmdbusd for more details.
+	 */
+
+	lockfile = getenv(LVM_DBUS_LOCK_FILE_ENV_KEY);
+	if (!lockfile) {
+		lockfile = LVM_DBUS_LOCK_FILE;
+	}
+
+	errno = 0;
+	fd = open(lockfile, O_RDWR);
+	if (-1 == fd) {
+		errno_cpy = errno;
+		if (errno_cpy == ENOENT) {
+			return 0;
+		} else {
+			/* Safest option is to return running when we encounter unexpected errors */
+			log_debug_dbus("Unexpected errno: %d on lockfile open, returning running", errno_cpy);
+			return 1;
+		}
+	}
+
+	/* Need to ensure we close lock FD now */
+	errno = 0;
+	rc = lockf(fd, F_TLOCK|F_TEST, 0);
+	if (-1 != rc) {
+		/* Not locked, thus not running */
+		running = 0;
+	} else {
+		errno_cpy = errno;
+		if (errno_cpy == EACCES || errno_cpy == EAGAIN) {
+			/* Locked, so daemon is running */
+			running = 1;
+		} else {
+			log_debug_dbus("Unexpected errno: %d on lockf, returning running", errno_cpy);
+			running = 1 ;
+		}
+	}
+
+	close(fd);
+	return running;
+}
+
+
 void lvmnotify_send(struct cmd_context *cmd)
 {
 	static const char _dbus_notification_failed_msg[] = "D-Bus notification failed";
@@ -43,6 +105,12 @@ void lvmnotify_send(struct cmd_context *cmd)
 	cmd->lv_notify = 0;
 	cmd->pv_notify = 0;
 
+	/* If lvmdbusd isn't running, don't notify as you will start it as it will auto activate */
+	if (!lvmdbusd_running()) {
+		log_debug_dbus("dbus damon not running, not notifying");
+		return;
+	}
+
 	cmd_name = get_cmd_name();
 
 	ret = sd_bus_open_system(&bus);


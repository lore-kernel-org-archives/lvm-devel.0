From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 15 Nov 2016 09:09:34 +0000 (UTC)
Subject: master - dbus: also recognize error state for missing service that comes from original D-Bus
Message-ID: <20161115090934.BA80B60E3C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cd0736a94554750e0077f390770212c68da8fa4e
Commit:        cd0736a94554750e0077f390770212c68da8fa4e
Parent:        68d6d342f83f00784b53dda254d66875e134808d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Nov 15 10:09:11 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Nov 15 10:09:11 2016 +0100

dbus: also recognize error state for missing service that comes from original D-Bus

---
 lib/notify/lvmnotify.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/notify/lvmnotify.c b/lib/notify/lvmnotify.c
index ac0ca73..1daee1e 100644
--- a/lib/notify/lvmnotify.c
+++ b/lib/notify/lvmnotify.c
@@ -15,7 +15,8 @@
 #define LVM_DBUS_DESTINATION "com.redhat.lvmdbus1"
 #define LVM_DBUS_PATH        "/com/redhat/lvmdbus1/Manager"
 #define LVM_DBUS_INTERFACE   "com.redhat.lvmdbus1.Manager"
-#define SD_BUS_NO_SUCH_UNIT_ERROR "org.freedesktop.systemd1.NoSuchUnit"
+#define SD_BUS_SYSTEMD_NO_SUCH_UNIT_ERROR "org.freedesktop.systemd1.NoSuchUnit"
+#define SD_BUS_DBUS_SERVICE_UNKNOWN_ERROR "org.freedesktop.DBus.Error.ServiceUnknown"
 
 #ifdef NOTIFYDBUS_SUPPORT
 #include <systemd/sd-bus.h>
@@ -63,7 +64,8 @@ void lvmnotify_send(struct cmd_context *cmd)
 				 cmd_name);
 
 	if (ret < 0) {
-		if (sd_bus_error_has_name(&error, SD_BUS_NO_SUCH_UNIT_ERROR))
+		if (sd_bus_error_has_name(&error, SD_BUS_SYSTEMD_NO_SUCH_UNIT_ERROR) ||
+		    sd_bus_error_has_name(&error, SD_BUS_DBUS_SERVICE_UNKNOWN_ERROR))
 			log_debug_dbus("%s: %s", _dbus_notification_failed_msg, error.message);
 		else
 			log_warn("WARNING: %s: %s", _dbus_notification_failed_msg, error.message);



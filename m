From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 14 Nov 2016 13:53:20 +0000 (UTC)
Subject: master - dbus: only log msg as debug if lvm2-lvmdbusd unit missing for D-Bus notification
Message-ID: <20161114135320.6A1BC60EED@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=68d6d342f83f00784b53dda254d66875e134808d
Commit:        68d6d342f83f00784b53dda254d66875e134808d
Parent:        e7da8e7e1f27c2ee193a2dfc20819076c2bd19bf
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Nov 14 14:46:44 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Nov 14 14:53:19 2016 +0100

dbus: only log msg as debug if lvm2-lvmdbusd unit missing for D-Bus notification

Do not emit warning message but only log debug message if
lvm2-lvmdbusd.service unit is missing and at the same time
we have global/notify_dbus=1 (which is used by default if we
configured sources with "--enable-notify-dbus"). We don't want
hard dependency between LVM2 and lvmdbusd so it's enough to log
only debug message in this case.
---
 WHATS_NEW              |    1 +
 lib/notify/lvmnotify.c |    7 ++++++-
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 57c382f..7f8801a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.168 - 
 ====================================
+  Only log msg as debug if lvm2-lvmdbusd unit missing for D-Bus notification.
   Missing stripe filler now could be also 'zero'.
   lvconvert --repair accepts --interval and --background option.
   More efficiently prepare _rmeta devices when creating a new raid LV.
diff --git a/lib/notify/lvmnotify.c b/lib/notify/lvmnotify.c
index e9f8e29..ac0ca73 100644
--- a/lib/notify/lvmnotify.c
+++ b/lib/notify/lvmnotify.c
@@ -15,6 +15,7 @@
 #define LVM_DBUS_DESTINATION "com.redhat.lvmdbus1"
 #define LVM_DBUS_PATH        "/com/redhat/lvmdbus1/Manager"
 #define LVM_DBUS_INTERFACE   "com.redhat.lvmdbus1.Manager"
+#define SD_BUS_NO_SUCH_UNIT_ERROR "org.freedesktop.systemd1.NoSuchUnit"
 
 #ifdef NOTIFYDBUS_SUPPORT
 #include <systemd/sd-bus.h>
@@ -26,6 +27,7 @@ int lvmnotify_is_supported(void)
 
 void lvmnotify_send(struct cmd_context *cmd)
 {
+	static const char _dbus_notification_failed_msg[] = "D-Bus notification failed";
 	sd_bus *bus = NULL;
 	sd_bus_message *m = NULL;
 	sd_bus_error error = SD_BUS_ERROR_NULL;
@@ -61,7 +63,10 @@ void lvmnotify_send(struct cmd_context *cmd)
 				 cmd_name);
 
 	if (ret < 0) {
-		log_warn("WARNING: D-Bus notification failed: %s", error.message);
+		if (sd_bus_error_has_name(&error, SD_BUS_NO_SUCH_UNIT_ERROR))
+			log_debug_dbus("%s: %s", _dbus_notification_failed_msg, error.message);
+		else
+			log_warn("WARNING: %s: %s", _dbus_notification_failed_msg, error.message);
 		goto out;
 	}
 



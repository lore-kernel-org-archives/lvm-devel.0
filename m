From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 20 Apr 2010 16:51:44 +0200
Subject: [PATCH] Utilize new IMPORT{db} udev rule to repopulate udev db for spurious events
Message-ID: <4BCDBF80.3010902@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Udev v152 was released just today. This one adds new IMPORT{db}="<property_name>"
udev rule that reads a single value from udev database identified by property_name.

We can use this rule to (partially) support artificial events (e.g. the ones
generated as a result of "udevadm trigger" call or the "watch" udev rule). These
spurious events do not have the flags set which we use to direct the rule
application. The old values could not be read from udev db because it was always
cleared on ADD and CHANGE events making.

Now, we can use new IMPORT{db} rule to repopulate udev db content if such
situation occurs. I've added new DM_UDEV_PRIMARY_SOURCE_FLAG so we can easily
separate events and identify the ones which originate in libdevmapper. For all
the other ones, we will try to reuse existing information that is currently in
udev db.

However, we still can't synchronize with those spurious events, but at least
it is a step forward and one problem less.

(Looking more at the udev changelog, "udevadm trigger" generates CHANGE events
by default from now on, so this helps us a little too - people calling *plain*
udevadm trigger won't lose their nodes/symlinks for DM devices anymore. People
can still call "udevadm trigger --action=add" though and need to be aware of
what the consequences of reacting to ADD events are for DM devices!)

Peter
---
 libdm/ioctl/libdm-iface.c |   59 +++++++++++++++++++++++++++-----------------
 libdm/libdevmapper.h      |   10 +++++++
 tools/dmsetup.c           |    3 +-
 udev/10-dm.rules.in       |   22 ++++++++++++++++
 4 files changed, 70 insertions(+), 24 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index c37ccbb..5961607 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -1736,31 +1736,44 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 			    dmt->type == DM_DEVICE_REMOVE ||
 			    dmt->type == DM_DEVICE_RENAME;
 
-	/*
-	 * Prevent udev vs. libdevmapper race when processing nodes and
-	 * symlinks. This can happen when the udev rules are installed and
-	 * udev synchronisation code is enabled in libdevmapper but the
-	 * software using libdevmapper does not make use of it (by not calling
-	 * dm_task_set_cookie before). We need to instruct the udev rules not
-	 * to be applied at all in this situation so we can gracefully fallback
-	 * to libdevmapper's node and symlink creation code.
-	 */
-	if (dm_udev_get_sync_support() && !dmt->cookie_set && ioctl_with_uevent) {
-		log_debug("Cookie value is not set while trying to call "
-			  "DM_DEVICE_RESUME, DM_DEVICE_REMOVE or DM_DEVICE_RENAME "
-			  "ioctl. Please, consider using libdevmapper's udev "
-			  "synchronisation interface or disable it explicitly "
-			  "by calling dm_udev_set_sync_support(0).");
-		log_debug("Switching off device-mapper and all subsystem related "
-			  "udev rules. Falling back to libdevmapper node creation.");
+	if (ioctl_with_uevent && dm_cookie_supported()) {
 		/*
-		 * Disable general dm and subsystem rules but keep dm disk rules
-		 * if not flagged out explicitly before. We need /dev/disk content
-		 * for the software that expects it.
-		*/
-		dmi->event_nr |= (DM_UDEV_DISABLE_DM_RULES_FLAG |
-				  DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG) <<
+		 * Always mark events coming from libdevmapper as
+		 * "primary sourced". This is needed to distinguish
+		 * any spurious events so we can act appropriately.
+		 * This needs to be applied even when udev_sync is
+		 * not used because udev flags could be used alone.
+		 */
+		dmi->event_nr |= DM_UDEV_PRIMARY_SOURCE_FLAG <<
 				 DM_UDEV_FLAGS_SHIFT;
+
+		/*
+		 * Prevent udev vs. libdevmapper race when processing nodes
+		 * and symlinks. This can happen when the udev rules are
+		 * installed and udev synchronisation code is enabled in
+		 * libdevmapper but the software using libdevmapper does not
+		 * make use of it (by not calling dm_task_set_cookie before).
+		 * We need to instruct the udev rules not to be applied at
+		 * all in this situation so we can gracefully fallback to
+		 * libdevmapper's node and symlink creation code.
+		 */
+		if (!dmt->cookie_set && dm_udev_get_sync_support()) {
+			log_debug("Cookie value is not set while trying to call "
+				  "DM_DEVICE_RESUME, DM_DEVICE_REMOVE or DM_DEVICE_RENAME "
+				  "ioctl. Please, consider using libdevmapper's udev "
+				  "synchronisation interface or disable it explicitly "
+				  "by calling dm_udev_set_sync_support(0).");
+			log_debug("Switching off device-mapper and all subsystem related "
+				  "udev rules. Falling back to libdevmapper node creation.");
+			/*
+			 * Disable general dm and subsystem rules but keep
+			 * dm disk rules if not flagged out explicitly before.
+			 * We need /dev/disk content for the software that expects it.
+			*/
+			dmi->event_nr |= (DM_UDEV_DISABLE_DM_RULES_FLAG |
+					  DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG) <<
+					 DM_UDEV_FLAGS_SHIFT;
+		}
 	}
 
 	log_debug("dm %s %s %s%s%s %s%.0d%s%.0d%s"
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 2435774..60737ed 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1092,6 +1092,16 @@ void dm_report_field_set_value(struct dm_report_field *field, const void *value,
  * udev does something improperly.
  */
 #define DM_UDEV_DISABLE_LIBRARY_FALLBACK 0x0020
+/*
+ * DM_UDEV_PRIMARY_SOURCE_FLAG is automatically appended by
+ * libdevmapper for all ioctls generating udev uevents. Once used in
+ * udev rules, we know if this is a real "primary sourced" event or not.
+ * We need to distinguish real events originated in libdevmapper from
+ * any spurious events to gather all missing information (e.g. events
+ * generated as a result of "udevadm trigger" command or as a result
+ * of the "watch" udev rule).
+ */
+#define DM_UDEV_PRIMARY_SOURCE_FLAG 0x0040
 
 int dm_cookie_supported(void);
 
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 0f02f3c..32d1521 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -842,7 +842,8 @@ static int _udevflags(int args, char **argv, void *data __attribute((unused)))
 					      "DISABLE_OTHER_RULES",
 					      "LOW_PRIORITY",
 					      "DISABLE_LIBRARY_FALLBACK",
-					       0, 0};
+					      "PRIMARY_SOURCE",
+					       0};
 
 	if (!(cookie = _get_cookie_value(argv[1])))
 		return 0;
diff --git a/udev/10-dm.rules.in b/udev/10-dm.rules.in
index 7cffc0b..1a1379d 100644
--- a/udev/10-dm.rules.in
+++ b/udev/10-dm.rules.in
@@ -44,6 +44,28 @@ ENV{DM_COOKIE}=="?*", IMPORT{program}="$env{DM_SBIN_PATH}/dmsetup udevflags $env
 
 ACTION!="add|change", GOTO="dm_end"
 
+# There is no cookie set nor any flags encoded in events not originating
+# in libdevmapper so we need to detect this and try to behave correctly.
+# For such spurious events, regenerate all flags from current udev databse content
+# (this information would normally be inaccessible for ADD and CHANGE events).
+ENV{DM_UDEV_PRIMARY_SOURCE_FLAG}=="1", GOTO="dm_flags_done"
+IMPORT{db}="DM_UDEV_DISABLE_DM_RULES_FLAG"
+IMPORT{db}="DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG"
+IMPORT{db}="DM_UDEV_DISABLE_DISK_RULES_FLAG"
+IMPORT{db}="DM_UDEV_DISABLE_OTHER_RULES_FLAG"
+IMPORT{db}="DM_UDEV_LOW_PRIORITY_FLAG"
+IMPORT{db}="DM_UDEV_DISABLE_LIBRARY_FALLBACK_FLAG"
+IMPORT{db}="DM_UDEV_FLAG7"
+IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG0"
+IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG1"
+IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG2"
+IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG3"
+IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG4"
+IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG5"
+IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG6"
+IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG7"
+LABEL="dm_flags_done"
+
 # Normally, we operate on "change" events only. But when
 # coldplugging, there's an "add" event present. We have to
 # recognize this and do our actions in this particular



From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 28 Apr 2010 13:37:40 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdevmapper.h libdm ...
Message-ID: <20100428133740.30352.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-04-28 13:37:38

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdevmapper.h 
	libdm/ioctl    : libdm-iface.c 
	tools          : dmsetup.c 
	udev           : 10-dm.rules.in 

Log message:
	Add support for new IMPORT{db} udev rule.
	
	This rule appeared in udev v152 and it helps us to support spurious events
	where we didn't have any flags set (events originated in udevadm trigger
	or the watch rule). These flags are important to direct the rule application.
	Now, with the help of this rule, we can regenerate old udev db content.
	To implement this correctly, we need to flag all proper DM udev events with
	DM_UDEV_PRIMARY_SOURCE_FLAG. That happens automatically for all ioctls
	generating events originated in libdevmapper.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.363&r2=1.364
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.111&r2=1.112
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.70&r2=1.71
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.137&r2=1.138
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/10-dm.rules.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/WHATS_NEW_DM	2010/04/26 09:05:50	1.363
+++ LVM2/WHATS_NEW_DM	2010/04/28 13:37:36	1.364
@@ -1,5 +1,7 @@
 Version 1.02.47 -
 =================================
+  Add support for new IMPORT{db} udev rule.
+  Add DM_UDEV_PRIMARY_SOURCE_FLAG udev flag to recognize proper DM events.
   Also include udev libs in libdevmapper.pc when udev_sync is enabled.
   Cache bitset locations to speed up _calc_states.
   Add a regex optimisation pass for shared character prefixes.
--- LVM2/libdm/libdevmapper.h	2010/04/20 13:58:22	1.111
+++ LVM2/libdm/libdevmapper.h	2010/04/28 13:37:36	1.112
@@ -1094,6 +1094,16 @@
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
 
--- LVM2/libdm/ioctl/libdm-iface.c	2010/04/07 15:57:20	1.70
+++ LVM2/libdm/ioctl/libdm-iface.c	2010/04/28 13:37:37	1.71
@@ -1736,31 +1736,44 @@
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
--- LVM2/tools/dmsetup.c	2010/04/07 15:57:20	1.137
+++ LVM2/tools/dmsetup.c	2010/04/28 13:37:37	1.138
@@ -842,7 +842,8 @@
 					      "DISABLE_OTHER_RULES",
 					      "LOW_PRIORITY",
 					      "DISABLE_LIBRARY_FALLBACK",
-					       0, 0};
+					      "PRIMARY_SOURCE",
+					       0};
 
 	if (!(cookie = _get_cookie_value(argv[1])))
 		return 0;
--- LVM2/udev/10-dm.rules.in	2009/12/07 12:03:47	1.7
+++ LVM2/udev/10-dm.rules.in	2010/04/28 13:37:37	1.8
@@ -44,6 +44,28 @@
 
 ACTION!="add|change", GOTO="dm_end"
 
+# There is no cookie set nor any flags encoded in events not originating
+# in libdevmapper so we need to detect this and try to behave correctly.
+# For such spurious events, regenerate all flags from current udev database content
+# (this information would normally be inaccessible for spurious ADD and CHANGE events).
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



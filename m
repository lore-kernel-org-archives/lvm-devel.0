From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 18 Aug 2010 13:11:58 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/ioctl/libdm-iface.c
Message-ID: <20100818131158.31496.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-08-18 13:11:57

Modified files:
	.              : WHATS_NEW_DM 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Fix dm-mod autoloading logic to not assume control node is set correctly.
	
	We can't rely on the fact that udev should prepare the node with right major
	and minor number to trigger the module autoloading. We have to take into
	account that the node could be missing or it could exist with improper
	major and minor number assigned (e.g. from previous kernel versions in
	an environment with static nodes and without udev). Make any corrections
	if needed!

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.410&r2=1.411
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.80&r2=1.81

--- LVM2/WHATS_NEW_DM	2010/08/16 22:54:35	1.410
+++ LVM2/WHATS_NEW_DM	2010/08/18 13:11:56	1.411
@@ -1,5 +1,6 @@
 Version 1.02.54 - 
 ================================
+  Fix dm-mod autoloading logic to not assume control node is set correctly.
   Add dmeventd/executable to lvm.conf to test alternative dmeventd.
   Export dm_event_handler_set_dmeventd_path to override built-in dmeventd path.
   Generate libdevmapper-event exported symbols.
--- LVM2/libdm/ioctl/libdm-iface.c	2010/08/16 11:13:18	1.80
+++ LVM2/libdm/ioctl/libdm-iface.c	2010/08/18 13:11:57	1.81
@@ -58,6 +58,15 @@
 
 #define NUMBER_OF_MAJORS 4096
 
+/*
+ * Static minor number assigned since kernel version 2.6.36.
+ * The original definition is in kernel's include/linux/miscdevice.h.
+ * This number is also visible in modules.devname exported by depmod
+ * utility (support included in module-init-tools version >= 3.12).
+ */
+#define MAPPER_CTRL_MINOR 236
+#define MISC_MAJOR 10
+
 /* dm major version no for running kernel */
 static unsigned _dm_version = DM_VERSION_MAJOR;
 static unsigned _dm_version_minor = 0;
@@ -341,10 +350,23 @@
 		return (major == _dm_device_major) ? 1 : 0;
 }
 
-static int _open_and_assign_control_fd(const char *control)
+static void _close_control_fd(void)
 {
+	if (_control_fd != -1) {
+		if (close(_control_fd) < 0)
+			log_sys_error("close", "_control_fd");
+		_control_fd = -1;
+	}
+}
+
+static int _open_and_assign_control_fd(const char *control,
+				       int ignore_nodev)
+{
+	_close_control_fd();
+
 	if ((_control_fd = open(control, O_RDWR)) < 0) {
-		log_sys_error("open", control);
+		if (!(ignore_nodev && errno == ENODEV))
+			log_sys_error("open", control);
 		return 0;
 	}
 
@@ -356,6 +378,7 @@
 #ifdef DM_IOCTLS
 	char control[PATH_MAX];
 	uint32_t major = 0, minor;
+	int dm_mod_autoload_support, needs_open;
 
 	if (_control_fd != -1)
 		return 1;
@@ -366,45 +389,61 @@
 	snprintf(control, sizeof(control), "%s/%s", dm_dir(), DM_CONTROL_NODE);
 
 	/*
-	 * Try to make use of module autoload kernel feature first.
-	 * This is accomplished with the help of udev that will
-	 * create static nodes based on modules.devname file extracted
-	 * by depmod (that udev reads). The /dev/mapper/control will
-	 * be created this way and the first access to a node will
-	 * load dm module automatically.
-	 *
-	 * To check for the module autoload support, we need:
-	 *
-	 *   - to check if the control node was created before (this
-	 *     should be the static node created by udev@its start)
-	 *
-	 *   - to check if we have recent enough kernel that is supposed
-	 *     to support this feature (a change in dm itself). We can't
-	 *     check dm version - we don't have a node to make an ioctl yet.
-	 *
-	 *   - try to open the control node (this will trigger the autoload).
-	 *     Successfull open means the autoload was successfull.
-	 *
-	 * If any of these three conditions fails, we fallback to old way.
-	 * It means we'll try to get the major:minor of control node,
-	 * we'll check its existence (checking the exact major:minor)
-	 * and we'll create the node if needed.
+	 * dm-mod autoloading is supported since kernel 2.6.36.
+	 * Udev daemon will try to read modules.devname file extracted
+	 * by depmod and create any static nodes needed.
+	 * The /dev/mapper/control node can be created and prepared this way.
+	 * First access to such node should load dm-mod module automatically.
 	 */
-	if (!_control_exists(control, 0, 0) ||
-	    !(KERNEL_VERSION(_kernel_major, _kernel_minor, _kernel_release) >=
-	      KERNEL_VERSION(2, 6, 36)) ||
-	    !_open_and_assign_control_fd(control)) {
-		if (!_control_device_number(&major, &minor))
-			log_error("Is device-mapper driver missing from kernel?");
+	dm_mod_autoload_support = KERNEL_VERSION(_kernel_major, _kernel_minor,
+				  _kernel_release) >= KERNEL_VERSION(2, 6, 36);
 
-		if (!_control_exists(control, major, minor) &&
-		    !_create_control(control, major, minor))
+	/*
+	 *  If dm-mod autoloading is supported and the control node exists
+	 *  already try to open it now. This should autoload dm-mod module.
+	 */
+	if (dm_mod_autoload_support) {
+		if (!_get_proc_number(PROC_DEVICES, MISC_NAME, &major))
+			/* If major not found, just fallback to hardcoded value. */
+			major = MISC_MAJOR;
+
+		/* Recreate the node with correct major and minor if needed. */
+		if (!_control_exists(control, major, MAPPER_CTRL_MINOR) &&
+		    !_create_control(control, major, MAPPER_CTRL_MINOR))
 			goto error;
 
-		if (!_open_and_assign_control_fd(control))
-			goto error;
+		_open_and_assign_control_fd(control, 1);
 	}
 
+	/*
+	 * Get major and minor number assigned for the control node.
+	 * In case we make use of the module autoload support, this
+	 * information should be accessible now as well.
+	 */
+	if (!_control_device_number(&major, &minor))
+		log_error("Is device-mapper driver missing from kernel?");
+
+	/*
+	 * Check the control node and its major and minor number.
+	 * If there's anything wrong, remove the old node and create
+	 * a correct one.
+	 */
+	if ((needs_open = !_control_exists(control, major, minor)) &&
+	    !_create_control(control, major, minor)) {
+		_close_control_fd();
+		goto error;
+	}
+
+	/*
+	 * For older kernels without dm-mod autoloading support, we always
+	 * need to open the control node here - we still haven't done that!
+	 * For newer kernels with dm-mod autoloading, we open it only if the
+	 * node was recreated and corrected in previous step.
+	 */
+	if ((!dm_mod_autoload_support || needs_open) &&
+	     !_open_and_assign_control_fd(control, 0))
+		goto error;
+
 	if (!_create_dm_bitset()) {
 		log_error("Failed to set up list of device-mapper major numbers");
 		return 0;
@@ -2045,10 +2084,7 @@
 
 void dm_lib_release(void)
 {
-	if (_control_fd != -1) {
-		close(_control_fd);
-		_control_fd = -1;
-	}
+	_close_control_fd();
 	update_devs();
 }
 



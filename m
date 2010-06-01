From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 1 Jun 2010 16:08:14 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/ioctl/libdm-iface.c ...
Message-ID: <20100601160814.13230.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-06-01 16:08:14

Modified files:
	.              : WHATS_NEW_DM 
	libdm/ioctl    : libdm-iface.c 
	libdm/misc     : dm-ioctl.h 

Log message:
	Add support for dm-mod module autoload.
	
	A kernel patch is on its way for 2.6.35 adding support for dm-mod module
	autoload. Udev v155 and higher is able to read static node information given
	in modules.devname (extracted by depmod before) and will create such nodes
	at its start. The first access to such node will load the module automatically
	(directly in kernel) before the actual read/write operation is processed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.375&r2=1.376
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.74&r2=1.75
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/misc/dm-ioctl.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/WHATS_NEW_DM	2010/05/28 03:50:15	1.375
+++ LVM2/WHATS_NEW_DM	2010/06/01 16:08:13	1.376
@@ -1,5 +1,6 @@
 Version 1.02.49 - 
 ================================
+  Add support for dm-mod module autoload.
   Document 'clear' in dmsetup man page.
   Use expected union semun for arguments in selected semaphore operations.
 
--- LVM2/libdm/ioctl/libdm-iface.c	2010/05/13 13:31:30	1.74
+++ LVM2/libdm/ioctl/libdm-iface.c	2010/06/01 16:08:13	1.75
@@ -64,6 +64,10 @@
 static unsigned _dm_version_patchlevel = 0;
 static int _log_suppress = 0;
 
+static int _kernel_major;
+static int _kernel_minor;
+static int _kernel_release;
+
 /*
  * If the kernel dm driver only supports one major number
  * we store it in _dm_device_major.  Otherwise we indicate
@@ -79,7 +83,6 @@
 static int _version_ok = 1;
 static unsigned _ioctl_buffer_double_factor = 0;
 
-
 /*
  * Support both old and new major numbers to ease the transition.
  * Clumsy, but only temporary.
@@ -136,6 +139,30 @@
 	return (void *) (((unsigned long) ptr + agn) & ~agn);
 }
 
+static int _uname()
+{
+	static int _uts_set = 0;
+	struct utsname _uts;
+
+	if (_uts_set)
+		return 1;
+
+	if (uname(&_uts)) {
+		log_error("uname failed: %s", strerror(errno));
+		return 0;
+	}
+	if (sscanf(_uts.release, "%d.%d.%d",
+			&_kernel_major,
+			&_kernel_minor,
+			&_kernel_release) != 3) {
+		log_error("Could not determine kernel version used.");
+		return 0;
+	}
+
+	_uts_set = 1;
+	return 1;
+}
+
 #ifdef DM_IOCTLS
 /*
  * Set number to NULL to populate _dm_bitset - otherwise first
@@ -266,12 +293,10 @@
 static int _create_dm_bitset(void)
 {
 #ifdef DM_IOCTLS
-	struct utsname uts;
-
 	if (_dm_bitset || _dm_device_major)
 		return 1;
 
-	if (uname(&uts))
+	if (!_uname())
 		return 0;
 
 	/*
@@ -279,7 +304,8 @@
 	 * Assume 2.4 kernels are patched not to.
 	 * FIXME Check _dm_version and _dm_version_minor if 2.6 changes this.
 	 */
-	if (!strncmp(uts.release, "2.6.", 4))
+	if (KERNEL_VERSION(_kernel_major, _kernel_minor, _kernel_release) >=
+	    KERNEL_VERSION(2, 6, 0))
 		_dm_multiple_major_support = 0;
 
 	if (!_dm_multiple_major_support) {
@@ -315,6 +341,16 @@
 		return (major == _dm_device_major) ? 1 : 0;
 }
 
+static int _open_and_assign_control_fd(const char *control)
+{
+	if ((_control_fd = open(control, O_RDWR)) < 0) {
+		log_sys_error("open", control);
+		return 0;
+	}
+
+	return 1;
+}
+
 static int _open_control(void)
 {
 #ifdef DM_IOCTLS
@@ -324,18 +360,49 @@
 	if (_control_fd != -1)
 		return 1;
 
-	snprintf(control, sizeof(control), "%s/control", dm_dir());
+	if (!_uname())
+		return 0;
 
-	if (!_control_device_number(&major, &minor))
-		log_error("Is device-mapper driver missing from kernel?");
+	snprintf(control, sizeof(control), "%s/%s", dm_dir(), DM_CONTROL_NODE);
 
-	if (!_control_exists(control, major, minor) &&
-	    !_create_control(control, major, minor))
-		goto error;
+	/*
+	 * Try to make use of module autoload kernel feature first.
+	 * This is accomplished with the help of udev that will
+	 * create static nodes based on modules.devname file extracted
+	 * by depmod (that udev reads). The /dev/mapper/control will
+	 * be created this way and the first access to a node will
+	 * load dm module automatically.
+	 *
+	 * To check for the module autoload support, we need:
+	 *
+	 *   - to check if the control node was created before (this
+	 *     should be the static node created by udev@its start)
+	 *
+	 *   - to check if we have recent enough kernel that is supposed
+	 *     to support this feature (a change in dm itself). We can't
+	 *     check dm version - we don't have a node to make an ioctl yet.
+	 *
+	 *   - try to open the control node (this will trigger the autoload).
+	 *     Successfull open means the autoload was successfull.
+	 *
+	 * If any of these three conditions fails, we fallback to old way.
+	 * It means we'll try to get the major:minor of control node,
+	 * we'll check its existence (checking the exact major:minor)
+	 * and we'll create the node if needed.
+	 */
+	if (!_control_exists(control, 0, 0) ||
+	    !(KERNEL_VERSION(_kernel_major, _kernel_minor, _kernel_release) >=
+	      KERNEL_VERSION(2, 6, 35)) ||
+	    !_open_and_assign_control_fd(control)) {
+		if (!_control_device_number(&major, &minor))
+			log_error("Is device-mapper driver missing from kernel?");
+
+		if (!_control_exists(control, major, minor) &&
+		    !_create_control(control, major, minor))
+			goto error;
 
-	if ((_control_fd = open(control, O_RDWR)) < 0) {
-		log_sys_error("open", control);
-		goto error;
+		if (!_open_and_assign_control_fd(control))
+			goto error;
 	}
 
 	if (!_create_dm_bitset()) {
--- LVM2/libdm/misc/dm-ioctl.h	2010/03/23 14:38:38	1.4
+++ LVM2/libdm/misc/dm-ioctl.h	2010/06/01 16:08:14	1.5
@@ -13,6 +13,7 @@
 #endif
 
 #define DM_DIR "mapper"		/* Slashes not supported */
+#define DM_CONTROL_NODE "control"
 #define DM_MAX_TYPE_NAME 16
 #define DM_NAME_LEN 128
 #define DM_UUID_LEN 129



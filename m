From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Feb 2009 20:42:08 -0000
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM lib/activate/d ...
Message-ID: <20090212204208.16166.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-02-12 20:42:08

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM 
	lib/activate   : dev_manager.c 
	libdm/ioctl    : libdm-iface.c 

Log message:
	If kernel supports only one dm major number, use in place of any supplied.
	No longer require kernel and metadata major numbers to match.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1042&r2=1.1043
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.262&r2=1.263
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.144&r2=1.145
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56

--- LVM2/WHATS_NEW	2009/02/11 10:13:20	1.1042
+++ LVM2/WHATS_NEW	2009/02/12 20:42:07	1.1043
@@ -1,5 +1,6 @@
 Version 2.02.45 - 
 ===================================
+  No longer require kernel and metadata major numbers to match.
   Add a fully-functional get_cluster_name() to clvmd corosync interface.
   Remove duplicate cpg_initialize from clvmd startup.
   Add option to /etc/sysconfig/cluster to select cluster type for clvmd.
--- LVM2/WHATS_NEW_DM	2009/01/26 14:46:09	1.262
+++ LVM2/WHATS_NEW_DM	2009/02/12 20:42:07	1.263
@@ -1,5 +1,6 @@
 Version 1.02.31 - 
 ====================================
+  If kernel supports only one dm major number, use in place of any supplied.
 
 Version 1.02.30 - 26th January 2009
 ====================================
--- LVM2/lib/activate/dev_manager.c	2008/12/19 15:23:03	1.144
+++ LVM2/lib/activate/dev_manager.c	2009/02/12 20:42:07	1.145
@@ -640,7 +640,10 @@
 	 * requested major/minor and that major/minor pair is available for use
 	 */
 	if (!layer && lv->major != -1 && lv->minor != -1) {
-		if (info.exists && (info.major != lv->major || info.minor != lv->minor)) {
+		/*
+		 * FIXME compare info.major with lv->major if multiple major support
+		 */
+		if (info.exists && (info.minor != lv->minor)) {
 			log_error("Volume %s (%" PRIu32 ":%" PRIu32")"
 				  " differs from already active device "
 				  "(%" PRIu32 ":%" PRIu32")",
--- LVM2/libdm/ioctl/libdm-iface.c	2009/01/07 12:17:40	1.55
+++ LVM2/libdm/ioctl/libdm-iface.c	2009/02/12 20:42:07	1.56
@@ -24,6 +24,7 @@
 #include <fcntl.h>
 #include <dirent.h>
 #include <sys/ioctl.h>
+#include <sys/utsname.h>
 #include <limits.h>
 
 #ifdef linux
@@ -63,12 +64,22 @@
 static unsigned _dm_version_patchlevel = 0;
 static int _log_suppress = 0;
 
+/*
+ * If the kernel dm driver only supports one major number
+ * we store it in _dm_device_major.  Otherwise we indicate
+ * which major numbers have been claimed by device-mapper
+ * in _dm_bitset.
+ */
+static unsigned _dm_multiple_major_support = 1;
 static dm_bitset_t _dm_bitset = NULL;
+static uint32_t _dm_device_major = 0;
+
 static int _control_fd = -1;
 static int _version_checked = 0;
 static int _version_ok = 1;
 static unsigned _ioctl_buffer_double_factor = 0;
 
+
 /*
  * Support both old and new major numbers to ease the transition.
  * Clumsy, but only temporary.
@@ -249,12 +260,35 @@
 }
 #endif
 
+/*
+ * FIXME Update bitset in long-running process if dm claims new major numbers.
+ */
 static int _create_dm_bitset(void)
 {
 #ifdef DM_IOCTLS
-	if (_dm_bitset)
+	struct utsname uts;
+
+	if (_dm_bitset || _dm_device_major)
+		return 1;
+
+	if (uname(&uts))
+		return 0;
+
+	/*
+	 * 2.6 kernels are limited to one major number.
+	 * Assume 2.4 kernels are patched not to.
+	 * FIXME Check _dm_version and _dm_version_minor if 2.6 changes this.
+	 */
+	if (!strncmp(uts.release, "2.6.", 4))
+		_dm_multiple_major_support = 0;
+
+	if (!_dm_multiple_major_support) {
+		if (!_get_proc_number(PROC_DEVICES, DM_NAME, &_dm_device_major))
+			return 0;
 		return 1;
+	}
 
+	/* Multiple major numbers supported */
 	if (!(_dm_bitset = dm_bitset_create(NULL, NUMBER_OF_MAJORS)))
 		return 0;
 
@@ -275,7 +309,10 @@
 	if (!_create_dm_bitset())
 		return 0;
 
-	return dm_bit(_dm_bitset, major) ? 1 : 0;
+	if (_dm_multiple_major_support)
+		return dm_bit(_dm_bitset, major) ? 1 : 0;
+	else
+		return (major == _dm_device_major) ? 1 : 0;
 }
 
 static int _open_control(void)
@@ -1297,6 +1334,14 @@
 			log_error("Missing major number for persistent device.");
 			goto bad;
 		}
+
+		if (!_dm_multiple_major_support && dmt->major != _dm_device_major) {
+			log_verbose("Overriding major number of %" PRIu32 
+				    " with %" PRIu32 " for persistent device.",
+				    dmt->major, _dm_device_major);
+			dmt->major = _dm_device_major;
+		}
+
 		dmi->flags |= DM_PERSISTENT_DEV_FLAG;
 		dmi->dev = MKDEV(dmt->major, dmt->minor);
 	}



From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 18 Mar 2011 12:17:59 -0000
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM lib/activate/d ...
Message-ID: <20110318121759.15685.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-03-18 12:17:58

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM 
	lib/activate   : dev_manager.c 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Mitigate some warnings if running as non-root user.
	
	LVM doesn't behave correctly if running as non-root user,
	there is warning when it detects it.
	
	Despite this, it produces many error messages, saying nothing.
	See https://bugzilla.redhat.com/show_bug.cgi?id=620571
	
	This patch fixes two things:
	1) Removes eror message from device_is_usable() which has no
	information value anyway (real warning is printed inside it).
	
	2) it fixes device-mapper initialization, if we support
	core dm module autoload and device node is present, it should
	fail early and not try recreate existing and correct node.
	(non-root == permission denied here)
	
	N.B. In future code should support user roles, some more
	drastic checks in code are probably contraproductive now.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1956&r2=1.1957
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.455&r2=1.456
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.214&r2=1.215
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.99&r2=1.100

--- LVM2/WHATS_NEW	2011/03/14 17:00:58	1.1956
+++ LVM2/WHATS_NEW	2011/03/18 12:17:57	1.1957
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Mitigate annoying error warning from device is usable check if run as non-root.
   Add missing \0 for grown debug object in _bitset_with_random_bits().
   Fix allocation of system_id buffer in volume_group structure.
   Fix readlink usage inside get_primary_dev().
--- LVM2/WHATS_NEW_DM	2011/03/10 12:48:40	1.455
+++ LVM2/WHATS_NEW_DM	2011/03/18 12:17:57	1.456
@@ -1,5 +1,6 @@
 Version 1.02.64 - 
 ===================================
+  Fallback to control node creation only if node doesn't exist yet.
   Change dm_hash API for binary data to accept const void *key.
   Fix memory access of empty params string in _reload_with_suppression_v4().
   Lower severity of selabel_lookup and matchpathcon failure to log_debug.
--- LVM2/lib/activate/dev_manager.c	2011/02/28 19:53:03	1.214
+++ LVM2/lib/activate/dev_manager.c	2011/03/18 12:17:58	1.215
@@ -141,10 +141,8 @@
 	int only_error_target = 1;
 	int r = 0;
 
-	if (!(dmt = dm_task_create(DM_DEVICE_STATUS))) {
-		log_error("Failed to create dm_task struct to check dev status");
-		return 0;
-	}
+	if (!(dmt = dm_task_create(DM_DEVICE_STATUS)))
+		return_0;
 
 	if (!dm_task_set_major_minor(dmt, MAJOR(dev->dev), MINOR(dev->dev), 1))
 		goto_out;
--- LVM2/libdm/ioctl/libdm-iface.c	2011/03/08 22:43:20	1.99
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/03/18 12:17:58	1.100
@@ -365,8 +365,9 @@
 	_close_control_fd();
 
 	if ((_control_fd = open(control, O_RDWR)) < 0) {
-		if (!(ignore_nodev && errno == ENODEV))
-			log_sys_error("open", control);
+		if (ignore_nodev && errno == ENODEV)
+			return 1;
+		log_sys_error("open", control);
 		return 0;
 	}
 
@@ -412,7 +413,9 @@
 		    !_create_control(control, major, MAPPER_CTRL_MINOR))
 			goto error;
 
-		_open_and_assign_control_fd(control, 1);
+		/* Fallback to old code only if control node doesn't exist */
+		if (!_open_and_assign_control_fd(control, 1))
+			goto error;
 	}
 
 	/*



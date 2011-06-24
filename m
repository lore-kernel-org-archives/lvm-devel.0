From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Jun 2011 19:33:45 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-deptree.c libd ...
Message-ID: <20110624193345.20432.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-24 19:33:41

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-deptree.c 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Return immediately dm_lib_exit() if called more than once.
	(Avoiding calling it twice would involve some untangling.)
	Decrement the new suspended_counter if removing a suspended device.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.473&r2=1.474
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.97&r2=1.98
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.106&r2=1.107

--- LVM2/WHATS_NEW_DM	2011/06/17 14:55:51	1.473
+++ LVM2/WHATS_NEW_DM	2011/06/24 19:33:41	1.474
@@ -1,5 +1,6 @@
 Version 1.02.65 - 
 ==================================
+  Return immediately dm_lib_exit() if called more than once.
   Disable udev fallback by default and add --udevfallback option to dmsetup.
   Warn if a table is loaded while a device is known to be in suspended state.
   Add dm_get_suspended_counter() for number of devs in suspended state by lib.
--- LVM2/libdm/libdm-deptree.c	2011/06/22 12:56:02	1.97
+++ LVM2/libdm/libdm-deptree.c	2011/06/24 19:33:41	1.98
@@ -1188,7 +1188,8 @@
 				  info.minor);
 			r = 0;
 			continue;
-		}
+		} else if (info.suspended)
+			dec_suspended();
 
 		if (dm_tree_node_num_children(child, 0)) {
 			if (!_dm_tree_deactivate_children(child, uuid_prefix, uuid_prefix_len, level + 1))
--- LVM2/libdm/ioctl/libdm-iface.c	2011/06/13 03:53:02	1.106
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/06/24 19:33:41	1.107
@@ -2173,6 +2173,15 @@
 
 void dm_lib_exit(void)
 {
+	int suspended_counter;
+	static unsigned _exited = 0;
+
+	if (_exited++)
+		return;
+
+	if ((suspended_counter = dm_get_suspended_counter()))
+		log_error("libdevmapper exiting with %d device(s) still suspended.", suspended_counter);
+
 	dm_lib_release();
 	selinux_release();
 	if (_dm_bitset)



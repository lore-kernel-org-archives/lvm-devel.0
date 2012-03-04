From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Mar 2012 17:40:59 -0000
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM lib/device/dev ...
Message-ID: <20120304174059.28091.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-04 17:40:59

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM 
	lib/device     : dev-cache.c 

Log message:
	Validate udev structures
	
	Avoid using NULL pointers from udev. It seems like some older versions of udev
	were improperly returning NULL in some case, so do not silently break here,
	and give at least a warning to the user.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2340&r2=1.2341
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.585&r2=1.586
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.c.diff?cvsroot=lvm2&r1=1.72&r2=1.73

--- LVM2/WHATS_NEW	2012/03/04 17:36:23	1.2340
+++ LVM2/WHATS_NEW	2012/03/04 17:40:59	1.2341
@@ -1,6 +1,6 @@
 Version 2.02.95 -
 ================================
-  Deactivation of failed thin check on thin pool returns success.
+  Validate udev structures in _insert_udev_dir().
   Scan all devices for lvmetad if 'pvscan --cache' used without device list.
   Populate lvmcache from lvmetad before displaying PVs in pvscan. (2.02.94)
   Suppress incorrect -n pvscan warning now always displayed. (2.02.94)
--- LVM2/WHATS_NEW_DM	2012/03/03 02:08:37	1.585
+++ LVM2/WHATS_NEW_DM	2012/03/04 17:40:59	1.586
@@ -1,5 +1,6 @@
 Version 1.02.74 - 
 ================================
+  Deactivation of failed thin check on thin pool returns success.
 
 Version 1.02.73 - 3rd March 2012
 ================================
--- LVM2/lib/device/dev-cache.c	2012/02/23 13:11:09	1.72
+++ LVM2/lib/device/dev-cache.c	2012/03/04 17:40:59	1.73
@@ -509,14 +509,21 @@
 		goto bad;
 
 	udev_list_entry_foreach(device_entry, udev_enumerate_get_list_entry(udev_enum)) {
-		device = udev_device_new_from_syspath(udev, udev_list_entry_get_name(device_entry));
+		if (!(device = udev_device_new_from_syspath(udev, udev_list_entry_get_name(device_entry)))) {
+			log_warn("Udev returns NULL device.");
+			continue;
+		}
 
-		node_name = udev_device_get_devnode(device);
-		r &= _insert(node_name, 0, 0);
+		if (!(node_name = udev_device_get_devnode(device)))
+			log_warn("Udev returns NULL devnode.");
+		else
+			r &= _insert(node_name, 0, 0);
 
 		udev_list_entry_foreach(symlink_entry, udev_device_get_devlinks_list_entry(device)) {
-			symlink_name = udev_list_entry_get_name(symlink_entry);
-			r &= _insert(symlink_name, 0, 0);
+			if (!(symlink_name = udev_list_entry_get_name(symlink_entry)))
+				log_warn("Udev returns NULL name.");
+			else
+				r &= _insert(symlink_name, 0, 0);
 		}
 
 		udev_device_unref(device);



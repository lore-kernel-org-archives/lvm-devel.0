From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Mar 2012 02:39:25 -0000
Subject: LVM2/lib/device dev-cache.c
Message-ID: <20120306023925.5208.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-03-06 02:39:25

Modified files:
	lib/device     : dev-cache.c 

Log message:
	re-word warnings to be clearer to user

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.c.diff?cvsroot=lvm2&r1=1.73&r2=1.74

--- LVM2/lib/device/dev-cache.c	2012/03/04 17:40:59	1.73
+++ LVM2/lib/device/dev-cache.c	2012/03/06 02:39:25	1.74
@@ -510,18 +510,18 @@
 
 	udev_list_entry_foreach(device_entry, udev_enumerate_get_list_entry(udev_enum)) {
 		if (!(device = udev_device_new_from_syspath(udev, udev_list_entry_get_name(device_entry)))) {
-			log_warn("Udev returns NULL device.");
+			log_warn("WARNING: udev failed to return a device entry.");
 			continue;
 		}
 
 		if (!(node_name = udev_device_get_devnode(device)))
-			log_warn("Udev returns NULL devnode.");
+			log_warn("WARNING: udev failed to return a device node.");
 		else
 			r &= _insert(node_name, 0, 0);
 
 		udev_list_entry_foreach(symlink_entry, udev_device_get_devlinks_list_entry(device)) {
 			if (!(symlink_name = udev_list_entry_get_name(symlink_entry)))
-				log_warn("Udev returns NULL name.");
+				log_warn("WARNING: udev failed to return a symlink name.");
 			else
 				r &= _insert(symlink_name, 0, 0);
 		}



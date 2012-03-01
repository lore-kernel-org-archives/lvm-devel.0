From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Mar 2012 21:16:05 -0000
Subject: LVM2/lib/commands toolcontext.c
Message-ID: <20120301211605.9291.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-01 21:16:05

Modified files:
	lib/commands   : toolcontext.c 

Log message:
	Check for udev_get_dev_dir result
	
	Don't use NULL return value.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.152&r2=1.153

--- LVM2/lib/commands/toolcontext.c	2012/02/27 10:05:35	1.152
+++ LVM2/lib/commands/toolcontext.c	2012/03/01 21:16:05	1.153
@@ -664,8 +664,9 @@
 	if ((device_list_from_udev = udev_is_running() ?
 		find_config_tree_bool(cmd, "devices/obtain_device_list_from_udev",
 				      DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV) : 0)) {
-		udev_dir = udev_get_dev_dir();
-		udev_dir_len = strlen(udev_dir);
+		if (!(udev_dir = udev_get_dev_dir()))
+			stack;
+		udev_dir_len = (udev_dir) ? strlen(udev_dir) : 0;
 	}
 	init_obtain_device_list_from_udev(device_list_from_udev);
 
@@ -687,7 +688,7 @@
 			return 0;
 		}
 
-		if (device_list_from_udev) {
+		if (device_list_from_udev && udev_dir) {
 			len = strlen(cv->v.str);
 			len = udev_dir_len > len ? len : udev_dir_len;
 			if (strncmp(udev_dir, cv->v.str, len) ||



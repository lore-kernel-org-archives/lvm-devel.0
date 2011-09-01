From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Sep 2011 13:30:12 -0000
Subject: LVM2/lib/misc lvm-globals.c
Message-ID: <20110901133012.5878.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-01 13:30:11

Modified files:
	lib/misc       : lvm-globals.c 

Log message:
	Match the prototype old-style declaration

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-globals.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/lib/misc/lvm-globals.c	2011/08/11 17:46:14	1.13
+++ LVM2/lib/misc/lvm-globals.c	2011/09/01 13:30:11	1.14
@@ -207,7 +207,7 @@
 	return _full_scan_done;
 }
 
-int obtain_device_list_from_udev()
+int obtain_device_list_from_udev(void)
 {
 	return _obtain_device_list_from_udev;
 }



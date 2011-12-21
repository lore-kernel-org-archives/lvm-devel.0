From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 Dec 2011 13:24:25 -0000
Subject: LVM2 ./WHATS_NEW lib/device/dev-io.c
Message-ID: <20111221132425.11606.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-12-21 13:24:25

Modified files:
	.              : WHATS_NEW 
	lib/device     : dev-io.c 

Log message:
	Drop extra stat before open of device
	
	Since the !(dev->flags & DEV_REGULAR) code path just called
	dev_name_confirmed() which has just called 'stat()' inside,
	remove duplicate second stat() call here.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2212&r2=1.2213
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-io.c.diff?cvsroot=lvm2&r1=1.78&r2=1.79

--- LVM2/WHATS_NEW	2011/12/21 13:21:09	1.2212
+++ LVM2/WHATS_NEW	2011/12/21 13:24:24	1.2213
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Drop extra stat call before opening device.
   Reduce number of lstat calls when selecting device alias.
   Add function to inialize common structure device members.
   Always zalloc device structure during initialization.
--- LVM2/lib/device/dev-io.c	2011/05/28 09:48:14	1.78
+++ LVM2/lib/device/dev-io.c	2011/12/21 13:24:25	1.79
@@ -449,17 +449,6 @@
 	else if (!(name = dev_name_confirmed(dev, quiet)))
 		return_0;
 
-	if (!(dev->flags & DEV_REGULAR)) {
-		if (stat(name, &buf) < 0) {
-			log_sys_error("%s: stat failed", name);
-			return 0;
-		}
-		if (buf.st_rdev != dev->dev) {
-			log_error("%s: device changed", name);
-			return 0;
-		}
-	}
-
 #ifdef O_DIRECT_SUPPORT
 	if (direct) {
 		if (!(dev->flags & DEV_O_DIRECT_TESTED))



From: meyering@sourceware.org <meyering@sourceware.org>
Date: 7 Sep 2007 11:24:19 -0000
Subject: LVM2 ./WHATS_NEW lib/device/dev-io.c
Message-ID: <20070907112419.23479.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2007-09-07 11:24:19

Modified files:
	.              : WHATS_NEW 
	lib/device     : dev-io.c 

Log message:
	Include strerror string in dev_open_flags' stat failure message.
	* lib/device/dev-io.c (dev_open_flags):
	Use log_sys_error after failed stat to report strerror(errno).
	Use a slightly different diagnostic to report mismatched device number.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.701&r2=1.702
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-io.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59

--- LVM2/WHATS_NEW	2007/08/30 20:30:41	1.701
+++ LVM2/WHATS_NEW	2007/09/07 11:24:19	1.702
@@ -1,12 +1,13 @@
 Version 2.02.29 -
 ==================================
+  Include strerror string in dev_open_flags' stat failure message.
   Move guts of pvresize into library.
   Avoid error when --corelog is provided without --mirrorlog. (2.02.28)
   Correct --mirrorlog argument name in man pages (not --log).
   Clear MIRROR_NOTSYNCED LV flag when converting from mirror to linear.
   Modify lvremove to prompt for removal if LV active on other cluster nodes.
   Add '-f' to vgremove to force removal of VG even if LVs exist.
-  
+
 Version 2.02.28 - 24th August 2007
 ==================================
   Fix clvmd logging so you can get lvm-level debugging out of it.
--- LVM2/lib/device/dev-io.c	2007/08/20 20:55:25	1.58
+++ LVM2/lib/device/dev-io.c	2007/09/07 11:24:19	1.59
@@ -359,10 +359,15 @@
 		return 0;
 	}
 
-	if (!(dev->flags & DEV_REGULAR) &&
-	    ((stat(name, &buf) < 0) || (buf.st_rdev != dev->dev))) {
-		log_error("%s: stat failed: Has device name changed?", name);
-		return 0;
+	if (!(dev->flags & DEV_REGULAR)) {
+		if (stat(name, &buf) < 0) {
+			log_sys_error("%s: stat failed", name);
+			return 0;
+		}
+		if (buf.st_rdev != dev->dev) {
+			log_error("%s: device changed", name);
+			return 0;
+		}
 	}
 
 #ifdef O_DIRECT_SUPPORT



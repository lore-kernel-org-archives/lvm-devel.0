From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 Dec 2011 13:21:09 -0000
Subject: LVM2 ./WHATS_NEW lib/device/dev-cache.c
Message-ID: <20111221132109.10681.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-12-21 13:21:09

Modified files:
	.              : WHATS_NEW 
	lib/device     : dev-cache.c 

Log message:
	Do not lstat common path prefix
	
	When both path have identical prefix i.e. /dev/disk/by-id
	skip  2 x lstat() for /dev  /dev/disk /dev/disk/by-id
	and directly lstat() only different part of the path.
	
	Reduces amount of lstat calls on system with lots of devices.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2211&r2=1.2212
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.c.diff?cvsroot=lvm2&r1=1.68&r2=1.69

--- LVM2/WHATS_NEW	2011/12/21 13:17:54	1.2211
+++ LVM2/WHATS_NEW	2011/12/21 13:21:09	1.2212
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Reduce number of lstat calls when selecting device alias.
   Add function to inialize common structure device members.
   Always zalloc device structure during initialization.
   Fix missing thread list manipulation protection in dmeventd.
--- LVM2/lib/device/dev-cache.c	2011/12/21 13:17:54	1.68
+++ LVM2/lib/device/dev-cache.c	2011/12/21 13:21:09	1.69
@@ -259,6 +259,13 @@
 	s0 = &p0[0] + 1;
 	s1 = &p1[0] + 1;
 
+	/*
+	 * If we reach here, both paths are the same length.
+	 * Now skip past identical path components.
+	 */
+	while (*s0 && *s0 == *s1)
+		s0++, s1++;
+
 	/* We prefer symlinks - they exist for a reason!
 	 * So we prefer a shorter path before the first symlink in the name.
 	 * FIXME Configuration option to invert this? */



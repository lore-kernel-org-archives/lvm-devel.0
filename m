From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 19 Apr 2010 15:24:01 -0000
Subject: LVM2 VERSION WHATS_NEW
Message-ID: <20100419152401.4026.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-04-19 15:24:01

Modified files:
	.              : VERSION WHATS_NEW 

Log message:
	Change lvm2app version number from 1 to 2.
	
	This version number change reflects the memory handling change
	for string-based pv/vg/lv string based attributes.
	In addition, when adding support for tags, I forgot to increase
	the version number.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.231&r2=1.232
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1529&r2=1.1530

--- LVM2/VERSION	2010/04/14 21:47:48	1.231
+++ LVM2/VERSION	2010/04/19 15:24:00	1.232
@@ -1 +1 @@
-2.02.64(1)-cvs (2010-04-14)
+2.02.64(2)-cvs (2010-04-14)
--- LVM2/WHATS_NEW	2010/04/15 19:15:03	1.1529
+++ LVM2/WHATS_NEW	2010/04/19 15:24:00	1.1530
@@ -1,5 +1,7 @@
 Version 2.02.64 -
 =================================
+  Increment lvm2app version from 1 to 2.
+  Change lvm2app memory alloc/free for pv/vg/lv properties.
   Change daemon lock filename from lvm2_monitor to lvm2-monitor for consistency.
   Added awk script relpath.awk to calculate relative paths.
   Fix double DESTDIR usage for infodir and mandir.



From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 13 Oct 2010 15:50:35 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20101013155035.24173.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-10-13 15:50:34

Modified files:
	.              : WHATS_NEW 

Log message:
	Tweak WHATS_NEW for devices/disable_after_error_count.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1759&r2=1.1760

--- LVM2/WHATS_NEW	2010/10/13 15:41:52	1.1759
+++ LVM2/WHATS_NEW	2010/10/13 15:50:34	1.1760
@@ -1,6 +1,6 @@
 Version 2.02.75 - 
 =====================================
-  Limit repeated accesses to broken devices.
+  Add "devices/disable_after_error_count" to lvm.conf.
   Give correct error message when creating a too-small snapshot.
   Implement vgextend --restoremissing.
   Refactor and add 'get' functions for lv properties/fields.



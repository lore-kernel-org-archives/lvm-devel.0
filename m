From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Jan 2011 14:51:35 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20110110145135.18467.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-01-10 14:51:33

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	post-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.267&r2=1.268
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.76&r2=1.77
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1871&r2=1.1872
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.437&r2=1.438

--- LVM2/VERSION	2011/01/10 14:28:18	1.267
+++ LVM2/VERSION	2011/01/10 14:51:33	1.268
@@ -1 +1 @@
-2.02.80(2)-cvs (2011-01-10)
+2.02.81(2)-cvs (2011-01-10)
--- LVM2/VERSION_DM	2011/01/10 14:28:18	1.76
+++ LVM2/VERSION_DM	2011/01/10 14:51:33	1.77
@@ -1 +1 @@
-1.02.61-cvs (2011-01-10)
+1.02.62-cvs (2011-01-10)
--- LVM2/WHATS_NEW	2011/01/10 14:28:17	1.1871
+++ LVM2/WHATS_NEW	2011/01/10 14:51:33	1.1872
@@ -1,3 +1,6 @@
+Version 2.02.81 - 
+===================================
+
 Version 2.02.80 - 10th January 2011
 ===================================
   Use same dm cookie for consecutive dm ops in same VG to reduce udev waits.
--- LVM2/WHATS_NEW_DM	2011/01/10 14:28:18	1.437
+++ LVM2/WHATS_NEW_DM	2011/01/10 14:51:33	1.438
@@ -1,3 +1,6 @@
+Version 1.02.62 - 
+===================================
+
 Version 1.02.61 - 10th January 2011
 ===================================
   Add DM_COOKIE_AUTO_CREATE to libdevmapper.h.



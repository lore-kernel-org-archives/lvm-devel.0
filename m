From: agk@sourceware.org <agk@sourceware.org>
Date: 22 May 2009 15:23:11 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20090522152311.19268.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-05-22 15:23:11

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	post-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.195&r2=1.196
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1123&r2=1.1124
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.268&r2=1.269

--- LVM2/VERSION	2009/05/22 14:44:59	1.195
+++ LVM2/VERSION	2009/05/22 15:23:10	1.196
@@ -1 +1 @@
-2.02.47-cvs (2009-05-22)
+2.02.48-cvs (2009-05-22)
--- LVM2/VERSION_DM	2009/05/21 03:04:52	1.8
+++ LVM2/VERSION_DM	2009/05/22 15:23:10	1.9
@@ -1 +1 @@
-1.02.32-cvs (2009-05-21)
+1.02.33-cvs (2009-05-22)
--- LVM2/WHATS_NEW	2009/05/22 14:44:59	1.1123
+++ LVM2/WHATS_NEW	2009/05/22 15:23:11	1.1124
@@ -1,3 +1,6 @@
+Version 2.02.48 - 
+===============================
+
 Version 2.02.47 - 22nd May 2009
 ===============================
   Rename liblvm.so to liblvm2app.so and use configure --enable-applib.
--- LVM2/WHATS_NEW_DM	2009/05/21 03:04:52	1.268
+++ LVM2/WHATS_NEW_DM	2009/05/22 15:23:11	1.269
@@ -1,3 +1,6 @@
+Version 1.02.33 - 
+===============================
+
 Version 1.02.32 - 21st May 2009
 ===============================
   Only generate libdevmapper.a when configured to link statically.



From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Oct 2009 21:56:24 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20091026215624.31638.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-10-26 21:56:24

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.211&r2=1.212
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1304&r2=1.1305
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.307&r2=1.308

--- LVM2/VERSION	2009/09/26 00:42:47	1.211
+++ LVM2/VERSION	2009/10/26 21:56:23	1.212
@@ -1 +1 @@
-2.02.54(1)-cvs (2009-09-26)
+2.02.54(1)-cvs (2009-10-26)
--- LVM2/VERSION_DM	2009/09/26 00:42:47	1.23
+++ LVM2/VERSION_DM	2009/10/26 21:56:23	1.24
@@ -1 +1 @@
-1.02.39-cvs (2009-09-26)
+1.02.39-cvs (2009-10-26)
--- LVM2/WHATS_NEW	2009/10/26 14:37:09	1.1304
+++ LVM2/WHATS_NEW	2009/10/26 21:56:23	1.1305
@@ -1,5 +1,5 @@
-Version 2.02.54 -
-=====================================
+Version 2.02.54 - 26th October 2009
+===================================
   Update lvcreate/lvconvert man pages to explain PhysicalVolume parameter.
   Document --all option in man pages, cleanup {pv|vg|lv}{s|display} man pages.
   Permit snapshots of mirrors.
--- LVM2/WHATS_NEW_DM	2009/10/22 13:11:33	1.307
+++ LVM2/WHATS_NEW_DM	2009/10/26 21:56:23	1.308
@@ -1,5 +1,5 @@
-Version 1.02.39 - 
-=====================================
+Version 1.02.39 - 26th October 2009
+===================================
   Remove strict default permissions for DM devices from 95-dm-notify.rules.
   Add dmsetup udevflags command to decode udev flags in given cookie value.
   Add udev flags support in libdevmapper.



From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Aug 2009 17:08:04 -0000
Subject: LVM2 ./VERSION ./VERSION_DM ./WHATS_NEW libdm/ ...
Message-ID: <20090806170804.13976.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-08-06 17:08:02

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW 
	libdm          : .exported_symbols 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.205&r2=1.206
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1232&r2=1.1233
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/.exported_symbols.diff?cvsroot=lvm2&r1=1.42&r2=1.43

--- LVM2/VERSION	2009/07/28 20:47:40	1.205
+++ LVM2/VERSION	2009/08/06 17:08:01	1.206
@@ -1 +1 @@
-2.02.51(1)-cvs (2009-07-28)
+2.02.51(1)-cvs (2009-08-06)
--- LVM2/VERSION_DM	2009/07/28 20:47:40	1.17
+++ LVM2/VERSION_DM	2009/08/06 17:08:01	1.18
@@ -1 +1 @@
-1.02.36-cvs (2009-07-28)
+1.02.36-cvs (2009-08-06)
--- LVM2/WHATS_NEW	2009/08/05 14:18:35	1.1232
+++ LVM2/WHATS_NEW	2009/08/06 17:08:01	1.1233
@@ -1,5 +1,5 @@
-Version 2.02.51 - 
-================================
+Version 2.02.51 - 6th August 2009
+=================================
   Fix locking in clvmd (2.02.50).
   Add --noudevsync option for relevant LVM tools.
   Add activation/udev_sync to lvm.conf.
--- LVM2/libdm/.exported_symbols	2009/08/03 18:01:47	1.42
+++ LVM2/libdm/.exported_symbols	2009/08/06 17:08:01	1.43
@@ -157,6 +157,7 @@
 dm_list_prev
 dm_list_next
 dm_list_size
+dm_cookie_supported
 dm_udev_set_sync_support
 dm_udev_get_sync_support
 dm_udev_complete



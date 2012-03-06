From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Mar 2012 02:50:42 -0000
Subject: LVM2 WHATS_NEW WHATS_NEW_DM VERSION VERSION_DM
Message-ID: <20120306025042.19236.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-03-06 02:50:40

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM VERSION VERSION_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2346&r2=1.2347
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.589&r2=1.590
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.298&r2=1.299
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.103&r2=1.104

--- LVM2/WHATS_NEW	2012/03/06 02:30:49	1.2346
+++ LVM2/WHATS_NEW	2012/03/06 02:50:40	1.2347
@@ -1,8 +1,8 @@
-Version 2.02.95 -
+Version 2.02.95 - 6th March 2012
 ================================
-  Try to fit thin pool metadata size into 128MB.
+  If unspecified, adjust thin pool metadata and chunk size to fit into 128MB.
   Print just warning on thin pool check callback path for failing check.
-  Always use 64bit math with VG extent_size expression.
+  Always use 64bit arithmetic with VG extent_size expression.
   Validate udev structures in _insert_udev_dir().
   Take repeatable --major --minor with pvscan --cache instead of major:minor.
   Scan all devices for lvmetad if 'pvscan --cache' used without device list.
--- LVM2/WHATS_NEW_DM	2012/03/05 12:48:12	1.589
+++ LVM2/WHATS_NEW_DM	2012/03/06 02:50:40	1.590
@@ -1,6 +1,6 @@
-Version 1.02.74 - 
+Version 1.02.74 - 6th March 2012
 ================================
-  Check for multiple mangled names in auto mangling mode.
+  Check for multiply-mangled names in auto mangling mode.
   Fix dm_task_get_name_unmangled to not unmangle already unmangled name.
   Check whether device names are properly mangled on ioctl return.
   Deactivation of failed thin check on thin pool returns success.
--- LVM2/VERSION	2012/03/03 02:08:37	1.298
+++ LVM2/VERSION	2012/03/06 02:50:40	1.299
@@ -1 +1 @@
-2.02.95(2)-cvs (2012-03-03)
+2.02.95(2)-cvs (2012-03-06)
--- LVM2/VERSION_DM	2012/03/03 02:08:37	1.103
+++ LVM2/VERSION_DM	2012/03/06 02:50:40	1.104
@@ -1 +1 @@
-1.02.74-cvs (2012-03-03)
+1.02.74-cvs (2012-03-06)



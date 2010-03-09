From: agk@sourceware.org <agk@sourceware.org>
Date: 9 Mar 2010 13:13:09 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20100309131309.32758.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-03-09 13:13:08

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.227&r2=1.228
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1456&r2=1.1457
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.348&r2=1.349

--- LVM2/VERSION	2010/02/16 00:27:01	1.227
+++ LVM2/VERSION	2010/03/09 13:13:07	1.228
@@ -1 +1 @@
-2.02.62(1)-cvs (2010-02-15)
+2.02.62(1)-cvs (2010-03-09)
--- LVM2/VERSION_DM	2010/02/16 00:27:01	1.39
+++ LVM2/VERSION_DM	2010/03/09 13:13:08	1.40
@@ -1 +1 @@
-1.02.45-cvs (2010-02-15)
+1.02.45-cvs (2010-03-09)
--- LVM2/WHATS_NEW	2010/03/09 03:20:12	1.1456
+++ LVM2/WHATS_NEW	2010/03/09 13:13:08	1.1457
@@ -1,17 +1,18 @@
-Version 2.02.62 -
-====================================
-  Reimplement mlockall() with mlock() to reduce pinned memory size.
+Version 2.02.62 - 9th March 2010
+================================
+  Add use_mlockall and mlock_filter to activation section of lvm.conf.
+  Add default alternative to mlockall using mlock to reduce pinned memory size.
   Remove -rdynamic from static builds.
   Update checks for pthread, readline & selinux libs and link only when needed.
   Introduce makefile vars UDEV_LIBS, DL_LIBS, SELINUX_LIBS, STATIC_LIBS.
   Introduce makefile vars LVMINTERNAL_LIBS, READLINE_LIBS, PTHREAD_LIBS.
-  Help for configure prints --disable-fsadm.
-  Use consistently $() instead of ${} for all Makefile variables.
+  Toggle configure help to print --disable-fsadm.
+  Use $() instead of ${} consistently for all Makefile variables.
   Replace CFLOW_CMD only in make.tmpl and use it as variable elsewhere.
   Use $(top_builddir) for inclusion of make.tmpl in Makefiles.
   Fix autoconf warning about ignored datarootdir.
   Increase AC_PREREQ version to 2.61 (for AC_PROC_SED, AC_PROG_MKDIR_P).
-  Handle a misaligned device that reports a -1 alignment_offset.
+  Handle misaligned devices that report alignment_offset of -1.
   Extend core allocation code in preparation for mirrored log areas.
   Rewrite clvmd init script.
   Remove lvs_in_vg_activated_by_uuid_only call.
--- LVM2/WHATS_NEW_DM	2010/03/08 16:05:07	1.348
+++ LVM2/WHATS_NEW_DM	2010/03/09 13:13:08	1.349
@@ -1,7 +1,7 @@
-Version 1.02.45 -
-====================================
-  Add --showkeys parameter description into dmsetup man page.
-  Add --help option as the synonym for help command.
+Version 1.02.45 - 9th March 2010
+================================
+  Add --showkeys parameter description to dmsetup man page.
+  Add --help option as synonym for help command.
 
 Version 1.02.44 - 15th February 2010
 ====================================



From: agk@sourceware.org <agk@sourceware.org>
Date: 9 Mar 2010 03:20:13 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20100309032013.14645.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-03-09 03:20:13

Modified files:
	.              : WHATS_NEW 

Log message:
	.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1455&r2=1.1456

--- LVM2/WHATS_NEW	2010/03/05 14:48:33	1.1455
+++ LVM2/WHATS_NEW	2010/03/09 03:20:12	1.1456
@@ -1,16 +1,10 @@
 Version 2.02.62 -
 ====================================
-  Reimplement mlockall() with mlock() to reduce mmaped memory size.
-  Define and use internal makefile variable UDEV_LIBS.
-  Define and use internal makefile variable DL_LIBS.
-  Update check for selinux libraries and link them only when needed.
-  Define and use internal makefile variable SELINUX_LIBS and STATIC_LIBS.
+  Reimplement mlockall() with mlock() to reduce pinned memory size.
   Remove -rdynamic from static builds.
-  Update check for pthread library and link it only when needed.
-  Define and use internal makefile variable PTHREAD_LIBS.
-  Update check for readline library and link it only when needed.
-  Define and use internal makefile variable READLINE_LIBS.
-  Define and use internal makefile variable LVMINTERNAL_LIBS.
+  Update checks for pthread, readline & selinux libs and link only when needed.
+  Introduce makefile vars UDEV_LIBS, DL_LIBS, SELINUX_LIBS, STATIC_LIBS.
+  Introduce makefile vars LVMINTERNAL_LIBS, READLINE_LIBS, PTHREAD_LIBS.
   Help for configure prints --disable-fsadm.
   Use consistently $() instead of ${} for all Makefile variables.
   Replace CFLOW_CMD only in make.tmpl and use it as variable elsewhere.



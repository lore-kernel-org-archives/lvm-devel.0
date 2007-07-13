From: agk@sourceware.org <agk@sourceware.org>
Date: 13 Jul 2007 17:08:04 -0000
Subject: LVM2 WHATS_NEW configure configure.in
Message-ID: <20070713170804.9637.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-07-13 17:08:00

Modified files:
	.              : WHATS_NEW configure configure.in 

Log message:
	Fix configure libdevmapper.h check when --with-dmdir is used.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.655&r2=1.656
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.57&r2=1.58
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.56&r2=1.57

--- LVM2/WHATS_NEW	2007/07/12 15:38:52	1.655
+++ LVM2/WHATS_NEW	2007/07/13 17:08:00	1.656
@@ -1,5 +1,6 @@
 Version 2.02.27 - 
 ================================
+  Fix configure libdevmapper.h check when --with-dmdir is used.
   Turn _add_pv_to_vg() into external library function add_pv_to_vg().
   Add pv_by_path() external library function.
   Tidy clvmd-openais of redundant bits, and improve an error report.
--- LVM2/configure	2007/01/09 22:07:20	1.57
+++ LVM2/configure	2007/07/13 17:08:00	1.58
@@ -8957,7 +8957,7 @@
 # Check whether --with-dmdir or --without-dmdir was given.
 if test "${with_dmdir+set}" = set; then
   withval="$with_dmdir"
-   DMDIR="$withval"
+   DMDIR="$withval" CPPFLAGS="$CPPFLAGS -I$DMDIR/include"
 else
    DMDIR=
 fi;
--- LVM2/configure.in	2007/01/09 22:07:20	1.56
+++ LVM2/configure.in	2007/07/13 17:08:00	1.57
@@ -522,7 +522,7 @@
 
 AC_ARG_WITH(dmdir,
 	    [  --with-dmdir=DIR        Build against device-mapper source tree in DIR],
-  	    [ DMDIR="$withval" ],
+  	    [ DMDIR="$withval" CPPFLAGS="$CPPFLAGS -I$DMDIR/include"],
 	    [ DMDIR= ])
 
 ################################################################################



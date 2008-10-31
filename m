From: agk@sourceware.org <agk@sourceware.org>
Date: 31 Oct 2008 22:22:05 -0000
Subject: LVM2 ./configure.in include/.symlinks
Message-ID: <20081031222205.831.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-10-31 22:22:05

Modified files:
	.              : configure.in 
	include        : .symlinks 

Log message:
	drop configure --with-dmdir

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.81&r2=1.82
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/include/.symlinks.diff?cvsroot=lvm2&r1=1.50&r2=1.51

--- LVM2/configure.in	2008/10/31 22:06:09	1.81
+++ LVM2/configure.in	2008/10/31 22:22:04	1.82
@@ -611,11 +611,6 @@
 	    [ STATICDIR="$withval" ],
 	    [ STATICDIR='${exec_prefix}/sbin' ])
 
-AC_ARG_WITH(dmdir,
-	    [  --with-dmdir=DIR        Build against device-mapper source tree in DIR],
-	    [ DMDIR="$withval" CPPFLAGS="$CPPFLAGS -I$DMDIR/include"],
-	    [ DMDIR= ])
-
 # Convert a relative dir name to absolute.
 case $DMDIR in
   /*) ;;
--- LVM2/include/.symlinks	2008/10/30 17:54:11	1.50
+++ LVM2/include/.symlinks	2008/10/31 22:22:04	1.51
@@ -50,6 +50,7 @@
 ../lib/misc/sharedlib.h
 ../lib/report/report.h
 ../lib/uuid/uuid.h
+../libdm/libdevmapper.h
 ../libdm/misc/dm-ioctl.h
 ../libdm/misc/dm-logging.h
 ../libdm/misc/kdev_t.h



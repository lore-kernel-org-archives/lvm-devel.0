From: agk@sourceware.org <agk@sourceware.org>
Date: 31 Oct 2008 22:32:09 -0000
Subject: LVM2 configure.in
Message-ID: <20081031223209.17822.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-10-31 22:32:09

Modified files:
	.              : configure.in 

Log message:
	no DMDIR

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.83&r2=1.84

--- LVM2/configure.in	2008/10/31 22:29:44	1.83
+++ LVM2/configure.in	2008/10/31 22:32:09	1.84
@@ -611,12 +611,6 @@
 	    [ STATICDIR="$withval" ],
 	    [ STATICDIR='${exec_prefix}/sbin' ])
 
-# Convert a relative dir name to absolute.
-case $DMDIR in
-  /*) ;;
-  *) DMDIR="`pwd`/$DMDIR" ;;
-esac
-
 AC_ARG_WITH(usrlibdir,
 	    [  --with-usrlibdir=DIR],
 	    [ usrlibdir="$withval"],
@@ -723,7 +717,6 @@
 AC_SUBST(CSCOPE_CMD)
 AC_SUBST(DEBUG)
 AC_SUBST(DEVMAPPER)
-AC_SUBST(DMDIR)
 AC_SUBST(DMEVENTD)
 AC_SUBST(DM_COMPAT)
 AC_SUBST(DM_DEVICE_GID)



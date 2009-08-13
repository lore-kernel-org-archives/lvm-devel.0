From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 13 Aug 2009 20:23:02 -0000
Subject: LVM2 configure.in
Message-ID: <20090813202302.30304.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2009-08-13 20:23:02

Modified files:
	.              : configure.in 

Log message:
	configure script:  A couple unwanted changes snuck in.
	
	Previously while messing around with 'configure.in' and autoconf,
	I changed a couple lines that I didn't want in the final check-in.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.106&r2=1.107

--- LVM2/configure.in	2009/08/13 16:34:07	1.106
+++ LVM2/configure.in	2009/08/13 20:23:01	1.107
@@ -63,7 +63,7 @@
 
 ################################################################################
 dnl -- Checks for programs.
-m4_pattern_allow(AC_PROG_SED)
+AC_PROG_SED
 AC_PROG_AWK
 AC_PROG_CC
 
@@ -72,7 +72,7 @@
 AC_PROG_INSTALL
 AC_PROG_LN_S
 AC_PROG_MAKE_SET
-m4_pattern_allow(AC_PROG_MKDIR_P)
+AC_PROG_MKDIR_P
 AC_PROG_RANLIB
 AC_PATH_PROG(CFLOW_CMD, cflow)
 AC_PATH_PROG(CSCOPE_CMD, cscope)



From: agk@sourceware.org <agk@sourceware.org>
Date: 18 Mar 2010 13:24:37 -0000
Subject: LVM2 ./WHATS_NEW ./configure lib/misc/configur ...
Message-ID: <20100318132437.27847.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-03-18 13:24:36

Modified files:
	.              : WHATS_NEW configure 
	lib/misc       : configure.h.in 

Log message:
	autoreconf & add missing WHATS_NEW entry

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1468&r2=1.1469
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.121&r2=1.122
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/configure.h.in.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/WHATS_NEW	2010/03/17 14:55:28	1.1468
+++ LVM2/WHATS_NEW	2010/03/18 13:24:35	1.1469
@@ -1,5 +1,6 @@
 Version 2.02.63 - 
 ================================
+  Add configure --with-clvmd=singlenode to use clvmd w/o cluster infrastructure.
   Get stacktrace if testsuite test drops core and lvm was built with debugging.
   Disable long living process flag in lvm2app.
   Fix pvcreate device md filter check.
--- LVM2/configure	2010/03/04 12:12:34	1.121
+++ LVM2/configure	2010/03/18 13:24:35	1.122
@@ -1554,6 +1554,7 @@
                            * cman,gulm             (RHEL4 or equivalent)
                            * cman                  (RHEL5 or equivalent)
                            * cman,corosync,openais (or selection of them)
+                           * singlenode            (localhost only)
                            * all                   (autodetect)
                            * none                  (disable build)
                           TYPE=none
--- LVM2/lib/misc/configure.h.in	2010/03/18 09:19:32	1.17
+++ LVM2/lib/misc/configure.h.in	2010/03/18 13:24:36	1.18
@@ -270,7 +270,7 @@
 /* Define to 1 if you have the `strtoul' function. */
 #undef HAVE_STRTOUL
 
-/* Define to 1 if `struct stat' is a member of `st_rdev'. */
+/* Define to 1 if `st_rdev' is member of `struct stat'. */
 #undef HAVE_STRUCT_STAT_ST_RDEV
 
 /* Define to 1 if you have the <syslog.h> header file. */
@@ -407,9 +407,6 @@
 /* Define to the one symbol short name of this package. */
 #undef PACKAGE_TARNAME
 
-/* Define to the home page for this package. */
-#undef PACKAGE_URL
-
 /* Define to the version of this package. */
 #undef PACKAGE_VERSION
 



From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 20 Aug 2010 22:25:01 -0000
Subject: LVM2 ./configure.in doc/example.conf.in lib/co ...
Message-ID: <20100820222501.4701.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-08-20 22:24:59

Modified files:
	.              : configure.in 
	doc            : example.conf.in 
	lib/config     : defaults.h 

Log message:
	Switch to using configure --with-default-data-alignment=<NUM> to
	establish DEFAULT_DATA_ALIGNMENT.  Again, 0=64KiB, 1=1MiB, 2=2MiB
	
	Default is 1.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.153&r2=1.154
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.67&r2=1.68

--- LVM2/configure.in	2010/08/16 22:54:35	1.153
+++ LVM2/configure.in	2010/08/20 22:24:58	1.154
@@ -1185,6 +1185,15 @@
 		   [Name of default locking directory.])
 
 ################################################################################
+dnl -- Setup default data alignment
+AC_ARG_WITH(default-data-alignment,
+	    AC_HELP_STRING([--with-default-data-alignment=NUM],
+			   [set the default data alignment in MiB [[1]]]),
+	    DEFAULT_DATA_ALIGNMENT=$withval, DEFAULT_DATA_ALIGNMENT=1)
+AC_DEFINE_UNQUOTED(DEFAULT_DATA_ALIGNMENT, [$DEFAULT_DATA_ALIGNMENT],
+		   [Default data alignment.])
+
+################################################################################
 dnl -- which kernel interface to use (ioctl only)
 AC_MSG_CHECKING(for kernel interface choice)
 AC_ARG_WITH(interface,
@@ -1244,6 +1253,7 @@
 AC_SUBST(DEFAULT_ARCHIVE_SUBDIR)
 AC_SUBST(DEFAULT_BACKUP_SUBDIR)
 AC_SUBST(DEFAULT_CACHE_SUBDIR)
+AC_SUBST(DEFAULT_DATA_ALIGNMENT)
 AC_SUBST(DEFAULT_LOCK_DIR)
 AC_SUBST(DEFAULT_RUN_DIR)
 AC_SUBST(DEVMAPPER)
--- LVM2/doc/example.conf.in	2010/08/20 20:59:05	1.9
+++ LVM2/doc/example.conf.in	2010/08/20 22:24:58	1.10
@@ -101,7 +101,7 @@
     # Default alignment of the start of a data area in MB.  If set to 0,
     # a small value of 64KB will be used, which was the default until
     # LVM2 version 2.02.73.  Set to 1 for 1MiB, 2 for 2MiB, etc.
-    default_data_alignment = 1
+    # default_data_alignment = @DEFAULT_DATA_ALIGNMENT@
 
     # By default, the start of a PV's data area will be a multiple of
     # the 'minimum_io_size' or 'optimal_io_size' exposed in sysfs.
--- LVM2/lib/config/defaults.h	2010/08/20 20:59:05	1.67
+++ LVM2/lib/config/defaults.h	2010/08/20 22:24:59	1.68
@@ -34,7 +34,6 @@
 #define DEFAULT_MD_CHUNK_ALIGNMENT 1
 #define DEFAULT_IGNORE_SUSPENDED_DEVICES 1
 #define DEFAULT_REQUIRE_RESTOREFILE_WITH_UUID 1
-#define DEFAULT_DATA_ALIGNMENT 1
 #define DEFAULT_DATA_ALIGNMENT_OFFSET_DETECTION 1
 #define DEFAULT_DATA_ALIGNMENT_DETECTION 1
 



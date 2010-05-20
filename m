From: agk@sourceware.org <agk@sourceware.org>
Date: 20 May 2010 22:32:45 -0000
Subject: LVM2 ./configure.in lib/misc/configure.h.in
Message-ID: <20100520223245.16798.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-05-20 22:32:44

Modified files:
	.              : configure.in 
	lib/misc       : configure.h.in 

Log message:
	backup->cache

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.139&r2=1.140
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/configure.h.in.diff?cvsroot=lvm2&r1=1.20&r2=1.21

--- LVM2/configure.in	2010/05/20 13:47:21	1.139
+++ LVM2/configure.in	2010/05/20 22:32:44	1.140
@@ -1042,7 +1042,7 @@
 	    [ DEFAULT_BACKUP_SUBDIR="backup" ])
 AC_DEFINE_UNQUOTED(DEFAULT_BACKUP_SUBDIR,["$DEFAULT_BACKUP_SUBDIR"] )
 
-AH_TEMPLATE(DEFAULT_CACHE_SUBDIR, [Name of default metadata backup subdirectory.])
+AH_TEMPLATE(DEFAULT_CACHE_SUBDIR, [Name of default metadata cache subdirectory.])
 AC_ARG_WITH(default-cache-subdir,
 	    [  --with-default-cache-subdir=SUBDIR   Default metadata cache subdir [[cache]] ],
 	    [ DEFAULT_CACHE_SUBDIR="$withval" ],
--- LVM2/lib/misc/configure.h.in	2010/05/20 13:47:21	1.20
+++ LVM2/lib/misc/configure.h.in	2010/05/20 22:32:44	1.21
@@ -23,7 +23,7 @@
 /* Name of default metadata backup subdirectory. */
 #undef DEFAULT_BACKUP_SUBDIR
 
-/* Name of default metadata backup subdirectory. */
+/* Name of default metadata cache subdirectory. */
 #undef DEFAULT_CACHE_SUBDIR
 
 /* Name of default locking directory. */



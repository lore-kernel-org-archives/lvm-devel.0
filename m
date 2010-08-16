From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Aug 2010 17:49:26 -0000
Subject: LVM2 make.tmpl.in
Message-ID: <20100816174926.1932.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-08-16 17:49:26

Modified files:
	.              : make.tmpl.in 

Log message:
	set DEFAULT_RUN_DIR (missed from earlier checkin?)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.109&r2=1.110

--- LVM2/make.tmpl.in	2010/08/02 12:57:04	1.109
+++ LVM2/make.tmpl.in	2010/08/16 17:49:26	1.110
@@ -73,6 +73,7 @@
 DEFAULT_BACKUP_DIR = $(DEFAULT_SYS_DIR)/@DEFAULT_BACKUP_SUBDIR@
 DEFAULT_CACHE_DIR = $(DEFAULT_SYS_DIR)/@DEFAULT_CACHE_SUBDIR@
 DEFAULT_LOCK_DIR = @DEFAULT_LOCK_DIR@
+DEFAULT_RUN_DIR = @DEFAULT_RUN_DIR@
 
 # Setup vpath search paths for some suffixes
 vpath %.c $(srcdir)



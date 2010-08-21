From: agk@sourceware.org <agk@sourceware.org>
Date: 21 Aug 2010 00:16:37 -0000
Subject: LVM2/lib/misc configure.h.in
Message-ID: <20100821001637.476.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-08-21 00:16:37

Modified files:
	lib/misc       : configure.h.in 

Log message:
	autoreconf also updates configure.h.in

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/configure.h.in.diff?cvsroot=lvm2&r1=1.27&r2=1.28

--- LVM2/lib/misc/configure.h.in	2010/08/16 22:54:36	1.27
+++ LVM2/lib/misc/configure.h.in	2010/08/21 00:16:37	1.28
@@ -32,6 +32,9 @@
 /* Name of default metadata cache subdirectory. */
 #undef DEFAULT_CACHE_SUBDIR
 
+/* Default data alignment. */
+#undef DEFAULT_DATA_ALIGNMENT
+
 /* Name of default locking directory. */
 #undef DEFAULT_LOCK_DIR
 



From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Jun 2010 18:23:11 -0000
Subject: LVM2/tools .exported_symbols Makefile.in
Message-ID: <20100625182311.5568.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-06-25 18:23:11

Modified files:
	tools          : .exported_symbols Makefile.in 

Log message:
	generate liblvm2cmd exported symbols too

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/.exported_symbols.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.119&r2=1.120

--- LVM2/tools/.exported_symbols	2004/03/26 14:51:23	1.1
+++ LVM2/tools/.exported_symbols	2010/06/25 18:23:10	1.2
@@ -1,5 +0,0 @@
-lvm2_init
-lvm2_run
-lvm2_log_level
-lvm2_log_fn
-lvm2_exit
--- LVM2/tools/Makefile.in	2010/06/03 13:52:21	1.119
+++ LVM2/tools/Makefile.in	2010/06/25 18:23:10	1.120
@@ -106,6 +106,9 @@
 
 LVMLIBS += -ldevmapper
 
+EXPORTED_HEADER = $(srcdir)/lvm2cmd.h
+EXPORTED_FN_PREFIX = lvm2
+
 DEFS += -DLVM_SHARED_PATH=\"$(exec_prefix)/sbin/lvm\"
 
 CFLOW_LIST = lvmcmdlib.c lvm2cmd.c



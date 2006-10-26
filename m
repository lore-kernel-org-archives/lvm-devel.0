From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Oct 2006 20:37:13 -0000
Subject: LVM2 ./WHATS_NEW tools/Makefile.in
Message-ID: <20061026203713.20961.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-10-26 20:37:13

Modified files:
	.              : WHATS_NEW 
	tools          : Makefile.in 

Log message:
	dd couple of missing files to tools/Makefile CLEAN_TARGETS.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.483&r2=1.484
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.76&r2=1.77

--- LVM2/WHATS_NEW	2006/10/26 18:22:10	1.483
+++ LVM2/WHATS_NEW	2006/10/26 20:37:13	1.484
@@ -1,5 +1,6 @@
 Version 2.02.13 -
 ===================================
+  Add couple of missing files to tools/Makefile CLEAN_TARGETS.
   When adding snapshot leave cow LV mapped device active after zeroing.
   Fix a clvmd debug message.
   Add dev_flush() to set_lv().
--- LVM2/tools/Makefile.in	2006/08/18 21:17:18	1.76
+++ LVM2/tools/Makefile.in	2006/10/26 20:37:13	1.77
@@ -82,7 +82,8 @@
 
 CLEAN_TARGETS = liblvm2cmd.so liblvm2cmd.a liblvm2cmd-static.a lvm lvm.o \
 		lvm2cmd.o lvm2cmd-static.o lvm2cmdlib.o lvm.static \
-		lvm.cflow lvm.xref lvm.tree lvm.rxref lvm.rtree
+		lvm.cflow lvm.xref lvm.tree lvm.rxref lvm.rtree \
+		lvmcmdlib.o lvm-static.o
 
 ifeq ("@CMDLIB@", "yes")
 	TARGETS += liblvm2cmd.so



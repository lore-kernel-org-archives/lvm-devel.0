From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 Nov 2011 13:11:09 -0000
Subject: LVM2 ./make.tmpl.in test/unit/Makefile.in
Message-ID: <20111121131109.31258.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-21 13:11:04

Modified files:
	.              : make.tmpl.in 
	test/unit      : Makefile.in 

Log message:
	Add some cflags to ldflags
	
	Things like gcov needs the compilation flags for linker as well.
	TODO: cleanup compilation flags usage

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.124&r2=1.125
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/unit/Makefile.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/make.tmpl.in	2011/11/20 20:52:09	1.124
+++ LVM2/make.tmpl.in	2011/11/21 13:11:03	1.125
@@ -120,6 +120,7 @@
 #CFLAGS += -DDEBUG_CRC32
 
 CFLAGS += @COPTIMISE_FLAG@
+LDFLAGS += @COPTIMISE_FLAG@
 
 ifeq ("@DEBUG@", "yes")
   CFLAGS += -g -fno-omit-frame-pointer
--- LVM2/test/unit/Makefile.in	2011/11/20 21:43:20	1.1
+++ LVM2/test/unit/Makefile.in	2011/11/21 13:11:03	1.2
@@ -18,8 +18,8 @@
 SOURCES = bitset_t.c matcher_t.c run.c
 TARGETS = run
 
-LDFLAGS = -ldevmapper -lcunit
 include $(top_builddir)/make.tmpl
+LDFLAGS += -ldevmapper -lcunit
 
 unit: run
 	LD_LIBRARY_PATH=$(top_builddir)/libdm ./run



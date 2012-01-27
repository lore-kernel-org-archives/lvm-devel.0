From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 27 Jan 2012 10:55:03 -0000
Subject: LVM2/test/unit Makefile.in
Message-ID: <20120127105503.1147.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-27 10:55:02

Modified files:
	test/unit      : Makefile.in 

Log message:
	TARGETS macro has to be defined before inclusion of make.tmpl
	
	Use @TESTING@ check in this case.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/unit/Makefile.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/test/unit/Makefile.in	2012/01/26 21:40:36	1.6
+++ LVM2/test/unit/Makefile.in	2012/01/27 10:55:02	1.7
@@ -16,10 +16,12 @@
 
 VPATH = $(srcdir)
 SOURCES = bitset_t.c matcher_t.c config_t.c run.c
+ifeq ("@TESTING@", "yes")
+TARGETS = run
+endif
 
 include $(top_builddir)/make.tmpl
 ifeq ("$(TESTING)", "yes")
-TARGETS = run
 LDLIBS += -ldevmapper @CUNIT_LIBS@
 CFLAGS += @CUNIT_CFLAGS@
 



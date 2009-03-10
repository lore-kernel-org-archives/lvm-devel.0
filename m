From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 10 Mar 2009 12:10:13 -0000
Subject: LVM2/daemons/clvmd Makefile.in
Message-ID: <20090310121013.11274.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-03-10 12:10:13

Modified files:
	daemons/clvmd  : Makefile.in 

Log message:
	Fix clvmd build after liblvm commit.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/Makefile.in.diff?cvsroot=lvm2&r1=1.28&r2=1.29

--- LVM2/daemons/clvmd/Makefile.in	2009/02/25 22:41:13	1.28
+++ LVM2/daemons/clvmd/Makefile.in	2009/03/10 12:10:12	1.29
@@ -84,7 +84,7 @@
 TARGETS = \
 	clvmd
 
-LVMLIBS = -llvm -lpthread
+LVMLIBS = -llvm-internal -lpthread
 
 ifeq ("@DMEVENTD@", "yes")
 	LVMLIBS += -ldevmapper-event
@@ -100,7 +100,7 @@
 INSTALL_TARGETS = \
 	install_clvmd
 
-clvmd: $(OBJECTS) $(top_srcdir)/lib/liblvm.a
+clvmd: $(OBJECTS) $(top_srcdir)/lib/liblvm-internal.a
 	$(CC) -o clvmd $(OBJECTS) $(CFLAGS) $(LDFLAGS) \
 		$(LVMLIBS) $(LMLIBS) $(LIBS)
 



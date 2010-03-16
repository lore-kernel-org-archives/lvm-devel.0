From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 16 Mar 2010 08:47:51 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/Makefile.in
Message-ID: <20100316084751.6027.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-03-16 08:47:47

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : Makefile.in 

Log message:
	Fix clvmd Makefile to not overwrite LIBS from template definition

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1459&r2=1.1460
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/Makefile.in.diff?cvsroot=lvm2&r1=1.35&r2=1.36

--- LVM2/WHATS_NEW	2010/03/09 14:01:47	1.1459
+++ LVM2/WHATS_NEW	2010/03/16 08:47:46	1.1460
@@ -1,5 +1,6 @@
 Version 2.02.63 - 
 ================================
+  Fix clvmd Makefile to not overwrite LIBS from template definition.
 
 Version 2.02.62 - 9th March 2010
 ================================
--- LVM2/daemons/clvmd/Makefile.in	2010/03/04 11:21:05	1.35
+++ LVM2/daemons/clvmd/Makefile.in	2010/03/16 08:47:47	1.36
@@ -81,14 +81,14 @@
 	LVMLIBS += -ldevmapper-event
 endif
  
+include $(top_builddir)/make.tmpl
+
 LVMLIBS += -ldevmapper
 LIBS += $(PTHREAD_LIBS)
 
 DEFS += -D_REENTRANT
 CFLAGS += -fno-strict-aliasing
 
-include $(top_builddir)/make.tmpl
-
 INSTALL_TARGETS = \
 	install_clvmd
 



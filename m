From: agk@sourceware.org <agk@sourceware.org>
Date: 9 Oct 2009 16:04:55 -0000
Subject: LVM2/daemons/dmeventd/plugins mirror/Makefile. ...
Message-ID: <20091009160455.30336.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-10-09 16:04:54

Modified files:
	daemons/dmeventd/plugins/mirror: Makefile.in 
	daemons/dmeventd/plugins/snapshot: Makefile.in 

Log message:
	Extra libs must be appended, not defined first.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/Makefile.in.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2009/10/05 13:46:01	1.11
+++ LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2009/10/09 16:04:54	1.12
@@ -19,7 +19,6 @@
 
 INCLUDES += -I${top_srcdir}/tools
 CLDFLAGS += -L${top_builddir}/tools
-LIBS += -ldevmapper @LIB_PTHREAD@ @LVM2CMD_LIB@
 
 SOURCES = dmeventd_mirror.c
 
@@ -33,6 +32,8 @@
 
 include $(top_builddir)/make.tmpl
 
+LIBS += -ldevmapper @LIB_PTHREAD@ @LVM2CMD_LIB@
+
 install_lvm2: libdevmapper-event-lvm2mirror.$(LIB_SUFFIX)
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
 		$(libdir)/$<.$(LIB_VERSION)
--- LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in	2009/10/05 13:46:02	1.7
+++ LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in	2009/10/09 16:04:54	1.8
@@ -19,7 +19,6 @@
 
 INCLUDES += -I${top_srcdir}/tools
 CLDFLAGS += -L${top_builddir}/tools
-LIBS += -ldevmapper @LIB_PTHREAD@ @LVM2CMD_LIB@
 
 SOURCES = dmeventd_snapshot.c
 
@@ -33,6 +32,8 @@
 
 include $(top_builddir)/make.tmpl
 
+LIBS += -ldevmapper @LIB_PTHREAD@ @LVM2CMD_LIB@
+
 install_lvm2: libdevmapper-event-lvm2snapshot.$(LIB_SUFFIX)
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
 		$(libdir)/$<.$(LIB_VERSION)



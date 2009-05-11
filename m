From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 11 May 2009 10:28:48 -0000
Subject: LVM2 ./WHATS_NEW ./make.tmpl.in daemons/dmeven ...
Message-ID: <20090511102848.22776.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-05-11 10:28:47

Modified files:
	.              : WHATS_NEW make.tmpl.in 
	daemons/dmeventd/plugins/mirror: Makefile.in 
	daemons/dmeventd/plugins/snapshot: Makefile.in 
	doc            : Makefile.in 
	include        : Makefile.in 
	man            : Makefile.in 
	scripts        : Makefile.in 
	tools          : Makefile.in 

Log message:
	Introduce lvm2_install target.
	
	Buildsystem support device-mapper only install,
	but generic install tagret includes both dm+lvm2.
	
	For distribution which uses separate install_device-mapper,
	there is no way how to install lvm2 only
	(so after installing lvm2 for packaging purposes
	built system must remove installed device-mapper files).
	
	Fix it by allowing lvm2_install target, similarily like
	install_cluster for clvmd.
	
	(install = install_device-mapper + install_lvm2)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1098&r2=1.1099
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.66&r2=1.67
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/Makefile.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/Makefile.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/include/Makefile.in.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/Makefile.in.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/Makefile.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.96&r2=1.97

--- LVM2/WHATS_NEW	2009/05/09 13:47:03	1.1098
+++ LVM2/WHATS_NEW	2009/05/11 10:28:45	1.1099
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Add make install_lvm2 as complement to device-mapper install.
   Reject missing PVs from allocation in toollib.
   Fix PV datalignment for values starting prior to MDA area. (2.02.45)
   Add sparse devices: lvcreate -s --virtualoriginsize (hidden zero origin).
--- LVM2/make.tmpl.in	2009/04/08 14:08:18	1.66
+++ LVM2/make.tmpl.in	2009/05/11 10:28:45	1.67
@@ -126,7 +126,7 @@
 POTFILES = $(SOURCES:%.c=%.pot)
 
 .PHONY: all install install_cluster pofile distclean clean cflow device-mapper 
-.PHONY: install_device-mapper
+.PHONY: install_device-mapper install_lvm2
 .PHONY: $(SUBDIRS) $(SUBDIRS.install) $(SUBDIRS.clean) $(SUBDIRS.distclean)
 .PHONY: $(SUBDIRS.pofile) $(SUBDIRS.install_cluster) $(SUBDIRS.cflow)
 .PHONY: $(SUBDIRS.device-mapper) $(SUBDIRS.install-device-mapper)
@@ -135,6 +135,7 @@
 SUBDIRS.install := $(SUBDIRS:=.install)
 SUBDIRS.install_cluster := $(SUBDIRS:=.install_cluster)
 SUBDIRS.install_device-mapper := $(SUBDIRS:=.install_device-mapper)
+SUBDIRS.install_lvm2 := $(SUBDIRS:=.install_lvm2)
 SUBDIRS.pofile := $(SUBDIRS:=.pofile)
 SUBDIRS.cflow := $(SUBDIRS:=.cflow)
 SUBDIRS.clean := $(SUBDIRS:=.clean)
@@ -147,6 +148,7 @@
 install: all $(SUBDIRS.install)
 install_cluster: all $(SUBDIRS.install_cluster)
 install_device-mapper: $(SUBDIRS.install_device-mapper)
+install_lvm2: $(SUBDIRS.install_lvm2)
 
 $(SUBDIRS): $(SUBDIRS.device-mapper)
 	$(MAKE) -C $@
@@ -163,6 +165,9 @@
 $(SUBDIRS.install_device-mapper): device-mapper
 	$(MAKE) -C $(@:.install_device-mapper=) install_device-mapper
 
+$(SUBDIRS.install_lvm2): $(SUBDIRS)
+	$(MAKE) -C $(@:.install_lvm2=) install_lvm2
+
 $(SUBDIRS.clean):
 	-$(MAKE) -C $(@:.clean=) clean
 
--- LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2008/11/03 22:14:26	1.8
+++ LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2009/05/11 10:28:46	1.9
@@ -31,7 +31,9 @@
 
 include $(top_srcdir)/make.tmpl
 
-install: libdevmapper-event-lvm2mirror.$(LIB_SUFFIX)
+install_lvm2: libdevmapper-event-lvm2mirror.$(LIB_SUFFIX)
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
 		$(libdir)/$<.$(LIB_VERSION)
 	$(LN_S) -f $<.$(LIB_VERSION) $(libdir)/$<
+
+install: install_lvm2
--- LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in	2008/11/03 22:14:27	1.4
+++ LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in	2009/05/11 10:28:46	1.5
@@ -31,7 +31,9 @@
 
 include $(top_srcdir)/make.tmpl
 
-install: libdevmapper-event-lvm2snapshot.$(LIB_SUFFIX)
+install_lvm2: libdevmapper-event-lvm2snapshot.$(LIB_SUFFIX)
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
 		$(libdir)/$<.$(LIB_VERSION)
 	$(LN_S) -f $<.$(LIB_VERSION) $(libdir)/$<
+
+install: install_lvm2
--- LVM2/doc/Makefile.in	2007/09/21 10:16:43	1.4
+++ LVM2/doc/Makefile.in	2009/05/11 10:28:46	1.5
@@ -20,10 +20,11 @@
 
 include $(top_srcdir)/make.tmpl
 
-install:
+install_lvm2:
 	@if [ ! -e $(confdir)/$(CONFDEST) ]; then \
 		echo "Installing $(CONFSRC) as $(confdir)/$(CONFDEST)"; \
 		@INSTALL@ -D $(OWNER) $(GROUP) -m 644 $(CONFSRC) \
 			$(confdir)/$(CONFDEST); \
 	fi
 
+install: install_lvm2
--- LVM2/include/Makefile.in	2008/11/04 17:25:32	1.10
+++ LVM2/include/Makefile.in	2009/05/11 10:28:46	1.11
@@ -45,5 +45,7 @@
 
 install_device-mapper:
 
+install_lvm2:
+
 cflow:
 
--- LVM2/man/Makefile.in	2008/11/04 17:25:32	1.25
+++ LVM2/man/Makefile.in	2009/05/11 10:28:46	1.26
@@ -57,7 +57,7 @@
 %: %.in
 	$(SED) -e "s/#VERSION#/$(LVM_VERSION)/" $< > $@
 
-install: install_device-mapper
+install_lvm2:
 	@echo "Installing $(MAN8) in $(MAN8DIR)"
 	@for f in $(MAN8); \
 	do \
@@ -87,3 +87,5 @@
 	   $(RM) $(MAN8DIR)/$$f; \
 	   @INSTALL@ -D $(OWNER) $(GROUP) -m 444 $$f $(MAN8DIR)/$$f; \
 	done
+
+install: install_lvm2 install_device-mapper
--- LVM2/scripts/Makefile.in	2009/03/16 20:00:10	1.6
+++ LVM2/scripts/Makefile.in	2009/05/11 10:28:46	1.7
@@ -17,6 +17,8 @@
 
 include $(top_srcdir)/make.tmpl
 
+install_lvm2: install
+
 install:
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) lvm_dump.sh \
 		$(sbindir)/lvmdump
--- LVM2/tools/Makefile.in	2009/05/11 10:13:28	1.96
+++ LVM2/tools/Makefile.in	2009/05/11 10:28:46	1.97
@@ -195,4 +195,6 @@
 
 install_device-mapper: $(INSTALL_DMSETUP_TARGETS)
 
-install: $(INSTALL_LVM_TARGETS) install_device-mapper
+install_lvm2: $(INSTALL_LVM_TARGETS)
+
+install: install_lvm2 install_device-mapper



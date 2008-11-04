From: agk@sourceware.org <agk@sourceware.org>
Date: 4 Nov 2008 17:25:34 -0000
Subject: LVM2 ./make.tmpl.in daemons/dmeventd/Makefile. ...
Message-ID: <20081104172534.19712.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-11-04 17:25:33

Modified files:
	.              : make.tmpl.in 
	daemons/dmeventd: Makefile.in 
	include        : Makefile.in 
	libdm          : Makefile.in 
	man            : Makefile.in 
	tools          : Makefile.in 

Log message:
	make install_device-mapper

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.62&r2=1.63
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/Makefile.in.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/include/Makefile.in.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/Makefile.in.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/Makefile.in.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.87&r2=1.88

--- LVM2/make.tmpl.in	2008/11/04 15:55:26	1.62
+++ LVM2/make.tmpl.in	2008/11/04 17:25:32	1.63
@@ -129,7 +129,8 @@
 OBJECTS = $(SOURCES:%.c=%.o)
 POTFILES = $(SOURCES:%.c=%.pot)
 
-.PHONY: all install install_cluster pofile distclean clean cflow device-mapper
+.PHONY: all install install_cluster pofile distclean clean cflow device-mapper 
+.PHONY: install_device-mapper
 .PHONY: $(SUBDIRS) $(SUBDIRS.install) $(SUBDIRS.clean) $(SUBDIRS.distclean)
 .PHONY: $(SUBDIRS.pofile) $(SUBDIRS.install_cluster) $(SUBDIRS.cflow)
 .PHONY: $(SUBDIRS.device-mapper) $(SUBDIRS.install-device-mapper)
@@ -163,7 +164,7 @@
 $(SUBDIRS.install_cluster): $(SUBDIRS)
 	$(MAKE) -C $(@:.install_cluster=) install_cluster
 
-$(SUBDIRS.install_device-mapper): $(SUBDIRS)
+$(SUBDIRS.install_device-mapper): device-mapper
 	$(MAKE) -C $(@:.install_device-mapper=) install_device-mapper
 
 $(SUBDIRS.clean):
--- LVM2/daemons/dmeventd/Makefile.in	2008/11/04 15:55:27	1.22
+++ LVM2/daemons/dmeventd/Makefile.in	2008/11/04 17:25:32	1.23
@@ -61,6 +61,8 @@
 
 install: $(INSTALL_TYPE) install_include install_dmeventd
 
+install_device-mapper: install
+
 install_include:
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 libdevmapper-event.h \
 		$(includedir)/libdevmapper-event.h
--- LVM2/include/Makefile.in	2008/11/01 02:19:17	1.9
+++ LVM2/include/Makefile.in	2008/11/04 17:25:32	1.10
@@ -20,7 +20,7 @@
 
 LN_S = @LN_S@
 
-.PHONY: clean distclean all install pofile install_cluster
+.PHONY: clean distclean all install pofile install_cluster install_device-mapper
 
 all: .symlinks_created
 
@@ -43,5 +43,7 @@
 
 install_cluster:
 
+install_device-mapper:
+
 cflow:
 
--- LVM2/libdm/Makefile.in	2008/11/03 22:14:29	1.41
+++ LVM2/libdm/Makefile.in	2008/11/04 17:25:32	1.42
@@ -67,6 +67,8 @@
 
 install: $(INSTALL_TYPE) install_include
 
+install_device-mapper: install
+
 install_include:
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 libdevmapper.h \
 		$(includedir)/libdevmapper.h
--- LVM2/man/Makefile.in	2008/11/01 02:19:18	1.24
+++ LVM2/man/Makefile.in	2008/11/04 17:25:32	1.25
@@ -32,10 +32,11 @@
 	vgimport.8 vgmerge.8 vgmknodes.8 vgreduce.8 vgremove.8 vgrename.8 \
 	vgs.8 vgscan.8 vgsplit.8 $(FSADMMAN)
 MAN8CLUSTER=clvmd.8
+MAN8DM=dmsetup.8
 MAN5DIR=${mandir}/man5
 MAN8DIR=${mandir}/man8
 
-CLEAN_TARGETS=$(MAN5) $(MAN8) $(MAN8CLUSTER) $(FSADMMAN) dmsetup.8
+CLEAN_TARGETS=$(MAN5) $(MAN8) $(MAN8CLUSTER) $(FSADMMAN) $(MAN8DM)
 
 include $(top_srcdir)/make.tmpl
 
@@ -47,7 +48,7 @@
 
 .PHONY: man
 
-device-mapper: dmsetup.8
+device-mapper: $(MAN8DM)
 
 man: $(MAN5) $(MAN8) $(MAN8CLUSTER)
 
@@ -56,7 +57,7 @@
 %: %.in
 	$(SED) -e "s/#VERSION#/$(LVM_VERSION)/" $< > $@
 
-install:
+install: install_device-mapper
 	@echo "Installing $(MAN8) in $(MAN8DIR)"
 	@for f in $(MAN8); \
 	do \
@@ -78,3 +79,11 @@
 	   $(RM) $(MAN8DIR)/$$f; \
 	   @INSTALL@ -D $(OWNER) $(GROUP) -m 444 $$f $(MAN8DIR)/$$f; \
 	done
+
+install_device-mapper:
+	@echo "Installing $(MAN8DM) in $(MAN8DIR)"
+	@for f in $(MAN8DM); \
+	do \
+	   $(RM) $(MAN8DIR)/$$f; \
+	   @INSTALL@ -D $(OWNER) $(GROUP) -m 444 $$f $(MAN8DIR)/$$f; \
+	done
--- LVM2/tools/Makefile.in	2008/11/03 22:14:30	1.87
+++ LVM2/tools/Makefile.in	2008/11/04 17:25:32	1.88
@@ -66,12 +66,14 @@
 	.commands \
 	lvm
 
-INSTALL_TARGETS = install_tools_dynamic
+INSTALL_LVM_TARGETS = install_tools_dynamic
+INSTALL_DMSETUP_TARGETS = install_dmsetup_dynamic
 INSTALL_CMDLIB_TARGETS = install_cmdlib_dynamic
 
 ifeq ("@STATIC_LINK@", "yes")
   TARGETS += lvm.static
-  INSTALL_TARGETS += install_tools_static
+  INSTALL_LVM_TARGETS += install_tools_static
+  INSTALL_DMSETUP_TARGETS += install_dmsetup_static
   INSTALL_CMDLIB_TARGETS += install_cmdlib_static
 endif
 
@@ -84,7 +86,7 @@
 
 ifeq ("@CMDLIB@", "yes")
 	TARGETS += liblvm2cmd.so
-	INSTALL_TARGETS += $(INSTALL_CMDLIB_TARGETS)
+	INSTALL_LVM_TARGETS += $(INSTALL_CMDLIB_TARGETS)
 endif
 
 ifeq ("@DMEVENTD@", "yes")
@@ -182,4 +184,12 @@
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) lvm.static \
 		$(staticdir)/lvm.static
 
-install: $(INSTALL_TARGETS)
+install_dmsetup_dynamic: dmsetup
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< $(sbindir)/$<
+
+install_dmsetup_static: dmsetup.static
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< $(sbindir)/$<
+
+install_device-mapper: $(INSTALL_DMSETUP_TARGETS)
+
+install: $(INSTALL_LVM_TARGETS) install_device-mapper



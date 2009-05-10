From: Milan Broz <mbroz@redhat.com>
Date: Sun, 10 May 2009 20:06:12 +0200
Subject: [PATCH] Introduce lvm2_install target.
In-Reply-To: <1241978772-6394-1-git-send-email-mbroz@redhat.com>
References: <1241978772-6394-1-git-send-email-mbroz@redhat.com>
Message-ID: <1241978772-6394-5-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Buildsystem support device-mapper only install,
but generic install tagret includes both dm+lvm2.

For distribution which uses separate install_device-mapper,
there is no way how to install lvm2 only
(so after installing lvm2 for packaging purposes
built system must remove installed device-mapper files).

Fix it by allowing lvm2_install target, similarily like
install_cluster for clvmd.

(install = install_device-mapper + install_lvm2)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 WHATS_NEW                                     |    1 +
 daemons/dmeventd/plugins/mirror/Makefile.in   |    4 +++-
 daemons/dmeventd/plugins/snapshot/Makefile.in |    4 +++-
 doc/Makefile.in                               |    4 +++-
 include/Makefile.in                           |    2 ++
 make.tmpl.in                                  |    7 ++++++-
 man/Makefile.in                               |    4 +++-
 scripts/Makefile.in                           |    2 ++
 tools/Makefile.in                             |    4 +++-
 9 files changed, 26 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 25ab1ae..f6dd5ae 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Add make install_lvm2 as complement to device-mapper install.
   Inherit read ahead from underlying device.
   Fix first_seg() call for empty segment list.
   Fix PV datalignment for values starting prior to MDA area. (2.02.45)
diff --git a/daemons/dmeventd/plugins/mirror/Makefile.in b/daemons/dmeventd/plugins/mirror/Makefile.in
index 4154d05..284ab52 100644
--- a/daemons/dmeventd/plugins/mirror/Makefile.in
+++ b/daemons/dmeventd/plugins/mirror/Makefile.in
@@ -31,7 +31,9 @@ LIB_VERSION = $(LIB_VERSION_LVM)
 
 include $(top_srcdir)/make.tmpl
 
-install: libdevmapper-event-lvm2mirror.$(LIB_SUFFIX)
+install: install_lvm2
+
+install_lvm2: libdevmapper-event-lvm2mirror.$(LIB_SUFFIX)
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
 		$(libdir)/$<.$(LIB_VERSION)
 	$(LN_S) -f $<.$(LIB_VERSION) $(libdir)/$<
diff --git a/daemons/dmeventd/plugins/snapshot/Makefile.in b/daemons/dmeventd/plugins/snapshot/Makefile.in
index fd3851b..98f398a 100644
--- a/daemons/dmeventd/plugins/snapshot/Makefile.in
+++ b/daemons/dmeventd/plugins/snapshot/Makefile.in
@@ -31,7 +31,9 @@ LIB_VERSION = $(LIB_VERSION_LVM)
 
 include $(top_srcdir)/make.tmpl
 
-install: libdevmapper-event-lvm2snapshot.$(LIB_SUFFIX)
+install: install_lvm2
+
+install_lvm2: libdevmapper-event-lvm2snapshot.$(LIB_SUFFIX)
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
 		$(libdir)/$<.$(LIB_VERSION)
 	$(LN_S) -f $<.$(LIB_VERSION) $(libdir)/$<
diff --git a/doc/Makefile.in b/doc/Makefile.in
index b327752..56dca0a 100644
--- a/doc/Makefile.in
+++ b/doc/Makefile.in
@@ -20,7 +20,9 @@ CONFDEST=lvm.conf
 
 include $(top_srcdir)/make.tmpl
 
-install:
+install: install_lvm2
+
+install_lvm2:
 	@if [ ! -e $(confdir)/$(CONFDEST) ]; then \
 		echo "Installing $(CONFSRC) as $(confdir)/$(CONFDEST)"; \
 		@INSTALL@ -D $(OWNER) $(GROUP) -m 644 $(CONFSRC) \
diff --git a/include/Makefile.in b/include/Makefile.in
index 2d86488..301290e 100644
--- a/include/Makefile.in
+++ b/include/Makefile.in
@@ -45,5 +45,7 @@ install_cluster:
 
 install_device-mapper:
 
+install_lvm2:
+
 cflow:
 
diff --git a/make.tmpl.in b/make.tmpl.in
index d5c2fa9..fa3b884 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -126,7 +126,7 @@ OBJECTS = $(SOURCES:%.c=%.o)
 POTFILES = $(SOURCES:%.c=%.pot)
 
 .PHONY: all install install_cluster pofile distclean clean cflow device-mapper 
-.PHONY: install_device-mapper
+.PHONY: install_device-mapper install_lvm2
 .PHONY: $(SUBDIRS) $(SUBDIRS.install) $(SUBDIRS.clean) $(SUBDIRS.distclean)
 .PHONY: $(SUBDIRS.pofile) $(SUBDIRS.install_cluster) $(SUBDIRS.cflow)
 .PHONY: $(SUBDIRS.device-mapper) $(SUBDIRS.install-device-mapper)
@@ -135,6 +135,7 @@ SUBDIRS.device-mapper := $(SUBDIRS:=.device-mapper)
 SUBDIRS.install := $(SUBDIRS:=.install)
 SUBDIRS.install_cluster := $(SUBDIRS:=.install_cluster)
 SUBDIRS.install_device-mapper := $(SUBDIRS:=.install_device-mapper)
+SUBDIRS.install_lvm2 := $(SUBDIRS:=.install_lvm2)
 SUBDIRS.pofile := $(SUBDIRS:=.pofile)
 SUBDIRS.cflow := $(SUBDIRS:=.cflow)
 SUBDIRS.clean := $(SUBDIRS:=.clean)
@@ -147,6 +148,7 @@ all: $(SUBDIRS) $(TARGETS)
 install: all $(SUBDIRS.install)
 install_cluster: all $(SUBDIRS.install_cluster)
 install_device-mapper: $(SUBDIRS.install_device-mapper)
+install_lvm2: $(SUBDIRS.install_lvm2)
 
 $(SUBDIRS): $(SUBDIRS.device-mapper)
 	$(MAKE) -C $@
@@ -163,6 +165,9 @@ $(SUBDIRS.install_cluster): $(SUBDIRS)
 $(SUBDIRS.install_device-mapper): device-mapper
 	$(MAKE) -C $(@:.install_device-mapper=) install_device-mapper
 
+$(SUBDIRS.install_lvm2): $(SUBDIRS)
+	$(MAKE) -C $(@:.install_lvm2=) install_lvm2
+
 $(SUBDIRS.clean):
 	-$(MAKE) -C $(@:.clean=) clean
 
diff --git a/man/Makefile.in b/man/Makefile.in
index f1a34d7..c7c28d1 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -57,7 +57,9 @@ $(MAN5) $(MAN8) $(MAN8CLUSTER):	Makefile
 %: %.in
 	$(SED) -e "s/#VERSION#/$(LVM_VERSION)/" $< > $@
 
-install: install_device-mapper
+install: install_lvm2 install_device-mapper
+
+install_lvm2:
 	@echo "Installing $(MAN8) in $(MAN8DIR)"
 	@for f in $(MAN8); \
 	do \
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index afd3916..d8ee816 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -17,6 +17,8 @@ VPATH = @srcdir@
 
 include $(top_srcdir)/make.tmpl
 
+install_lvm2: install
+
 install:
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) lvm_dump.sh \
 		$(sbindir)/lvmdump
diff --git a/tools/Makefile.in b/tools/Makefile.in
index 874d391..89c4609 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -195,4 +195,6 @@ install_dmsetup_static: dmsetup.static
 
 install_device-mapper: $(INSTALL_DMSETUP_TARGETS)
 
-install: $(INSTALL_LVM_TARGETS) install_device-mapper
+install_lvm2: $(INSTALL_LVM_TARGETS)
+
+install: install_lvm2 install_device-mapper
-- 
1.6.2.4



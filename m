From: Fabio M. Di Nitto <fabbione@fabbione.net>
Date: Thu,  8 Oct 2009 14:49:17 +0200
Subject: [PATCH 10/11] debian: make the subdir recursion -j capable
In-Reply-To: <1255006158-8053-1-git-send-email-fabbione@fabbione.net>
References: <1255006158-8053-1-git-send-email-fabbione@fabbione.net>
Message-ID: <14be282c1124b6bcb3652593127d3878707585fc.1255002311.git.fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Fabio M. Di Nitto <fdinitto@redhat.com>

but it removes some dependencies on the way

Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
---
:100644 100644 556d1ff... 2e8a010... M	Makefile.in
:100644 100644 5464188... 56dfa8b... M	make.tmpl.in
:100644 100644 f0c98fd... f0acb84... M	man/Makefile.in
 Makefile.in     |   27 +----------------------
 make.tmpl.in    |   64 +++++++++++-------------------------------------------
 man/Makefile.in |    4 +--
 3 files changed, 15 insertions(+), 80 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 556d1ff..2e8a010 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -27,7 +27,7 @@ ifeq ("@INTL@", "yes")
   SUBDIRS += po
 endif
 
-SUBDIRS += lib tools daemons libdm
+SUBDIRS += libdm lib tools daemons
 
 ifeq ("@APPLIB@", "yes")
   SUBDIRS += liblvm
@@ -54,31 +54,6 @@ endif
 
 include make.tmpl
 
-libdm: include
-lib: libdm
-liblvm: lib
-daemons: lib tools
-tools: lib device-mapper
-po: tools daemons
-
-libdm.device-mapper: include.device-mapper
-daemons.device-mapper: libdm.device-mapper
-tools.device-mapper: libdm.device-mapper
-device-mapper: tools.device-mapper daemons.device-mapper man.device-mapper
-
-ifeq ("@INTL@", "yes")
-lib.pofile: include.pofile
-tools.pofile: lib.pofile
-daemons.pofile: lib.pofile
-po.pofile: tools.pofile daemons.pofile
-pofile: po.pofile
-endif
-
-ifneq ("@CFLOW_CMD@", "")
-tools.cflow: lib.cflow
-cflow: tools.cflow
-endif
-
 ifneq ("@CSCOPE_CMD@", "")
 cscope.out: tools
 	@CSCOPE_CMD@ -b -R
diff --git a/make.tmpl.in b/make.tmpl.in
index 5464188..56dfa8b 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -132,65 +132,27 @@ POTFILES = $(SOURCES:%.c=%.pot)
 
 .PHONY: all install install_cluster pofile distclean clean cflow device-mapper 
 .PHONY: install_device-mapper install_lvm2
-.PHONY: $(SUBDIRS) $(SUBDIRS.install) $(SUBDIRS.clean) $(SUBDIRS.distclean)
-.PHONY: $(SUBDIRS.pofile) $(SUBDIRS.install_cluster) $(SUBDIRS.cflow)
-.PHONY: $(SUBDIRS.device-mapper) $(SUBDIRS.install-device-mapper)
-
-SUBDIRS.device-mapper := $(SUBDIRS:=.device-mapper)
-SUBDIRS.install := $(SUBDIRS:=.install)
-SUBDIRS.install_cluster := $(SUBDIRS:=.install_cluster)
-SUBDIRS.install_device-mapper := $(SUBDIRS:=.install_device-mapper)
-SUBDIRS.install_lvm2 := $(SUBDIRS:=.install_lvm2)
-SUBDIRS.pofile := $(SUBDIRS:=.pofile)
-SUBDIRS.cflow := $(SUBDIRS:=.cflow)
-SUBDIRS.clean := $(SUBDIRS:=.clean)
-SUBDIRS.distclean := $(SUBDIRS:=.distclean)
 
 TARGETS += $(LIB_SHARED) $(LIB_STATIC) $(VERSIONED_SHLIB)
 
-all: $(SUBDIRS) $(TARGETS)
+all: subdirs-all $(TARGETS)
 
-install: all $(SUBDIRS.install)
-install_cluster: all $(SUBDIRS.install_cluster)
-install_device-mapper: $(SUBDIRS.install_device-mapper)
-install_lvm2: $(SUBDIRS.install_lvm2)
+install: subdirs-install
+install_cluster: subdirs-install_cluster
+install_device-mapper: subdirs-install_device-mapper
+install_lvm2: subdirs-install_lvm2
 
-$(SUBDIRS): $(SUBDIRS.device-mapper)
-	$(MAKE) -C $@
-
-$(SUBDIRS.device-mapper):
-	$(MAKE) -C $(@:.device-mapper=) device-mapper
-
-$(SUBDIRS.install): $(SUBDIRS)
-	$(MAKE) -C $(@:.install=) install
-
-$(SUBDIRS.install_cluster): $(SUBDIRS)
-	$(MAKE) -C $(@:.install_cluster=) install_cluster
-
-$(SUBDIRS.install_device-mapper): device-mapper
-	$(MAKE) -C $(@:.install_device-mapper=) install_device-mapper
-
-$(SUBDIRS.install_lvm2): $(SUBDIRS)
-	$(MAKE) -C $(@:.install_lvm2=) install_lvm2
-
-$(SUBDIRS.clean):
-	-$(MAKE) -C $(@:.clean=) clean
-
-$(SUBDIRS.distclean):
-	-$(MAKE) -C $(@:.distclean=) distclean
+subdirs-%:
+	+ at set -e; for subdir in $(SUBDIRS); do \
+		$(MAKE) -C $$subdir $(patsubst subdirs-%,%,$@); \
+	done
 
 ifeq ("@INTL@", "yes")
-pofile: $(SUBDIRS.pofile) $(POTFILES)
-
-$(SUBDIRS.pofile):
-	$(MAKE) -C $(@:.pofile=) pofile
+pofile: subdirs-pofile $(POTFILES)
 endif
 
 ifneq ("@CFLOW_CMD@", "")
-cflow: $(SUBDIRS.cflow)
-
-$(SUBDIRS.cflow):
-	$(MAKE) -C $(@:.cflow=) cflow
+cflow: subdirs-cflow
 endif
 
 $(TARGETS): $(OBJECTS)
@@ -238,12 +200,12 @@ $(LIB_STATIC): $(OBJECTS)
 %.mo: %.po
 	$(MSGFMT) -o $@ $<
 
-clean: $(SUBDIRS.clean)
+clean: subdirs-clean
 	$(RM) $(OBJECTS) $(TARGETS) $(CLEAN_TARGETS) $(SOURCES:%.c=%.d) \
 	      $(SOURCES2:%.c=%.d) $(SOURCES:%.c=%.pot) $(SOURCES:%.c=%.gcno) \
 	      $(SOURCES:%.c=%.gcda) $(LDDEPS)
 
-distclean: $(SUBDIRS.distclean)
+distclean: subdir-distclean
 	$(RM) -rf $(DISTCLEAN_DIRS)
 	$(RM) $(DISTCLEAN_TARGETS) \
 	      $(OBJECTS) $(TARGETS) $(CLEAN_TARGETS) $(SOURCES:%.c=%.d) \
diff --git a/man/Makefile.in b/man/Makefile.in
index f0c98fd..f0acb84 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -49,9 +49,7 @@ all: man
 
 .PHONY: man
 
-device-mapper: $(MAN8DM)
-
-man: $(MAN5) $(MAN8) $(MAN8CLUSTER)
+man: $(MAN5) $(MAN8) $(MAN8CLUSTER) $(MAN8DM)
 
 $(MAN5) $(MAN8) $(MAN8CLUSTER):	Makefile
 
-- 
1.5.4.3



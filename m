From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 18 May 2015 10:52:31 +0000 (UTC)
Subject: master - makefiles: better clean
Message-ID: <20150518105231.6BF4E61057@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=30c3bbcd9e852d7f79846ecc57148a47e52e818d
Commit:        30c3bbcd9e852d7f79846ecc57148a47e52e818d
Parent:        1bed578535f9f2442916ce7da060132233502bcb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 18 10:27:48 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 18 12:45:42 2015 +0200

makefiles: better clean

More exact clean of library exported symbols files.

Also use $(firstword) test to check for empty string
so 'make clean' has now cleaner condensed look.

Clean also created include links.
---
 include/Makefile.in |   12 ++++++++----
 libdm/Makefile.in   |    2 +-
 liblvm/Makefile.in  |    2 +-
 make.tmpl.in        |   20 ++++++++++++++------
 test/Makefile.in    |   10 ++++------
 tools/Makefile.in   |    3 ++-
 6 files changed, 30 insertions(+), 19 deletions(-)

diff --git a/include/Makefile.in b/include/Makefile.in
index 3daaab1..2049b67 100644
--- a/include/Makefile.in
+++ b/include/Makefile.in
@@ -20,8 +20,12 @@ include $(top_builddir)/make.tmpl
 
 all: .symlinks_created
 
-.symlinks_created: .symlinks 
-	find . -maxdepth 1 -type l -exec $(RM) \{\} \;
+LINKS := $(shell find . -maxdepth 1 -type l)
+
+.symlinks_created: .symlinks
+ifneq (,$(firstword $(LINKS)))
+	$(RM) $(LINKS)
+endif
 	for i in `cat $<`; do $(LN_S) $$i ; done
 	touch $@
 
@@ -31,5 +35,5 @@ device-mapper: all
 
 cflow: all
 
-DISTCLEAN_TARGETS += $(shell find . -maxdepth 1 -type l)
-DISTCLEAN_TARGETS += .include_symlinks .symlinks_created .symlinks
+DISTCLEAN_TARGETS += .symlinks
+CLEAN_TARGETS += $(LINKS) .include_symlinks .symlinks_created
diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index c1d7871..ba65c6a 100644
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -94,4 +94,4 @@ install_ioctl_static: $(LIB_STATIC)
 	$(INSTALL_DATA) -D $< $(usrlibdir)/$(<F)
 
 CLEAN_TARGETS += ioctl/libdevmapper.a
-DISTCLEAN_TARGETS += libdevmapper.pc .exported_symbols_generated
+DISTCLEAN_TARGETS += libdevmapper.pc
diff --git a/liblvm/Makefile.in b/liblvm/Makefile.in
index d0f8d1b..69c12bb 100644
--- a/liblvm/Makefile.in
+++ b/liblvm/Makefile.in
@@ -81,4 +81,4 @@ liblvm.cflow: $(SOURCES)
 
 cflow: liblvm.cflow
 
-DISTCLEAN_TARGETS += $(LIB_NAME).pc .exported_symbols_generated
+DISTCLEAN_TARGETS += $(LIB_NAME).pc
diff --git a/make.tmpl.in b/make.tmpl.in
index 4ad7f58..95ca299 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -423,6 +423,8 @@ endif
 $(LIB_SHARED): $(LIB_SHARED).$(LIB_VERSION)
 	$(LN_S) -f $(<F) $@
 
+CLEAN_TARGETS += $(LDDEPS) .exported_symbols_generated
+
 install_lib_shared: $(LIB_SHARED)
 	$(INSTALL_PROGRAM) -D $< $(libdir)/$(<F).$(LIB_VERSION)
 	$(INSTALL_DIR) $(usrlibdir)
@@ -459,17 +461,23 @@ $(LIB_STATIC): $(OBJECTS)
 %.mo: %.po
 	$(MSGFMT) -o $@ $<
 
+CLEAN_TARGETS += \
+	$(SOURCES:%.c=%.d) $(SOURCES:%.c=%.gcno) $(SOURCES:%.c=%.gcda) \
+	$(SOURCES2:%.c=%.o) $(SOURCES2:%.c=%.d) $(SOURCES2:%.c=%.gcno) $(SOURCES2:%.c=%.gcda) \
+	$(POTFILES) $(CLEAN_CFLOW)
+
 cleandir:
-	test -z "$(CLEAN_DIRS)" || $(RM) -r $(CLEAN_DIRS)
-	$(RM) $(OBJECTS) $(TARGETS) $(CLEAN_TARGETS) $(CLEAN_CFLOW) $(LDDEPS) \
-	  $(POTFILES) $(SOURCES:%.c=%.d) $(SOURCES:%.c=%.gcno) $(SOURCES:%.c=%.gcda) \
-	  $(SOURCES2:%.c=%.o) $(SOURCES2:%.c=%.d) $(SOURCES2:%.c=%.gcno) $(SOURCES2:%.c=%.gcda) \
-	  .exported_symbols_generated core
+ifneq (,$(firstword $(CLEAN_DIRS)))
+	$(RM) -r $(CLEAN_DIRS)
+endif
+	$(RM) $(OBJECTS) $(TARGETS) $(CLEAN_TARGETS) core
 
 clean: $(SUBDIRS.clean) cleandir
 
 distclean: cleandir $(SUBDIRS.distclean)
-	test -z "$(DISTCLEAN_DIRS)" || $(RM) -r $(DISTCLEAN_DIRS)
+ifneq (,$(firstword $(DISTCLEAN_DIRS)))
+	$(RM) -r $(DISTCLEAN_DIRS)
+endif
 	$(RM) $(DISTCLEAN_TARGETS) Makefile
 
 .exported_symbols_generated: $(EXPORTED_HEADER) .exported_symbols $(DEPS)
diff --git a/test/Makefile.in b/test/Makefile.in
index 5b9d5ad..cd2c425 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -263,12 +263,10 @@ LIB = $(LIB_SHARED) $(LIB_LOCAL) $(LIB_EXEC) $(LIB_FLAVOURS)
 	$(LN_S) -f $(abs_top_srcdir)/conf/thin-performance.profile lib/thin-performance.profile
 	touch $@
 
-cleantest:
-	test "$(srcdir)" = . || $(RM) $(RUN_BASE)
-	$(RM) -r $(LVM_TEST_RESULTS)
-
-clean: cleantest
-distclean: cleantest
+CLEAN_DIRS += $(LVM_TEST_RESULTS)
+ifneq (.,$(firstword $(srcdir)))
+CLEAN_TARGETS += $(RUN_BASE)
+endif
 
 CLEAN_TARGETS += .lib-dir-stamp .tests-stamp $(LIB) $(addprefix lib/,$(CMDS)) \
 	lib/clvmd lib/dmeventd lib/dmsetup lib/lvmetad lib/fsadm lib/vgimportclone \
diff --git a/tools/Makefile.in b/tools/Makefile.in
index 20c988d..9bbf87b 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -97,7 +97,8 @@ LIB_VERSION = $(LIB_VERSION_LVM)
 
 CLEAN_TARGETS = liblvm2cmd.$(LIB_SUFFIX) $(TARGETS_DM) \
 	liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION) lvm-static.o \
-	liblvm2cmd-static.a dmsetup.static lvm.static
+	liblvm2cmd-static.a dmsetup.static lvm.static \
+	$(LDDEPS) .exported_symbols_generated
 
 ifeq ("@CMDLIB@", "yes")
 	TARGETS += liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION)



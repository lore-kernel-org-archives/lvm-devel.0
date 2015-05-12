From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 12 May 2015 10:41:29 +0000 (UTC)
Subject: master - makefiles: runtime spec.inc
Message-ID: <20150512104129.D028A60E21@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9c2a6de68f776be2b6839960d955c75e749ccc0c
Commit:        9c2a6de68f776be2b6839960d955c75e749ccc0c
Parent:        f5199a1cbddf9fbfaba54635c12b7ebd6e4dd0a8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 11 21:48:11 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 12 12:40:37 2015 +0200

makefiles: runtime spec.inc

Support  CLEAN_DIRS
Var for rpmbuilddir
Use LN_S
Generate spec.inc at runtime for 'make rpm'.
---
 Makefile.in  |   37 +++++++++++++++++++++++--------------
 WHATS_NEW    |    1 +
 make.tmpl.in |    2 ++
 3 files changed, 26 insertions(+), 14 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index a180d10..be4241c 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -99,24 +99,33 @@ check check_system check_cluster check_local check_lvmetad unit: all
 
 conf.generate: tools
 
-VER = LVM2. at LVM_MAJOR@. at LVM_MINOR@. at LVM_PATCHLEVEL@
-CLEAN_TARGETS += $(VER).tgz
-clean:
-	$(RM) -r build
+# how to use parenthesis in makefiles
+leftparen:=(
+LVM_VER := $(firstword $(subst $(leftparen), ,$(LVM_VERSION)))
+VER := LVM2.$(LVM_VER)
+# release file name
+FILE_VER := $(VER).tgz
+CLEAN_TARGETS += $(FILE_VER)
+CLEAN_DIRS += $(rpmbuilddir)
 
 dist:
-	@echo "Generating $(VER).tgz";\
-	git ls-tree -r HEAD --name-only | xargs tar --transform "s,^,$(VER)/," -zcf $(VER).tgz
+	@echo "Generating $(FILE_VER)";\
+	(cd $(top_srcdir); git ls-tree -r HEAD --name-only | xargs tar --transform "s,^,$(VER)/," -c) | gzip >$(FILE_VER)
 
 rpm: dist
-	$(MKDIR_P) build/SPECS build/SOURCES
-	ln -sf $(abs_top_srcdir)/spec/lvm2.spec build/SPECS
-	ln -sf $(abs_top_srcdir)/spec/build.inc build/SOURCES
-	ln -sf $(abs_top_srcdir)/spec/macros.inc build/SOURCES
-	ln -sf $(abs_top_srcdir)/spec/packages.inc build/SOURCES
-	ln -sf $(abs_top_srcdir)/spec/source.inc build/SOURCES
-	ln -sf $(abs_top_builddir)/$(VER).tgz build/SOURCES
-	rpmbuild -v --define "_topdir $(abs_top_builddir)/build" -ba build/SPECS/lvm2.spec
+	$(RM) -r $(rpmbuilddir)/SOURCES
+	$(MKDIR_P) $(rpmbuilddir)/SOURCES
+	$(LN_S) -f $(abs_top_builddir)/$(FILE_VER) $(rpmbuilddir)/SOURCES
+	$(LN_S) -f $(abs_top_srcdir)/spec/build.inc $(rpmbuilddir)/SOURCES
+	$(LN_S) -f $(abs_top_srcdir)/spec/macros.inc $(rpmbuilddir)/SOURCES
+	$(LN_S) -f $(abs_top_srcdir)/spec/packages.inc $(rpmbuilddir)/SOURCES
+	DM_VER=$$(cut -d- -f1 $(top_srcdir)/VERSION_DM);\
+	GIT_VER=$$(cd $(top_srcdir); git describe | cut -d- --output-delimiter=. -f2,3 || echo 0);\
+	sed -e "s,\(device_mapper_version\) [0-9.]*$$,\1 $$DM_VER," \
+	    -e "s,^\(Version:[^0-9%]*\)[0-9.]*$$,\1 $(LVM_VER)," \
+	    -e "s,^\(Release:[^0-9%]*\)[0-9.]\+,\1 $$GIT_VER," \
+	    $(top_srcdir)/spec/source.inc >$(rpmbuilddir)/SOURCES/source.inc
+	rpmbuild -v --define "_topdir $(abs_top_builddir)/$(rpmbuilddir)" -ba $(top_srcdir)/spec/lvm2.spec
 
 generate: conf.generate
 	$(MAKE) -C conf generate
diff --git a/WHATS_NEW b/WHATS_NEW
index e4fe6b6..d724a1b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.120 -
 ===============================
+  Provide make dist and make rpm targets
   Configure lvm.conf for use_lvmetad and use_lvmpolld.
   Add lvpoll for cmdline communication with lvmpolld.
   Add lvmpolld acting as a free-standing version of polldaemon.
diff --git a/make.tmpl.in b/make.tmpl.in
index 1cac75e..dce5b2c 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -116,6 +116,7 @@ vpath %.exported_symbols $(srcdir)
 
 interface = @interface@
 interfacebuilddir = $(top_builddir)/libdm/$(interface)
+rpmbuilddir = build
 
 # The number of jobs to run, if blank, defaults to the make standard
 ifndef MAKEFLAGS
@@ -465,6 +466,7 @@ $(LIB_STATIC): $(OBJECTS)
 	$(MSGFMT) -o $@ $<
 
 cleandir:
+	test -z "$(CLEAN_DIRS)" || $(RM) -r $(CLEAN_DIRS)
 	$(RM) $(OBJECTS) $(TARGETS) $(CLEAN_TARGETS) $(CLEAN_CFLOW) $(LDDEPS) \
 	  $(POTFILES) $(SOURCES:%.c=%.d) $(SOURCES:%.c=%.gcno) $(SOURCES:%.c=%.gcda) \
 	  $(SOURCES2:%.c=%.o) $(SOURCES2:%.c=%.d) $(SOURCES2:%.c=%.gcno) $(SOURCES2:%.c=%.gcda) \



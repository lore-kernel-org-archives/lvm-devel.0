From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  2 Mar 2021 21:58:23 +0000 (GMT)
Subject: main - makefiles: better logging
Message-ID: <20210302215823.611633851C35@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=39eee85fff1930047a7dffe11183b4cafb6eb653
Commit:        39eee85fff1930047a7dffe11183b4cafb6eb653
Parent:        456b659b4edfc758b5aa0b72af25677a4f5042ea
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 28 21:20:54 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 2 22:54:40 2021 +0100

makefiles: better logging

Show only filename instead of full path name when building
in builddir != srcdir
---
 daemons/dmeventd/Makefile.in |  2 +-
 daemons/lvmlockd/Makefile.in |  2 +-
 libdm/dm-tools/Makefile.in   |  4 ++--
 libdm/make.tmpl.in           | 12 ++++++------
 make.tmpl.in                 | 12 ++++++------
 man/Makefile.in              |  6 ++++--
 scripts/Makefile.in          | 10 +++++-----
 tools/Makefile.in            | 26 +++++++++++++-------------
 8 files changed, 38 insertions(+), 36 deletions(-)

diff --git a/daemons/dmeventd/Makefile.in b/daemons/dmeventd/Makefile.in
index 6bd36d032..99e4a816f 100644
--- a/daemons/dmeventd/Makefile.in
+++ b/daemons/dmeventd/Makefile.in
@@ -82,7 +82,7 @@ CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES))
 endif
 
 install_include: $(srcdir)/libdevmapper-event.h
-	@echo "    [INSTALL] $<"
+	@echo "    [INSTALL] $(<F)"
 	$(Q) $(INSTALL_DATA) -D $< $(includedir)/$(<F)
 
 install_pkgconfig: libdevmapper-event.pc
diff --git a/daemons/lvmlockd/Makefile.in b/daemons/lvmlockd/Makefile.in
index 9c0340145..bd577d1e6 100644
--- a/daemons/lvmlockd/Makefile.in
+++ b/daemons/lvmlockd/Makefile.in
@@ -56,7 +56,7 @@ lvmlockd: $(OBJECTS) $(top_builddir)/libdaemon/client/libdaemonclient.a \
 
 lvmlockctl: lvmlockctl.o $(top_builddir)/libdaemon/client/libdaemonclient.a
 	@echo "    [CC] $@"
-	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -o $@ lvmlockctl.o $(INTERNAL_LIBS) $(LIBS)
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -o $@ $< $(INTERNAL_LIBS) $(LIBS)
 
 install_lvmlockd: lvmlockd
 	@echo "    [INSTALL] $<"
diff --git a/libdm/dm-tools/Makefile.in b/libdm/dm-tools/Makefile.in
index 15a9d8ef5..0b2ef9605 100644
--- a/libdm/dm-tools/Makefile.in
+++ b/libdm/dm-tools/Makefile.in
@@ -71,12 +71,12 @@ install_dmsetup_static: dmsetup.static
 	$(Q) $(LN_S) -f $(<F) $(staticdir)/dmstats
 
 
-dmfilemapd: $(LIB_SHARED) dmfilemapd.o
+dmfilemapd: dmfilemapd.o $(LIB_SHARED)
 	@echo "    [CC] $@"
 	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) \
 	      -o $@ $+ $(DMLIBS)
 
-dmfilemapd.static: $(LIB_STATIC) dmfilemapd.o
+dmfilemapd.static: dmfilemapd.o $(LIB_STATIC)
 	@echo "    [CC] $@"
 	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(ELDFLAGS) -static \
 	      -o $@ $+ $(DMLIBS) $(STATIC_LIBS)
diff --git a/libdm/make.tmpl.in b/libdm/make.tmpl.in
index 46916d23f..1192e87e8 100644
--- a/libdm/make.tmpl.in
+++ b/libdm/make.tmpl.in
@@ -401,11 +401,11 @@ endif
 DEFS+=-D_FILE_OFFSET_BITS=64
 
 %.o: %.c
-	@echo "    [CC] $<"
+	@echo "    [CC] $(<F)"
 	$(Q) $(CC) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(WCFLAGS) $(CFLAGS) $(CFLAGS_$@) $< -o $@
 
 %.o: %.cpp
-	@echo "    [CXX] $<"
+	@echo "    [CXX] $(<F)"
 	$(Q) $(CXX) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(CXXFLAGS) $(CXXFLAGS_$@) $< -o $@
 
 %.pot: %.c Makefile
@@ -413,7 +413,7 @@ DEFS+=-D_FILE_OFFSET_BITS=64
 	$(Q) $(CC) -E $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) -include $(top_builddir)/po/pogen.h $(DEFS) $(WFLAGS) $(CFLAGS) $< >$@
 
 %.so: %.o
-	@echo "    [CC] $<"
+	@echo "    [CC] $(<F)"
 	$(Q) $(CC) -c $(CFLAGS) $(CLDFLAGS) $< $(LIBS) -o $@
 
 ifneq (,$(LIB_SHARED))
@@ -431,7 +431,7 @@ ifeq ("@LIB_SUFFIX@","dylib")
 endif
 
 $(LIB_SHARED): $(LIB_SHARED).$(LIB_VERSION)
-	@echo "    [LN] $<"
+	@echo "    [LN] $(<F)"
 	$(Q) $(LN_S) -f $(<F) $@
 
 CLEAN_TARGETS += $(LDDEPS) .exported_symbols_generated
@@ -463,7 +463,7 @@ $(LIB_STATIC): $(OBJECTS)
 	$(Q) $(AR) rsv $@ $(OBJECTS) > /dev/null
 
 %.d: %.c
-	@echo "    [DEP] $<"
+	@echo "    [DEP] $(<F)"
 	$(Q) $(MKDIR_P) $(dir $@); \
 	set -e; \
 	FILE=`echo $@ | sed 's/\\//\\\\\\//g;s/\\.d//g'`; \
@@ -475,7 +475,7 @@ $(LIB_STATIC): $(OBJECTS)
 	[ -s $@ ] || $(RM) $@
 
 %.mo: %.po
-	@echo "    [MSGFMT] $<"
+	@echo "    [MSGFMT] $(<F)"
 	$(Q) $(MSGFMT) -o $@ $<
 
 CLEAN_TARGETS += \
diff --git a/make.tmpl.in b/make.tmpl.in
index 4bd089d24..024302ff2 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -440,19 +440,19 @@ endif
 DEFS+=-D_FILE_OFFSET_BITS=64
 
 %.o: %.c
-	@echo "    [CC] $<"
+	@echo "    [CC] $(<F)"
 	$(Q) $(CC) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(WCFLAGS) $(CFLAGS) $(CFLAGS_$@) $< -o $@
 
 %.o: %.cpp
-	@echo "    [CXX] $<"
+	@echo "    [CXX] $(<F)"
 	$(Q) $(CXX) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(CXXFLAGS) $(CXXFLAGS_$@) $< -o $@
 
 %.pot: %.c Makefile
-	@echo "    [CC] $@"
+	@echo "    [CC] $(<F)"
 	$(Q) $(CC) -E $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) -include $(top_builddir)/po/pogen.h $(DEFS) $(WFLAGS) $(CFLAGS) $< >$@
 
 %.so: %.o
-	@echo "    [CC] $<"
+	@echo "    [CC] $(<F)"
 	$(Q) $(CC) -c $(CFLAGS) $(CLDFLAGS) $< $(LIBS) -o $@
 
 ifneq (,$(LIB_SHARED))
@@ -502,7 +502,7 @@ $(LIB_STATIC): $(OBJECTS)
 	$(Q) $(AR) rsv $@ $(OBJECTS) > /dev/null
 
 %.d: %.c
-	@echo "    [DEP] $<"
+	@echo "    [DEP] $(<F)"
 	$(Q) $(MKDIR_P) $(dir $@); \
 	set -e; \
 	FILE=`echo $@ | sed 's/\\//\\\\\\//g;s/\\.d//g'`; \
@@ -514,7 +514,7 @@ $(LIB_STATIC): $(OBJECTS)
 	[ -s $@ ] || $(RM) $@
 
 %.mo: %.po
-	@echo "    [MSGFMT] $<"
+	@echo "    [MSGFMT] $(<F)"
 	$(Q) $(MSGFMT) -o $@ $<
 
 CLEAN_TARGETS += \
diff --git a/man/Makefile.in b/man/Makefile.in
index 6bca8cabc..786671e3a 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -112,7 +112,8 @@ $(MAN5) $(MAN7) $(MAN8) $(MAN8SO) $(MAN8DM) $(MAN8CLUSTER) $(MAN8SYSTEMD_GENERAT
 
 # Test whether or not the man page generator works
 $(TESTMAN): $(MANGENERATOR) Makefile
-	- $(MANGENERATOR) --primary lvmconfig > $@
+	@echo "    [TSTMAN] $@"
+	$(Q) - $(MANGENERATOR) --primary lvmconfig > $@
 
 SEE_ALSO=$(srcdir)/see_also.end
 
@@ -246,7 +247,8 @@ install_all_man: install install_systemd_generators
 
 # Copy generated man pages back to source tree as fallback for machines where generator doesn't work
 pregenerated_man: all
-	set -e ; for i in $(srcdir)/*.8_des; do \
+	@echo "    [GENERATE] $^"
+	$(Q) set -e ; for i in $(srcdir)/*.8_des; do \
 		CMD=`basename $$i .8_des`; \
 		cat $${CMD}.8_gen > $(srcdir)/$$CMD.8_pregen ; \
 	done
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index e3843977e..e8f674282 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -59,7 +59,7 @@ install: install_lvm2 install_ocf install_device-mapper
 
 # FIXME Customise for other distributions
 install_initscripts:
-	@echo "    [INSTALL] $<"
+	@echo "    [INSTALL] initscripts"
 	$(Q) $(INSTALL_DIR) $(initdir)
 ifeq ("@BUILD_DMEVENTD@", "yes")
 	$(Q) $(INSTALL_SCRIPT) lvm2_monitoring_init_red_hat $(initdir)/lvm2-monitor
@@ -81,12 +81,12 @@ lvm2_activation_generator_systemd_red_hat: $(OBJECTS) $(LVMINTERNAL_LIBS)
 	$(Q) $(CC) -o $@ $(OBJECTS) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) $(LVMINTERNAL_LIBS) $(LIBS)
 
 install_systemd_generators:
-	@echo "    [INSTALL] $<"
+	@echo "    [INSTALL] systemd_generators"
 	$(Q) $(INSTALL_DIR) $(systemd_generator_dir)
 	$(Q) $(INSTALL_PROGRAM) lvm2_activation_generator_systemd_red_hat $(systemd_generator_dir)/lvm2-activation-generator
 
 install_systemd_units:	install_dbus_service
-	@echo "    [INSTALL] $<"
+	@echo "    [INSTALL] systemd_units"
 	$(Q) $(INSTALL_DIR) $(systemd_unit_dir)
 	$(Q) $(INSTALL_DATA) lvm2-pvscan.service $(systemd_unit_dir)/lvm2-pvscan@.service
 ifeq ("@BUILD_DMEVENTD@", "yes")
@@ -114,7 +114,7 @@ endif
 
 ifeq ("@BUILD_LVMDBUSD@", "yes")
 install_dbus_service:
-	@echo "    [INSTALL] $<"
+	@echo "    [INSTALL] dbus_service"
 	$(Q) $(INSTALL_DIR) $(dbusconfdir)
 	$(Q) $(INSTALL_DIR) $(dbusservicedir)
 	$(Q) $(INSTALL_DATA) $(top_srcdir)/scripts/com.redhat.lvmdbus1.conf $(dbusconfdir)
@@ -124,7 +124,7 @@ install_systemd_units:	install_dbus_service
 endif
 
 install_tmpfiles_configuration:
-	@echo "    [INSTALL] $<"
+	@echo "    [INSTALL] configuration"
 	$(Q) $(INSTALL_DIR) $(tmpfiles_dir)
 	$(Q) $(INSTALL_DATA) lvm2_tmpfiles_red_hat.conf $(tmpfiles_dir)/lvm2.conf
 
diff --git a/tools/Makefile.in b/tools/Makefile.in
index c89c75fa5..a099973e1 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -155,16 +155,16 @@ liblvm2cmd.$(LIB_SUFFIX): liblvm2cmd.a $(LDDEPS)
 	@echo "    [CC] $@"
 	$(Q) $(CC) -shared -Wl,-soname,$@.$(LIB_VERSION) \
 		$(CFLAGS) $(CLDFLAGS) -o $@ \
-		@CLDWHOLEARCHIVE@ liblvm2cmd.a @CLDNOWHOLEARCHIVE@ \
+		@CLDWHOLEARCHIVE@ $< @CLDNOWHOLEARCHIVE@ \
 		$(LVMINTERNAL_LIBS) $(LVMLIBS)
 
 liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION): liblvm2cmd.$(LIB_SUFFIX)
 	@echo "    [LN] $@"
 	$(Q) $(LN_S) -f $< $@
 
-.commands: $(srcdir)/commands.h $(srcdir)/cmdnames.h Makefile
-	@echo "    [CC] $<"
-	$(Q) $(CC) -E -P $(srcdir)/cmdnames.h 2> /dev/null | \
+.commands: $(srcdir)/cmdnames.h $(srcdir)/commands.h Makefile
+	@echo "    [CC] $(<F)"
+	$(Q) $(CC) -E -P $< 2> /dev/null | \
 		$(EGREP) -v '^ *(|#.*|config|devtypes|dumpconfig|formats|fullreport|help|lastlog|lvmchange|lvpoll|pvdata|segtypes|systemid|tags|version) *$$' > .commands
 
 command-count.h: $(srcdir)/command-lines.in Makefile
@@ -173,13 +173,13 @@ command-count.h: $(srcdir)/command-lines.in Makefile
 	( cat $(top_srcdir)/tools/license.inc && \
 	  echo "/* Do not edit. This file is generated by the Makefile. */" && \
 	  echo -n "#define COMMAND_COUNT " && \
-	  $(GREP) '^ID:' $(srcdir)/command-lines.in | $(WC) -l \
+	  $(GREP) '^ID:' $< | $(WC) -l \
 	) > $@
 
 cmds.h: $(srcdir)/command-lines.in Makefile
 	@echo "    [GEN] $@"
 	$(Q) set -o pipefail && \
-	( cat $(top_srcdir)/tools/license.inc && \
+	( cat $(srcdir)/license.inc && \
 	  echo "/* Do not edit. This file is generated by the Makefile. */" && \
 	  echo "cmd(CMD_NONE, none)" && \
 	  $(GREP) '^ID:' $(srcdir)/command-lines.in | LANG=C $(SORT) -u | $(AWK) '{print "cmd(" $$2 "_CMD, " $$2 ")"}' && \
@@ -189,7 +189,7 @@ cmds.h: $(srcdir)/command-lines.in Makefile
 command-lines-input.h: $(srcdir)/command-lines.in Makefile
 	@echo "    [GEN] $@"
 	$(Q) set -o pipefail && \
-	( cat $(top_srcdir)/tools/license.inc && \
+	( cat $(srcdir)/license.inc && \
 	  echo "/* Do not edit. This file is generated by the Makefile. */" && \
 	  echo -en "const char _command_input[] =\n\n\"" && \
 	  $(EGREP) -v '^#|\-\-\-|^$$' $(srcdir)/command-lines.in | $(AWK) 'BEGIN {ORS = "\\n\"\n\""} //' && \
@@ -208,7 +208,7 @@ endif
 	install_tools_dynamic install_tools_static
 
 install_cmdlib_include: $(srcdir)/lvm2cmd.h
-	@echo "    [INSTALL] $<"
+	@echo "    [INSTALL] $(<F)"
 	$(Q) $(INSTALL_DATA) -D $< $(includedir)/$(<F)
 
 install_cmdlib_dynamic: liblvm2cmd.$(LIB_SUFFIX)
@@ -223,12 +223,12 @@ install_cmdlib_static: liblvm2cmd-static.a
 
 install_tools_dynamic: lvm .commands
 	@echo "    [INSTALL] $<"
-	$(Q) $(INSTALL_PROGRAM) -D lvm $(sbindir)/lvm
+	$(Q) $(INSTALL_PROGRAM) -D $< $(sbindir)/$(<F)
 	@echo Creating symbolic links for individual commands in $(sbindir)
-	@for v in `cat .commands`; do \
-		test -n "$(Q)" || echo "$(LN_S) -f lvm $(sbindir)/$$v"; \
-		$(LN_S) -f lvm $(sbindir)/$$v; \
-	done;
+	@cat .commands | while read v ; do \
+		test -n "$(Q)" || echo "$(LN_S) -f $(<F) $(sbindir)/$$v"; \
+		$(LN_S) -f $(<F) $(sbindir)/$$v; \
+	done
 
 install_tools_static: lvm.static
 	@echo "    [INSTALL] $<"



From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:50:57 -0400
Subject: master - [build] Quieten the build down
Message-ID: <201804231350.w3NDovGK032042@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7a475bef323cae74d602f2aae8074b106ddb3f4b
Commit:        7a475bef323cae74d602f2aae8074b106ddb3f4b
Parent:        da7e13ef88541c4ca4b067f4f47ad7b43d346501
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Wed Jan 31 10:04:17 2018 +0000
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:10:45 2018 -0500

[build] Quieten the build down

It was hard to see warnings with the long command lines scrolling by so
quickly.

Use 'make V=1' if you need to see all the gritty details.
---
 make.tmpl.in      |   62 ++++++++++++++++++++++++++--------------
 man/Makefile.in   |   81 +++++++++++++++++++++++++----------------------------
 tools/Makefile.in |   73 ++++++++++++++++++++++++++++++-----------------
 3 files changed, 125 insertions(+), 91 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index bdf2349..75134ca 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -13,6 +13,12 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+ifeq ($(V),1)
+	Q=
+else
+	Q=@
+endif
+
 SHELL = @SHELL@
 
 @SET_MAKE@
@@ -438,59 +444,70 @@ endif
 .LIBPATTERNS = lib%.so lib%.a
 
 %.o: %.c
-	$(CC) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(WCFLAGS) $(CFLAGS) $(CFLAGS_$@) $< -o $@
+	@echo "    [CC] $<"
+	$(Q) $(CC) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(WCFLAGS) $(CFLAGS) $(CFLAGS_$@) $< -o $@
 
 %.o: %.cpp
-	$(CXX) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(CXXFLAGS) $(CXXFLAGS_$@) $< -o $@
+	@echo "    [CXX] $<"
+	$(Q) $(CXX) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(CXXFLAGS) $(CXXFLAGS_$@) $< -o $@
 
 %.pot: %.c Makefile
-	$(CC) -E $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) -include $(top_builddir)/include/pogen.h $(DEFS) $(WFLAGS) $(CFLAGS) $< >$@
+	@echo "    [CC] $@"
+	$(Q) $(CC) -E $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) -include $(top_builddir)/include/pogen.h $(DEFS) $(WFLAGS) $(CFLAGS) $< >$@
 
 %.so: %.o
-	$(CC) -c $(CFLAGS) $(CLDFLAGS) $< $(LIBS) -o $@
+	@echo "    [CC] $<"
+	$(Q) $(CC) -c $(CFLAGS) $(CLDFLAGS) $< $(LIBS) -o $@
 
 ifneq (,$(LIB_SHARED))
 
 TARGETS += $(LIB_SHARED).$(LIB_VERSION)
 $(LIB_SHARED).$(LIB_VERSION): $(OBJECTS) $(LDDEPS)
+	@echo "    [CC] $@"
 ifeq ("@LIB_SUFFIX@","so")
-	$(CC) -shared -Wl,-soname,$(notdir $@) \
+	$(Q) $(CC) -shared -Wl,-soname,$(notdir $@) \
 		$(CFLAGS) $(CLDFLAGS) $(OBJECTS) $(LIBS) -o $@
 endif
 ifeq ("@LIB_SUFFIX@","dylib")
-	$(CC) -dynamiclib -dylib_current_version,$(LIB_VERSION) \
+	$(Q) $(CC) -dynamiclib -dylib_current_version,$(LIB_VERSION) \
 		$(CFLAGS) $(CLDFLAGS) $(OBJECTS) $(LIBS) -o $@
 endif
 
 $(LIB_SHARED): $(LIB_SHARED).$(LIB_VERSION)
-	$(LN_S) -f $(<F) $@
+	@echo "    [LN] $<"
+	$(Q) $(LN_S) -f $(<F) $@
 
 CLEAN_TARGETS += $(LDDEPS) .exported_symbols_generated
 
 install_lib_shared: $(LIB_SHARED)
-	$(INSTALL_PROGRAM) -D $< $(libdir)/$(<F).$(LIB_VERSION)
-	$(INSTALL_DIR) $(usrlibdir)
-	$(LN_S) -f $(USRLIB_RELPATH)$(<F).$(LIB_VERSION) $(usrlibdir)/$(<F)
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL_PROGRAM) -D $< $(libdir)/$(<F).$(LIB_VERSION)
+	$(Q) $(INSTALL_DIR) $(usrlibdir)
+	$(Q) $(LN_S) -f $(USRLIB_RELPATH)$(<F).$(LIB_VERSION) $(usrlibdir)/$(<F)
 
 # FIXME: plugins are installed to subdirs
 #        and for compatibility links in libdir are created
 #        when the code is fixed links could be removed.
 install_dm_plugin: $(LIB_SHARED)
-	$(INSTALL_PROGRAM) -D $< $(libdir)/device-mapper/$(<F)
-	$(LN_S) -f device-mapper/$(<F) $(libdir)/$(<F)
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL_PROGRAM) -D $< $(libdir)/device-mapper/$(<F)
+	$(Q) $(LN_S) -f device-mapper/$(<F) $(libdir)/$(<F)
 
 install_lvm2_plugin: $(LIB_SHARED)
-	$(INSTALL_PROGRAM) -D $< $(libdir)/lvm2/$(<F)
-	$(LN_S) -f lvm2/$(<F) $(libdir)/$(<F)
-	$(LN_S) -f $(<F) $(libdir)/$(<F).$(LIB_VERSION)
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL_PROGRAM) -D $< $(libdir)/lvm2/$(<F)
+	$(Q) $(LN_S) -f lvm2/$(<F) $(libdir)/$(<F)
+	$(Q) $(LN_S) -f $(<F) $(libdir)/$(<F).$(LIB_VERSION)
 endif
 
 $(LIB_STATIC): $(OBJECTS)
-	$(RM) $@
-	$(AR) rsv $@ $(OBJECTS)
+	@echo "    [AR] $@"
+	$(Q) $(RM) $@
+	$(Q) $(AR) rsv $@ $(OBJECTS) > /dev/null
 
 %.d: %.c $(INC_LNS)
-	$(MKDIR_P) $(dir $@); \
+	@echo "    [DEP] $<"
+	$(Q) $(MKDIR_P) $(dir $@); \
 	set -e; \
 	FILE=`echo $@ | sed 's/\\//\\\\\\//g;s/\\.d//g'`; \
 	DEPS=`echo $(DEPS) | sed -e 's/\\//\\\\\\//g'`; \
@@ -501,7 +518,8 @@ $(LIB_STATIC): $(OBJECTS)
 	[ -s $@ ] || $(RM) $@
 
 %.mo: %.po
-	$(MSGFMT) -o $@ $<
+	@echo "    [MSGFMT] $<"
+	$(Q) $(MSGFMT) -o $@ $<
 
 CLEAN_TARGETS += \
 	$(SOURCES:%.c=%.d) $(SOURCES:%.c=%.gcno) $(SOURCES:%.c=%.gcda) \
@@ -523,7 +541,7 @@ endif
 	$(RM) $(DISTCLEAN_TARGETS) Makefile
 
 .exported_symbols_generated: $(EXPORTED_HEADER) .exported_symbols $(DEPS)
-	set -e; \
+	$(Q) set -e; \
 	( cat $(srcdir)/.exported_symbols; \
 	  if test -n "$(EXPORTED_HEADER)"; then \
 		$(CC) -E -P $(INCLUDES) $(DEFS) $(EXPORTED_HEADER) | \
@@ -536,13 +554,13 @@ EXPORTED_SYMBOLS := $(wildcard $(srcdir)/.exported_symbols.Base $(srcdir)/.expor
 
 .export.sym: .exported_symbols_generated $(EXPORTED_SYMBOLS)
 ifeq (,$(firstword $(EXPORTED_SYMBOLS)))
-	set -e; (echo "Base {"; echo "	global:";\
+	$(Q) set -e; (echo "Base {"; echo "	global:";\
 		 $(SED) "s/^/		/;s/$$/;/" $<;\
 		 echo "};";\
 		 echo "Local {"; echo "	local:"; echo "		*;"; echo "};";\
 		 ) > $@
 else
-	set -e;\
+	$(Q) set -e;\
 	R=$$($(SORT) $^ | uniq -u);\
 	test -z "$$R" || { echo "Mismatch between symbols in shared library and lists in .exported_symbols.* files: $$R"; false; } ;\
 	( for i in $$(echo $(EXPORTED_SYMBOLS) | tr ' ' '\n' | $(SORT) -rnt_ -k5 ); do\
diff --git a/man/Makefile.in b/man/Makefile.in
index cd1106f..a40e168 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -16,6 +16,12 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
+ifeq ($(V),1)
+	Q=
+else
+	Q=@
+endif
+
 FSADMMAN = fsadm.8
 BLKDEACTIVATEMAN = blkdeactivate.8
 DMEVENTDMAN = dmeventd.8
@@ -46,20 +52,6 @@ MAN8DM=dmsetup.8 dmstats.8
 MAN8CLUSTER=
 MAN8SYSTEMD_GENERATORS=lvm2-activation-generator.8
 
-ifeq ("$(origin V)", "command line")
-  BUILD_VERBOSE = $(V)
-endif
-ifndef BUILD_VERBOSE
-  BUILD_VERBOSE = 0
-endif
-
-ifeq ($(BUILD_VERBOSE),1)
-  Q =
-else
-  Q = @
-endif
-
-
 ifeq ($(MAKECMDGOALS),all_man)
   MAN_ALL="yes"
 endif
@@ -164,13 +156,6 @@ SEE_ALSO=$(srcdir)/see_also.end
 .PRECIOUS: %.8_gen
 
 %.8_gen: $(srcdir)/%.8_des $(srcdir)/%.8_end $(MANGENERATOR) $(TESTMAN)
-	$(Q)( \
-	    if [ ! -s $(TESTMAN) ] ; then \
-		echo "Copying pre-generated template $@" ; \
-	    else \
-		echo "Generating template $@" ; \
-	    fi \
-	)
 	$(Q)set -e ; ( \
 	    if [ ! -s $(TESTMAN) ] ; then \
 		cat $(srcdir)/$(@:%.8_gen=%.8_pregen) ; \
@@ -184,7 +169,6 @@ SEE_ALSO=$(srcdir)/see_also.end
 	) > $@
 
 define SUBSTVARS
-$(Q)echo "Generating $@"
 $(Q)$(SED) -e "s+#VERSION#+$(LVM_VERSION)+" \
 	-e "s+#DEFAULT_SYS_DIR#+$(DEFAULT_SYS_DIR)+" \
 	-e "s+#DEFAULT_ARCHIVE_DIR#+$(DEFAULT_ARCHIVE_DIR)+" \
@@ -237,51 +221,62 @@ $(Q)$(SED) -i -e "s+\([ [:alpha:]]\)-\{7\}+\1\\\-\\\-\\\-\\\-\\\-\\\-\\\-+g" \
 endef
 
 %.5: $(srcdir)/%.5_main
-	$(SUBSTVARS)
-	$(ESCAPEHYPHENS)
+	@echo "    [MAN] $@"
+	$(Q) $(SUBSTVARS)
+	$(Q) $(ESCAPEHYPHENS)
 
 %.7: $(srcdir)/%.7_main
-	$(SUBSTVARS)
-	$(ESCAPEHYPHENS)
+	@echo "    [MAN] $@"
+	$(Q) $(SUBSTVARS)
+	$(Q) $(ESCAPEHYPHENS)
 
 %.8: $(srcdir)/%.8_main
-	$(SUBSTVARS)
-	$(ESCAPEHYPHENS)
+	@echo "    [MAN] $@"
+	$(Q) $(SUBSTVARS)
+	$(Q) $(ESCAPEHYPHENS)
 
 %.8: %.8_gen
-	$(SUBSTVARS)
-	$(ESCAPEHYPHENS)
+	@echo "    [MAN] $@"
+	$(Q) $(SUBSTVARS)
+	$(Q) $(ESCAPEHYPHENS)
 
 $(MAN8SO): lvmconfig.8
-	echo ".so $<" > $@
+	@echo "    [MAN] $@"
+	$(Q) echo ".so $<" > $@
 
 install_man5: $(MAN5)
-	$(INSTALL) -d $(MAN5DIR)
-	$(INSTALL_DATA) $(MAN5) $(MAN5DIR)/
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL) -d $(MAN5DIR)
+	$(Q) $(INSTALL_DATA) $(MAN5) $(MAN5DIR)/
 
 install_man7: $(MAN7)
-	$(INSTALL) -d $(MAN7DIR)
-	$(INSTALL_DATA) $(MAN7) $(MAN7DIR)/
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL) -d $(MAN7DIR)
+	$(Q) $(INSTALL_DATA) $(MAN7) $(MAN7DIR)/
 
 install_man8: $(MAN8) $(MAN8SO)
-	$(INSTALL) -d $(MAN8DIR)
-	$(INSTALL_DATA) $(MAN8) $(MAN8SO) $(MAN8DIR)/
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL) -d $(MAN8DIR)
+	$(Q) $(INSTALL_DATA) $(MAN8) $(MAN8SO) $(MAN8DIR)/
 
 install_lvm2: install_man5 install_man7 install_man8
 
 install_cluster: $(MAN8CLUSTER)
 ifdef MAN8CLUSTER
-	$(INSTALL) -d $(MAN8DIR)
-	$(INSTALL_DATA) $(MAN8CLUSTER) $(MAN8DIR)/
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL) -d $(MAN8DIR)
+	$(Q) $(INSTALL_DATA) $(MAN8CLUSTER) $(MAN8DIR)/
 endif
 
 install_device-mapper: $(MAN8DM)
-	$(INSTALL) -d $(MAN8DIR)
-	$(INSTALL_DATA) $(MAN8DM) $(MAN8DIR)/
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL) -d $(MAN8DIR)
+	$(Q) $(INSTALL_DATA) $(MAN8DM) $(MAN8DIR)/
 
 install_systemd_generators: $(MAN8SYSTEMD_GENERATORS)
-	$(INSTALL) -d $(MAN8DIR)
-	$(INSTALL_DATA) $(MAN8SYSTEMD_GENERATORS) $(MAN8DIR)/
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL) -d $(MAN8DIR)
+	$(Q) $(INSTALL_DATA) $(MAN8SYSTEMD_GENERATORS) $(MAN8DIR)/
 
 install: install_lvm2 install_device-mapper install_cluster
 
diff --git a/tools/Makefile.in b/tools/Makefile.in
index de5b628..61c6f38 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -123,11 +123,13 @@ device-mapper: $(TARGETS_DM)
 CFLAGS_dmsetup.o += $(UDEV_CFLAGS) $(EXTRA_EXEC_CFLAGS)
 
 dmsetup: dmsetup.o $(top_builddir)/libdm/libdevmapper.$(LIB_SUFFIX)
-	$(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) \
+	@echo "    [CC] $@"
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) \
 	      -o $@ dmsetup.o -ldevmapper $(LIBS)
 
 dmsetup.static: dmsetup.o $(interfacebuilddir)/libdevmapper.a
-	$(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacebuilddir) \
+	@echo "    [CC] $@"
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacebuilddir) \
 	      -o $@ dmsetup.o -ldevmapper $(M_LIBS) $(PTHREAD_LIBS) $(STATIC_LIBS) $(LIBS)
 
 all: device-mapper
@@ -137,15 +139,18 @@ CFLAGS_lvm.o += $(EXTRA_EXEC_CFLAGS)
 INCLUDES += -I$(top_builddir)/tools
 
 lvm: $(OBJECTS) lvm.o $(top_builddir)/lib/liblvm-internal.a
-	$(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $(OBJECTS) lvm.o \
+	@echo "    [CC] $@"
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $(OBJECTS) lvm.o \
 		$(LVMLIBS) $(READLINE_LIBS) $(LIBS)
 
 DEFS_man-generator.o += -DMAN_PAGE_GENERATOR
 
 man-generator.c: command.c
-	$(LN_S) -f $< $@
+	@echo "    [LN] $@"
+	$(Q) $(LN_S) -f $< $@
 
 man-generator: man-generator.o
+	@echo "    [CC] $@"
 	$(CC) $(CFLAGS) -o $@ $<
 
 ifeq ("@BUILD_LVMETAD@", "yes")
@@ -153,32 +158,39 @@ lvm: $(top_builddir)/libdaemon/client/libdaemonclient.a
 endif
 
 lvm.static: $(OBJECTS) lvm-static.o $(top_builddir)/lib/liblvm-internal.a  $(interfacebuilddir)/libdevmapper.a
-	$(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacebuilddir) -o $@ \
+	@echo "    [CC] $@"
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacebuilddir) -o $@ \
 	      $(OBJECTS) lvm-static.o $(LVMLIBS) $(STATIC_LIBS) $(LIBS)
 
 liblvm2cmd.a: $(top_builddir)/lib/liblvm-internal.a $(OBJECTS) lvmcmdlib.o lvm2cmd.o
-	cat $(top_builddir)/lib/liblvm-internal.a > $@
-	$(AR) rs $@ $(OBJECTS) lvmcmdlib.o lvm2cmd.o
+	@echo "    [AR] $@"
+	$(Q) cat $(top_builddir)/lib/liblvm-internal.a > $@
+	$(Q) $(AR) rs $@ $(OBJECTS) lvmcmdlib.o lvm2cmd.o > /dev/null
 
 liblvm2cmd-static.a: $(top_builddir)/lib/liblvm-internal.a $(OBJECTS) lvmcmdlib.o lvm2cmd-static.o
-	cat $(top_builddir)/lib/liblvm-internal.a > $@
-	$(AR) rs $@ $(OBJECTS) lvmcmdlib.o lvm2cmd-static.o
+	@echo "    [AR] $@"
+	$(Q) cat $(top_builddir)/lib/liblvm-internal.a > $@
+	$(Q) $(AR) rs $@ $(OBJECTS) lvmcmdlib.o lvm2cmd-static.o > /dev/null
 
 liblvm2cmd.$(LIB_SUFFIX): liblvm2cmd.a $(LDDEPS)
-	$(CC) -shared -Wl,-soname,$@.$(LIB_VERSION) \
+	@echo "    [CC] $@"
+	$(Q) $(CC) -shared -Wl,-soname,$@.$(LIB_VERSION) \
 		$(CFLAGS) $(CLDFLAGS) -o $@ \
 		@CLDWHOLEARCHIVE@ liblvm2cmd.a @CLDNOWHOLEARCHIVE@ \
 		$(LVMLIBS) $(LIBS)
 
 liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION): liblvm2cmd.$(LIB_SUFFIX)
-	$(LN_S) -f $< $@
+	@echo "    [LN] $@"
+	$(Q) $(LN_S) -f $< $@
 
 .commands: $(srcdir)/commands.h $(srcdir)/cmdnames.h Makefile
-	$(CC) -E -P $(srcdir)/cmdnames.h 2> /dev/null | \
+	@echo "    [CC] $<"
+	$(Q) $(CC) -E -P $(srcdir)/cmdnames.h 2> /dev/null | \
 		$(EGREP) -v '^ *(|#.*|config|devtypes|dumpconfig|formats|fullreport|help|lastlog|lvmchange|lvpoll|pvdata|segtypes|systemid|tags|version) *$$' > .commands
 
 command-count.h: $(srcdir)/command-lines.in Makefile
-	set -o pipefail && \
+	@echo "    [GEN] $@"
+	$(Q) set -o pipefail && \
 	( cat $(top_srcdir)/tools/license.inc && \
 	  echo "/* Do not edit. This file is generated by the Makefile. */" && \
 	  echo -n "#define COMMAND_COUNT " && \
@@ -186,7 +198,8 @@ command-count.h: $(srcdir)/command-lines.in Makefile
 	) > $@
 
 cmds.h: $(srcdir)/command-lines.in Makefile
-	set -o pipefail && \
+	@echo "    [GEN] $@"
+	$(Q) set -o pipefail && \
 	( cat $(top_srcdir)/tools/license.inc && \
 	  echo "/* Do not edit. This file is generated by the Makefile. */" && \
 	  echo "cmd(CMD_NONE, none)" && \
@@ -195,7 +208,8 @@ cmds.h: $(srcdir)/command-lines.in Makefile
 	) > $@
 
 command-lines-input.h: $(srcdir)/command-lines.in Makefile
-	set -o pipefail && \
+	@echo "    [GEN] $@"
+	$(Q) set -o pipefail && \
 	( cat $(top_srcdir)/tools/license.inc && \
 	  echo "/* Do not edit. This file is generated by the Makefile. */" && \
 	  echo -en "const char _command_input[] =\n\n\"" && \
@@ -217,18 +231,22 @@ endif
 	install_dmsetup_dynamic install_dmsetup_static
 
 install_cmdlib_include: $(srcdir)/lvm2cmd.h
-	$(INSTALL_DATA) -D $< $(includedir)/$(<F)
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL_DATA) -D $< $(includedir)/$(<F)
 
 install_cmdlib_dynamic: liblvm2cmd.$(LIB_SUFFIX)
-	$(INSTALL_PROGRAM) -D $< $(libdir)/$(<F).$(LIB_VERSION)
-	$(INSTALL_DIR) $(usrlibdir)
-	$(LN_S) -f $(USRLIB_RELPATH)$(<F).$(LIB_VERSION) $(usrlibdir)/$(<F)
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL_PROGRAM) -D $< $(libdir)/$(<F).$(LIB_VERSION)
+	$(Q) $(INSTALL_DIR) $(usrlibdir)
+	$(Q) $(LN_S) -f $(USRLIB_RELPATH)$(<F).$(LIB_VERSION) $(usrlibdir)/$(<F)
 
 install_cmdlib_static: liblvm2cmd-static.a
-	$(INSTALL_DATA) -D $< $(usrlibdir)/liblvm2cmd.a
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL_DATA) -D $< $(usrlibdir)/liblvm2cmd.a
 
 install_tools_dynamic: lvm .commands
-	$(INSTALL_PROGRAM) -D lvm $(sbindir)/lvm
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL_PROGRAM) -D lvm $(sbindir)/lvm
 	@echo Creating symbolic links for individual commands in $(sbindir)
 	@for v in `cat .commands`; do \
 		echo "$(LN_S) -f lvm $(sbindir)/$$v"; \
@@ -236,15 +254,18 @@ install_tools_dynamic: lvm .commands
 	done;
 
 install_tools_static: lvm.static
-	$(INSTALL_PROGRAM) -D $< $(staticdir)/$(<F)
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL_PROGRAM) -D $< $(staticdir)/$(<F)
 
 install_dmsetup_dynamic: dmsetup
-	$(INSTALL_PROGRAM) -D $< $(sbindir)/$(<F)
-	$(LN_S) -f $(<F) $(sbindir)/dmstats
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL_PROGRAM) -D $< $(sbindir)/$(<F)
+	$(Q) $(LN_S) -f $(<F) $(sbindir)/dmstats
 
 install_dmsetup_static: dmsetup.static
-	$(INSTALL_PROGRAM) -D $< $(staticdir)/$(<F)
-	$(LN_S) -f $(<F) $(staticdir)/dmstats
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL_PROGRAM) -D $< $(staticdir)/$(<F)
+	$(Q) $(LN_S) -f $(<F) $(staticdir)/dmstats
 
 install_device-mapper: $(INSTALL_DMSETUP_TARGETS)
 



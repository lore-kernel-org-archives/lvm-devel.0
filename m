From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 1 Aug 2017 06:02:07 -0400
Subject: master - makefiles: fixing linking
Message-ID: <201708011002.v71A27Za011580@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2232e82d25382f499adf83cbc7525b281f4f8b92
Commit:        2232e82d25382f499adf83cbc7525b281f4f8b92
Parent:        918e867abe6a455a401346744820d9e54a977749
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 1 00:01:07 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 1 11:53:30 2017 +0200

makefiles: fixing linking

Avoid adding -g more then once for debug builds.
Avoid enabling  DEBUG_MEM when we build multithreaded tools.
Link executables with -fPIE -pie and --export-dynamic LDFLAGS
Introduce PROGS_FLAGS to add option to pass flags for external libs.
Link  lvm2 internally library only when really used.
Link DAEMON_LIBS with daemons.
Pass VALGRIND_CFLAGS internally
Set shell failure mode on couple places.
---
 WHATS_NEW                      |    1 +
 daemons/clvmd/Makefile.in      |   15 +++------------
 daemons/cmirrord/Makefile.in   |    2 +-
 daemons/dmeventd/Makefile.in   |   12 +++++-------
 daemons/dmfilemapd/Makefile.in |    9 ++++-----
 daemons/lvmetad/Makefile.in    |   15 ++++++---------
 daemons/lvmlockd/Makefile.in   |   26 ++++++++------------------
 daemons/lvmpolld/Makefile.in   |   12 ++++--------
 lib/Makefile.in                |    9 ++-------
 libdm/Makefile.in              |    2 +-
 liblvm/Makefile.in             |    5 +----
 make.tmpl.in                   |   29 +++++++++++++++++++++--------
 man/Makefile.in                |    6 +++---
 tools/Makefile.in              |   13 +++----------
 14 files changed, 63 insertions(+), 93 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 515b0eb..46a944b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.174 - 
 =================================
+  Imporove makefiles' linking.
   Fix some paths in generated makefiles to respected configured settings.
   Add warning when creating thin-pool with zeroing and chunk size >= 512KiB.
   Introduce exit code 4 EINIT_FAILED to replace -1 when initialisation fails.
diff --git a/daemons/clvmd/Makefile.in b/daemons/clvmd/Makefile.in
index 257afb2..170041f 100644
--- a/daemons/clvmd/Makefile.in
+++ b/daemons/clvmd/Makefile.in
@@ -72,26 +72,17 @@ endif
 TARGETS = \
 	clvmd
 
-LVMLIBS = $(LVMINTERNAL_LIBS)
-
-ifeq ("@DMEVENTD@", "yes")
-	LVMLIBS += -ldevmapper-event
-endif
- 
 include $(top_builddir)/make.tmpl
 
-LVMLIBS += -ldevmapper
-LIBS += $(PTHREAD_LIBS)
-
+LIBS += $(LVMINTERNAL_LIBS) -ldevmapper $(PTHREAD_LIBS)
 CFLAGS += -fno-strict-aliasing $(EXTRA_EXEC_CFLAGS)
-LDFLAGS += $(EXTRA_EXEC_LDFLAGS)
 
 INSTALL_TARGETS = \
 	install_clvmd
 
 clvmd: $(OBJECTS) $(top_builddir)/lib/liblvm-internal.a
-	$(CC) $(CFLAGS) $(LDFLAGS) -o clvmd $(OBJECTS) \
-		$(LVMLIBS) $(LMLIBS) $(LIBS)
+	$(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) \
+	      -o clvmd $(OBJECTS) $(LMLIBS) $(LIBS)
 
 .PHONY: install_clvmd
 
diff --git a/daemons/cmirrord/Makefile.in b/daemons/cmirrord/Makefile.in
index 9d9dd7a..96e0db8 100644
--- a/daemons/cmirrord/Makefile.in
+++ b/daemons/cmirrord/Makefile.in
@@ -29,7 +29,7 @@ include $(top_builddir)/make.tmpl
 LIBS += -ldevmapper
 LMLIBS += $(CPG_LIBS) $(SACKPT_LIBS)
 CFLAGS += $(CPG_CFLAGS) $(SACKPT_CFLAGS) $(EXTRA_EXEC_CFLAGS)
-LDFLAGS += $(EXTRA_EXEC_LDFLAGS)
+LDFLAGS += $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS)
 
 cmirrord: $(OBJECTS) $(top_builddir)/lib/liblvm-internal.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) \
diff --git a/daemons/dmeventd/Makefile.in b/daemons/dmeventd/Makefile.in
index 52ec938..d5241eb 100644
--- a/daemons/dmeventd/Makefile.in
+++ b/daemons/dmeventd/Makefile.in
@@ -56,18 +56,16 @@ include $(top_builddir)/make.tmpl
 all: device-mapper
 device-mapper: $(TARGETS)
 
-LIBS += -ldevmapper
-LVMLIBS += -ldevmapper-event $(PTHREAD_LIBS)
-
 CFLAGS_dmeventd.o += $(EXTRA_EXEC_CFLAGS)
+LIBS += -ldevmapper $(PTHREAD_LIBS)
 
 dmeventd: $(LIB_SHARED) dmeventd.o
-	$(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -L. -o $@ dmeventd.o \
-	$(DL_LIBS) $(LVMLIBS) $(LIBS) -rdynamic
+	$(CC) $(CFLAGS) -L. $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) dmeventd.o \
+		-o $@ $(DL_LIBS) $(DMEVENT_LIBS) $(LIBS)
 
 dmeventd.static: $(LIB_STATIC) dmeventd.o $(interfacebuilddir)/libdevmapper.a
-	$(CC) $(CFLAGS) $(LDFLAGS) $(ELDFLAGS) -static -L. -L$(interfacebuilddir) -o $@ \
-	dmeventd.o $(DL_LIBS) $(LVMLIBS) $(LIBS) $(STATIC_LIBS)
+	$(CC) $(CFLAGS) $(LDFLAGS) -static -L. -L$(interfacebuilddir) dmeventd.o \
+		-o $@ $(DL_LIBS) $(DMEVENT_LIBS) $(LIBS) $(STATIC_LIBS)
 
 ifeq ("@PKGCONFIG@", "yes")
   INSTALL_LIB_TARGETS += install_pkgconfig
diff --git a/daemons/dmfilemapd/Makefile.in b/daemons/dmfilemapd/Makefile.in
index 53dc09b..f37ac1b 100644
--- a/daemons/dmfilemapd/Makefile.in
+++ b/daemons/dmfilemapd/Makefile.in
@@ -39,12 +39,12 @@ LIBS += -ldevmapper
 CFLAGS_dmfilemapd.o += $(EXTRA_EXEC_CFLAGS)
 
 dmfilemapd: $(LIB_SHARED) dmfilemapd.o
-	$(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -L. -o $@ dmfilemapd.o \
-	$(DL_LIBS) $(LVMLIBS) $(LIBS) -rdynamic
+	$(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) \
+		-o $@ dmfilemapd.o $(DL_LIBS) $(LIBS)
 
 dmfilemapd.static: $(LIB_STATIC) dmfilemapd.o $(interfacebuilddir)/libdevmapper.a
-	$(CC) $(CFLAGS) $(LDFLAGS) $(ELDFLAGS) -static -L. -L$(interfacebuilddir) -o $@ \
-	dmfilemapd.o $(DL_LIBS) $(LVMLIBS) $(LIBS) $(STATIC_LIBS)
+	$(CC) $(CFLAGS) $(LDFLAGS) $(ELDFLAGS) -static -L$(interfacebuilddir) \
+		-o $@ dmfilemapd.o $(DL_LIBS) $(LIBS) $(STATIC_LIBS)
 
 ifneq ("$(CFLOW_CMD)", "")
 CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES))
@@ -65,4 +65,3 @@ install_dmfilemapd: $(INSTALL_DMFILEMAPD_TARGETS)
 install: install_dmfilemapd
 
 install_device-mapper: install_dmfilemapd
-
diff --git a/daemons/lvmetad/Makefile.in b/daemons/lvmetad/Makefile.in
index fa3bdf1..0473318 100644
--- a/daemons/lvmetad/Makefile.in
+++ b/daemons/lvmetad/Makefile.in
@@ -28,22 +28,19 @@ CFLOW_TARGET = lvmetad
 
 include $(top_builddir)/make.tmpl
 
+CFLAGS_lvmetactl.o += $(EXTRA_EXEC_CFLAGS)
+CFLAGS_lvmetad-core.o += $(EXTRA_EXEC_CFLAGS)
 INCLUDES += -I$(top_srcdir)/libdaemon/server
-LVMLIBS = -ldaemonserver $(LVMINTERNAL_LIBS) -ldevmapper
-
-LIBS += $(PTHREAD_LIBS)
-
-LDFLAGS += -L$(top_builddir)/libdaemon/server $(EXTRA_EXEC_LDFLAGS)
-CLDFLAGS += -L$(top_builddir)/libdaemon/server
-CFLAGS += $(EXTRA_EXEC_CFLAGS)
+LDFLAGS += -L$(top_builddir)/libdaemon/server $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS)
+LIBS += $(DAEMON_LIBS) -ldevmapper $(PTHREAD_LIBS)
 
 lvmetad: $(OBJECTS) $(top_builddir)/libdaemon/client/libdaemonclient.a \
 		    $(top_builddir)/libdaemon/server/libdaemonserver.a
-	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) $(LVMLIBS) $(LIBS)
+	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) -ldaemonserver $(LIBS)
 
 lvmetactl: lvmetactl.o $(top_builddir)/libdaemon/client/libdaemonclient.a \
 	$(top_builddir)/libdaemon/server/libdaemonserver.a
-	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ lvmetactl.o $(LVMLIBS)
+	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ lvmetactl.o $(LIBS)
 
 CLEAN_TARGETS += lvmetactl.o
 
diff --git a/daemons/lvmlockd/Makefile.in b/daemons/lvmlockd/Makefile.in
index 1b9d787..33038ec 100644
--- a/daemons/lvmlockd/Makefile.in
+++ b/daemons/lvmlockd/Makefile.in
@@ -19,10 +19,12 @@ SOURCES = lvmlockd-core.c
 
 ifeq ("@BUILD_LOCKDSANLOCK@", "yes")
   SOURCES += lvmlockd-sanlock.c
+  LOCK_LIBS += -lsanlock_client
 endif
 
 ifeq ("@BUILD_LOCKDDLM@", "yes")
   SOURCES += lvmlockd-dlm.c
+  LOCK_LIBS += -ldlm_lt
 endif
 
 TARGETS = lvmlockd lvmlockctl
@@ -31,29 +33,17 @@ TARGETS = lvmlockd lvmlockctl
 
 include $(top_builddir)/make.tmpl
 
+CFLAGS += $(EXTRA_EXEC_CFLAGS)
 INCLUDES += -I$(top_srcdir)/libdaemon/server
-LVMLIBS = -ldaemonserver $(LVMINTERNAL_LIBS) -ldevmapper
-
-LIBS += $(PTHREAD_LIBS)
-
-ifeq ("@BUILD_LOCKDSANLOCK@", "yes")
-  LIBS += -lsanlock_client
-endif
-
-ifeq ("@BUILD_LOCKDDLM@", "yes")
-  LIBS += -ldlm_lt
-endif
-
-LDFLAGS += -L$(top_builddir)/libdaemon/server
-CLDFLAGS += -L$(top_builddir)/libdaemon/server
+LDFLAGS += -L$(top_builddir)/libdaemon/server $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS)
+LIBS +=  $(DAEMON_LIBS) -ldevmapper $(PTHREAD_LIBS)
 
 lvmlockd: $(OBJECTS) $(top_builddir)/libdaemon/client/libdaemonclient.a \
 		    $(top_builddir)/libdaemon/server/libdaemonserver.a
-	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) $(LVMLIBS) $(LIBS)
+	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) $(LOCK_LIBS) -ldaemonserver $(LIBS)
 
-lvmlockctl: lvmlockctl.o $(top_builddir)/libdaemon/client/libdaemonclient.a \
-		    $(top_builddir)/libdaemon/server/libdaemonserver.a
-	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ lvmlockctl.o $(LVMLIBS)
+lvmlockctl: lvmlockctl.o $(top_builddir)/libdaemon/client/libdaemonclient.a
+	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ lvmlockctl.o $(LIBS)
 
 install_lvmlockd: lvmlockd
 	$(INSTALL_PROGRAM) -D $< $(sbindir)/$(<F)
diff --git a/daemons/lvmpolld/Makefile.in b/daemons/lvmpolld/Makefile.in
index 0bc2861..483758d 100644
--- a/daemons/lvmpolld/Makefile.in
+++ b/daemons/lvmpolld/Makefile.in
@@ -27,18 +27,14 @@ CFLOW_TARGET = lvmpolld
 
 include $(top_builddir)/make.tmpl
 
+CFLAGS += $(EXTRA_EXEC_CFLAGS)
 INCLUDES += -I$(top_srcdir)/libdaemon/server
-LVMLIBS = -ldaemonserver $(LVMINTERNAL_LIBS) -ldevmapper
-
-LIBS += $(PTHREAD_LIBS)
-
-LDFLAGS += -L$(top_builddir)/libdaemon/server $(DAEMON_LDFLAGS)
-CLDFLAGS += -L$(top_builddir)/libdaemon/server
-CFLAGS += $(DAEMON_CFLAGS)
+LDFLAGS += -L$(top_builddir)/libdaemon/server $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS)
+LIBS += $(DAEMON_LIBS) -ldaemonserver -ldevmapper $(PTHREAD_LIBS)
 
 lvmpolld: $(OBJECTS) $(top_builddir)/libdaemon/client/libdaemonclient.a \
 		    $(top_builddir)/libdaemon/server/libdaemonserver.a
-	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) $(LVMLIBS) $(LIBS)
+	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) $(LIBS)
 
 install_lvmpolld: lvmpolld
 	$(INSTALL_PROGRAM) -D $< $(sbindir)/$(<F)
diff --git a/lib/Makefile.in b/lib/Makefile.in
index c75ffc2..752f195 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -204,11 +204,6 @@ ifeq ("@BUILD_LVMLOCKD@", "yes")
 	locking/lvmlockd.c
 endif
 
-ifeq ("@DMEVENTD@", "yes")
-  CLDFLAGS += -L$(top_builddir)/daemons/dmeventd
-  LIBS += -ldevmapper-event
-endif
-
 LIB_NAME = liblvm-internal
 LIB_STATIC = $(LIB_NAME).a
 
@@ -229,9 +224,9 @@ endif
 CFLOW_LIST = $(SOURCES)
 CFLOW_LIST_TARGET = $(LIB_NAME).cflow
 
-include $(top_builddir)/make.tmpl
+PROGS_CFLAGS = $(BLKID_CFLAGS) $(UDEV_CFLAGS)
 
-CFLAGS += $(BLKID_CFLAGS) $(UDEV_CFLAGS) $(VALGRIND_CFLAGS)
+include $(top_builddir)/make.tmpl
 
 $(SUBDIRS): $(LIB_STATIC)
 
diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index 5adf992..7396cdc 100644
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -54,7 +54,7 @@ EXPORTED_FN_PREFIX = dm
 
 include $(top_builddir)/make.tmpl
 
-CFLAGS += $(UDEV_CFLAGS) $(VALGRIND_CFLAGS)
+PROGS_CFLAGS = $(UDEV_CFLAGS)
 
 LIBS += $(RT_LIB) $(SELINUX_LIBS) $(UDEV_LIBS) $(PTHREAD_LIBS) $(M_LIBS)
 
diff --git a/liblvm/Makefile.in b/liblvm/Makefile.in
index 4a221ca..6d0325c 100644
--- a/liblvm/Makefile.in
+++ b/liblvm/Makefile.in
@@ -42,12 +42,9 @@ LDDEPS += $(top_builddir)/lib/liblvm-internal.a
 
 include $(top_builddir)/make.tmpl
 
+LDFLAGS += -L$(top_builddir)/lib -L$(top_builddir)/daemons/dmeventd
 LIBS += $(LVMINTERNAL_LIBS) -ldevmapper
 
-ifeq ("@DMEVENTD@", "yes")
-  LIBS += -ldevmapper-event
-endif
-
 .PHONY: install_dynamic install_static install_include install_pkgconfig
 
 INSTALL_TYPE = install_dynamic
diff --git a/make.tmpl.in b/make.tmpl.in
index 102079e..3a09a10 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -57,12 +57,12 @@ STATIC_LIBS = $(SELINUX_LIBS) $(UDEV_LIBS) $(BLKID_LIBS)
 DEFS += @DEFS@
 # FIXME set this only where it's needed, not globally?
 CFLAGS ?= @COPTIMISE_FLAG@ @CFLAGS@
-LDFLAGS ?= @COPTIMISE_FLAG@ @LDFLAGS@
+LDFLAGS ?= @LDFLAGS@
 CLDFLAGS += @CLDFLAGS@
 ELDFLAGS += @ELDFLAGS@
 LDDEPS += @LDDEPS@
 LIB_SUFFIX = @LIB_SUFFIX@
-LVMINTERNAL_LIBS = -llvm-internal $(DAEMON_LIBS) $(UDEV_LIBS) $(DL_LIBS) $(BLKID_LIBS)
+LVMINTERNAL_LIBS = -llvm-internal $(DMEVENT_LIBS) $(DAEMON_LIBS) $(UDEV_LIBS) $(DL_LIBS) $(BLKID_LIBS)
 DL_LIBS = @DL_LIBS@
 M_LIBS = @M_LIBS@
 PTHREAD_LIBS = @PTHREAD_LIBS@
@@ -235,12 +235,25 @@ ifeq (,$(findstring fPIC,$(CFLAGS)))
 CFLAGS += -fPIC
 
 ifeq ("@DEBUG@", "yes")
-  CFLAGS += -g -fno-omit-frame-pointer
+ifeq (,$(findstring -g,$(CFLAGS)))
+  CFLAGS += -g
+endif
+  CFLAGS += -fno-omit-frame-pointer
   DEFS += -DDEBUG
   # memory debugging is not thread-safe yet
   ifneq ("@DMEVENTD@", "yes")
+  ifneq ("@DMFILEMAPD@", "yes")
+  ifneq ("@LVMLOCKD@", "yes")
+  ifneq ("@LVMPOLLD@", "yes")
+  ifneq ("@LVMETAD@", "yes")
+  ifneq ("@CLVMD@", "yes")
     DEFS += -DDEBUG_MEM
   endif
+  endif
+  endif
+  endif
+  endif
+  endif
 endif
 
 # end of fPIC protection
@@ -254,6 +267,7 @@ LDFLAGS += -L$(top_builddir)/libdaemon/client
 CLDFLAGS += -L$(top_builddir)/libdaemon/client
 
 ifeq ("@DMEVENTD@", "yes")
+  DMEVENT_LIBS = -ldevmapper-event
   LDFLAGS += -L$(top_builddir)/daemons/dmeventd
   CLDFLAGS += -L$(top_builddir)/daemons/dmeventd
 endif
@@ -420,14 +434,13 @@ endif
 .LIBPATTERNS = lib%.so lib%.a
 
 %.o: %.c
-	$(CC) -c $(INCLUDES) $(DEFS) $(DEFS_$@) $(WFLAGS) $(WCFLAGS) $(CFLAGS) $(CFLAGS_$@) $< -o $@
+	$(CC) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(WCFLAGS) $(CFLAGS) $(CFLAGS_$@) $< -o $@
 
 %.o: %.cpp
-	$(CXX) -c $(INCLUDES) $(DEFS) $(WFLAGS) $(CXXFLAGS) $(CXXFLAGS_$@) $< -o $@
+	$(CXX) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(DEFS) $(WFLAGS) $(CXXFLAGS) $(CXXFLAGS_$@) $< -o $@
 
 %.pot: %.c Makefile
-	$(CC) -E $(INCLUDES) $(BLKID_CFLAGS) $(VALGRIND_CFLAGS) $(UDEV_CFLAGS) -include $(top_builddir)/include/pogen.h \
-		$(DEFS) $(WFLAGS) $(CFLAGS) $< > $@
+	$(CC) -E $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) -include $(top_builddir)/include/pogen.h $(DEFS) $(WFLAGS) $(CFLAGS) $< >$@
 
 %.so: %.o
 	$(CC) -c $(CFLAGS) $(CLDFLAGS) $< $(LIBS) -o $@
@@ -477,7 +490,7 @@ $(LIB_STATIC): $(OBJECTS)
 	set -e; \
 	FILE=`echo $@ | sed 's/\\//\\\\\\//g;s/\\.d//g'`; \
 	DEPS=`echo $(DEPS) | sed -e 's/\\//\\\\\\//g'`; \
-	$(CC) -MM $(INCLUDES) $(BLKID_CFLAGS) $(VALGRIND_CFLAGS) $(UDEV_CFLAGS) $(DEFS) -o $@ $<; \
+	$(CC) -MM $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) $(DEFS) -o $@ $<; \
 	sed -i "s/\(.*\)\.o[ :]*/$$FILE.o $$FILE.d $$FILE.pot: $$DEPS /g" $@; \
 	DEPLIST=`sed 's/ \\\\//;s/.*://;' < $@`; \
 	echo $$DEPLIST | fmt -1 | sed 's/ //g;s/\(.*\)/\1:/' >> $@; \
diff --git a/man/Makefile.in b/man/Makefile.in
index f88b569..219b2b9 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -151,14 +151,14 @@ SEE_ALSO=$(srcdir)/see_also.end
 .PRECIOUS: %.8_gen
 
 %.8_gen: $(srcdir)/%.8_des $(srcdir)/%.8_end $(MANGENERATOR) $(TESTMAN)
-	( \
+	@( \
 	    if [ ! -s $(TESTMAN) ] ; then \
 		echo "Copying pre-generated template $@" ; \
 	    else \
 		echo "Generating template $@" ; \
 	    fi \
 	)
-	( \
+	set -e ; ( \
 	    if [ ! -s $(TESTMAN) ] ; then \
 		cat $(srcdir)/$(@:%.8_gen=%.8_pregen) ; \
 	    else \
@@ -276,7 +276,7 @@ install_all_man: install install_systemd_generators
 
 # Copy generated man pages back to source tree as fallback for machines where generator doesn't work
 pregenerated_man: all
-	for i in $(srcdir)/*.8_des; do \
+	set -e ; for i in $(srcdir)/*.8_des; do \
 		CMD=`basename $$i .8_des`; \
 		cat $${CMD}.8_gen > $(srcdir)/$$CMD.8_pregen ; \
 	done
diff --git a/tools/Makefile.in b/tools/Makefile.in
index e18c8d7..de5b628 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -95,7 +95,7 @@ ifeq ("@STATIC_LINK@", "yes")
   INSTALL_CMDLIB_TARGETS += install_cmdlib_static
 endif
 
-LVMLIBS = $(LVMINTERNAL_LIBS)
+LVMLIBS = $(LVMINTERNAL_LIBS) -ldevmapper
 LIB_VERSION = $(LIB_VERSION_LVM)
 
 CLEAN_TARGETS = liblvm2cmd.$(LIB_SUFFIX) $(TARGETS_DM) \
@@ -109,12 +109,6 @@ ifeq ("@CMDLIB@", "yes")
 	INSTALL_LVM_TARGETS += $(INSTALL_CMDLIB_TARGETS)
 endif
 
-ifeq ("@DMEVENTD@", "yes")
-	LVMLIBS += -ldevmapper-event
-endif
-
-LVMLIBS += -ldevmapper
-
 EXPORTED_HEADER = $(srcdir)/lvm2cmd.h
 EXPORTED_FN_PREFIX = lvm2
 
@@ -129,7 +123,7 @@ device-mapper: $(TARGETS_DM)
 CFLAGS_dmsetup.o += $(UDEV_CFLAGS) $(EXTRA_EXEC_CFLAGS)
 
 dmsetup: dmsetup.o $(top_builddir)/libdm/libdevmapper.$(LIB_SUFFIX)
-	$(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) -L$(top_builddir)/libdm \
+	$(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) \
 	      -o $@ dmsetup.o -ldevmapper $(LIBS)
 
 dmsetup.static: dmsetup.o $(interfacebuilddir)/libdevmapper.a
@@ -139,13 +133,12 @@ dmsetup.static: dmsetup.o $(interfacebuilddir)/libdevmapper.a
 all: device-mapper
 
 CFLAGS_lvm.o += $(EXTRA_EXEC_CFLAGS)
-CFLAGS_lvmcmdline.o += $(VALGRIND_CFLAGS)
 
 INCLUDES += -I$(top_builddir)/tools
 
 lvm: $(OBJECTS) lvm.o $(top_builddir)/lib/liblvm-internal.a
 	$(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $(OBJECTS) lvm.o \
-		$(LVMLIBS) $(READLINE_LIBS) $(LIBS) -rdynamic
+		$(LVMLIBS) $(READLINE_LIBS) $(LIBS)
 
 DEFS_man-generator.o += -DMAN_PAGE_GENERATOR
 



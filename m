From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  4 Dec 2013 12:30:23 +0000 (UTC)
Subject: master - daemons: use PIE and RELRO compiler/linker options
Message-ID: <20131204123023.C20B96030C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a65ab773b4ddb06e87d678d3b2f4d0ca3e5b9fd0
Commit:        a65ab773b4ddb06e87d678d3b2f4d0ca3e5b9fd0
Parent:        fc37d4fb0dfc47c49b8acdc773a4ad67d59b51b8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Dec 4 10:16:15 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Dec 4 13:30:08 2013 +0100

daemons: use PIE and RELRO compiler/linker options

The PIE and RELRO compiler/linker options can be used to produce a code
some techniques applied that makes the code more immune to some attacks:

  - PIE (Position Independent Executable). It can make use of the ASLR
    (Address Space Layout Randomization) provided by kernel to avoid
    static locations for .text regions of executables (this is the 'pie'
    compiler and linker option)

  - RELRO (Relocation Read-Only). This prevents overwrite attacks of
    the GOT (Global Offset Table) and PLT (Procedure Lookup Table)
    used for relocations by making it read-only after all relocations
    are resolved (these are the 'relro' and 'now' linker options) -
    hence all symbols are resolved at the very start so there's no
    need for those tables to be writeable later.

These compiler/linker options are now used by default for daemons
if the compiler/linker supports it.
---
 WHATS_NEW                    |    1 +
 daemons/clvmd/Makefile.in    |    3 ++-
 daemons/cmirrord/Makefile.in |    3 ++-
 daemons/dmeventd/Makefile.in |    4 +++-
 daemons/lvmetad/Makefile.in  |    4 ++--
 make.tmpl.in                 |    9 +++++++++
 6 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d512ab5..f299b84 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Compile/link daemons with RELRO and PIE options to harden daemon security.
   Support per-object compilation cflags via CFLAGS_object.o.
   Automatically detect support for compiler/linker options to use RELRO and PIE.
   Add --splitsnapshot to lvconvert to separate out cow LV.
diff --git a/daemons/clvmd/Makefile.in b/daemons/clvmd/Makefile.in
index 9ca11ba..4677048 100644
--- a/daemons/clvmd/Makefile.in
+++ b/daemons/clvmd/Makefile.in
@@ -88,7 +88,8 @@ LVMLIBS += -ldevmapper
 LIBS += $(PTHREAD_LIBS)
 
 DEFS += -D_REENTRANT
-CFLAGS += -fno-strict-aliasing
+CFLAGS += -fno-strict-aliasing $(DAEMON_CFLAGS)
+LDFLAGS += $(DAEMON_LDFLAGS)
 
 INSTALL_TARGETS = \
 	install_clvmd
diff --git a/daemons/cmirrord/Makefile.in b/daemons/cmirrord/Makefile.in
index 0efc8d4..df7c2a8 100644
--- a/daemons/cmirrord/Makefile.in
+++ b/daemons/cmirrord/Makefile.in
@@ -28,7 +28,8 @@ include $(top_builddir)/make.tmpl
 
 LIBS += -ldevmapper
 LMLIBS += $(CPG_LIBS) $(SACKPT_LIBS)
-CFLAGS += $(CPG_CFLAGS) $(SACKPT_CFLAGS)
+CFLAGS += $(CPG_CFLAGS) $(SACKPT_CFLAGS) $(DAEMON_CFLAGS)
+LDFLAGS += $(DAEMON_LDFLAGS)
 
 cmirrord: $(OBJECTS) $(top_builddir)/lib/liblvm-internal.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) \
diff --git a/daemons/dmeventd/Makefile.in b/daemons/dmeventd/Makefile.in
index 1302a44..fcc5c9e 100644
--- a/daemons/dmeventd/Makefile.in
+++ b/daemons/dmeventd/Makefile.in
@@ -59,8 +59,10 @@ device-mapper: $(TARGETS)
 LIBS += -ldevmapper
 LVMLIBS += -ldevmapper-event $(PTHREAD_LIBS)
 
+CFLAGS_dmeventd.o += $(DAEMON_CFLAGS)
+
 dmeventd: $(LIB_SHARED) dmeventd.o
-	$(CC) $(CFLAGS) $(LDFLAGS) $(ELDFLAGS) -L. -o $@ dmeventd.o \
+	$(CC) $(CFLAGS) $(LDFLAGS) $(DAEMON_LDFLAGS) $(ELDFLAGS) -L. -o $@ dmeventd.o \
 	$(DL_LIBS) $(LVMLIBS) $(LIBS) -rdynamic
 
 dmeventd.static: $(LIB_STATIC) dmeventd.o $(interfacebuilddir)/libdevmapper.a
diff --git a/daemons/lvmetad/Makefile.in b/daemons/lvmetad/Makefile.in
index 35aa4ab..f08198a 100644
--- a/daemons/lvmetad/Makefile.in
+++ b/daemons/lvmetad/Makefile.in
@@ -33,8 +33,8 @@ LVMLIBS = -ldaemonserver $(LVMINTERNAL_LIBS) -ldevmapper
 
 LIBS += $(PTHREAD_LIBS)
 
-LDFLAGS += -L$(top_builddir)/libdaemon/server
-CLDFLAGS += -L$(top_builddir)/libdaemon/server
+LDFLAGS += -L$(top_builddir)/libdaemon/server $(DAEMON_LDFLAGS)
+CLDFLAGS += -L$(top_builddir)/libdaemon/server $(DAEMON_CFLAGS)
 
 lvmetad: $(OBJECTS) $(top_builddir)/libdaemon/client/libdaemonclient.a \
 		    $(top_builddir)/libdaemon/server/libdaemonserver.a
diff --git a/make.tmpl.in b/make.tmpl.in
index 944be9b..5f72182 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -150,6 +150,15 @@ WFLAGS += -Wclobbered -Wempty-body -Wignored-qualifiers \
  -Wtype-limits -Wsync-nand -Wlogical-op
 endif
 
+ifneq ("@STATIC_LINK@", "yes")
+ifeq ("@HAVE_PIE@", "yes")
+ifeq ("@HAVE_FULL_RELRO@", "yes")
+  DAEMON_CFLAGS += -fPIE -DPIE
+  DAEMON_LDFLAGS += -Wl,-z,relro,-z,now -pie
+endif
+endif
+endif
+
 #WFLAGS += -W -Wno-sign-compare -Wno-unused-parameter -Wno-missing-field-initializers
 #WFLAGS += -Wsign-compare -Wunused-parameter -Wmissing-field-initializers 
 #WFLAGS += -Wconversion -Wbad-function-cast -Wcast-qual -Waggregate-return -Wpacked



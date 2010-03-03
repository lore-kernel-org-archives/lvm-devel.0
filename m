From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  3 Mar 2010 21:42:54 +0100
Subject: [PATCH 08/15] Introduce LVMINTERNAL_LIBS
In-Reply-To: <cover.1267648294.git.zkabelac@redhat.com>
References: <cover.1267648294.git.zkabelac@redhat.com>
Message-ID: <50a2becdb9d3525cf0918f26a69d03540f645921.1267648294.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Keep dependency libraries for liblvm-internal in one place.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/Makefile.in |    2 +-
 liblvm/Makefile.in        |    2 +-
 make.tmpl.in              |    1 +
 tools/Makefile.in         |    2 +-
 4 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/daemons/clvmd/Makefile.in b/daemons/clvmd/Makefile.in
index 905f1c9..40d1da4 100644
--- a/daemons/clvmd/Makefile.in
+++ b/daemons/clvmd/Makefile.in
@@ -75,7 +75,7 @@ endif
 TARGETS = \
 	clvmd
 
-LVMLIBS = -llvm-internal -lpthread
+LVMLIBS = $(LVMINTERNAL_LIBS) -lpthread
 
 ifeq ("@DMEVENTD@", "yes")
 	LVMLIBS += -ldevmapper-event
diff --git a/liblvm/Makefile.in b/liblvm/Makefile.in
index 25906e1..1b2b474 100644
--- a/liblvm/Makefile.in
+++ b/liblvm/Makefile.in
@@ -42,7 +42,7 @@ CLEAN_TARGETS += liblvm.cflow
 
 include $(top_builddir)/make.tmpl
 
-LIBS += -ldevmapper -llvm-internal
+LIBS += $(LVMINTERNAL_LIBS) -ldevmapper
 
 ifeq ("@DMEVENTD@", "yes")
   LIBS += -ldevmapper-event
diff --git a/make.tmpl.in b/make.tmpl.in
index 5b8476f..4b3ac17 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -36,6 +36,7 @@ CLDFLAGS += @CLDFLAGS@
 LDDEPS += @LDDEPS@
 LDFLAGS += @LDFLAGS@
 LIB_SUFFIX = @LIB_SUFFIX@
+LVMINTERNAL_LIBS = -llvm-internal
 
 # Setup directory variables
 prefix = @prefix@
diff --git a/tools/Makefile.in b/tools/Makefile.in
index 41c20db..efdf699 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -86,7 +86,7 @@ ifeq ("@STATIC_LINK@", "yes")
   INSTALL_CMDLIB_TARGETS += install_cmdlib_static
 endif
 
-LVMLIBS = -llvm-internal
+LVMLIBS = $(LVMINTERNAL_LIBS)
 LIB_VERSION = $(LIB_VERSION_LVM)
 
 CLEAN_TARGETS = liblvm2cmd.$(LIB_SUFFIX) liblvm2cmd.a liblvm2cmd-static.a lvm lvm.o \
-- 
1.7.0



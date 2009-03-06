From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri,  6 Mar 2009 03:49:13 -0500
Subject: [PATCH 1/2] Rename liblvm to liblvm-internal.
In-Reply-To: <1236329354-26253-1-git-send-email-dwysocha@redhat.com>
References: <1236329354-26253-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1236329354-26253-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Make preparation for using liblvm for new application library.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/Makefile.in   |    9 +++++----
 tools/Makefile.in |   16 ++++++++--------
 2 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/lib/Makefile.in b/lib/Makefile.in
index 47786a7..0d5ee94 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -140,18 +140,19 @@ ifeq ("@DMEVENTD@", "yes")
   CLDFLAGS += -ldevmapper-event
 endif
 
-LIB_STATIC = liblvm.a
+LIB_NAME = liblvm-internal
+LIB_STATIC = $(LIB_NAME).a
 
 $(SUBDIRS): $(LIB_STATIC)
 
-CLEAN_TARGETS += liblvm.cflow
+CLEAN_TARGETS += $(LIB_NAME).cflow
 
 include $(top_srcdir)/make.tmpl
 
-liblvm.cflow: $(SOURCES)
+$(LIB_NAME).cflow: $(SOURCES)
 	set -e; (echo -n "SOURCES += "; \
 		 echo $(SOURCES) | \
 		 sed "s/^/ /;s/ / $(top_srcdir)\/lib\//g;s/$$//"; \
 		 ) > $@
 
-cflow: liblvm.cflow
+cflow: $(LIB_NAME).cflow
diff --git a/tools/Makefile.in b/tools/Makefile.in
index 774d75e..72ecd98 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -77,7 +77,7 @@ ifeq ("@STATIC_LINK@", "yes")
   INSTALL_CMDLIB_TARGETS += install_cmdlib_static
 endif
 
-LVMLIBS = -llvm
+LVMLIBS = -llvm-internal
 
 CLEAN_TARGETS = liblvm2cmd.$(LIB_SUFFIX) liblvm2cmd.a liblvm2cmd-static.a lvm lvm.o \
 		lvm2cmd.o lvm2cmd-static.o lvm2cmdlib.o lvm.static \
@@ -112,21 +112,21 @@ dmsetup.static: dmsetup.o $(interfacedir)/libdevmapper.a
 
 all: device-mapper
 
-lvm: $(OBJECTS) lvm.o $(top_srcdir)/lib/liblvm.a
+lvm: $(OBJECTS) lvm.o $(top_srcdir)/lib/liblvm-internal.a
 	$(CC) -o $@ $(CFLAGS) $(OBJECTS) lvm.o \
 		$(LDFLAGS) $(LVMLIBS) $(LIBS) -rdynamic
 
 LIB_PTHREAD = @LIB_PTHREAD@
-lvm.static: $(OBJECTS) lvm-static.o $(top_srcdir)/lib/liblvm.a  $(interfacedir)/libdevmapper.a
+lvm.static: $(OBJECTS) lvm-static.o $(top_srcdir)/lib/liblvm-internal.a  $(interfacedir)/libdevmapper.a
 	$(CC) -o $@ $(CFLAGS) $(OBJECTS) lvm-static.o -static \
 		-L$(interfacedir) $(LDFLAGS) $(LVMLIBS) $(LIBS) $(LIB_PTHREAD) -rdynamic
 
-liblvm2cmd.a: $(top_srcdir)/lib/liblvm.a $(OBJECTS) lvmcmdlib.o lvm2cmd.o
-	cat $(top_srcdir)/lib/liblvm.a > $@
+liblvm2cmd.a: $(top_srcdir)/lib/liblvm-internal.a $(OBJECTS) lvmcmdlib.o lvm2cmd.o
+	cat $(top_srcdir)/lib/liblvm-internal.a > $@
 	$(AR) rs $@ $(OBJECTS) lvmcmdlib.o lvm2cmd.o
 
-liblvm2cmd-static.a: $(top_srcdir)/lib/liblvm.a $(OBJECTS) lvmcmdlib.o lvm2cmd-static.o
-	cat $(top_srcdir)/lib/liblvm.a > $@
+liblvm2cmd-static.a: $(top_srcdir)/lib/liblvm-internal.a $(OBJECTS) lvmcmdlib.o lvm2cmd-static.o
+	cat $(top_srcdir)/lib/liblvm-internal.a > $@
 	$(AR) rs $@ $(OBJECTS) lvmcmdlib.o lvm2cmd-static.o
 
 liblvm2cmd.$(LIB_SUFFIX): liblvm2cmd.a $(LDDEPS)
@@ -141,7 +141,7 @@ liblvm2cmd.$(LIB_SUFFIX): liblvm2cmd.a $(LDDEPS)
 ifneq ("@CFLOW_CMD@", "")
 CFLOW_FLAGS += --cpp="$(CC) -E"
 .PHONY: lvm.cflow
--include $(top_srcdir)/lib/liblvm.cflow
+-include $(top_srcdir)/lib/liblvm-internal.cflow
 lvm.cflow: $(SOURCES)
 	@CFLOW_CMD@ -o$@ $(CFLOW_FLAGS) $(INCLUDES) $(DEFS) $(SOURCES)
 lvm.rxref: $(SOURCES)
-- 
1.6.0.6



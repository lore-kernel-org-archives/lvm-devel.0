From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  3 Mar 2010 21:42:57 +0100
Subject: [PATCH 11/15] Remove -rdynamic
In-Reply-To: <cover.1267648294.git.zkabelac@redhat.com>
References: <cover.1267648294.git.zkabelac@redhat.com>
Message-ID: <2222d66f815196feb293f95f0f492b1a56a18a63.1267648294.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch might be a bit contraversional. It removes -rdynamic from
linking of lvm.static and dmeventd.static. In my understanding
this compiler flag (or "-Wl,--export-dynamic") is mainly useful
for dynamicaly linked libraries. It should not be needed for linking
of static binary.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/dmeventd/Makefile.in |    2 +-
 tools/Makefile.in            |    3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/daemons/dmeventd/Makefile.in b/daemons/dmeventd/Makefile.in
index aa20453..84514f0 100644
--- a/daemons/dmeventd/Makefile.in
+++ b/daemons/dmeventd/Makefile.in
@@ -66,7 +66,7 @@ dmeventd: $(LIB_SHARED) $(VERSIONED_SHLIB) dmeventd.o
 
 dmeventd.static: $(LIB_STATIC) dmeventd.o $(interfacebuilddir)/libdevmapper.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -static -L. -L$(interfacebuilddir) -o $@ \
-	dmeventd.o $(LVMLIBS) $(LIBS) -rdynamic
+	dmeventd.o $(LVMLIBS) $(LIBS)
 
 ifeq ("@PKGCONFIG@", "yes")
   INSTALL_LIB_TARGETS += install_pkgconfig
diff --git a/tools/Makefile.in b/tools/Makefile.in
index a590d61..b3b0b29 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -125,8 +125,7 @@ lvm: $(OBJECTS) lvm.o $(top_builddir)/lib/liblvm-internal.a
 
 lvm.static: $(OBJECTS) lvm-static.o $(top_builddir)/lib/liblvm-internal.a  $(interfacebuilddir)/libdevmapper.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacebuilddir) -o $@ \
-	      $(OBJECTS) lvm-static.o $(LVMLIBS) $(LIBS) \
-	      -rdynamic
+	      $(OBJECTS) lvm-static.o $(LVMLIBS) $(LIBS)
 
 liblvm2cmd.a: $(top_builddir)/lib/liblvm-internal.a $(OBJECTS) lvmcmdlib.o lvm2cmd.o
 	cat $(top_builddir)/lib/liblvm-internal.a > $@
-- 
1.7.0



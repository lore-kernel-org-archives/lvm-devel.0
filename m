From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue,  2 Mar 2010 13:07:25 +0100
Subject: [PATCH 7/9] Remove -rdynamic
In-Reply-To: <cover.1267529065.git.zkabelac@redhat.com>
References: <cover.1267529065.git.zkabelac@redhat.com>
Message-ID: <ebecbe28ecbdcddf14de15dc5ff4a2a6db0ddb98.1267529065.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch might be a bit contraversional. It removes -rdynamic from
linking of lvm.statis and dmeventd.static. In my understanding
this compiler flag (or "-Wl,--export-dynamic") is mainly useful
for dynamic linked libraries. It should not be needed for linking
of static binary. But I could be wrong here...

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/dmeventd/Makefile.in |    2 +-
 tools/Makefile.in            |    3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/daemons/dmeventd/Makefile.in b/daemons/dmeventd/Makefile.in
index eaf897a..aacb6a4 100644
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
index 974abd2..a8cb6aa 100644
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



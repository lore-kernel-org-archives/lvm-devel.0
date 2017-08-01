From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 1 Aug 2017 06:01:33 -0400
Subject: master - makefiles: cleanups
Message-ID: <201708011001.v71A1X4p011532@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=00fdf01d9d3885e7b1e2c3d92664423892811e25
Commit:        00fdf01d9d3885e7b1e2c3d92664423892811e25
Parent:        2232e82d25382f499adf83cbc7525b281f4f8b92
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 31 23:58:51 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 1 11:53:32 2017 +0200

makefiles: cleanups

---
 daemons/clvmd/Makefile.in      |    6 +++---
 daemons/dmfilemapd/Makefile.in |    3 +--
 daemons/lvmetad/Makefile.in    |    2 +-
 lib/Makefile.in                |    8 ++++----
 4 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/daemons/clvmd/Makefile.in b/daemons/clvmd/Makefile.in
index 170041f..7b1b49b 100644
--- a/daemons/clvmd/Makefile.in
+++ b/daemons/clvmd/Makefile.in
@@ -31,9 +31,9 @@ SALCK_LIBS = @SALCK_LIBS@
 SALCK_CFLAGS = @SALCK_CFLAGS@
 
 SOURCES = \
-	clvmd-command.c  \
-	clvmd.c          \
-	lvm-functions.c  \
+	clvmd-command.c\
+	clvmd.c\
+	lvm-functions.c\
 	refresh_clvmd.c
 
 ifneq (,$(findstring cman,, "@CLVMD@,"))
diff --git a/daemons/dmfilemapd/Makefile.in b/daemons/dmfilemapd/Makefile.in
index f37ac1b..8a4938b 100644
--- a/daemons/dmfilemapd/Makefile.in
+++ b/daemons/dmfilemapd/Makefile.in
@@ -34,9 +34,8 @@ include $(top_builddir)/make.tmpl
 all: device-mapper
 device-mapper: $(TARGETS)
 
-LIBS += -ldevmapper
-
 CFLAGS_dmfilemapd.o += $(EXTRA_EXEC_CFLAGS)
+LIBS += -ldevmapper
 
 dmfilemapd: $(LIB_SHARED) dmfilemapd.o
 	$(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) \
diff --git a/daemons/lvmetad/Makefile.in b/daemons/lvmetad/Makefile.in
index 0473318..44e10fa 100644
--- a/daemons/lvmetad/Makefile.in
+++ b/daemons/lvmetad/Makefile.in
@@ -16,7 +16,7 @@ top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
 SOURCES = lvmetad-core.c
-SOURCES2 = testclient.c
+SOURCES2 = lvmetactl.c
 
 TARGETS = lvmetad lvmetactl
 
diff --git a/lib/Makefile.in b/lib/Makefile.in
index 752f195..ddbd8de 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -48,6 +48,10 @@ ifeq ("@CACHE@", "shared")
   SUBDIRS += cache_segtype
 endif
 
+ifeq ("@CLUSTER@", "shared")
+  SUBDIRS += locking
+endif
+
 SOURCES =\
 	activate/activate.c \
 	cache/lvmcache.c \
@@ -149,10 +153,6 @@ ifeq ("@CLUSTER@", "internal")
   SOURCES += locking/cluster_locking.c
 endif
 
-ifeq ("@CLUSTER@", "shared")
-  SUBDIRS += locking
-endif
-
 ifeq ("@SNAPSHOTS@", "internal")
   SOURCES += snapshot/snapshot.c
 endif



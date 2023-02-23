From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 23 Feb 2023 15:48:59 +0000 (GMT)
Subject: main - configure.ac: add STATIC_LDFLAGS
Message-ID: <20230223154859.25D813858C5E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2b7fa40aacfe3765ea14c476789de4bf7bd5efe6
Commit:        2b7fa40aacfe3765ea14c476789de4bf7bd5efe6
Parent:        2b592a67d69bc22ec32929052320731abd8aad61
Author:        David Seifert <soap@gentoo.org>
AuthorDate:    Wed Feb 22 14:41:08 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 23 16:46:35 2023 +0100

configure.ac: add STATIC_LDFLAGS

Add support for specif STATIC_LDFLAGS when linking static binaries.
---
 configure.ac                 | 2 ++
 daemons/dmeventd/Makefile.in | 2 +-
 libdm/dm-tools/Makefile.in   | 4 ++--
 libdm/make.tmpl.in           | 1 +
 4 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/configure.ac b/configure.ac
index cee24c93c..ec36f10ab 100644
--- a/configure.ac
+++ b/configure.ac
@@ -32,6 +32,7 @@ AS_CASE(["$host_os"],
 	[linux*], [
 		# equivalent to -rdynamic
 		ELDFLAGS="-Wl,--export-dynamic"
+		STATIC_LDFLAGS="-Wl,--no-export-dynamic"
 		# FIXME Generate list and use --dynamic-list=.dlopen.sym
 		CLDWHOLEARCHIVE="-Wl,-whole-archive"
 		CLDNOWHOLEARCHIVE="-Wl,-no-whole-archive"
@@ -1884,6 +1885,7 @@ AC_SUBST(SELINUX_PC)
 AC_SUBST(SILENT_RULES)
 AC_SUBST(SNAPSHOTS)
 AC_SUBST(STATICDIR)
+AC_SUBST(STATIC_LDFLAGS)
 AC_SUBST(STATIC_LINK)
 AC_SUBST(SYSCONFDIR)
 AC_SUBST(SYSTEMD_RUN_CMD)
diff --git a/daemons/dmeventd/Makefile.in b/daemons/dmeventd/Makefile.in
index af51198aa..f7896e581 100644
--- a/daemons/dmeventd/Makefile.in
+++ b/daemons/dmeventd/Makefile.in
@@ -76,7 +76,7 @@ dmeventd: $(LIB_SHARED) dmeventd.o
 
 dmeventd.static: $(LIB_STATIC) dmeventd.o
 	@echo "    [CC] $@"
-	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -static dmeventd.o \
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(STATIC_LDFLAGS) -static dmeventd.o \
 		-o $@ $(DL_LIBS) $(DMEVENT_LIBS) $(LIBS) $(STATIC_LIBS)
 
 ifeq ("@PKGCONFIG@", "yes")
diff --git a/libdm/dm-tools/Makefile.in b/libdm/dm-tools/Makefile.in
index 9ddb3c261..78d2d719d 100644
--- a/libdm/dm-tools/Makefile.in
+++ b/libdm/dm-tools/Makefile.in
@@ -63,7 +63,7 @@ dmsetup: dmsetup.o $(LIBDM_SHARED)
 
 dmsetup.static: dmsetup.o $(LIBDM_STATIC)
 	@echo "    [CC] $@"
-	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -static \
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(STATIC_LDFLAGS) -static \
 	      -o $@ $< $(LIBDM_LIBS) $(LIBS) $(STATIC_LIBS)
 
 install_dmsetup_dynamic: dmsetup
@@ -84,7 +84,7 @@ dmfilemapd: dmfilemapd.o $(LIBDM_SHARED)
 
 dmfilemapd.static: dmfilemapd.o $(LIBDM_STATIC)
 	@echo "    [CC] $@"
-	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -static \
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(STATIC_LDFLAGS) -static \
 	      -o $@ $< $(LIBDM_LIBS) $(LIBS) $(STATIC_LIBS)
 
 install_dmfilemapd_dynamic: dmfilemapd
diff --git a/libdm/make.tmpl.in b/libdm/make.tmpl.in
index a731687c2..3d032f1b0 100644
--- a/libdm/make.tmpl.in
+++ b/libdm/make.tmpl.in
@@ -59,6 +59,7 @@ DEFS += @DEFS@
 # FIXME set this only where it's needed, not globally?
 CFLAGS ?= @COPTIMISE_FLAG@ @CFLAGS@
 LDFLAGS ?= @LDFLAGS@
+STATIC_LDFLAGS += @STATIC_LDFLAGS@
 CPPFLAGS ?= @CPPFLAGS@
 CLDFLAGS += @CLDFLAGS@
 ELDFLAGS += @ELDFLAGS@


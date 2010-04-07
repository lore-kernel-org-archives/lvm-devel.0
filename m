From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  7 Apr 2010 14:28:35 +0200
Subject: [PATCH 1/3] Do not use VPATH
In-Reply-To: <cover.1270641130.git.zkabelac@redhat.com>
References: <cover.1270641130.git.zkabelac@redhat.com>
Message-ID: <f7692ceb422eb13dfc7d000870b018cae01d973d.1270641130.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Usage of VPATH makes troubles when used with builddir.
Not only source files are being found through VPATH,
but targets as well. (make --debug=v)

Thus if user builds the code in $(srcdir) and also in some $(builddir)
he gets mangled results as some generated files (i.e. .export.sym)
are 'reused' from $(srcdir) instead of $(builddir).

This patch switches to use vpath were we could explicitly name
suffixes that should be looked via vpath - we must take care,
we do not generate files with these suffixes:
.c, .in, .po, .exported_symbols

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 Makefile.in                                   |    1 -
 daemons/Makefile.in                           |    1 -
 daemons/clvmd/Makefile.in                     |    1 -
 daemons/cmirrord/Makefile.in                  |    1 -
 daemons/dmeventd/Makefile.in                  |    1 -
 daemons/dmeventd/plugins/Makefile.in          |    1 -
 daemons/dmeventd/plugins/lvm2/Makefile.in     |    1 -
 daemons/dmeventd/plugins/mirror/Makefile.in   |    1 -
 daemons/dmeventd/plugins/snapshot/Makefile.in |    1 -
 doc/Makefile.in                               |    3 +--
 lib/Makefile.in                               |    1 -
 lib/format1/Makefile.in                       |    1 -
 lib/format_pool/Makefile.in                   |    1 -
 lib/locking/Makefile.in                       |    1 -
 lib/mirror/Makefile.in                        |    1 -
 lib/snapshot/Makefile.in                      |    1 -
 libdm/Makefile.in                             |    1 -
 liblvm/Makefile.in                            |    1 -
 make.tmpl.in                                  |    6 ++++++
 man/Makefile.in                               |    1 -
 po/Makefile.in                                |    1 -
 scripts/Makefile.in                           |    1 -
 test/api/Makefile.in                          |    1 -
 tools/Makefile.in                             |    3 +--
 udev/Makefile.in                              |    3 ++-
 25 files changed, 10 insertions(+), 26 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index e81160c..5e584e2 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -15,7 +15,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 SUBDIRS = doc include man scripts
 
diff --git a/daemons/Makefile.in b/daemons/Makefile.in
index 2f5837a..ce400d7 100644
--- a/daemons/Makefile.in
+++ b/daemons/Makefile.in
@@ -14,7 +14,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 .PHONY: dmeventd clvmd cmirrord
 
diff --git a/daemons/clvmd/Makefile.in b/daemons/clvmd/Makefile.in
index e3f70d5..773c368 100644
--- a/daemons/clvmd/Makefile.in
+++ b/daemons/clvmd/Makefile.in
@@ -14,7 +14,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 CCS_LIBS = @CCS_LIBS@
 CCS_CFLAGS = @CCS_CFLAGS@
diff --git a/daemons/cmirrord/Makefile.in b/daemons/cmirrord/Makefile.in
index b8928c7..583c454 100644
--- a/daemons/cmirrord/Makefile.in
+++ b/daemons/cmirrord/Makefile.in
@@ -14,7 +14,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 CPG_LIBS = @CPG_LIBS@
 CPG_CFLAGS = @CPG_CFLAGS@
diff --git a/daemons/dmeventd/Makefile.in b/daemons/dmeventd/Makefile.in
index cd2a4d3..e0a6349 100644
--- a/daemons/dmeventd/Makefile.in
+++ b/daemons/dmeventd/Makefile.in
@@ -14,7 +14,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 SOURCES = libdevmapper-event.c
 SOURCES2 = dmeventd.c
diff --git a/daemons/dmeventd/plugins/Makefile.in b/daemons/dmeventd/plugins/Makefile.in
index 6b25235..45176ad 100644
--- a/daemons/dmeventd/plugins/Makefile.in
+++ b/daemons/dmeventd/plugins/Makefile.in
@@ -15,7 +15,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 SUBDIRS += lvm2 mirror snapshot
 
diff --git a/daemons/dmeventd/plugins/lvm2/Makefile.in b/daemons/dmeventd/plugins/lvm2/Makefile.in
index 0f23c84..f44a562 100644
--- a/daemons/dmeventd/plugins/lvm2/Makefile.in
+++ b/daemons/dmeventd/plugins/lvm2/Makefile.in
@@ -14,7 +14,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 CLDFLAGS += -L$(top_builddir)/tools
 
diff --git a/daemons/dmeventd/plugins/mirror/Makefile.in b/daemons/dmeventd/plugins/mirror/Makefile.in
index 02c4e24..3dfc3a2 100644
--- a/daemons/dmeventd/plugins/mirror/Makefile.in
+++ b/daemons/dmeventd/plugins/mirror/Makefile.in
@@ -15,7 +15,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 INCLUDES += -I$(top_srcdir)/tools -I$(top_srcdir)/daemons/dmeventd/plugins/lvm2
 CLDFLAGS += -L$(top_builddir)/tools -L$(top_builddir)/daemons/dmeventd/plugins/lvm2
diff --git a/daemons/dmeventd/plugins/snapshot/Makefile.in b/daemons/dmeventd/plugins/snapshot/Makefile.in
index 793fd38..0f202b3 100644
--- a/daemons/dmeventd/plugins/snapshot/Makefile.in
+++ b/daemons/dmeventd/plugins/snapshot/Makefile.in
@@ -15,7 +15,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 INCLUDES += -I$(top_srcdir)/tools -I$(top_srcdir)/daemons/dmeventd/plugins/lvm2
 CLDFLAGS += -L$(top_builddir)/tools -L$(top_builddir)/daemons/dmeventd/plugins/lvm2
diff --git a/doc/Makefile.in b/doc/Makefile.in
index ce66209..61b32e9 100644
--- a/doc/Makefile.in
+++ b/doc/Makefile.in
@@ -14,9 +14,8 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
-CONFSRC=example.conf
+CONFSRC=$(srcdir)/example.conf
 CONFDEST=lvm.conf
 
 include $(top_builddir)/make.tmpl
diff --git a/lib/Makefile.in b/lib/Makefile.in
index acfb23e..9662120 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -15,7 +15,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 ifeq ("@LVM1@", "shared")
   SUBDIRS = format1
diff --git a/lib/format1/Makefile.in b/lib/format1/Makefile.in
index f62ab7c..327a1c2 100644
--- a/lib/format1/Makefile.in
+++ b/lib/format1/Makefile.in
@@ -15,7 +15,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 SOURCES =\
 	disk-rep.c \
diff --git a/lib/format_pool/Makefile.in b/lib/format_pool/Makefile.in
index b0ebc36..d9cedf0 100644
--- a/lib/format_pool/Makefile.in
+++ b/lib/format_pool/Makefile.in
@@ -15,7 +15,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 SOURCES =\
 	disk_rep.c \
diff --git a/lib/locking/Makefile.in b/lib/locking/Makefile.in
index 399b0af..99cc206 100644
--- a/lib/locking/Makefile.in
+++ b/lib/locking/Makefile.in
@@ -15,7 +15,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 SOURCES = cluster_locking.c
 
diff --git a/lib/mirror/Makefile.in b/lib/mirror/Makefile.in
index 038399a..233fa96 100644
--- a/lib/mirror/Makefile.in
+++ b/lib/mirror/Makefile.in
@@ -15,7 +15,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 SOURCES = mirrored.c
 
diff --git a/lib/snapshot/Makefile.in b/lib/snapshot/Makefile.in
index 80728c7..e2c2b10 100644
--- a/lib/snapshot/Makefile.in
+++ b/lib/snapshot/Makefile.in
@@ -15,7 +15,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 SOURCES = snapshot.c
 
diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index 63e6603..1e9284a 100644
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -15,7 +15,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 SOURCES =\
 	datastruct/bitset.c \
diff --git a/liblvm/Makefile.in b/liblvm/Makefile.in
index 1b2b474..165ce46 100644
--- a/liblvm/Makefile.in
+++ b/liblvm/Makefile.in
@@ -15,7 +15,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 SOURCES =\
 	lvm_misc.c \
diff --git a/make.tmpl.in b/make.tmpl.in
index b42358a..5d8169c 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -63,6 +63,12 @@ localedir = $(DESTDIR)@LOCALEDIR@
 staticdir = $(DESTDIR)@STATICDIR@
 udevdir = $(DESTDIR)@udevdir@
 
+# Setup vpath search paths for some suffixes
+vpath %.c $(srcdir)
+vpath %.in $(srcdir)
+vpath %.po $(srcdir)
+vpath %.exported_symbols $(srcdir)
+
 interface = @interface@
 interfacebuilddir = $(top_builddir)/libdm/$(interface)
 
diff --git a/man/Makefile.in b/man/Makefile.in
index 446bbe6..f34014e 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -15,7 +15,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 ifeq ("@FSADM@", "yes")
 FSADMMAN = fsadm.8
diff --git a/po/Makefile.in b/po/Makefile.in
index 22184f1..79bd340 100644
--- a/po/Makefile.in
+++ b/po/Makefile.in
@@ -14,7 +14,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 LANGS=de
 
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index b79d312..4b1ab7f 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -14,7 +14,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 include $(top_builddir)/make.tmpl
 
diff --git a/test/api/Makefile.in b/test/api/Makefile.in
index 605da33..d373ff8 100644
--- a/test/api/Makefile.in
+++ b/test/api/Makefile.in
@@ -14,7 +14,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 ifeq ("@DEBUG@", "yes")
 	DEFS += -DDEBUG
diff --git a/tools/Makefile.in b/tools/Makefile.in
index 8cab5c4..b048fad 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -15,7 +15,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 SOURCES =\
 	dumpconfig.c \
@@ -146,7 +145,7 @@ liblvm2cmd-static.a: $(top_builddir)/lib/liblvm-internal.a $(OBJECTS) lvmcmdlib.
 
 liblvm2cmd.$(LIB_SUFFIX): liblvm2cmd.a $(LDDEPS)
 
-.commands: commands.h cmdnames.h Makefile
+.commands: $(srcdir)/commands.h $(srcdir)/cmdnames.h Makefile
 	$(CC) -E -P $(srcdir)/cmdnames.h 2> /dev/null | \
 		egrep -v '^ *(|#.*|dumpconfig|formats|help|pvdata|segtypes|version) *$$' > .commands
 
diff --git a/udev/Makefile.in b/udev/Makefile.in
index 0d9e2ec..2511cf8 100644
--- a/udev/Makefile.in
+++ b/udev/Makefile.in
@@ -14,7 +14,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 DM_RULES=10-dm.rules 13-dm-disk.rules 95-dm-notify.rules
 LVM_RULES=11-dm-lvm.rules
@@ -24,6 +23,8 @@ CLEAN_TARGETS=10-dm.rules
 
 include $(top_builddir)/make.tmpl
 
+vpath %.rules $(srcdir)
+
 %: %.in
 	$(SED) -e "s/(DM_DIR)/$(DM_DIR)/" $< >$@
 
-- 
1.7.0.1



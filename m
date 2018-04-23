From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:52:11 -0400
Subject: master - [makefile] add -laio to makefiles
Message-ID: <201804231352.w3NDqBmC000344@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=697fa7aa1dbcc2ed8e141d9d13118cb38d609161
Commit:        697fa7aa1dbcc2ed8e141d9d13118cb38d609161
Parent:        93fc9374294aae679faa23aef0bd631db2e9a31a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 8 09:32:19 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:13:17 2018 -0500

[makefile] add -laio to makefiles

---
 daemons/clvmd/Makefile.in |    2 +-
 liblvm/Makefile.in        |    2 +-
 scripts/Makefile.in       |    2 +-
 tools/Makefile.in         |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/daemons/clvmd/Makefile.in b/daemons/clvmd/Makefile.in
index 7b1b49b..83af00e 100644
--- a/daemons/clvmd/Makefile.in
+++ b/daemons/clvmd/Makefile.in
@@ -74,7 +74,7 @@ TARGETS = \
 
 include $(top_builddir)/make.tmpl
 
-LIBS += $(LVMINTERNAL_LIBS) -ldevmapper $(PTHREAD_LIBS)
+LIBS += $(LVMINTERNAL_LIBS) -ldevmapper $(PTHREAD_LIBS) -laio
 CFLAGS += -fno-strict-aliasing $(EXTRA_EXEC_CFLAGS)
 
 INSTALL_TARGETS = \
diff --git a/liblvm/Makefile.in b/liblvm/Makefile.in
index 6d0325c..be3049a 100644
--- a/liblvm/Makefile.in
+++ b/liblvm/Makefile.in
@@ -43,7 +43,7 @@ LDDEPS += $(top_builddir)/lib/liblvm-internal.a
 include $(top_builddir)/make.tmpl
 
 LDFLAGS += -L$(top_builddir)/lib -L$(top_builddir)/daemons/dmeventd
-LIBS += $(LVMINTERNAL_LIBS) -ldevmapper
+LIBS += $(LVMINTERNAL_LIBS) -ldevmapper -laio
 
 .PHONY: install_dynamic install_static install_include install_pkgconfig
 
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index d06766f..720ae9f 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -28,7 +28,7 @@ ifeq ("@APPLIB@", "yes")
 ifeq ("@BUILD_DMEVENTD@", "yes")
 	LDFLAGS += -Wl,-rpath-link,$(top_builddir)/daemons/dmeventd
 endif
-	LVMLIBS = @LVM2APP_LIB@ -ldevmapper
+	LVMLIBS = @LVM2APP_LIB@ -ldevmapper -laio
 endif
 
 LVM_SCRIPTS = lvmdump.sh lvmconf.sh
diff --git a/tools/Makefile.in b/tools/Makefile.in
index 61c6f38..103b767 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -95,7 +95,7 @@ ifeq ("@STATIC_LINK@", "yes")
   INSTALL_CMDLIB_TARGETS += install_cmdlib_static
 endif
 
-LVMLIBS = $(LVMINTERNAL_LIBS) -ldevmapper
+LVMLIBS = $(LVMINTERNAL_LIBS) -ldevmapper -laio
 LIB_VERSION = $(LIB_VERSION_LVM)
 
 CLEAN_TARGETS = liblvm2cmd.$(LIB_SUFFIX) $(TARGETS_DM) \



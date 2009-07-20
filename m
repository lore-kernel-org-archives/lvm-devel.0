From: Thomas Woerner <twoerner@redhat.com>
Date: Mon, 20 Jul 2009 18:23:48 +0200
Subject: [PATCH 2/2] Add liblvm2app install environment, cleanup build environment
In-Reply-To: <1248107028-1130-1-git-send-email-twoerner@redhat.com>
References: <1248107028-1130-1-git-send-email-twoerner@redhat.com>
Message-ID: <1248107028-1130-2-git-send-email-twoerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add liblvm2app install environment, cleanup build environment

---
 configure               |   18 +++++++++++++++---
 configure.in            |    8 +++++++-
 lib/misc/configure.h.in |    3 +++
 liblvm/Makefile.in      |   39 +++++++++++++++++++++++++++++++++++----
 liblvm/lvm2app.pc.in    |   11 +++++++++++
 test/api/Makefile.in    |   20 ++++++++++++++------
 6 files changed, 85 insertions(+), 14 deletions(-)
 create mode 100644 liblvm/lvm2app.pc.in

diff --git a/configure b/configure
index 2b8d9d7..c79a209 100755
--- a/configure
+++ b/configure
@@ -690,11 +690,13 @@ CLDWHOLEARCHIVE
 CLDNOWHOLEARCHIVE
 CLDFLAGS
 BUILD_DMEVENTD
+LVM2APP_LIB_VERSION
 APPLIB
 MODPROBE_CMD
 MSGFMT
 LVM2CMD_LIB
 LVM2APP_LIB
+LVM2APP_LIB_NAME
 GENHTML
 LCOV
 CPG_LIBS
@@ -9711,8 +9713,8 @@ _ACEOF
 fi
 
 ################################################################################
-{ $as_echo "$as_me:$LINENO: checking whether to build liblvm2app.so application library" >&5
-$as_echo_n "checking whether to build liblvm2app.so application library... " >&6; }
+{ $as_echo "$as_me:$LINENO: checking whether to build liblvm application library" >&5
+$as_echo_n "checking whether to build liblvm application library... " >&6; }
 # Check whether --enable-applib was given.
 if test "${enable_applib+set}" = set; then
   enableval=$enable_applib; APPLIB=$enableval
@@ -9723,6 +9725,8 @@ fi
 { $as_echo "$as_me:$LINENO: result: $APPLIB" >&5
 $as_echo "$APPLIB" >&6; }
 
+LVM2APP_LIB_NAME=liblvm2app
+
 test x$APPLIB = xyes \
   && LVM2APP_LIB=-llvm2app \
   || LVM2APP_LIB=
@@ -12604,6 +12608,12 @@ _ACEOF
 DM_LIB_PATCHLEVEL=`cat VERSION_DM | $AWK -F '[-. ]' '{printf "%s.%s.%s",$1,$2,$3}'`
 
 LVM_VERSION="\"`cat VERSION 2>/dev/null || echo Unknown`\""
+LVM2APP_LIB_VERSION=`cat VERSION | $AWK -F '[-. ]' '{printf "%s.%s.%s",$1,$2,$3}'`
+
+cat >>confdefs.h <<_ACEOF
+#define LVM2APP_LIB_VERSION $LVM2APP_LIB_VERSION
+_ACEOF
+
 
 VER=`cat VERSION`
 LVM_RELEASE_DATE="\"`echo $VER | $SED 's/.*(//;s/).*//'`\""
@@ -12681,8 +12691,9 @@ LVM_PATCHLEVEL=`echo "$VER" | $AWK -F '.' '{print $3}'`
 
 
 
+
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/lvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -13302,6 +13313,7 @@ do
     "libdm/Makefile") CONFIG_FILES="$CONFIG_FILES libdm/Makefile" ;;
     "libdm/libdevmapper.pc") CONFIG_FILES="$CONFIG_FILES libdm/libdevmapper.pc" ;;
     "liblvm/Makefile") CONFIG_FILES="$CONFIG_FILES liblvm/Makefile" ;;
+    "liblvm/lvm2app.pc") CONFIG_FILES="$CONFIG_FILES liblvm/lvm2app.pc" ;;
     "man/Makefile") CONFIG_FILES="$CONFIG_FILES man/Makefile" ;;
     "po/Makefile") CONFIG_FILES="$CONFIG_FILES po/Makefile" ;;
     "scripts/clvmd_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/clvmd_init_red_hat" ;;
diff --git a/configure.in b/configure.in
index eb6278d..e9f5dcc 100644
--- a/configure.in
+++ b/configure.in
@@ -425,11 +425,13 @@ fi
 
 ################################################################################
 dnl -- Enable liblvm2app.so
-AC_MSG_CHECKING(whether to build liblvm2app.so application library)
+AC_MSG_CHECKING(whether to build liblvm application library)
 AC_ARG_ENABLE(applib,
   [  --enable-applib         Build application library],
   APPLIB=$enableval, APPLIB=no)
 AC_MSG_RESULT($APPLIB)
+AC_SUBST([LVM2APP_LIB_NAME])
+LVM2APP_LIB_NAME=liblvm2app
 AC_SUBST([LVM2APP_LIB])
 test x$APPLIB = xyes \
   && LVM2APP_LIB=-llvm2app \
@@ -748,6 +750,8 @@ AC_DEFINE_UNQUOTED(DM_LIB_VERSION, $DM_LIB_VERSION, [Library version])
 DM_LIB_PATCHLEVEL=`cat VERSION_DM | $AWK -F '[[-. ]]' '{printf "%s.%s.%s",$1,$2,$3}'`
 
 LVM_VERSION="\"`cat VERSION 2>/dev/null || echo Unknown`\""
+LVM2APP_LIB_VERSION=`cat VERSION | $AWK -F '[[-. ]]' '{printf "%s.%s.%s",$1,$2,$3}'`
+AC_DEFINE_UNQUOTED(LVM2APP_LIB_VERSION, $LVM2APP_LIB_VERSION, [APP Library version])
 
 VER=`cat VERSION`
 LVM_RELEASE_DATE="\"`echo $VER | $SED 's/.*(//;s/).*//'`\""
@@ -760,6 +764,7 @@ LVM_PATCHLEVEL=`echo "$VER" | $AWK -F '.' '{print $3}'`
 
 ################################################################################
 AC_SUBST(APPLIB)
+AC_SUBST(LVM2APP_LIB_VERSION)
 AC_SUBST(BUILD_DMEVENTD)
 AC_SUBST(CFLAGS)
 AC_SUBST(CFLOW_CMD)
@@ -850,6 +855,7 @@ lib/snapshot/Makefile
 libdm/Makefile
 libdm/libdevmapper.pc
 liblvm/Makefile
+liblvm/lvm2app.pc
 man/Makefile
 po/Makefile
 scripts/clvmd_init_red_hat
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index ccab9f5..f9d430f 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -355,6 +355,9 @@
 /* Define to 1 to include built-in support for LVM1 metadata. */
 #undef LVM1_INTERNAL
 
+/* APP Library version */
+#undef LVM2APP_LIB_VERSION
+
 /* Define to 1 to include built-in support for mirrors. */
 #undef MIRRORED_INTERNAL
 
diff --git a/liblvm/Makefile.in b/liblvm/Makefile.in
index 643cc0c..28e2943 100644
--- a/liblvm/Makefile.in
+++ b/liblvm/Makefile.in
@@ -20,16 +20,17 @@ SOURCES =\
 	lvm_base.c \
 	lvm_vg.c
 
-LIB_NAME = liblvm2app
+LIB_NAME = @LVM2APP_LIB_NAME@
 LIB_VERSION = $(LIB_VERSION_LVM)
-VERSIONED_SHLIB = $(LIB_NAME).$(LIB_SUFFIX).$(LIB_VERSION_LVM)
+VERSIONED_SHLIB = $(LIB_NAME).$(LIB_SUFFIX).$(LIB_VERSION)
+PKGCONFIG_NAME = $(subst lib,,$(LIB_NAME)).pc
 
 ifeq ("@STATIC_LINK@", "yes")
 LIB_STATIC = $(LIB_NAME).a
 endif
 LIB_SHARED = $(LIB_NAME).so
 
-CLEAN_TARGETS += liblvm.cflow
+CLEAN_TARGETS += $(LIB_NAME).cflow $(LIB_NAME).$(LIB_SUFFIX)
 
 include $(top_srcdir)/make.tmpl
 
@@ -45,4 +46,34 @@ liblvm.cflow: $(SOURCES)
 		 sed "s/^/ /;s/ / $(top_srcdir)\/lib\//g;s/$$//"; \
 		 ) > $@
 
-cflow: liblvm.cflow
+cflow: $(LIB_NAME).cflow
+
+.PHONY: install_dynamic install_include install_pkgconfig
+
+INSTALL_TYPE = install_dynamic
+
+ifeq ("@PKGCONFIG@", "yes")
+  INSTALL_TYPE += install_pkgconfig
+endif
+
+install: $(INSTALL_TYPE) install_include
+
+install_include:
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 lvm.h \
+		$(includedir)/lvm.h
+
+install_dynamic:
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $(VERSIONED_SHLIB) \
+		$(libdir)/$(VERSIONED_SHLIB)
+	$(LN_S) -f $(VERSIONED_SHLIB) $(libdir)/$(LIB_NAME).$(LIB_SUFFIX)
+
+install_pkgconfig:
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $(PKGCONFIG_NAME) \
+		$(usrlibdir)/pkgconfig/
+
+.PHONY: distclean_lib distclean
+
+distclean_lib:
+	$(RM) $(LVM2APP_LIB_NAME:lib=).pc
+
+distclean: distclean_lib
diff --git a/liblvm/lvm2app.pc.in b/liblvm/lvm2app.pc.in
new file mode 100644
index 0000000..3cfd15c
--- /dev/null
+++ b/liblvm/lvm2app.pc.in
@@ -0,0 +1,11 @@
+prefix=@prefix@
+exec_prefix=@exec_prefix@
+libdir=@libdir@
+includedir=@includedir@
+
+Name: lvm
+Description: lvm library
+Version: @LVM2APP_LIB_VERSION@
+Cflags: -I${includedir} 
+Libs: -L${libdir} @LVM2APP_LIB@
+Libs.private: -ldevmapper
diff --git a/test/api/Makefile.in b/test/api/Makefile.in
index 11eb1a5..851ac1c 100644
--- a/test/api/Makefile.in
+++ b/test/api/Makefile.in
@@ -16,16 +16,17 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 VPATH = @srcdir@
 
-SOURCES = test.c
-INCLUDES += -I${top_srcdir}/lib
-
 ifeq ("@DEBUG@", "yes")
 	DEFS += -DDEBUG
 endif
 
-TARGETS = test
+TARGETS = test vgcreate
+test_SOURCES = test.c
+vgcreate_SOURCES = vgcreate.c
+INCLUDES += -I${top_srcdir}/lib
 
 LVMLIBS = @LVM2APP_LIB@ -ldevmapper
+DEPLIBS = $(top_srcdir)/liblvm/liblvm2app.so $(top_srcdir)/libdm/libdevmapper.so
 
 DEFS += -D_REENTRANT
 CFLAGS += -fno-strict-aliasing
@@ -35,6 +36,13 @@ include $(top_srcdir)/make.tmpl
 LDFLAGS = -L$(top_srcdir)/libdm -L$(top_srcdir)/liblvm
 CLDFLAGS = -L$(top_srcdir)/libdm -L$(top_srcdir)/liblvm
 
-test: $(OBJECTS) $(top_srcdir)/liblvm/liblvm2app.so $(top_srcdir)/libdm/libdevmapper.so
-	$(CC) -o test $(OBJECTS) $(CFLAGS) $(LDFLAGS) $(LVMLIBS) $(LIBS)
+test_OBJECTS = $(test_SOURCES:.c=.o)
+vgcreate_OBJECTS = $(vgcreate_SOURCES:.c=.o)
+OBJECTS = $(test_OBJECTS) $(vgcreate_OBJECTS)
+
+test: $(test_OBJECTS) $(DEPLIBS)
+	$(CC) -o $@ $(test_OBJECTS) $(CFLAGS) $(LDFLAGS) $(LVMLIBS) $(LIBS)
+
+vgcreate: $(vgcreate_OBJECTS) $(DEPLIBS)
+	$(CC) -o $@ $(vgcreate_OBJECTS) $(CFLAGS) $(LDFLAGS) $(LVMLIBS) $(LIBS)
 
-- 
1.6.2.5



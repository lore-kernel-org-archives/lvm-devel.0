From: Thomas Woerner <twoerner@redhat.com>
Date: Fri, 17 Jul 2009 17:38:22 +0200
Subject: [PATCH] liblvm install environment
Message-ID: <1247845102-8166-1-git-send-email-twoerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 configure               |   31 ++++++++++++++++++++-----------
 configure.in            |   18 +++++++++++-------
 lib/misc/configure.h.in |    3 +++
 liblvm/Makefile.in      |   36 +++++++++++++++++++++++++++++++++---
 liblvm/liblvm.pc.in     |   11 +++++++++++
 5 files changed, 78 insertions(+), 21 deletions(-)
 create mode 100644 liblvm/liblvm.pc.in

diff --git a/configure b/configure
index 2b8d9d7..4187b31 100755
--- a/configure
+++ b/configure
@@ -690,11 +690,12 @@ CLDWHOLEARCHIVE
 CLDNOWHOLEARCHIVE
 CLDFLAGS
 BUILD_DMEVENTD
+LVM_LIB_VERSION
 APPLIB
 MODPROBE_CMD
 MSGFMT
 LVM2CMD_LIB
-LVM2APP_LIB
+LVM_LIB
 GENHTML
 LCOV
 CPG_LIBS
@@ -802,7 +803,7 @@ enable_devmapper
 enable_compat
 enable_ioctl
 enable_o_direct
-enable_applib
+enable_api
 enable_cmdlib
 enable_pkgconfig
 enable_fsadm
@@ -1470,7 +1471,7 @@ Optional Features:
   --enable-compat         Enable support for old device-mapper versions
   --disable-driver        Disable calls to device-mapper in the kernel
   --disable-o_direct      Disable O_DIRECT
-  --enable-applib         Build application library
+  --enable-api            Build application library
   --enable-cmdlib         Build shared command library
   --enable-pkgconfig      Install pkgconfig support
   --enable-fsadm          Enable fsadm
@@ -9711,11 +9712,11 @@ _ACEOF
 fi
 
 ################################################################################
-{ $as_echo "$as_me:$LINENO: checking whether to build liblvm2app.so application library" >&5
-$as_echo_n "checking whether to build liblvm2app.so application library... " >&6; }
-# Check whether --enable-applib was given.
-if test "${enable_applib+set}" = set; then
-  enableval=$enable_applib; APPLIB=$enableval
+{ $as_echo "$as_me:$LINENO: checking whether to build liblvm application library" >&5
+$as_echo_n "checking whether to build liblvm application library... " >&6; }
+# Check whether --enable-api was given.
+if test "${enable_api+set}" = set; then
+  enableval=$enable_api; APPLIB=$enableval
 else
   APPLIB=no
 fi
@@ -9724,8 +9725,8 @@ fi
 $as_echo "$APPLIB" >&6; }
 
 test x$APPLIB = xyes \
-  && LVM2APP_LIB=-llvm2app \
-  || LVM2APP_LIB=
+  && LVM_LIB=-llvm2 \
+  || LVM_LIB=
 
 ################################################################################
 { $as_echo "$as_me:$LINENO: checking whether to compile liblvm2cmd.so" >&5
@@ -12604,6 +12605,12 @@ _ACEOF
 DM_LIB_PATCHLEVEL=`cat VERSION_DM | $AWK -F '[-. ]' '{printf "%s.%s.%s",$1,$2,$3}'`
 
 LVM_VERSION="\"`cat VERSION 2>/dev/null || echo Unknown`\""
+LVM_LIB_VERSION=`cat VERSION | $AWK -F '[-. ]' '{printf "%s.%s.%s",$1,$2,$3}'`
+
+cat >>confdefs.h <<_ACEOF
+#define LVM_LIB_VERSION $LVM_LIB_VERSION
+_ACEOF
+
 
 VER=`cat VERSION`
 LVM_RELEASE_DATE="\"`echo $VER | $SED 's/.*(//;s/).*//'`\""
@@ -12681,8 +12688,9 @@ LVM_PATCHLEVEL=`echo "$VER" | $AWK -F '.' '{print $3}'`
 
 
 
+
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -13302,6 +13310,7 @@ do
     "libdm/Makefile") CONFIG_FILES="$CONFIG_FILES libdm/Makefile" ;;
     "libdm/libdevmapper.pc") CONFIG_FILES="$CONFIG_FILES libdm/libdevmapper.pc" ;;
     "liblvm/Makefile") CONFIG_FILES="$CONFIG_FILES liblvm/Makefile" ;;
+    "liblvm/liblvm.pc") CONFIG_FILES="$CONFIG_FILES liblvm/liblvm.pc" ;;
     "man/Makefile") CONFIG_FILES="$CONFIG_FILES man/Makefile" ;;
     "po/Makefile") CONFIG_FILES="$CONFIG_FILES po/Makefile" ;;
     "scripts/clvmd_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/clvmd_init_red_hat" ;;
diff --git a/configure.in b/configure.in
index eb6278d..2a62284 100644
--- a/configure.in
+++ b/configure.in
@@ -424,16 +424,16 @@ if test x$ODIRECT = xyes; then
 fi
 
 ################################################################################
-dnl -- Enable liblvm2app.so
-AC_MSG_CHECKING(whether to build liblvm2app.so application library)
-AC_ARG_ENABLE(applib,
-  [  --enable-applib         Build application library],
+dnl -- Enable liblvm2.so
+AC_MSG_CHECKING(whether to build liblvm application library)
+AC_ARG_ENABLE(api,
+  [  --enable-api            Build application library],
   APPLIB=$enableval, APPLIB=no)
 AC_MSG_RESULT($APPLIB)
-AC_SUBST([LVM2APP_LIB])
+AC_SUBST([LVM_LIB])
 test x$APPLIB = xyes \
-  && LVM2APP_LIB=-llvm2app \
-  || LVM2APP_LIB=
+  && LVM_LIB=-llvm2 \
+  || LVM_LIB=
 
 ################################################################################
 dnl -- Enable cmdlib
@@ -748,6 +748,8 @@ AC_DEFINE_UNQUOTED(DM_LIB_VERSION, $DM_LIB_VERSION, [Library version])
 DM_LIB_PATCHLEVEL=`cat VERSION_DM | $AWK -F '[[-. ]]' '{printf "%s.%s.%s",$1,$2,$3}'`
 
 LVM_VERSION="\"`cat VERSION 2>/dev/null || echo Unknown`\""
+LVM_LIB_VERSION=`cat VERSION | $AWK -F '[[-. ]]' '{printf "%s.%s.%s",$1,$2,$3}'`
+AC_DEFINE_UNQUOTED(LVM_LIB_VERSION, $LVM_LIB_VERSION, [Library version])
 
 VER=`cat VERSION`
 LVM_RELEASE_DATE="\"`echo $VER | $SED 's/.*(//;s/).*//'`\""
@@ -760,6 +762,7 @@ LVM_PATCHLEVEL=`echo "$VER" | $AWK -F '.' '{print $3}'`
 
 ################################################################################
 AC_SUBST(APPLIB)
+AC_SUBST(LVM_LIB_VERSION)
 AC_SUBST(BUILD_DMEVENTD)
 AC_SUBST(CFLAGS)
 AC_SUBST(CFLOW_CMD)
@@ -850,6 +853,7 @@ lib/snapshot/Makefile
 libdm/Makefile
 libdm/libdevmapper.pc
 liblvm/Makefile
+liblvm/liblvm.pc
 man/Makefile
 po/Makefile
 scripts/clvmd_init_red_hat
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index ccab9f5..b5a57fe 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -355,6 +355,9 @@
 /* Define to 1 to include built-in support for LVM1 metadata. */
 #undef LVM1_INTERNAL
 
+/* Library version */
+#undef LVM_LIB_VERSION
+
 /* Define to 1 to include built-in support for mirrors. */
 #undef MIRRORED_INTERNAL
 
diff --git a/liblvm/Makefile.in b/liblvm/Makefile.in
index 643cc0c..8f96245 100644
--- a/liblvm/Makefile.in
+++ b/liblvm/Makefile.in
@@ -20,7 +20,7 @@ SOURCES =\
 	lvm_base.c \
 	lvm_vg.c
 
-LIB_NAME = liblvm2app
+LIB_NAME = liblvm2api
 LIB_VERSION = $(LIB_VERSION_LVM)
 VERSIONED_SHLIB = $(LIB_NAME).$(LIB_SUFFIX).$(LIB_VERSION_LVM)
 
@@ -29,7 +29,7 @@ LIB_STATIC = $(LIB_NAME).a
 endif
 LIB_SHARED = $(LIB_NAME).so
 
-CLEAN_TARGETS += liblvm.cflow
+CLEAN_TARGETS += $(LIB_NAME).cflow $(LIB_NAME).$(LIB_SUFFIX)
 
 include $(top_srcdir)/make.tmpl
 
@@ -45,4 +45,34 @@ liblvm.cflow: $(SOURCES)
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
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $(LIB_NAME).pc \
+		$(usrlibdir)/pkgconfig/lvm2api.pc
+
+.PHONY: distclean_lib distclean
+
+distclean_lib:
+	$(RM) $(LIB_NAME).pc
+
+distclean: distclean_lib
diff --git a/liblvm/liblvm.pc.in b/liblvm/liblvm.pc.in
new file mode 100644
index 0000000..7961567
--- /dev/null
+++ b/liblvm/liblvm.pc.in
@@ -0,0 +1,11 @@
+prefix=@prefix@
+exec_prefix=@exec_prefix@
+libdir=@libdir@
+includedir=@includedir@
+
+Name: lvm
+Description: lvm library
+Version: @LVM_LIB_VERSION@
+Cflags: -I${includedir} 
+Libs: -L${libdir} -llvm
+Libs.private: -ldevmapper
-- 
1.6.2.5



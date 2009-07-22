From: Thomas Woerner <twoerner@redhat.com>
Date: Wed, 22 Jul 2009 17:38:16 +0200
Subject: [PATCH 5/5] Add lvm2app pkgconfig file
In-Reply-To: <1248277096-29947-5-git-send-email-twoerner@redhat.com>
References: <1248277096-29947-1-git-send-email-twoerner@redhat.com>
	<1248277096-29947-2-git-send-email-twoerner@redhat.com>
	<1248277096-29947-3-git-send-email-twoerner@redhat.com>
	<1248277096-29947-4-git-send-email-twoerner@redhat.com>
	<1248277096-29947-5-git-send-email-twoerner@redhat.com>
Message-ID: <1248277096-29947-6-git-send-email-twoerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add liblvm/lvm2app.pc.in.
Add LVM2APP_LIB_VERSION to configure.in to create lvm2app.pc from lvm2app.pc.in with the proper version.
Add install_pkgconfig target and also distclean_lib to liblvm/Makefile.in.

Signed-off-by: Thomas Woerner <twoerner@redhat.com>
---
 configure.in         |    4 ++++
 liblvm/Makefile.in   |    7 +++++++
 liblvm/lvm2app.pc.in |   11 +++++++++++
 3 files changed, 22 insertions(+), 0 deletions(-)
 create mode 100644 liblvm/lvm2app.pc.in

diff --git a/configure.in b/configure.in
index d0e68a6..6af7109 100644
--- a/configure.in
+++ b/configure.in
@@ -758,6 +758,8 @@ LVM_MAJOR=`echo "$VER" | $AWK -F '.' '{print $1}'`
 LVM_MINOR=`echo "$VER" | $AWK -F '.' '{print $2}'`
 LVM_PATCHLEVEL=`echo "$VER" | $AWK -F '[[(.]]' '{print $3}'`
 
+LVM2APP_LIB_VERSION=`echo "$VER" | $AWK -F'[- ]' '{print $1}'`
+
 ################################################################################
 AC_SUBST(APPLIB)
 AC_SUBST(BUILD_DMEVENTD)
@@ -806,6 +808,7 @@ AC_SUBST(LVM_MINOR)
 AC_SUBST(LVM_PATCHLEVEL)
 AC_SUBST(LVM_RELEASE)
 AC_SUBST(LVM_RELEASE_DATE)
+AC_SUBST(LVM2APP_LIB_VERSION)
 AC_SUBST(MIRRORS)
 AC_SUBST(MSGFMT)
 AC_SUBST(OWNER)
@@ -850,6 +853,7 @@ lib/snapshot/Makefile
 libdm/Makefile
 libdm/libdevmapper.pc
 liblvm/Makefile
+liblvm/lvm2app.pc
 man/Makefile
 po/Makefile
 scripts/clvmd_init_red_hat
diff --git a/liblvm/Makefile.in b/liblvm/Makefile.in
index f19069d..1c1decb 100644
--- a/liblvm/Makefile.in
+++ b/liblvm/Makefile.in
@@ -62,6 +62,13 @@ install_dynamic:
 		$(libdir)/$(VERSIONED_SHLIB)
 	$(LN_S) -f $(VERSIONED_SHLIB) $(libdir)/$(LIB_NAME).$(LIB_SUFFIX)
 
+install_pkgconfig:
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 lvm2app.pc \
+		$(usrlibdir)/pkgconfig/
+
 .PHONY: distclean_lib distclean
 
+distclean_lib:
+	$(RM) lvm2app.pc
+
 distclean: distclean_lib
diff --git a/liblvm/lvm2app.pc.in b/liblvm/lvm2app.pc.in
new file mode 100644
index 0000000..abfbc7e
--- /dev/null
+++ b/liblvm/lvm2app.pc.in
@@ -0,0 +1,11 @@
+prefix=@prefix@
+exec_prefix=@exec_prefix@
+libdir=@libdir@
+includedir=@includedir@
+
+Name: lvm2app
+Description: lvm2app application library
+Version: @LVM2APP_LIB_VERSION@
+Cflags: -I${includedir} 
+Libs: -L${libdir} -llvm2app
+Libs.private: -ldevmapper
-- 
1.6.2.5



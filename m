From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 11 Nov 2015 14:18:40 +0000 (UTC)
Subject: master - configure: check for udev_device_get_is_initialized is available
Message-ID: <20151111141840.3C6E96055F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b8779e706e1019a8e8212d81bde0cc7e42be5426
Commit:        b8779e706e1019a8e8212d81bde0cc7e42be5426
Parent:        f82e0210b7cb9f3926ef5051ca34a4ad383ba271
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Nov 11 15:15:34 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Nov 11 15:15:50 2015 +0100

configure: check for udev_device_get_is_initialized is available

The udev_device_get_is_initialized is available since libudev version
165. Older versions are still used somewhere (e.g. RHEL6). So better
check for this fn and use it only if it's available.
---
 aclocal.m4             |    2 +-
 configure              |   44 ++++++++++++++++++++++++++++++++++++++++++++
 configure.in           |    4 ++++
 include/configure.h.in |    3 +++
 lib/device/dev-ext.c   |    2 ++
 5 files changed, 54 insertions(+), 1 deletions(-)

diff --git a/aclocal.m4 b/aclocal.m4
index 67b2d59..05e0ad5 100644
--- a/aclocal.m4
+++ b/aclocal.m4
@@ -15,7 +15,7 @@ m4_ifndef([AC_CONFIG_MACRO_DIRS], [m4_defun([_AM_CONFIG_MACRO_DIRS], [])m4_defun
 # pkg.m4 - Macros to locate and utilise pkg-config.            -*- Autoconf -*-
 # serial 1 (pkg-config-0.24)
 # 
-# Copyright (c) 2004 Scott James Remnant <scott@netsplit.com>.
+# Copyright ?? 2004 Scott James Remnant <scott@netsplit.com>.
 #
 # This program is free software; you can redistribute it and/or modify
 # it under the terms of the GNU General Public License as published by
diff --git a/configure b/configure
index c566466..8a9482d 100755
--- a/configure
+++ b/configure
@@ -12007,6 +12007,50 @@ fi
 
 $as_echo "#define UDEV_SYNC_SUPPORT 1" >>confdefs.h
 
+
+	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for udev_device_get_is_initialized in -ludev" >&5
+$as_echo_n "checking for udev_device_get_is_initialized in -ludev... " >&6; }
+if ${ac_cv_lib_udev_udev_device_get_is_initialized+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  ac_check_lib_save_LIBS=$LIBS
+LIBS="-ludev  $LIBS"
+cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+
+/* Override any GCC internal prototype to avoid an error.
+   Use char because int might match the return type of a GCC
+   builtin and then its argument prototype would still apply.  */
+#ifdef __cplusplus
+extern "C"
+#endif
+char udev_device_get_is_initialized ();
+int
+main ()
+{
+return udev_device_get_is_initialized ();
+  ;
+  return 0;
+}
+_ACEOF
+if ac_fn_c_try_link "$LINENO"; then :
+  ac_cv_lib_udev_udev_device_get_is_initialized=yes
+else
+  ac_cv_lib_udev_udev_device_get_is_initialized=no
+fi
+rm -f core conftest.err conftest.$ac_objext \
+    conftest$ac_exeext conftest.$ac_ext
+LIBS=$ac_check_lib_save_LIBS
+fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_udev_udev_device_get_is_initialized" >&5
+$as_echo "$ac_cv_lib_udev_udev_device_get_is_initialized" >&6; }
+if test "x$ac_cv_lib_udev_udev_device_get_is_initialized" = xyes; then :
+
+$as_echo "#define HAVE_LIBUDEV_UDEV_DEVICE_GET_IS_INITIALIZED 1" >>confdefs.h
+
+fi
+
+	LIBS=$ac_check_lib_save_LIBS
 fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable installation of udev rules required for synchronisation" >&5
diff --git a/configure.in b/configure.in
index 68bd341..8e04782 100644
--- a/configure.in
+++ b/configure.in
@@ -1334,6 +1334,10 @@ if test "$UDEV_SYNC" = yes; then
 	pkg_config_init
 	PKG_CHECK_MODULES(UDEV, libudev >= 143, [UDEV_PC="libudev"])
 	AC_DEFINE([UDEV_SYNC_SUPPORT], 1, [Define to 1 to enable synchronisation with udev processing.])
+
+	AC_CHECK_LIB(udev, udev_device_get_is_initialized, AC_DEFINE([HAVE_LIBUDEV_UDEV_DEVICE_GET_IS_INITIALIZED], 1,
+	  [Define to 1 if udev_device_get_is_initialized is available.]))
+	LIBS=$ac_check_lib_save_LIBS
 fi
 
 dnl -- Enable udev rules
diff --git a/include/configure.h.in b/include/configure.h.in
index cb7771f..1681af0 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -258,6 +258,9 @@
 /* Define to 1 if you have the <libintl.h> header file. */
 #undef HAVE_LIBINTL_H
 
+/* Define to 1 if udev_device_get_is_initialized is available. */
+#undef HAVE_LIBUDEV_UDEV_DEVICE_GET_IS_INITIALIZED
+
 /* Define to 1 if you have the <limits.h> header file. */
 #undef HAVE_LIMITS_H
 
diff --git a/lib/device/dev-ext.c b/lib/device/dev-ext.c
index 22e9a6d..e8cc012 100644
--- a/lib/device/dev-ext.c
+++ b/lib/device/dev-ext.c
@@ -60,11 +60,13 @@ static struct dev_ext *_dev_ext_get_udev(struct device *dev)
 	if (!(udev_device = udev_device_new_from_devnum(udev, 'b', dev->dev)))
 		return_NULL;
 
+#ifdef HAVE_LIBUDEV_UDEV_DEVICE_GET_IS_INITIALIZED
 	if (!udev_device_get_is_initialized(udev_device)) {
 		/* Timeout or some other udev db inconsistency! */
 		log_error("Udev database has incomplete information about device %s.", dev_name(dev));
 		return NULL;
 	}
+#endif
 
 	dev->ext.handle = (void *) udev_device;
 	return &dev->ext;



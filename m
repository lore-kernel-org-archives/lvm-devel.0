From: Andy Grover <agrover@redhat.com>
Date: Tue,  2 Oct 2012 09:03:44 -0700
Subject: [PATCH 3/4] python-lvm: build infrastructure
In-Reply-To: <1349193825-32244-1-git-send-email-agrover@redhat.com>
References: <1349193825-32244-1-git-send-email-agrover@redhat.com>
Message-ID: <1349193825-32244-4-git-send-email-agrover@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add a Makefile.in and setup.py.in, along with changes to upper
build files as necessary.

Add --enable-python-bindings configure option

Add install_python_bindings target to toplevel makefile

Signed-off-by: Andy Grover <agrover@redhat.com>
---
 Makefile.in               |    3 +++
 configure.in              |   10 ++++++++++
 liblvm/Makefile.in        |    6 +++++-
 liblvm/python/Makefile.in |   30 ++++++++++++++++++++++++++++++
 liblvm/python/setup.py.in |   17 +++++++++++++++++
 5 files changed, 65 insertions(+), 1 deletions(-)
 create mode 100644 liblvm/python/Makefile.in
 create mode 100644 liblvm/python/setup.py.in

diff --git a/Makefile.in b/Makefile.in
index 6b153d3..4523e16 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -103,6 +103,9 @@ install_systemd_generators:
 install_systemd_units:
 	$(MAKE) -C scripts install_systemd_units
 
+install_python_bindings:
+	$(MAKE) -C liblvm/python install_python_bindings
+
 install_tmpfiles_configuration:
 	$(MAKE) -C scripts install_tmpfiles_configuration
 
diff --git a/configure.in b/configure.in
index 1c908f9..c4507ee 100644
--- a/configure.in
+++ b/configure.in
@@ -1022,6 +1022,13 @@ test x$CMDLIB = xyes \
   || LVM2CMD_LIB=
 
 ################################################################################
+dnl -- Enable Python lvm.so
+AC_MSG_CHECKING(whether to build Python wrapper for liblvm2app.so)
+AC_ARG_ENABLE(python-bindings,
+	      AC_HELP_STRING([--enable-python-bindings], [build Python applib bindings]),
+	      PYTHON_BINDINGS=$enableval, PYTHON_BINDINGS=no)
+
+################################################################################
 dnl -- Enable pkg-config
 AC_ARG_ENABLE(pkgconfig,
 	      AC_HELP_STRING([--enable-pkgconfig], [install pkgconfig support]),
@@ -1518,6 +1525,7 @@ AC_SUBST(OCFDIR)
 AC_SUBST(PKGCONFIG)
 AC_SUBST(POOL)
 AC_SUBST(PTHREAD_LIBS)
+AC_SUBST(PYTHON_BINDINGS)
 AC_SUBST(QUORUM_CFLAGS)
 AC_SUBST(QUORUM_LIBS)
 AC_SUBST(RAID)
@@ -1598,6 +1606,8 @@ libdm/Makefile
 libdm/libdevmapper.pc
 liblvm/Makefile
 liblvm/liblvm2app.pc
+liblvm/python/Makefile
+liblvm/python/setup.py
 man/Makefile
 po/Makefile
 scripts/clvmd_init_red_hat
diff --git a/liblvm/Makefile.in b/liblvm/Makefile.in
index 8ae4661..8941288 100644
--- a/liblvm/Makefile.in
+++ b/liblvm/Makefile.in
@@ -30,6 +30,10 @@ ifeq ("@STATIC_LINK@", "yes")
   LIB_STATIC = $(LIB_NAME).a
 endif
 
+ifeq ("@PYTHON_BINDINGS@", "yes")
+  SUBDIRS += python
+endif
+
 LIB_SHARED = $(LIB_NAME).$(LIB_SUFFIX)
 
 CLEAN_TARGETS += liblvm.cflow $(LIB_NAME).a
@@ -47,7 +51,7 @@ ifeq ("@DMEVENTD@", "yes")
   LIBS += -ldevmapper-event
 endif
 
-.PHONY: install_dynamic install_static install_include install_pkgconfig
+.PHONY: install_dynamic install_static install_include install_pkgconfig python
 
 INSTALL_TYPE = install_dynamic
 
diff --git a/liblvm/python/Makefile.in b/liblvm/python/Makefile.in
new file mode 100644
index 0000000..39a6753
--- /dev/null
+++ b/liblvm/python/Makefile.in
@@ -0,0 +1,30 @@
+#
+# Copyright (C) 2011-2012 Red Hat, Inc.
+#
+# This file is part of LVM2.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU Lesser General Public License v.2.1.
+#
+# You should have received a copy of the GNU Lesser General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+srcdir = @srcdir@
+top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
+
+SOURCES = liblvm.c
+
+python_bindings:
+	python setup.py build
+
+install_python_bindings:
+	python setup.py install --skip-build --root $(top_builddir)
+
+install_lvm2: install_python_bindings
+
+install: install_lvm2
+
+include $(top_builddir)/make.tmpl
diff --git a/liblvm/python/setup.py.in b/liblvm/python/setup.py.in
new file mode 100644
index 0000000..fb58ea7
--- /dev/null
+++ b/liblvm/python/setup.py.in
@@ -0,0 +1,17 @@
+from distutils.core import setup, Extension
+
+liblvm = Extension('lvm',
+                    sources = ['liblvm.c'],
+                    libraries= ['lvm2app'],
+                    library_dirs= ['@top_builddir@/liblvm'],
+                    include_dirs= ['@top_builddir@/include'])
+
+setup (name='lvm',
+       version=@LVM_VERSION@,
+       description='Python bindings for liblvm2',
+       license="LGPLv2+",
+       maintainer='LVM2 maintainers',
+       maintainer_email='linux-lvm at redhat.com',
+       url='http://sourceware.org/lvm2/',
+       ext_modules=[liblvm],
+)
-- 
1.7.1



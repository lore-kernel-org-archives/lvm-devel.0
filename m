From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 08 Jan 2010 15:53:17 +0100
Subject: [PATCH 3/4] Set env vars for tests to disable udev checking
Message-ID: <4B4746DD.4070102@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When configured with --enable-udev_sync, set env vars to disable udev checking for our tests
since they use their own location for nodes and symlinks.

Peter

diff --git a/configure.in b/configure.in
index 834fd6e..8db301c 100644
--- a/configure.in
+++ b/configure.in
@@ -1130,6 +1130,7 @@ AC_SUBST(SNAPSHOTS)
 AC_SUBST(STATICDIR)
 AC_SUBST(STATIC_LINK)
 AC_SUBST(UDEV_RULES)
+AC_SUBST(UDEV_SYNC)
 AC_SUBST([LIB_PTHREAD])
 AC_SUBST(interface)
 AC_SUBST(kerneldir)
diff --git a/test/Makefile.in b/test/Makefile.in
index 75366fd..6b7c76a 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -30,6 +30,11 @@ SHELL_PATH_SQ = $(subst ','\'',$(SHELL_PATH))
 
 T = $(wildcard $(srcdir)/t-*.sh)
 
+ifeq ("@UDEV_SYNC@", "yes")
+dm_udev_disable_checking = 1
+lvm_udev_disable_checking = 1
+endif
+
 ifeq ("@APPLIB@", "yes")
 T += $(srcdir)/lvm2app.sh
 all: api/vgtest
@@ -56,6 +61,8 @@ init.sh: $(srcdir)/Makefile.in $(srcdir)/test-utils.sh .bin-dir-stamp bin/not bi
 	echo 'abs_srcdir=$(abs_srcdir)' >> $@-t
 	echo 'abs_builddir=$(abs_builddir)' >> $@-t
 	echo 'export PATH' >> $@-t
+	echo 'export DM_UDEV_DISABLE_CHECKING=$(dm_udev_disable_checking)' >> $@-t
+	echo 'export LVM_UDEV_DISABLE_CHECKING=$(lvm_udev_disable_checking)' >> $@-t
 	chmod a-w $@-t
 	mv $@-t $@
 	if test "$(srcdir)" != "."; then cp $(srcdir)/test-utils.sh \



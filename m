From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 14 Sep 2022 13:16:50 +0000 (GMT)
Subject: master - configure: update
Message-ID: <20220914131650.21CF03858412@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a2d33cdfc516d946d390645cc694e745008b6fc0
Commit:        a2d33cdfc516d946d390645cc694e745008b6fc0
Parent:        bf386411b87047e37e394b3c46c336507c80bd68
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Sep 14 15:16:30 2022 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Sep 14 15:16:30 2022 +0200

configure: update

---
 configure              | 22 ++++++++++++++++++++++
 include/configure.h.in |  6 ++++--
 2 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/configure b/configure
index 2dbcf1c40..742012569 100755
--- a/configure
+++ b/configure
@@ -735,6 +735,7 @@ HAVE_VALGRIND
 HAVE_REALTIME
 HAVE_LIBDL
 BLKDEACTIVATE
+LVRESIZE_FS_HELPER_PATH
 FSADM_PATH
 FSADM
 ELDFLAGS
@@ -1012,6 +1013,7 @@ with_confdir
 with_staticdir
 with_usrlibdir
 with_usrsbindir
+with_libexecdir
 with_udev_prefix
 with_udevdir
 with_systemdsystemunitdir
@@ -1813,6 +1815,7 @@ Optional Packages:
   --with-staticdir=DIR    static binaries in DIR [EPREFIX/sbin]
   --with-usrlibdir=DIR    usrlib in DIR [PREFIX/lib]
   --with-usrsbindir=DIR   usrsbin executables in DIR [PREFIX/sbin]
+  --with-libexecdir=DIR   libexec executables in DIR [PREFIX/libexec]
   --with-udev-prefix=UPREFIX
                           install udev rule files in UPREFIX [EPREFIX]
   --with-udevdir=DIR      udev rules in DIR [UPREFIX/lib/udev/rules.d]
@@ -14652,6 +14655,16 @@ else $as_nop
 fi
 
 
+
+# Check whether --with-libexecdir was given.
+if test ${with_libexecdir+y}
+then :
+  withval=$with_libexecdir; libexecdir=$withval
+else $as_nop
+  libexecdir='${prefix}/libexec'
+fi
+
+
 ################################################################################
 
 # Check whether --with-udev_prefix was given.
@@ -15155,6 +15168,13 @@ LVMIMPORTVDO_PATH="$SBINDIR/lvm_import_vdo"
 printf "%s\n" "#define LVMIMPORTVDO_PATH \"$LVMIMPORTVDO_PATH\"" >>confdefs.h
 
 
+LIBEXECDIR="$(eval echo $(eval echo $libexecdir))"
+
+LVRESIZE_FS_HELPER_PATH="$LIBEXECDIR/lvresize_fs_helper"
+
+printf "%s\n" "#define LVRESIZE_FS_HELPER_PATH \"$LVRESIZE_FS_HELPER_PATH\"" >>confdefs.h
+
+
 ################################################################################
 if test "$BUILD_DMEVENTD" = yes; then
 
@@ -15474,6 +15494,8 @@ printf "%s\n" "#define LVM_CONFIGURE_LINE \"$CONFIGURE_LINE\"" >>confdefs.h
 
 
 
+
+
 
 
 
diff --git a/include/configure.h.in b/include/configure.h.in
index 584c2b4f1..e7abca2f1 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -127,9 +127,8 @@
 /* Define to 1 to include the LVM editline shell. */
 #undef EDITLINE_SUPPORT
 
-/* Paths to binaries. */
+/* Path to fsadm binary. */
 #undef FSADM_PATH
-#undef LVRESIZE_FS_HELPER_PATH
 
 /* Define to use GNU versioning in the shared library. */
 #undef GNU_SYMVER
@@ -599,6 +598,9 @@
 /* Path to lvm binary. */
 #undef LVM_PATH
 
+/* Path to lvresize_fs_helper script. */
+#undef LVRESIZE_FS_HELPER_PATH
+
 /* Define to 1 if `major', `minor', and `makedev' are declared in <mkdev.h>.
    */
 #undef MAJOR_IN_MKDEV


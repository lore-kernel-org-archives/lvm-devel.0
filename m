From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri,  9 Jul 2021 12:59:20 +0000 (GMT)
Subject: main - configure: updates
Message-ID: <20210709125920.3E8FA384BC11@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3a92d633a5a23377aa0d5d4ed5a01db8ca14cf69
Commit:        3a92d633a5a23377aa0d5d4ed5a01db8ca14cf69
Parent:        d5a06f9a7df5a43b2e2311db62ff8d3011217d74
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 9 14:42:26 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 9 14:57:59 2021 +0200

configure: updates

---
 configure              | 26 ++++++++++++++------------
 include/configure.h.in |  6 +++---
 2 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/configure b/configure
index e2299ee91..3a9888528 100755
--- a/configure
+++ b/configure
@@ -747,7 +747,6 @@ BUILD_DMFILEMAPD
 BUILD_LOCKDDLM_CONTROL
 BUILD_LOCKDDLM
 BUILD_LOCKDSANLOCK
-BUILD_LOCKDIDM
 BUILD_LVMLOCKD
 BUILD_LVMPOLLD
 BUILD_LVMDBUSD
@@ -773,18 +772,18 @@ UDEV_LIBS
 UDEV_CFLAGS
 SYSTEMD_LIBS
 SYSTEMD_CFLAGS
-BLKID_LIBS
-BLKID_CFLAGS
 NOTIFY_DBUS_LIBS
 NOTIFY_DBUS_CFLAGS
+BLKID_LIBS
+BLKID_CFLAGS
+LOCKD_IDM_LIBS
+LOCKD_IDM_CFLAGS
 LOCKD_DLM_CONTROL_LIBS
 LOCKD_DLM_CONTROL_CFLAGS
 LOCKD_DLM_LIBS
 LOCKD_DLM_CFLAGS
 LOCKD_SANLOCK_LIBS
 LOCKD_SANLOCK_CFLAGS
-LOCKD_IDM_LIBS
-LOCKD_IDM_CFLAGS
 VALGRIND_LIBS
 VALGRIND_CFLAGS
 GENPNG
@@ -1025,10 +1024,10 @@ LOCKD_DLM_CONTROL_CFLAGS
 LOCKD_DLM_CONTROL_LIBS
 LOCKD_IDM_CFLAGS
 LOCKD_IDM_LIBS
-NOTIFY_DBUS_CFLAGS
-NOTIFY_DBUS_LIBS
 BLKID_CFLAGS
 BLKID_LIBS
+NOTIFY_DBUS_CFLAGS
+NOTIFY_DBUS_LIBS
 SYSTEMD_CFLAGS
 SYSTEMD_LIBS
 UDEV_CFLAGS
@@ -1843,13 +1842,13 @@ Some influential environment variables:
               C compiler flags for LOCKD_IDM, overriding pkg-config
   LOCKD_IDM_LIBS
               linker flags for LOCKD_IDM, overriding pkg-config
+  BLKID_CFLAGS
+              C compiler flags for BLKID, overriding pkg-config
+  BLKID_LIBS  linker flags for BLKID, overriding pkg-config
   NOTIFY_DBUS_CFLAGS
               C compiler flags for NOTIFY_DBUS, overriding pkg-config
   NOTIFY_DBUS_LIBS
               linker flags for NOTIFY_DBUS, overriding pkg-config
-  BLKID_CFLAGS
-              C compiler flags for BLKID, overriding pkg-config
-  BLKID_LIBS  linker flags for BLKID, overriding pkg-config
   SYSTEMD_CFLAGS
               C compiler flags for SYSTEMD, overriding pkg-config
   SYSTEMD_LIBS
@@ -11260,7 +11259,7 @@ fi
 
 
 if test $pkg_failed = yes; then
-	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+   	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
 $as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
@@ -11278,7 +11277,7 @@ fi
 
 	$bailout
 elif test $pkg_failed = untried; then
-	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+     	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
 $as_echo "no" >&6; }
 	$bailout
 else
@@ -11286,6 +11285,7 @@ else
 	LOCKD_IDM_LIBS=$pkg_cv_LOCKD_IDM_LIBS
         { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
 $as_echo "yes" >&6; }
+	HAVE_LOCKD_IDM=yes
 fi
 
 pkg_failed=no
@@ -14350,6 +14350,8 @@ _ACEOF
 
 
 
+
+
 
 
 
diff --git a/include/configure.h.in b/include/configure.h.in
index bcb282660..08f696167 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -558,12 +558,12 @@
 /* Define to 1 to include code that uses lvmlockd dlm option. */
 #undef LOCKDDLM_SUPPORT
 
-/* Define to 1 to include code that uses lvmlockd sanlock option. */
-#undef LOCKDSANLOCK_SUPPORT
-
 /* Define to 1 to include code that uses lvmlockd IDM option. */
 #undef LOCKDIDM_SUPPORT
 
+/* Define to 1 to include code that uses lvmlockd sanlock option. */
+#undef LOCKDSANLOCK_SUPPORT
+
 /* Define to 1 if `lstat' dereferences a symlink specified with a trailing
    slash. */
 #undef LSTAT_FOLLOWS_SLASHED_SYMLINK



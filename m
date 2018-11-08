From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 8 Nov 2018 06:23:44 -0500
Subject: master - configure: update
Message-ID: <201811081123.wA8BNits013967@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3a557dcfbf42b9124ab17ba3dcd71b417aee9be1
Commit:        3a557dcfbf42b9124ab17ba3dcd71b417aee9be1
Parent:        6cee8f1b063dcf5d809e14de38ba489ce5b8f562
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 8 12:22:07 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 8 12:22:07 2018 +0100

configure: update

---
 configure              |   27 +++++++++++++++++++++++++++
 include/configure.h.in |    3 +++
 2 files changed, 30 insertions(+), 0 deletions(-)

diff --git a/configure b/configure
index d8f7384..496741f 100755
--- a/configure
+++ b/configure
@@ -915,6 +915,7 @@ with_cache_restore
 enable_cache_check_needs_check
 with_vdo
 with_vdo_format
+with_writecache
 enable_readline
 enable_realtime
 enable_ocf
@@ -1708,6 +1709,7 @@ Optional Packages:
                           cache_restore tool: [autodetect]
   --with-vdo=TYPE         vdo support: internal/none [internal]
   --with-vdo-format=PATH  vdoformat tool: [autodetect]
+  --with-writecache=TYPE  writecache support: internal/none [internal]
   --with-ocfdir=DIR       install OCF files in
                           [PREFIX/lib/ocf/resource.d/lvm2]
   --with-default-pid-dir=PID_DIR
@@ -9706,6 +9708,31 @@ _ACEOF
 #AC_MSG_RESULT($VDO_LIB)
 
 ################################################################################
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include writecache" >&5
+$as_echo_n "checking whether to include writecache... " >&6; }
+
+# Check whether --with-writecache was given.
+if test "${with_writecache+set}" = set; then :
+  withval=$with_writecache; WRITECACHE=$withval
+else
+  WRITECACHE="none"
+fi
+
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $WRITECACHE" >&5
+$as_echo "$WRITECACHE" >&6; }
+
+case "$WRITECACHE" in
+ none) ;;
+ internal)
+
+$as_echo "#define WRITECACHE_INTERNAL 1" >>confdefs.h
+
+	;;
+ *) as_fn_error $? "--with-writecache parameter invalid" "$LINENO" 5 ;;
+esac
+
+################################################################################
 # Check whether --enable-readline was given.
 if test "${enable_readline+set}" = set; then :
   enableval=$enable_readline; READLINE=$enableval
diff --git a/include/configure.h.in b/include/configure.h.in
index 3721844..19c1922 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -669,6 +669,9 @@
 /* Define to 1 to include built-in support for vdo. */
 #undef VDO_INTERNAL
 
+/* Define to 1 to include built-in support for writecache. */
+#undef WRITECACHE_INTERNAL
+
 /* Define for Solaris 2.5.1 so the uint32_t typedef from <sys/synch.h>,
    <pthread.h>, or <semaphore.h> is not used. If the typedef were allowed, the
    #define below would cause a syntax error. */



From: Milan Broz <mbroz@redhat.com>
Date: Mon, 19 Jan 2009 13:54:53 +0100
Subject: [PATCH] fix configure for static build
Message-ID: <4974781D.5060908@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I am still using static build for some testing,
but I think this should be fixed upstream too...

(and there are already tests in configure
for STATIC_LINK variable before it is defined)

Milan
--

commit 32dc3f7254811eb3068a541d6651e73adbb5da1a
Author: Milan Broz <mbroz@redhat.com>
Date:   Mon Jan 19 13:48:15 2009 +0100

    Fix problems with static build
    
     - compiler warning (missing header)
    
     - configure should set static flag early to be able
       use STATIC_LINK flag during configure script
    
    Signed-off-by: Milan Broz <mbroz@redhat.com>

diff --git a/configure b/configure
index 5d2ed22..8095090 100755
--- a/configure
+++ b/configure
@@ -1323,6 +1323,8 @@ if test -n "$ac_init_help"; then
 Optional Features:
   --disable-FEATURE       do not include FEATURE (same as --enable-FEATURE=no)
   --enable-FEATURE[=ARG]  include FEATURE [ARG=yes]
+  --enable-static_link    Use this to link the tools to their libraries
+                          statically.  Default is dynamic linking
   --enable-lvm1_fallback  Use this to fall back and use LVM1 binaries if
                           device-mapper is missing from the kernel
   --disable-readline      Disable readline support
@@ -1337,8 +1339,6 @@ Optional Features:
   --enable-pkgconfig      Install pkgconfig support
   --enable-fsadm          Enable fsadm
   --enable-dmeventd       Enable the device-mapper event daemon
-  --enable-static_link    Use this to link the tools to their libraries
-                          statically.  Default is dynamic linking
   --disable-selinux       Disable selinux support
   --enable-nls            Enable Native Language Support
 
@@ -8398,6 +8398,19 @@ done
 
 
 ################################################################################
+{ echo "$as_me:$LINENO: checking whether to use static linking" >&5
+echo $ECHO_N "checking whether to use static linking... $ECHO_C" >&6; }
+# Check whether --enable-static_link was given.
+if test "${enable_static_link+set}" = set; then
+  enableval=$enable_static_link; STATIC_LINK=$enableval
+else
+  STATIC_LINK=no
+fi
+
+{ echo "$as_me:$LINENO: result: $STATIC_LINK" >&5
+echo "${ECHO_T}$STATIC_LINK" >&6; }
+
+################################################################################
 
 
 ################################################################################
@@ -9308,19 +9321,6 @@ echo "$as_me: error: Features cannot be 'shared' when building statically
 fi
 
 ################################################################################
-{ echo "$as_me:$LINENO: checking whether to use static linking" >&5
-echo $ECHO_N "checking whether to use static linking... $ECHO_C" >&6; }
-# Check whether --enable-static_link was given.
-if test "${enable_static_link+set}" = set; then
-  enableval=$enable_static_link; STATIC_LINK=$enableval
-else
-  STATIC_LINK=no
-fi
-
-{ echo "$as_me:$LINENO: result: $STATIC_LINK" >&5
-echo "${ECHO_T}$STATIC_LINK" >&6; }
-
-################################################################################
 { echo "$as_me:$LINENO: checking whether to enable selinux support" >&5
 echo $ECHO_N "checking whether to enable selinux support... $ECHO_C" >&6; }
 # Check whether --enable-selinux was given.
@@ -10609,7 +10609,7 @@ if test "$ac_res" != no; then
   ac_cv_func_getmntent=yes
 
 cat >>confdefs.h <<\_ACEOF
-#define HAVE_GETMNTENT
+#define HAVE_GETMNTENT 1
 _ACEOF
 
 else
diff --git a/configure.in b/configure.in
index 0a05406..5d28c2c 100644
--- a/configure.in
+++ b/configure.in
@@ -129,6 +129,15 @@ AC_FUNC_STRTOD
 AC_FUNC_VPRINTF
 
 ################################################################################
+dnl -- Enables statically-linked tools
+AC_MSG_CHECKING(whether to use static linking)
+AC_ARG_ENABLE(static_link,
+  [  --enable-static_link    Use this to link the tools to their libraries
+                          statically.  Default is dynamic linking],
+  STATIC_LINK=$enableval, STATIC_LINK=no)
+AC_MSG_RESULT($STATIC_LINK)
+
+################################################################################
 dnl -- Prefix is /usr by default, the exec_prefix default is setup later
 AC_PREFIX_DEFAULT(/usr)
 
@@ -509,15 +518,6 @@ Features cannot be 'shared' when building statically
 fi
 
 ################################################################################
-dnl -- Enables statically-linked tools
-AC_MSG_CHECKING(whether to use static linking)
-AC_ARG_ENABLE(static_link,
-  [  --enable-static_link    Use this to link the tools to their libraries
-                          statically.  Default is dynamic linking],
-  STATIC_LINK=$enableval, STATIC_LINK=no)
-AC_MSG_RESULT($STATIC_LINK)
-
-################################################################################
 dnl -- Disable selinux
 AC_MSG_CHECKING(whether to enable selinux support)
 AC_ARG_ENABLE(selinux, [  --disable-selinux       Disable selinux support],
diff --git a/tools/lvm-static.c b/tools/lvm-static.c
index 822989f..f75930c 100644
--- a/tools/lvm-static.c
+++ b/tools/lvm-static.c
@@ -14,6 +14,7 @@
  */
 
 #include "lvm2cmdline.h"
+#include "lib.h"
 
 int main(int argc, char **argv)
 {




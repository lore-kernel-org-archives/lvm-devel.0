From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  9 Oct 2012 23:49:10 +0000 (UTC)
Subject: master - configure: Use pkg-config to look for valgrind/memcheck.h.
Message-ID: <20121009234910.D789A246B@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d760669e80f029a4d507e91ad431431b627f5555
Commit:        d760669e80f029a4d507e91ad431431b627f5555
Parent:        19971492632fb2273bb2a991858e5cd5b48e2c5d
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Oct 9 20:54:41 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Oct 9 20:54:41 2012 +0200

configure: Use pkg-config to look for valgrind/memcheck.h.

---
 configure.in          |    4 +++-
 libdm/Makefile.in     |    3 +++
 libdm/mm/dbg_malloc.c |    2 +-
 libdm/mm/pool-fast.c  |    2 +-
 4 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/configure.in b/configure.in
index 2bdffca..16f91fb 100644
--- a/configure.in
+++ b/configure.in
@@ -871,8 +871,10 @@ AC_ARG_ENABLE(valgrind_pool,
 AC_MSG_RESULT($VALGRIND_POOL)
 
 if test "$VALGRIND_POOL" = yes; then
-    AC_CHECK_HEADERS([valgrind/memcheck.h], , [AC_MSG_ERROR(bailing out)])
+    PKG_CHECK_MODULES(VALGRIND, valgrind, [], [AC_MSG_ERROR(bailing out)])
     AC_DEFINE([VALGRIND_POOL], 1, [Enable a valgrind aware build of pool])
+    AC_SUBST(VALGRIND_POOL)
+    AC_SUBST(VALGRIND_CFLAGS)
 fi
 
 ################################################################################
diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index b4f137a..bddb0a0 100644
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -34,6 +34,9 @@ SOURCES =\
 	$(interface)/libdm-iface.c
 
 INCLUDES = -I$(srcdir)/$(interface) -I$(srcdir)
+ifeq ("@VALGRIND_POOL@", "yes")
+INCLUDES += @VALGRIND_CFLAGS@
+endif
 
 ifeq ("@STATIC_LINK@", "yes")
 LIB_STATIC = $(interface)/libdevmapper.a
diff --git a/libdm/mm/dbg_malloc.c b/libdm/mm/dbg_malloc.c
index fe8f5a9..d37083f 100644
--- a/libdm/mm/dbg_malloc.c
+++ b/libdm/mm/dbg_malloc.c
@@ -16,7 +16,7 @@
 #include "dmlib.h"
 
 #ifdef VALGRIND_POOL
-#include "valgrind/memcheck.h"
+#include "memcheck.h"
 #endif
 
 #include <assert.h>
diff --git a/libdm/mm/pool-fast.c b/libdm/mm/pool-fast.c
index d54527a..61e076a 100644
--- a/libdm/mm/pool-fast.c
+++ b/libdm/mm/pool-fast.c
@@ -14,7 +14,7 @@
  */
 
 #ifdef VALGRIND_POOL
-#include "valgrind/memcheck.h"
+#include "memcheck.h"
 #endif
 
 #include "dmlib.h"



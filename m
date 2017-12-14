From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 14 Dec 2017 10:53:28 -0500
Subject: master - lvm2app: Suppress deprecation warnings for our builds
Message-ID: <201712141553.vBEFrSIQ011451@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=83e1a0bad836f8950cb1e38924bf2600f118861e
Commit:        83e1a0bad836f8950cb1e38924bf2600f118861e
Parent:        c957d46f1d73891e3a7e9c1482c1d4a39ca0e79a
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Dec 14 13:49:33 2017 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Dec 14 16:45:53 2017 +0100

lvm2app: Suppress deprecation warnings for our builds

---
 liblvm/lvm2app.h |    2 ++
 make.tmpl.in     |    2 ++
 python/liblvm.c  |    1 +
 3 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index f64262d..10ecd2e 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -18,7 +18,9 @@
 
 #include <stdint.h>
 
+#ifndef _BUILDING_LVM
 #warning "liblvm2app is deprecated, use D-Bus API instead."
+#endif
 
 #ifdef __cplusplus
 extern "C" {
diff --git a/make.tmpl.in b/make.tmpl.in
index 65362d8..bdf2349 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -261,6 +261,8 @@ endif
 # end of fPIC protection
 endif
 
+DEFS += -D_BUILDING_LVM
+
 LDFLAGS += -L$(top_builddir)/libdm -L$(top_builddir)/lib
 CLDFLAGS += -L$(top_builddir)/libdm -L$(top_builddir)/lib
 
diff --git a/python/liblvm.c b/python/liblvm.c
index 6d67b8b..06120e6 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -22,6 +22,7 @@
  */
 
 #include <Python.h>
+#define _BUILDING_LVM
 #include "lvm2app.h"
 #include "defaults.h"
 



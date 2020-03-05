From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 5 Mar 2020 11:39:43 -0500
Subject: master - container_of: use offsetof from stddef
Message-ID: <202003051639.025Gdhkq023941@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f439716b7583556352f1b7a6696ada32f52e44b4
Commit:        f439716b7583556352f1b7a6696ada32f52e44b4
Parent:        b3fa71fbd8e583c040c04e655f3ebe70a3d941b2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 5 12:58:34 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 5 17:38:55 2020 +0100

container_of:  use offsetof from stddef

Use standardized offsetof() macro from stddef.
Helps to build valid code with latest gcc10 with -O2.
---
 base/memory/container_of.h | 6 ++++--
 lib/device/bcache.h        | 9 +--------
 2 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/base/memory/container_of.h b/base/memory/container_of.h
index 4e4c662..ddb7959 100644
--- a/base/memory/container_of.h
+++ b/base/memory/container_of.h
@@ -1,4 +1,4 @@
-// Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+// Copyright (C) 2018 - 2020 Red Hat, Inc. All rights reserved.
 // 
 // This file is part of LVM2.
 //
@@ -13,10 +13,12 @@
 #ifndef BASE_MEMORY_CONTAINER_OF_H
 #define BASE_MEMORY_CONTAINER_OF_H
 
+#include <stddef.h>  // offsetof
+
 //----------------------------------------------------------------
 
 #define container_of(v, t, head) \
-    ((t *)((const char *)(v) - (const char *)&((t *) 0)->head))
+    ((t *)((const char *)(v) - offsetof(t, head)))
 
 //----------------------------------------------------------------
 
diff --git a/lib/device/bcache.h b/lib/device/bcache.h
index 4ef044c..2950afa 100644
--- a/lib/device/bcache.h
+++ b/lib/device/bcache.h
@@ -16,19 +16,12 @@
 #define BCACHE_H
 
 #include "device_mapper/all.h"
+#include "base/memory/container_of.h"
 
 #include <linux/fs.h>
 #include <stdint.h>
 #include <stdbool.h>
 
-/*----------------------------------------------------------------*/
-
-// FIXME: move somewhere more sensible
-#define container_of(v, t, head) \
-    ((t *)((const char *)(v) - (const char *)&((t *) 0)->head))
-
-/*----------------------------------------------------------------*/
-
 enum dir {
 	DIR_READ,
 	DIR_WRITE




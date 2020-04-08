From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  8 Apr 2020 13:36:27 +0000 (GMT)
Subject: stable-2.02 - container_of: use offsetof from stddef
Message-ID: <20200408133627.073F1385BF81@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5f766b32cf0d88644232a43a59247476a16fbc9c
Commit:        5f766b32cf0d88644232a43a59247476a16fbc9c
Parent:        5d93892d4ae67b355ab6b418c0c404e1536d055f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 5 12:58:34 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 8 15:22:54 2020 +0200

container_of:  use offsetof from stddef

Use standardized offsetof() macro from stddef.
Helps to build valid code with latest gcc10 with -O2.
---
 base/memory/container_of.h | 6 ++++--
 lib/device/bcache.h        | 2 +-
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/base/memory/container_of.h b/base/memory/container_of.h
index 4e4c662bf..ddb795935 100644
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
index f9067f70c..c5e6da1ad 100644
--- a/lib/device/bcache.h
+++ b/lib/device/bcache.h
@@ -25,7 +25,7 @@
 
 // FIXME: move somewhere more sensible
 #define container_of(v, t, head) \
-    ((t *)((const char *)(v) - (const char *)&((t *) 0)->head))
+    ((t *)((const char *)(v) - offsetof(t, head)))
 
 /*----------------------------------------------------------------*/
 




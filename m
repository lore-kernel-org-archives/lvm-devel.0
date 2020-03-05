From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 5 Mar 2020 11:39:35 -0500
Subject: master - libdm: fix dm_list pointer arithmentic for new gcc 10 optimization
Message-ID: <202003051639.025GdZ0T023909@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b3fa71fbd8e583c040c04e655f3ebe70a3d941b2
Commit:        b3fa71fbd8e583c040c04e655f3ebe70a3d941b2
Parent:        212cf8efbdc1c67f8ea85c951873b0fc3249eb07
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 4 16:07:22 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 5 17:38:55 2020 +0100

libdm: fix dm_list pointer arithmentic for new gcc 10 optimization

---
 base/data-struct/list.h | 6 ++++--
 libdm/libdevmapper.h    | 5 +++--
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/base/data-struct/list.h b/base/data-struct/list.h
index 1a107d1..54cb1c1 100644
--- a/base/data-struct/list.h
+++ b/base/data-struct/list.h
@@ -1,6 +1,8 @@
 #ifndef BASE_DATA_STRUCT_LIST_H
 #define BASE_DATA_STRUCT_LIST_H
 
+#include <stddef.h> /* offsetof */
+
 //----------------------------------------------------------------
 
 /*
@@ -98,7 +100,7 @@ struct dm_list *dm_list_next(const struct dm_list *head, const struct dm_list *e
  * contained in a structure of type t, return the containing structure.
  */
 #define dm_list_struct_base(v, t, head) \
-    ((t *)((const char *)(v) - (const char *)&((t *) 0)->head))
+    ((t *)((const char *)(v) - offsetof(t, head)))
 
 /*
  * Given the address v of an instance of 'struct dm_list list' contained in
@@ -111,7 +113,7 @@ struct dm_list *dm_list_next(const struct dm_list *head, const struct dm_list *e
  * return another element f.
  */
 #define dm_struct_field(v, t, e, f) \
-    (((t *)((uintptr_t)(v) - (uintptr_t)&((t *) 0)->e))->f)
+    (((t *)((uintptr_t)(v) - offsetof(t, e)))->f)
 
 /*
  * Given the address v of a known element e in a known structure of type t,
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 18fe9f9..03a43eb 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -30,6 +30,7 @@
 #include <string.h>
 #include <stdlib.h>
 #include <stdio.h>
+#include <stddef.h> /* offsetof */
 
 #ifndef __GNUC__
 # define __typeof__ typeof
@@ -2470,7 +2471,7 @@ struct dm_list *dm_list_next(const struct dm_list *head, const struct dm_list *e
  * contained in a structure of type t, return the containing structure.
  */
 #define dm_list_struct_base(v, t, head) \
-    ((t *)((const char *)(v) - (const char *)&((t *) 0)->head))
+    ((t *)((const char *)(v) - offsetof(t, head)))
 
 /*
  * Given the address v of an instance of 'struct dm_list list' contained in
@@ -2483,7 +2484,7 @@ struct dm_list *dm_list_next(const struct dm_list *head, const struct dm_list *e
  * return another element f.
  */
 #define dm_struct_field(v, t, e, f) \
-    (((t *)((uintptr_t)(v) - (uintptr_t)&((t *) 0)->e))->f)
+    (((t *)((uintptr_t)(v) - offsetof(t, e))->f)
 
 /*
  * Given the address v of a known element e in a known structure of type t,




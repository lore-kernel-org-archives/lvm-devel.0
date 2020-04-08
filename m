From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  8 Apr 2020 13:36:24 +0000 (GMT)
Subject: stable-2.02 - libdm: fix dm_list pointer arithmentic for new gcc 10 optimization
Message-ID: <20200408133624.B52C2385BF81@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8f3d2d5e11305b5f3fc7ced7bd2f81412c9e7d93
Commit:        8f3d2d5e11305b5f3fc7ced7bd2f81412c9e7d93
Parent:        2e3791b421a773b637705a3ca7a2ffc4efc8c873
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 4 16:07:22 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 8 15:22:54 2020 +0200

libdm: fix dm_list pointer arithmentic for new gcc 10 optimization

---
 libdm/libdevmapper.h | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 18fe9f9fd..03a43eb45 100644
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




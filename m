From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 20 May 2020 14:03:23 +0000 (GMT)
Subject: master - list: use container_of
Message-ID: <20200520140323.63B37395CC4E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=deb51601818ec9d2f9a29205896125c82cf6ce00
Commit:        deb51601818ec9d2f9a29205896125c82cf6ce00
Parent:        16da6651a1eebd776aa461db76cecaf3997cbf50
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 15 14:41:23 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 20 16:01:20 2020 +0200

list:  use container_of

Reuse macro
---
 base/data-struct/list.h              | 4 ++--
 daemons/lvmlockd/lvmlockd-internal.h | 6 ++----
 2 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/base/data-struct/list.h b/base/data-struct/list.h
index 54cb1c10b..e0a6256a4 100644
--- a/base/data-struct/list.h
+++ b/base/data-struct/list.h
@@ -1,7 +1,7 @@
 #ifndef BASE_DATA_STRUCT_LIST_H
 #define BASE_DATA_STRUCT_LIST_H
 
-#include <stddef.h> /* offsetof */
+#include "base/memory/container_of.h"
 
 //----------------------------------------------------------------
 
@@ -100,7 +100,7 @@ struct dm_list *dm_list_next(const struct dm_list *head, const struct dm_list *e
  * contained in a structure of type t, return the containing structure.
  */
 #define dm_list_struct_base(v, t, head) \
-    ((t *)((const char *)(v) - offsetof(t, head)))
+    container_of(v, t, head)
 
 /*
  * Given the address v of an instance of 'struct dm_list list' contained in
diff --git a/daemons/lvmlockd/lvmlockd-internal.h b/daemons/lvmlockd/lvmlockd-internal.h
index 04100c0c1..191c44926 100644
--- a/daemons/lvmlockd/lvmlockd-internal.h
+++ b/daemons/lvmlockd/lvmlockd-internal.h
@@ -11,6 +11,8 @@
 #ifndef _LVM_LVMLOCKD_INTERNAL_H
 #define _LVM_LVMLOCKD_INTERNAL_H
 
+#include "base/memory/container_of.h"
+
 #define MAX_NAME 64
 #define MAX_ARGS 64
 
@@ -217,10 +219,6 @@ struct val_blk {
 /* lm_unlock flags */
 #define LMUF_FREE_VG 0x00000001
 
-#define container_of(ptr, type, member) ({                      \
-	const typeof( ((type *)0)->member ) *__mptr = (ptr);    \
-	(type *)( (char *)__mptr - offsetof(type,member) );})
-
 static inline void INIT_LIST_HEAD(struct list_head *list)
 {
 	list->next = list;



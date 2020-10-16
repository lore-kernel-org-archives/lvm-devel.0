From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:10:42 +0000 (GMT)
Subject: stable-2.02 - container_of: drop needless const converion
Message-ID: <20201016191042.8C2FE396EC06@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=950a9bbde9b1b70848c8bb92f77be2c9ccbe1fec
Commit:        950a9bbde9b1b70848c8bb92f77be2c9ccbe1fec
Parent:        c4202bf458751fcb646aa411fa32cd0f91a72ce3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 28 18:26:07 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 16:02:05 2020 +0200

container_of: drop needless const converion

---
 base/memory/container_of.h | 2 +-
 libdm/libdevmapper.h       | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/base/memory/container_of.h b/base/memory/container_of.h
index ddb795935..faf167964 100644
--- a/base/memory/container_of.h
+++ b/base/memory/container_of.h
@@ -18,7 +18,7 @@
 //----------------------------------------------------------------
 
 #define container_of(v, t, head) \
-    ((t *)((const char *)(v) - offsetof(t, head)))
+    ((t *)((char *)(v) - offsetof(t, head)))
 
 //----------------------------------------------------------------
 
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 03a43eb45..e9b140563 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -2471,7 +2471,7 @@ struct dm_list *dm_list_next(const struct dm_list *head, const struct dm_list *e
  * contained in a structure of type t, return the containing structure.
  */
 #define dm_list_struct_base(v, t, head) \
-    ((t *)((const char *)(v) - offsetof(t, head)))
+    ((t *)((char *)(v) - offsetof(t, head)))
 
 /*
  * Given the address v of an instance of 'struct dm_list list' contained in



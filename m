From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 28 Aug 2020 19:59:08 +0000 (GMT)
Subject: master - container_of: drop needless const converion
Message-ID: <20200828195908.80607383E82A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fb7a3fe8d652592c41e149702efd101cc2954fed
Commit:        fb7a3fe8d652592c41e149702efd101cc2954fed
Parent:        ca54afd70166b1aece6e3893e6649e67731336aa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 28 18:26:07 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 28 21:43:02 2020 +0200

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



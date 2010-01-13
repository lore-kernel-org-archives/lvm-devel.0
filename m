From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 13 Jan 2010 14:35:55 +0100
Subject: [PATCH 4/6] Cleanup compiler pointer cast warning
In-Reply-To: <cover.1263389392.git.zkabelac@redhat.com>
References: <cover.1263389392.git.zkabelac@redhat.com>
Message-ID: <4ebf8824b6fcb8281be105a4fa1559077617e50f.1263389392.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Cleanup gcc warning: cast from function call of type 'struct dm_list *'
to non-matching type 'long unsigned int'

Casting pointer to long and back to pointer could be easily
handled with just pointer arithmetic.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/libdevmapper.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index d4c02ca..579cc14 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -754,7 +754,7 @@ struct dm_list *dm_list_next(const struct dm_list *head, const struct dm_list *e
  * contained in a structure of type t, return the containing structure.
  */
 #define dm_list_struct_base(v, t, head) \
-    ((t *)((uintptr_t)(v) - (uintptr_t)&((t *) 0)->head))
+    ((t *)((char*)(v) - (char*)&((t *) 0)->head))
 
 /*
  * Given the address v of an instance of 'struct dm_list list' contained in
-- 
1.6.6



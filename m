From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 16 Dec 2010 11:36:15 +0100
Subject: [PATCH 07/20] Use const char * arithmetic for offset calculation
In-Reply-To: <cover.1292495195.git.zkabelac@redhat.com>
References: <cover.1292495195.git.zkabelac@redhat.com>
Message-ID: <c1db7b8c83649a8b9e7abdf6d92e4662f22c6d7a.1292495195.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

As 'const' types are also passed to this macro - lets keep
offset calculation with const char *. Cleans several gcc
constness warnings.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/libdevmapper.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index d385030..4aa9991 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -814,7 +814,7 @@ struct dm_list *dm_list_next(const struct dm_list *head, const struct dm_list *e
  * contained in a structure of type t, return the containing structure.
  */
 #define dm_list_struct_base(v, t, head) \
-    ((t *)((char*)(v) - (char*)&((t *) 0)->head))
+    ((t *)((const char *)(v) - (const char *)&((t *) 0)->head))
 
 /*
  * Given the address v of an instance of 'struct dm_list list' contained in
-- 
1.7.3.3



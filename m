From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:47:07 -0400
Subject: master - [device/bcache] fix bug in _alloc_block
Message-ID: <201804231347.w3NDl7bU031188@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=19647d1cd44d029a8aa2f7e74dbdbd1f114a8c08
Commit:        19647d1cd44d029a8aa2f7e74dbdbd1f114a8c08
Parent:        1563b936911d26c665b590f200884c9ed31ab7c3
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri Feb 2 14:34:45 2018 +0000
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:12:50 2018 -0500

[device/bcache] fix bug in _alloc_block

---
 lib/device/bcache.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 4283ce5..e5d0e1b 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -449,8 +449,10 @@ static void _exit_free_list(struct bcache *cache)
 
 static struct block *_alloc_block(struct bcache *cache)
 {
-	struct block *b = dm_list_struct_base(_list_pop(&cache->free), struct block, list);
-	return b;
+	if (dm_list_empty(&cache->free))
+		return NULL;
+
+	return dm_list_struct_base(_list_pop(&cache->free), struct block, list);
 }
 
 /*----------------------------------------------------------------



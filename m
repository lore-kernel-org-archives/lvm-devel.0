From: Milan Broz <mbroz@redhat.com>
Date: Sun, 20 Dec 2009 16:32:56 +0100
Subject: [PATCH] Invalidate devices in cache after precommited metadata was wiped.
Message-ID: <1261323176-13839-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The only place when vginfo->precommited is set is during
metadata store in cache.

It means that if we store precommited metadata in cache,
then call drop_cached_metadata without subsequent storing
commited metadata, cache is not invalidated on drop cache call.

If there is no cached metadata, invalidate device info always.

This is real fix for bug 547842.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/cache/lvmcache.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 358cd80..fa6daee 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -173,7 +173,7 @@ static void _drop_metadata(const char *vgname)
 	 * and we must not do it again.
 	 */
 
-	if (!vginfo->precommitted)
+	if (!vginfo->precommitted || !vginfo->vgmetadata)
 		dm_list_iterate_items(info, &vginfo->infos)
 			info->status |= CACHE_INVALID;
 
-- 
1.6.5.7



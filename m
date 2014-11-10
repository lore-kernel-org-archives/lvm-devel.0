From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Nov 2014 21:06:36 +0000 (UTC)
Subject: master - cache: _corig has UUID suffix
Message-ID: <20141110210636.3FD1560FA4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f6932bfcf91cd317629d9c04007a495f2c05ae26
Commit:        f6932bfcf91cd317629d9c04007a495f2c05ae26
Parent:        6effcb16fcc912bdca250b45442b783ebe75c481
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 4 23:19:34 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 10 22:05:49 2014 +0100

cache: _corig has UUID suffix

Use -real suffix for cache origin device.
---
 lib/misc/lvm-string.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index ae4adbe..0101af9 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -187,7 +187,8 @@ char *build_dm_uuid(struct dm_pool *mem, const struct logical_volume *lv,
 		 * Should also make internal detection simpler.
 		 */
 		/* Suffixes used here MUST match lib/activate/dev_manager.c */
-		layer = lv_is_cache_pool_data(lv) ? "cdata" :
+		layer = lv_is_cache_origin(lv) ? "real" :
+			lv_is_cache_pool_data(lv) ? "cdata" :
 			lv_is_cache_pool_metadata(lv) ? "cmeta" :
 			// FIXME: dm-tree needs fixes for mirrors/raids
 			//lv_is_mirror_image(lv) ? "mimage" :



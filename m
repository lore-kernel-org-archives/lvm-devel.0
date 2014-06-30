From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 30 Jun 2014 13:00:34 +0000 (UTC)
Subject: master - uuid: revert uuids for mirrors and raids
Message-ID: <20140630130034.129976036B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=70551eec5921e3b8bce7318880e54836f467b5fa
Commit:        70551eec5921e3b8bce7318880e54836f467b5fa
Parent:        13fb02ff1fe5ebc47f315774eac8a31e1b150550
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 30 14:04:25 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 30 14:58:30 2014 +0200

uuid: revert uuids for mirrors and raids

Using suffixes for mirrors and raids will need more work,
before this could be enabled.

Meanwhile revert to previous behavior.

Keep suffixes for thins and caches.
---
 lib/misc/lvm-string.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index 79357f2..5858638 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -182,15 +182,16 @@ char *build_dm_uuid(struct dm_pool *mem, const struct logical_volume *lv,
 		/*
 		 * Mark internal LVs with layer suffix
 		 * so tools like blkid may immeditelly see it's
-		 * an internal LV they should not scan
-                 * Should also make internal detection simpler
+		 * an internal LV they should not scan.
+		 * Should also make internal detection simpler.
 		 */
 		layer = lv_is_cache_pool_data(lv) ? "cdata" :
 			lv_is_cache_pool_metadata(lv) ? "cmeta" :
-			lv_is_mirror_image(lv) ? "mimage" :
-			lv_is_mirror_log(lv) ? "mlog" :
-			lv_is_raid_image(lv) ? "rimage" :
-			lv_is_raid_metadata(lv) ? "rmeta" :
+			// FIXME: dm-tree needs fixes for mirrors/raids
+			//lv_is_mirror_image(lv) ? "mimage" :
+			//lv_is_mirror_log(lv) ? "mlog" :
+			//lv_is_raid_image(lv) ? "rimage" :
+			//lv_is_raid_metadata(lv) ? "rmeta" :
 			lv_is_thin_pool(lv) ? "pool" :
 			lv_is_thin_pool_data(lv) ? "tdata" :
 			lv_is_thin_pool_metadata(lv) ? "tmeta" :



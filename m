From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 30 Jun 2014 10:25:21 +0000 (UTC)
Subject: master - uuid: add more private uuid sufixes
Message-ID: <20140630102521.B8947611C9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=667f93b7d95d23a45cc5040043c9117de83f7336
Commit:        667f93b7d95d23a45cc5040043c9117de83f7336
Parent:        2ada6852162c2dc2ee0f92220c29fe5f0959f510
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 27 00:03:31 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 30 12:17:07 2014 +0200

uuid: add more private uuid sufixes

Use suffixes for easier detection of private volumes.

This commit makes older volume UUIDs incompatible and
it most probably needs machine reboot after upgrade.
---
 WHATS_NEW             |    1 +
 lib/misc/lvm-string.c |   20 ++++++++++++++++++--
 2 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 838eb41..4fa881c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.108 -
 =================================
+  Enhance private volumes UUIDs with suffixed for easier detection.
   Do not use reserved _[tc]meta volumes for temporary LVs.
   Leave backup pool metadata with _meta%d suffix instead of reserved _tmeta%d.
   Allow RAID repair to reuse PVs from same image that suffered a failure.
diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index be6298b..79357f2 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -178,8 +178,24 @@ char *build_dm_uuid(struct dm_pool *mem, const struct logical_volume *lv,
 {
 	const char *lvid = lv->lvid.s;
 
-	if (!layer && lv_is_thin_pool(lv))
-		layer = "pool";
+	if (!layer) {
+		/*
+		 * Mark internal LVs with layer suffix
+		 * so tools like blkid may immeditelly see it's
+		 * an internal LV they should not scan
+                 * Should also make internal detection simpler
+		 */
+		layer = lv_is_cache_pool_data(lv) ? "cdata" :
+			lv_is_cache_pool_metadata(lv) ? "cmeta" :
+			lv_is_mirror_image(lv) ? "mimage" :
+			lv_is_mirror_log(lv) ? "mlog" :
+			lv_is_raid_image(lv) ? "rimage" :
+			lv_is_raid_metadata(lv) ? "rmeta" :
+			lv_is_thin_pool(lv) ? "pool" :
+			lv_is_thin_pool_data(lv) ? "tdata" :
+			lv_is_thin_pool_metadata(lv) ? "tmeta" :
+			NULL;
+	}
 
 	return dm_build_dm_uuid(mem, UUID_PREFIX, lvid, layer);
 }



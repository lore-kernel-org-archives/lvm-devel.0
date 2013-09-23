From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 23 Sep 2013 10:16:11 +0000 (UTC)
Subject: master - cleanup: skip call of detect...
Message-ID: <20130923101611.3E0A060212@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=30432bd6048ce9c52eefeba9e99d1b0805c6c59b
Commit:        30432bd6048ce9c52eefeba9e99d1b0805c6c59b
Parent:        861a3b2f1940cd3667cc353c762ff3d1ef75c37b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 20 15:52:25 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 23 11:35:15 2013 +0200

cleanup: skip call of detect...

SInce we know the pool was locked and we want to reloc pool again,
just use '1' directly.
---
 lib/metadata/metadata.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 4ae7726..1e34f83 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -850,7 +850,7 @@ static int _vg_update_vg_ondisk(struct volume_group *vg)
 	dm_config_destroy(cft);
 
 	/* recompute the pool crc */
-	if (pool_locked && !dm_pool_lock(vg->vgmem, detect_internal_vg_cache_corruption()))
+	if (pool_locked && !dm_pool_lock(vg->vgmem, 1))
 		return_0;
 
 	return vg->vg_ondisk ? 1 : 0;



From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  5 Jul 2013 15:21:22 +0000 (UTC)
Subject: master - cleanup: move declaration to front
Message-ID: <20130705152122.AAD3B60CF9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7319bc04207ece28fa22224878ad6a3a0aacdbfa
Commit:        7319bc04207ece28fa22224878ad6a3a0aacdbfa
Parent:        21bc118d4db22259d45aef32aa77f78621ddf8c1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 5 13:19:33 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 5 17:20:57 2013 +0200

cleanup: move declaration to front

---
 lib/metadata/metadata.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 2d3f5ec..deb967c 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -833,10 +833,12 @@ int vgcreate_params_validate(struct cmd_context *cmd,
 static int _vg_update_vg_ondisk(struct volume_group *vg)
 {
 	struct dm_config_tree *cft;
+	int pool_locked;
+
 	if (vg->vg_ondisk) /* we already have it */
 		return 1;
 
-	int pool_locked = dm_pool_locked(vg->vgmem);
+	pool_locked = dm_pool_locked(vg->vgmem);
 	if (pool_locked && !dm_pool_unlock(vg->vgmem, 0))
 		return_0;
 



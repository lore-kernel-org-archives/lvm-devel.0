From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 23 Feb 2011 14:52:17 +0100
Subject: [PATCH 3/3] Destroy 'fic' memory in error path
In-Reply-To: <cover.1298466569.git.zkabelac@redhat.com>
References: <cover.1298466569.git.zkabelac@redhat.com>
Message-ID: <2a970eeba07b551a68f7abab7bbf2acd2e4c61c8.1298466569.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

As now FIC allocates hash table - we need to properly
destroy fid on error path.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/cache/lvmcache.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 7c53b14..3ce39f9 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -674,11 +674,13 @@ struct volume_group *lvmcache_get_vg(const char *vgid, int consistent, unsigned
 		    !(vginfo->cft =
 		      create_config_tree_from_string(fid->fmt->cmd,
 						     vginfo->vgmetadata))) {
+			fid->fmt->ops->destroy_instance(fid);
 			_free_cached_vgmetadata(vginfo);
 			return_NULL;
 		}
 
 		if (!(vg = import_vg_from_config_tree(vginfo->cft, fid))) {
+			fid->fmt->ops->destroy_instance(fid);
 			_free_cached_vgmetadata(vginfo);
 			return_NULL;
 		}
-- 
1.7.4.1



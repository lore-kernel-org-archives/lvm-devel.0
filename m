From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  7 Jan 2011 12:17:32 +0100
Subject: [PATCH 4/8] Cache config_tree
In-Reply-To: <cover.1294398815.git.zkabelac@redhat.com>
References: <cover.1294398815.git.zkabelac@redhat.com>
Message-ID: <f7ec0ff6e7489785adc0039602d1791857876aee.1294398815.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Start to use config_tree for cache just like vgmetedata.
When vgmetadata are erased - destroy its config tree.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/cache/lvmcache.c |   12 +++++++++---
 lib/cache/lvmcache.h |    1 +
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index ebd6d44..0e9cae1 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -83,6 +83,12 @@ static void _free_cached_vgmetadata(struct lvmcache_vginfo *vginfo)
 
 	vginfo->vgmetadata = NULL;
 
+	/* Release also cached config tree */
+	if (vginfo->cft) {
+		destroy_config_tree(vginfo->cft);
+		vginfo->cft = NULL;
+	}
+
 	log_debug("Metadata cache: VG %s wiped.", vginfo->vgname);
 }
 
@@ -651,7 +657,9 @@ struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted)
 						      vgid, NULL)))
 		return_NULL;
 
-	if (!(vginfo->cft =
+	/* Build config tree from vgmetadata, if not yet cached */
+	if (!vginfo->cft &&
+	    !(vginfo->cft =
 	      create_config_tree_from_string(fid->fmt->cmd,
 					     vginfo->vgmetadata))) {
 		_free_cached_vgmetadata(vginfo);
@@ -660,10 +668,8 @@ struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted)
 
 	if (!(vg = import_vg_from_config_tree(vginfo->cft, fid))) {
 		_free_cached_vgmetadata(vginfo);
-		destroy_config_tree(vginfo->cft);
 		return_NULL;
 	}
-	destroy_config_tree(vginfo->cft);
 
 	log_debug("Using cached %smetadata for VG %s.",
 		  vginfo->precommitted ? "pre-committed" : "", vginfo->vgname);
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 8c07a26..080f3b5 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -48,6 +48,7 @@ struct lvmcache_vginfo {
 	char *creation_host;
 	char *vgmetadata;	/* Copy of VG metadata as format_text string */
 	struct config_tree *cft; /* Config tree created from vgmetadata */
+				/* Lifetime is directly tied to vgmetadata */
 	unsigned precommitted;	/* Is vgmetadata live or precommitted? */
 };
 
-- 
1.7.3.4



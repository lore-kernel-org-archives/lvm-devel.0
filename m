From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 28 Jul 2010 11:15:55 +0200
Subject: [PATCH 09/14] Fix constness warning
In-Reply-To: <cover.1280307502.git.zkabelac@redhat.com>
References: <cover.1280307502.git.zkabelac@redhat.com>
Message-ID: <de61707830860a325f8f6a5326df0648d8df436d.1280307502.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Don't use const char* when it doesn't bring anything useful.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/dev_manager.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 7de341e..9b27616 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -220,7 +220,7 @@ int dev_manager_info(struct dm_pool *mem, const struct logical_volume *lv,
 		     int with_open_count, int with_read_ahead,
 		     struct dm_info *info, uint32_t *read_ahead)
 {
-	const char *dlid, *name;
+	char *dlid, *name;
 	int r;
 
 	if (!(name = build_dm_name(mem, lv->vg->name, lv->name, NULL))) {
@@ -236,7 +236,7 @@ int dev_manager_info(struct dm_pool *mem, const struct logical_volume *lv,
 	log_debug("Getting device info for %s [%s]", name, dlid);
 	r = _info(dlid, with_open_count, with_read_ahead, info, read_ahead);
 
-	dm_pool_free(mem, (char*)name);
+	dm_pool_free(mem, name);
 	return r;
 }
 
@@ -812,7 +812,7 @@ static int _dev_manager_lv_rmnodes(const struct logical_volume *lv)
 int dev_manager_mknodes(const struct logical_volume *lv)
 {
 	struct dm_info dminfo;
-	const char *name;
+	char *name;
 	int r = 0;
 
 	if (!(name = build_dm_name(lv->vg->cmd->mem, lv->vg->name, lv->name, NULL)))
@@ -826,7 +826,7 @@ int dev_manager_mknodes(const struct logical_volume *lv)
 			r = _dev_manager_lv_rmnodes(lv);
 	}
 
-	dm_pool_free(lv->vg->cmd->mem, (char*)name);
+	dm_pool_free(lv->vg->cmd->mem, name);
 	return r;
 }
 
-- 
1.7.2



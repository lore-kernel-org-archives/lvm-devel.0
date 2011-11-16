From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 16 Nov 2011 14:22:58 +0100
Subject: [PATCH 11/12] Remove fixmes
In-Reply-To: <cover.1321449480.git.zkabelac@redhat.com>
References: <cover.1321449480.git.zkabelac@redhat.com>
Message-ID: <9c01a6ffb362cb07fb5ed51f5071779913271168.1321449480.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Remove FIXMES - there should not be any pool free call since
the memory pool is from device manager, and pool is detroyed
after the operation, so doing extra free here would not help here.

However lv_has_target_type() is using cmd mempool so here the extra
call for dm_pool_free makes sence.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/dev_manager.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 4f7e6ac..fdeb967 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -411,7 +411,7 @@ int lv_has_target_type(struct dm_pool *mem, struct logical_volume *lv,
 
 	if (!(dmt = _setup_task(NULL, dlid, 0,
 				DM_DEVICE_STATUS, 0, 0)))
-		return_0;
+		goto_bad;
 
 	if (!dm_task_no_open_count(dmt))
 		log_error("Failed to disable open_count");
@@ -433,8 +433,10 @@ int lv_has_target_type(struct dm_pool *mem, struct logical_volume *lv,
 		}
 	} while (next);
 
- out:
+out:
 	dm_task_destroy(dmt);
+	dm_pool_free(mem, dlid);
+bad:
 	return r;
 }
 
@@ -737,8 +739,6 @@ int dev_manager_snapshot_percent(struct dev_manager *dm,
 		       NULL, fail_if_percent_unsupported)))
 		return_0;
 
-	/* FIXME dm_pool_free ? */
-
 	/* If the snapshot isn't available, percent will be -1 */
 	return 1;
 }
@@ -760,8 +760,6 @@ int dev_manager_mirror_percent(struct dev_manager *dm,
 	if (!(name = dm_build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
 		return_0;
 
-	/* FIXME dm_pool_free ? */
-
 	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, layer))) {
 		log_error("dlid build failed for %s", lv->name);
 		return 0;
-- 
1.7.7.3



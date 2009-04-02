From: Milan Broz <mbroz@redhat.com>
Date: Thu, 02 Apr 2009 16:19:54 +0200
Subject: [PATCH] fix _copy_pv to allocate even new pv->vg_name
Message-ID: <49D4C98A.5050906@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Allocate new pv->vg_name from pool, it can be destroyed later.

(The mempool rename will be used later by vg private mempools)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/metadata.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 7848d82..c90de6f 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -201,15 +201,17 @@ int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 static int _copy_pv(struct physical_volume *pv_to,
 		    struct physical_volume *pv_from)
 {
+	struct dm_pool *pvmem = pv_from->fmt->cmd->mem;
+
 	memcpy(pv_to, pv_from, sizeof(*pv_to));
 
-	if (!str_list_dup(pv_to->fmt->cmd->mem, &pv_to->tags, &pv_from->tags)) {
-		log_error("PV tags duplication failed");
-		return 0;
-	}
+	if (!(pv_to->vg_name = dm_pool_strdup(pvmem, pv_from->vg_name)))
+		return_0;
 
-	if (!peg_dup(pv_to->fmt->cmd->mem, &pv_to->segments,
-		     &pv_from->segments))
+	if (!str_list_dup(pvmem, &pv_to->tags, &pv_from->tags))
+		return_0;
+
+	if (!peg_dup(pvmem, &pv_to->segments, &pv_from->segments))
 		return_0;
 
 	return 1;
@@ -235,8 +237,10 @@ int get_pv_from_vg_by_id(const struct format_type *fmt, const char *vg_name,
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (id_equal(&pvl->pv->id, (const struct id *) pvid)) {
-			if (!_copy_pv(pv, pvl->pv))
+			if (!_copy_pv(pv, pvl->pv)) {
+				log_error("internal PV duplication failed");
 				return_0;
+			}
 			return 1;
 		}
 	}




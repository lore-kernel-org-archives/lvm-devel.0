From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon,  5 Apr 2010 15:51:39 -0400
Subject: [PATCH 5/5] Add pv->vg to solidify link between a pv and a vg.
In-Reply-To: <1270497099-13259-5-git-send-email-dwysocha@redhat.com>
References: <1270497099-13259-1-git-send-email-dwysocha@redhat.com>
	<1270497099-13259-2-git-send-email-dwysocha@redhat.com>
	<1270497099-13259-3-git-send-email-dwysocha@redhat.com>
	<1270497099-13259-4-git-send-email-dwysocha@redhat.com>
	<1270497099-13259-5-git-send-email-dwysocha@redhat.com>
Message-ID: <1270497099-13259-6-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

lvm2app needs a link back to the vg in order to use the vg handle for
memory allocations as well as other things.  This patch adds the field
to struct physical_volume, and sets pv->vg when reading a vg from disk or
extending a vg by using the helper function previously added,
add_pvl_to_vgs().  Moves and renames are handled with separate code
inside move_pv() and vgmerge().  Add pv->vg check to vg_validate().

NOTE: Unfortunately in the case of pv_read() callers, we cannot set
this pv->vg field properly, since the vg it belongs to may not be
known by just reading a single device, and no VG is in existence at
the time of pv_read().  Significant refactorings related to
lvmcache, PVs with 0 mdas, etc, are required to set this field
for callers of pv_read().  For now we assume that if the field is
NULL, the pv is not associated with a complete VG (as returned
by vg_read()).

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.c          |    8 ++++++++
 tools/vgmerge.c                  |    1 +
 3 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index b02a22c..ef6d1ef 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -184,6 +184,7 @@ struct physical_volume {
 	const char *vg_name;
 	struct id vgid;
 
+	struct volume_group *vg;
 	uint64_t status;
 	uint64_t size;
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 6ceb793..70debf4 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -140,6 +140,7 @@ void add_pvl_to_vgs(struct volume_group *vg, struct pv_list *pvl)
 {
 	dm_list_add(&vg->pvs, &pvl->list);
 	vg->pv_count++;
+	pvl->pv->vg = vg;
 }
 
 
@@ -336,6 +337,7 @@ int move_pv(struct volume_group *vg_from, struct volume_group *vg_to,
 
 	vg_from->pv_count--;
 	vg_to->pv_count++;
+	pvl->pv->vg = vg_to;
 
 	pv = pvl->pv;
 
@@ -2146,6 +2148,12 @@ int vg_validate(struct volume_group *vg)
 			/* FIXME Dump list structure? */
 			r = 0;
 		}
+		if (pvl->pv->vg != vg) {
+			log_error(INTERNAL_ERROR "VG %s PV list entry points "
+				  "to different VG %s", vg->name,
+				  pvl->pv->vg ? pvl->pv->vg->name : "NULL");
+			r = 0;
+		}
 	}
 
 	loop_counter1 = loop_counter2 = 0;
diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index 4a6721d..0acdbb9 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -90,6 +90,7 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 
 		pv = dm_list_item(pvh, struct pv_list)->pv;
 		pv->vg_name = dm_pool_strdup(cmd->mem, vg_to->name);
+		pv->vg = vg_to;
 	}
 	vg_to->pv_count += vg_from->pv_count;
 
-- 
1.6.0.6



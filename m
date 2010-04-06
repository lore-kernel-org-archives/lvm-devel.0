From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue,  6 Apr 2010 19:53:20 -0400
Subject: [PATCH 5/5] Add pv->vg to solidify link between a pv and a vg.
In-Reply-To: <1270598000-9771-5-git-send-email-dwysocha@redhat.com>
References: <1270598000-9771-1-git-send-email-dwysocha@redhat.com>
	<1270598000-9771-2-git-send-email-dwysocha@redhat.com>
	<1270598000-9771-3-git-send-email-dwysocha@redhat.com>
	<1270598000-9771-4-git-send-email-dwysocha@redhat.com>
	<1270598000-9771-5-git-send-email-dwysocha@redhat.com>
Message-ID: <1270598000-9771-6-git-send-email-dwysocha@redhat.com>
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
 lib/metadata/metadata-exported.h |   11 +++++++++++
 lib/metadata/metadata.c          |    8 ++++++++
 2 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 865cb3b..20dd669 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -181,9 +181,20 @@ struct physical_volume {
 	struct id id;
 	struct device *dev;
 	const struct format_type *fmt;
+
+	/*
+	 * vg_name and vgid are used before the parent VG struct exists.
+	 * FIXME: remove these in favor of using 'vg' below.
+	 */
 	const char *vg_name;
 	struct id vgid;
 
+	/*
+	 * 'vg' is set and maintained when the PV belongs to a 'pvs'
+	 * list in a parent VG struct.
+	 */
+	struct volume_group *vg;
+
 	uint64_t status;
 	uint64_t size;
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 85fa097..7369a3a 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -140,12 +140,14 @@ void add_pvl_to_vgs(struct volume_group *vg, struct pv_list *pvl)
 {
 	dm_list_add(&vg->pvs, &pvl->list);
 	vg->pv_count++;
+	pvl->pv->vg = vg;
 }
 
 void del_pvl_from_vgs(struct volume_group *vg, struct pv_list *pvl)
 {
 	vg->pv_count--;
 	dm_list_del(&pvl->list);
+	pvl->pv->vg = NULL;
 }
 
 
@@ -2150,6 +2152,12 @@ int vg_validate(struct volume_group *vg)
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
-- 
1.6.0.6



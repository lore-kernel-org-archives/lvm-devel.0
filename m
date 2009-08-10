From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 10 Aug 2009 14:08:23 -0400
Subject: [PATCH 2/4] Update vg_remove_single_* functions to use the removed_pvs list.
In-Reply-To: <1249927705-28528-2-git-send-email-dwysocha@redhat.com>
References: <1249927705-28528-1-git-send-email-dwysocha@redhat.com>
	<1249927705-28528-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1249927705-28528-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Now that we've split vg_remove_single into two routines, in the first routine
that only manipulates memory, we move the PVs from the vg->pvs list to the
vg->removed_pvs list.  Then later, we iterate through this list to write the
removed PVs to disk, which removes them from the volume group and places them
into the internal ORPHAN VG.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 6767668..0f53832 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -471,6 +471,7 @@ int remove_lvs_in_vg(struct cmd_context *cmd,
 int vg_remove_check(struct volume_group *vg)
 {
 	unsigned lv_count;
+	struct pv_list *pvl, *tpvl;
 
 	if (vg_read_error(vg) || vg_missing_pv_count(vg)) {
 		log_error("Volume group \"%s\" not found, is inconsistent "
@@ -494,6 +495,10 @@ int vg_remove_check(struct volume_group *vg)
 	if (!archive(vg))
 		return 0;
 
+	dm_list_iterate_items_safe(pvl, tpvl, &vg->pvs) {
+		dm_list_del(&pvl->list);
+		dm_list_add(&vg->removed_pvs, &pvl->list);
+	}
 	return 1;
 }
 
@@ -515,7 +520,7 @@ int vg_remove_ondisk(struct volume_group *vg)
 	}
 
 	/* init physical volumes */
-	dm_list_iterate_items(pvl, &vg->pvs) {
+	dm_list_iterate_items(pvl, &vg->removed_pvs) {
 		pv = pvl->pv;
 		log_verbose("Removing physical volume \"%s\" from "
 			    "volume group \"%s\"", pv_dev_name(pv), vg->name);
-- 
1.6.0.6



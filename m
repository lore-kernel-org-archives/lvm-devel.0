From: Milan Broz <mbroz@redhat.com>
Date: Fri, 18 Dec 2009 00:13:55 +0100
Subject: [PATCH] Remove missing flag if PV reappeared and is empty.
Message-ID: <1261091635-11359-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When PV device reappears with old metadata, it is
always updated to new version by atutomatic metadata
repair.

Remove missing flag if device is empty.

If device contains allocated extents, issue warning that
user must remove volumes and re-add this PV before
manipulating with VG.

This partially solves bug 547842 when one PV (log) is failed,
dmeventd removes that device and later this device reappears and
is wrongly added into VG marked missing.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/metadata.c |   26 ++++++++++++++++++++++++++
 1 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 103bc06..c4a0332 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2457,6 +2457,25 @@ int vg_missing_pv_count(const struct volume_group *vg)
 	return ret;
 }
 
+static void check_reappeared_pv(struct volume_group *correct_vg,
+				struct physical_volume *pv)
+{
+	struct pv_list *pvl;
+
+	dm_list_iterate_items(pvl, &correct_vg->pvs)
+		if (pv->dev == pvl->pv->dev && pvl->pv->status & MISSING_PV) {
+			log_warn("Missing device %s reappeared, updating "
+				 "metadata for VG %s to version %u.",
+				 pv_dev_name(pvl->pv),  pv_vg_name(pvl->pv), 
+				 correct_vg->seqno);
+			if (pvl->pv->pe_alloc_count == 0) {
+				pv->status &= ~MISSING_PV;
+				pvl->pv->status &= ~MISSING_PV;
+			} else
+				log_warn("Device still marked missing because of alocated data "
+					 "on it, remove volumes and consider vgreduce --removemissing.");
+		}
+}
 /* Caller sets consistent to 1 if it's safe for vg_read_internal to correct
  * inconsistent metadata on disk (i.e. the VG write lock is held).
  * This guarantees only consistent metadata is returned.
@@ -2737,6 +2756,13 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		log_warn("WARNING: Inconsistent metadata found for VG %s - updating "
 			 "to use version %u", vgname, correct_vg->seqno);
 
+		/*
+		 * If PV is marked missing but we found it,
+		 * update metadata and remove MISSING flag
+		 */
+		dm_list_iterate_items(pvl, &all_pvs)
+			check_reappeared_pv(correct_vg, pvl->pv);
+
 		cmd->handles_missing_pvs = 1;
 		if (!vg_write(correct_vg)) {
 			log_error("Automatic metadata correction failed");
-- 
1.6.5.4



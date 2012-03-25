From: Milan Broz <mbroz@redhat.com>
Date: Sun, 25 Mar 2012 22:56:05 +0200
Subject: [PATCH 3/4] Do not allow pvmove if some affected LVs are activated locally or on more nodes while others are activated exclusively.
In-Reply-To: <cover.1332708600.git.mbroz@redhat.com>
References: <cover.1332708600.git.mbroz@redhat.com>
Message-ID: <1ff1b02db7ebd97baedb71f806852763be322037.1332708600.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Current pvmove code can either use local mirror (for exclusive
activation) or cmirror (for clustered LVs).

Because the whole intenal pvmove LV is just segmented LV containing
segments of several top-level LVs, code cannot properly handle
situation if some segment need to be activated exclusively.

Previously, it wrongly activated exclusive LV on all nodes
(locing code allowed it) but now this is no lnger possible.

If there is exclusively activated LV, pvmove is only
possible if all affected LVs are aslo activated exclusively.

(Note that in non-exclusive mode pvmove still activates LVs
on other nodes during move.)

Example - lv1 and lv2 are on sdc:
  Error locking on node bar-01: Device or resource busy
  Error locking on node bar-03: Volume is busy on another node
...
  Failed to activate lv2

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 WHATS_NEW      |    1 +
 tools/pvmove.c |   26 ++++++++++++++++++++++++--
 2 files changed, 25 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 93b6440..13cb12d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Disallow pvmove for exclusive LV if some affected LVs are not exclusively activated.
   Remove unused and wrongly set cluster VG flag from clvmd lock query command.
   Fix pvmove for exclusively activated LV pvmove in clustered VG. (2.02.86)
   Always free hash table on update_pvid_to_vgid() in lvmetad.
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 40ef069..a6bcfc3 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -175,13 +175,16 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 						const char *lv_name,
 						struct dm_list *allocatable_pvs,
 						alloc_policy_t alloc,
-						struct dm_list **lvs_changed)
+						struct dm_list **lvs_changed,
+						unsigned *exclusive)
 {
 	struct logical_volume *lv_mirr, *lv;
 	struct lv_list *lvl;
 	uint32_t log_count = 0;
 	int lv_found = 0;
 	int lv_skipped = 0;
+	int lv_active_count = 0;
+	int lv_exclusive_count = 0;
 
 	/* FIXME Cope with non-contiguous => splitting existing segments */
 	if (!(lv_mirr = lv_create_empty("pvmove%d", NULL,
@@ -235,6 +238,14 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 			log_print("Skipping locked LV %s", lv->name);
 			continue;
 		}
+
+		if (vg_is_clustered(vg)) {
+			if (lv_is_active_exclusive(lv))
+				lv_exclusive_count++;
+			else if (lv_is_active(lv))
+				lv_active_count++;
+		}
+
 		if (!_insert_pvmove_mirrors(cmd, lv_mirr, source_pvl, lv,
 					    *lvs_changed))
 			return_NULL;
@@ -255,6 +266,17 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 		return NULL;
 	}
 
+	if (lv_exclusive_count) {
+		if (lv_active_count) {
+			log_error("Cannot move in clustered VG %s "
+				  "if some LVs are activated "
+				  "exclusively while others don't.",
+				  vg->name);
+			return NULL;
+		}
+		*exclusive = 1;
+	}
+
 	if (!lv_add_mirrors(cmd, lv_mirr, 1, 1, 0, 0, log_count,
 			    allocatable_pvs, alloc, MIRROR_BY_SEG)) {
 		log_error("Failed to convert pvmove LV to mirrored");
@@ -510,7 +532,7 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 
 		if (!(lv_mirr = _set_up_pvmove_lv(cmd, vg, source_pvl, lv_name,
 						  allocatable_pvs, alloc,
-						  &lvs_changed)))
+						  &lvs_changed, &exclusive)))
 			goto_out;
 	}
 
-- 
1.7.9.1



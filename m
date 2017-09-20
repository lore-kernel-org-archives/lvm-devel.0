From: David Teigland <teigland@sourceware.org>
Date: Wed, 20 Sep 2017 10:58:43 -0400
Subject: master - pvmove: require LV name in a shared VG
Message-ID: <201709201458.v8KEwhir027743@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f2ee0e7aca6020cf273f22dc5bca20bfa3c89051
Commit:        f2ee0e7aca6020cf273f22dc5bca20bfa3c89051
Parent:        518a8e8cfbb672c2bf5e3455f1fe7cd8d94eb5b0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 19 13:08:41 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Sep 20 09:56:51 2017 -0500

pvmove: require LV name in a shared VG

In a shared VG, only allow pvmove with a named LV,
so that only PE's used by the LV will be moved.
The LV is then activated exclusively, ensuring that
the PE's being moved are not used from another host.

Previously, pvmove was mistakenly allowed on a full PV.
This won't work when LVs using that PV are active on
other hosts.
---
 WHATS_NEW             |    1 +
 lib/metadata/mirror.c |    2 +-
 man/lvmlockd.8_main   |    3 +++
 tools/pvmove.c        |   42 ++++++++++++++++++++++++------------------
 4 files changed, 29 insertions(+), 19 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6d820bd..6b88fc4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.175 - 
 ======================================
+  Require LV name with pvmove in a shared VG.
   Allow shared active mirror LVs with lvmlockd, dlm, and cmirrord.
   Support lvconvert --repair with cache and cachepool volumes.
   lvconvert --repair respects --poolmetadataspare option.
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index e775495..238ce37 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -2145,7 +2145,7 @@ int lv_add_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 		}
 	}
 
-	if (lv->vg->lock_type && !strcmp(lv->vg->lock_type, "dlm")) {
+	if (lv->vg->lock_type && !strcmp(lv->vg->lock_type, "dlm") && cmd->lockd_lv_sh) {
 		if (!cluster_mirror_is_available(cmd)) {
 			log_error("Shared cluster mirrors are not available.");
 			return 0;
diff --git a/man/lvmlockd.8_main b/man/lvmlockd.8_main
index 067c60d..b7eba1a 100644
--- a/man/lvmlockd.8_main
+++ b/man/lvmlockd.8_main
@@ -826,6 +826,9 @@ using external origins for thin LVs
 splitting mirrors and snapshots from LVs
 .br
 \[bu]
+pvmove of entire PVs, or under LVs activated with shared locks
+.br
+\[bu]
 vgsplit
 .br
 \[bu]
diff --git a/tools/pvmove.c b/tools/pvmove.c
index eef5cc1..750f08e 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -480,7 +480,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 		 * If the VG is clustered, we are unable to handle
 		 * snapshots, origins, thin types, RAID or mirror
 		 */
-		if (vg_is_clustered(vg) &&
+		if ((vg_is_clustered(vg) || is_lockd_type(vg->lock_type)) &&
 		    (lv_is_origin(lv) || lv_is_cow(lv) ||
 		     lv_is_thin_type(lv) || lv_is_raid_type(lv))) {
 			log_print_unless_silent("Skipping %s LV %s",
@@ -692,6 +692,7 @@ static int _pvmove_setup_single(struct cmd_context *cmd,
 	struct dm_list *allocatable_pvs;
 	struct dm_list *lvs_changed;
 	struct logical_volume *lv_mirr;
+	struct logical_volume *lv = NULL;
 	const char *pv_name = pv_dev_name(pv);
 	unsigned flags = PVMOVE_FIRST_TIME;
 	unsigned exclusive;
@@ -712,27 +713,32 @@ static int _pvmove_setup_single(struct cmd_context *cmd,
 			pp->setup_result = EINVALID_CMD_LINE;
 			return ECMD_FAILED;
 		}
+
+		if (!(lv = find_lv(vg, lv_name))) {
+			log_error("Failed to find LV with name %s", lv_name);
+			return ECMD_FAILED;
+		}
 	}
 
 	/*
-	 * We cannot move blocks from under the sanlock leases, so disallow
-	 * pvmoving any PVs used by the lvmlock LV.
+	 * We would need to avoid any PEs used by LVs that are active (ex) on
+	 * other hosts.  For LVs that are active on multiple hosts (sh), we
+	 * would need to used cluster mirrors.
 	 */
-	if (vg->lock_type && !strcmp(vg->lock_type, "sanlock")) {
-		struct lv_segment *lvseg;
-		struct physical_volume *sanlock_pv;
-		unsigned s;
-
-		dm_list_iterate_items(lvseg, &vg->sanlock_lv->segments) {
-			for (s = 0; s < lvseg->area_count; s++) {
-				if (seg_type(lvseg, s) == AREA_PV) {
-					sanlock_pv = seg_pv(lvseg, s);
-					if (sanlock_pv->dev == pv->dev) {
-						log_error("Cannot pvmove device %s used for sanlock leases.", pv_name);
-						return ECMD_FAILED;
-					}
-				}
-			}
+	if (is_lockd_type(vg->lock_type)) {
+		if (!lv) {
+			log_error("pvmove in a shared VG requires a named LV.");
+			return ECMD_FAILED;
+		}
+
+		if (lv_is_lockd_sanlock_lv(lv)) {
+			log_error("pvmove not allowed on internal sanlock LV.");
+			return ECMD_FAILED;
+		}
+
+		if (!lockd_lv(cmd, lv, "ex", LDLV_PERSISTENT)) {
+			log_error("pvmove in a shared VG requires exclusive lock on named LV.");
+			return ECMD_FAILED;
 		}
 	}
 



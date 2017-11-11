From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Nov 2017 19:03:08 -0500
Subject: master - raid: protect raid4 activation
Message-ID: <201711110003.vAB0381D009545@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=05f9acdc7ff3e9968c2e2422b2cd384c74d7dbe4
Commit:        05f9acdc7ff3e9968c2e2422b2cd384c74d7dbe4
Parent:        f0d1c8429b9d59959170cd44732d8ff1987a886a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 9 13:00:28 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 11 00:56:10 2017 +0100

raid: protect raid4 activation

Move check for presence of raid4 into the right place
so there is no way how to hit activation of any LV
with raid4 on kernel which does not support it.
---
 lib/metadata/lv.c |   14 --------------
 lib/raid/raid.c   |   24 +++++++++++++++++-------
 2 files changed, 17 insertions(+), 21 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index e3815c9..e50b2bb 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -1462,7 +1462,6 @@ int lv_active_change(struct cmd_context *cmd, struct logical_volume *lv,
 		     enum activation_change activate, int needs_exclusive)
 {
 	const char *ay_with_mode = NULL;
-	struct lv_segment *seg = first_seg(lv);
 
 	if (activate == CHANGE_ASY)
 		ay_with_mode = "sh";
@@ -1499,9 +1498,6 @@ deactivate:
 		break;
 	case CHANGE_ALY:
 	case CHANGE_AAY:
-		if (!raid4_is_supported(cmd, seg->segtype))
-			goto no_raid4;
-
 		if (needs_exclusive || _lv_is_exclusive(lv)) {
 			log_verbose("Activating logical volume %s exclusively locally.",
 				    display_lvname(lv));
@@ -1516,9 +1512,6 @@ deactivate:
 		break;
 	case CHANGE_AEY:
 exclusive:
-		if (!raid4_is_supported(cmd, seg->segtype))
-			goto no_raid4;
-
 		log_verbose("Activating logical volume %s exclusively.",
 			    display_lvname(lv));
 		if (!activate_lv_excl(cmd, lv))
@@ -1527,9 +1520,6 @@ exclusive:
 	case CHANGE_ASY:
 	case CHANGE_AY:
 	default:
-		if (!raid4_is_supported(cmd, seg->segtype))
-			goto no_raid4;
-
 		if (needs_exclusive || _lv_is_exclusive(lv))
 			goto exclusive;
 		log_verbose("Activating logical volume %s.", display_lvname(lv));
@@ -1542,10 +1532,6 @@ exclusive:
 		log_error("Failed to unlock logical volume %s.", display_lvname(lv));
 
 	return 1;
-
-no_raid4:
-	log_error("Failed to activate %s LV %s", lvseg_name(seg), display_lvname(lv));
-	return 0;
 }
 
 char *lv_active_dup(struct dm_pool *mem, const struct logical_volume *lv)
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index b9f9161..5d2e1ea 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -24,6 +24,10 @@
 #include "metadata.h"
 #include "lv_alloc.h"
 
+static int _raid_target_present(struct cmd_context *cmd,
+				const struct lv_segment *seg __attribute__((unused)),
+				unsigned *attributes);
+
 static void _raid_display(const struct lv_segment *seg)
 {
 	unsigned s;
@@ -247,13 +251,19 @@ static int _raid_add_target_line(struct dev_manager *dm __attribute__((unused)),
 	int delta_disks = 0, delta_disks_minus = 0, delta_disks_plus = 0, data_offset = 0;
 	uint32_t s;
 	uint64_t flags = 0;
-	uint64_t rebuilds[RAID_BITMAP_SIZE];
-	uint64_t writemostly[RAID_BITMAP_SIZE];
-	struct dm_tree_node_raid_params_v2 params;
-
-	memset(&params, 0, sizeof(params));
-	memset(&rebuilds, 0, sizeof(rebuilds));
-	memset(&writemostly, 0, sizeof(writemostly));
+	uint64_t rebuilds[RAID_BITMAP_SIZE] = { 0 };
+	uint64_t writemostly[RAID_BITMAP_SIZE] = { 0 };
+	struct dm_tree_node_raid_params_v2 params = { 0 };
+	unsigned attrs;
+
+	if (seg_is_raid4(seg)) {
+		if (!_raid_target_present(cmd, NULL, &attrs) ||
+		    !(attrs & RAID_FEATURE_RAID4)) {
+			log_error("RAID target does not support RAID4 for LV %s.",
+				  display_lvname(seg->lv));
+			return 0;
+		}
+	}
 
 	if (!seg->area_count) {
 		log_error(INTERNAL_ERROR "_raid_add_target_line called "



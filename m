From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 26 Jul 2018 08:02:43 -0400
Subject: 2018-06-01-stable - lvconvert: reject conversions on raid1 split trackchanges SubLVs
Message-ID: <201807261202.w6QC2hCu008252@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e4fe0d1b8f5395fae9acd654ad3a752710290963
Commit:        e4fe0d1b8f5395fae9acd654ad3a752710290963
Parent:        951676a59eb2b3130abb9eec690206665708b0d0
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Jul 26 01:00:11 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Jul 26 14:01:37 2018 +0200

lvconvert: reject conversions on raid1 split trackchanges SubLVs

Prohibit conversions of raid1 split trackchanges SubLVs
because they will fail to get merged back into the RaidLV.

Resolves: rhbz1579438
(cherry picked from commit 8b0729af0fd357e66e95834e92913ea2a42d4e93)

Conflicts:
	WHATS_NEW
---
 WHATS_NEW                                        |    1 +
 test/shell/lvconvert-raid1-split-trackchanges.sh |   36 +++++++++++++++++
 tools/lvconvert.c                                |   45 ++++++++++++++++++++++
 3 files changed, 82 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index bdd2fa6..7c74c50 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.181 - 
 =================================
+  lvconvert: reject conversions on raid1 split tracked SubLVs
 
 Version 2.02.180 - 19th July 2018
 =================================
diff --git a/test/shell/lvconvert-raid1-split-trackchanges.sh b/test/shell/lvconvert-raid1-split-trackchanges.sh
new file mode 100644
index 0000000..e25a632
--- /dev/null
+++ b/test/shell/lvconvert-raid1-split-trackchanges.sh
@@ -0,0 +1,36 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+# rhbz1579072/rhbz1579438
+
+aux have_raid 1 3 0 || skip
+
+# 8 PVs needed for RAID10 testing (4-stripes/2-mirror)
+aux prepare_pvs 4 2
+get_devs
+vgcreate $SHARED -s 512k "$vg" "${DEVICES[@]}"
+
+lvcreate -y --ty raid1 -m 2 -n $lv1 -l 1 $vg
+lvconvert -y --splitmirrors 1 --trackchanges $vg/$lv1
+
+not lvconvert -y --ty striped -m 1 $vg/${lv1}_rimage_2
+not lvconvert -y --ty raid1 -m 1 $vg/${lv1}_rimage_2
+not lvconvert -y --ty mirror -m 1 $vg/${lv1}_rimage_2
+not lvconvert -y --ty cache-pool $vg/${lv1}_rimage_2
+not lvconvert -y --ty thin-pool $vg/${lv1}_rimage_2
+
+vgremove -ff $vg
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 11715bd..758ba3a 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1165,6 +1165,36 @@ static int _lvconvert_validate_thin(struct logical_volume *lv,
 	return 0;
 }
 
+/* Check for raid1 split trackchanges image to reject conversions on it. */
+static int _raid_split_image_conversion(struct logical_volume *lv)
+{
+	const char *s;
+
+	if (lv_is_raid_image(lv) &&
+	    (s = strstr(lv->name, "_rimage_"))) {
+		size_t len = s - lv->name;
+		char raidlv_name[len + 1];
+		const struct logical_volume *tmp_lv;
+
+		strncpy(raidlv_name, lv->name, len);
+		raidlv_name[len] = '\0';
+
+		if (!(tmp_lv = find_lv(lv->vg, raidlv_name))) {
+			log_error(INTERNAL_ERROR "Failed to find RaidLV of RAID subvolume %s.",
+				  display_lvname(lv));
+			return 1;
+		}
+
+		if (lv_is_raid_with_tracking(tmp_lv)) {
+			log_error("Conversion of tracked raid1 subvolume %s is not supported.",
+				  display_lvname(lv));
+			return 1;
+		}
+	}
+
+	return 0;
+}
+
 /*
  * _lvconvert_mirrors
  *
@@ -1180,6 +1210,9 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 	uint32_t new_mimage_count = 0;
 	uint32_t new_log_count = 0;
 
+	if (_raid_split_image_conversion(lv))
+		return 0;
+
 	if ((lp->corelog || lp->mirrorlog) && *lp->type_str && strcmp(lp->type_str, SEG_TYPE_NAME_MIRROR)) {
 		log_error("--corelog and --mirrorlog are only compatible with mirror devices.");
 		return 0;
@@ -1296,6 +1329,9 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 	struct cmd_context *cmd = lv->vg->cmd;
 	struct lv_segment *seg = first_seg(lv);
 
+	if (_raid_split_image_conversion(lv))
+		return 0;
+
 	if (_linear_type_requested(lp->type_str)) {
 		if (arg_is_set(cmd, mirrors_ARG) && (arg_uint_value(cmd, mirrors_ARG, 0) != 0)) {
 			log_error("Cannot specify mirrors with linear type.");
@@ -2574,6 +2610,9 @@ static int _lvconvert_to_thin_with_external(struct cmd_context *cmd,
 		.virtual_extents = lv->le_count,
 	};
 
+	if (_raid_split_image_conversion(lv))
+		return 0;
+
 	if (lv == thinpool_lv) {
 		log_error("Can't use same LV %s for thin pool and thin volume.",
 			  display_lvname(thinpool_lv));
@@ -2883,6 +2922,9 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	struct id lockd_meta_id;
 	const char *str_seg_type = to_cachepool ? SEG_TYPE_NAME_CACHE_POOL : SEG_TYPE_NAME_THIN_POOL;
 
+	if (_raid_split_image_conversion(lv))
+		return 0;
+
 	if (lv_is_thin_pool(lv) || lv_is_cache_pool(lv)) {
 		log_error(INTERNAL_ERROR "LV %s is already a pool.", display_lvname(lv));
 		return 0;
@@ -3334,6 +3376,9 @@ static int _lvconvert_to_cache_vol(struct cmd_context *cmd,
 	struct dm_config_tree *policy_settings = NULL;
 	int r = 0;
 
+	if (_raid_split_image_conversion(lv))
+		return 0;
+
 	/* If LV is inactive here, ensure it's not active elsewhere. */
 	if (!lockd_lv(cmd, lv, "ex", 0))
 		return_0;



From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Thu, 23 Feb 2017 14:16:35 +0000 (UTC)
Subject: master - lvchange: reject writemostly/writebehind on raid1 during resync
Message-ID: <20170223141635.C4F9F61123@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8ab072507706fb826eee05eb369429ad0a7a406a
Commit:        8ab072507706fb826eee05eb369429ad0a7a406a
Parent:        3f4ecaf8c2b3146e81bcb32bd4f0321beee1192a
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Feb 23 15:09:29 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Feb 23 15:09:29 2017 +0100

lvchange: reject writemostly/writebehind on raid1 during resync

The MD kernel raid1 personality does no use any writemostly leg as the primary.

In case a previous linear LV holding data gets upconverted to
raid1 it becomes the primary leg of the new raid1 LV and a full
resynchronization is started to update the new legs.

No writemostly and/or writebehind setting may be allowed during
this initial, full synchronization period of this new raid1 LV
(using the lvchange(8) command), because that would change the
primary (i.e the previous linear LV) thus causing data loss.

lvchange has a bug not preventing this scenario.

Fix rejects setting writemostly and/or writebehind on resychronizing raid1 LVs.

Once we have status in the lvm2 metadata about the linear -> raid upconversion,
we may relax this constraint for other types of resynchronization
(e.g. for user requested "lvchange --resync ").

New lvchange-raid1-writemostly.sh test is added to the test suite.

Resolves: https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=855895
---
 WHATS_NEW                                |    1 +
 lib/metadata/metadata-exported.h         |    1 +
 lib/metadata/raid_manip.c                |    8 +++++-
 test/shell/lvchange-raid1-writemostly.sh |   41 ++++++++++++++++++++++++++++++
 tools/lvchange.c                         |   15 +++++++++++
 5 files changed, 65 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 722b6f6..14109fb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Reject writemostly/writebehind in lvchange during resynchronization.
   Deactivate active origin first before removal for improved workflow.
   Fix regression of accepting options --type and -m with lvresize (2.02.158).
   Add lvconvert --swapmetadata, new specific way to swap pool metadata LVs.
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 573c09d..e4d2267 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1232,6 +1232,7 @@ uint32_t raid_rimage_extents(const struct segment_type *segtype,
 uint32_t raid_ensure_min_region_size(const struct logical_volume *lv, uint64_t raid_size, uint32_t region_size);
 int lv_raid_change_region_size(struct logical_volume *lv,
                                int yes, int force, uint32_t new_region_size);
+int lv_raid_in_sync(const struct logical_volume *lv);
 /* --  metadata/raid_manip.c */
 
 /* ++  metadata/cache_manip.c */
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index cdd7af8..b6215a2 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -238,7 +238,7 @@ static int _deactivate_and_remove_lvs(struct volume_group *vg, struct dm_list *r
  * Returns: 1 if in-sync, 0 otherwise.
  */
 #define _RAID_IN_SYNC_RETRIES  6
-static int _raid_in_sync(struct logical_volume *lv)
+static int _raid_in_sync(const struct logical_volume *lv)
 {
 	int retries = _RAID_IN_SYNC_RETRIES;
 	dm_percent_t sync_percent;
@@ -269,6 +269,12 @@ static int _raid_in_sync(struct logical_volume *lv)
 	return (sync_percent == DM_PERCENT_100) ? 1 : 0;
 }
 
+/* External interface to raid in-sync check */
+int lv_raid_in_sync(const struct logical_volume *lv)
+{
+	return _raid_in_sync(lv);
+}
+
 /* Check if RaidLV @lv is synced or any raid legs of @lv are not synced */
 static int _raid_devs_sync_healthy(struct logical_volume *lv)
 {
diff --git a/test/shell/lvchange-raid1-writemostly.sh b/test/shell/lvchange-raid1-writemostly.sh
new file mode 100644
index 0000000..edf11bd
--- /dev/null
+++ b/test/shell/lvchange-raid1-writemostly.sh
@@ -0,0 +1,41 @@
+#!/bin/sh
+# Copyright (C) 2017 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA2110-1301 USA
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+which mkfs.ext4 || skip
+aux have_raid 1 3 5 || skip
+
+aux prepare_vg 4
+
+for d in $dev1 $dev2 $dev3 $dev4
+do
+	aux delay_dev $d 1
+done
+
+#
+# Test writemostly prohibited on resyncrhonizing raid1
+#
+
+# Create 4-way striped LV
+lvcreate -aey --ty raid1 -m 3 -L 32M -n $lv1 $vg
+not lvchange -y --writemostly $dev1 $vg/$lv1
+check lv_field $vg/$lv1 segtype "raid1"
+check lv_field $vg/$lv1 stripes 4
+check lv_attr_bit health $vg/${lv1}_rimage_0 "-"
+aux wait_for_sync $vg $lv1
+lvchange -y --writemostly $dev1 $vg/$lv1
+check lv_attr_bit health $vg/${lv1}_rimage_0 "w"
+
+vgremove -ff $vg
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 1c00b76..cba0496 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -739,6 +739,21 @@ static int _lvchange_writemostly(struct logical_volume *lv)
 	struct cmd_context *cmd = lv->vg->cmd;
 	struct lv_segment *raid_seg = first_seg(lv);
 
+	/*
+	 * Prohibit writebehind and writebehind during synchronization.
+	 *
+	 * FIXME: we can do better once we can distingush between
+	 *        an initial sync after a linear -> raid1 upconversion
+	 *        and any later additions of legs, requested resyncs
+	 *        via lvchange or leg repairs/replacements.
+	 */
+	if (!lv_raid_in_sync(lv)) {
+		log_error("Unable to change write%s on %s while it is not in-sync.",
+			  arg_is_set(cmd, writemostly_ARG) ? "mostly" : "behind",
+			  display_lvname(lv));
+		return 0;
+	}
+
 	if (arg_is_set(cmd, writebehind_ARG))
 		raid_seg->writebehind = arg_uint_value(cmd, writebehind_ARG, 0);
 



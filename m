From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 3 May 2018 12:49:08 -0400
Subject: master - lvconvert: don't return success on degraded -m raid1 conversion
Message-ID: <201805031649.w43Gn870022369@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4ebfd8e8eb68442efc334b35bc1f22eda3e4dd3d
Commit:        4ebfd8e8eb68442efc334b35bc1f22eda3e4dd3d
Parent:        b393fbec00bbe1fb8d546ee3f360f8d2eb19540e
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu May 3 18:00:21 2018 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu May 3 18:48:00 2018 +0200

lvconvert: don't return success on degraded -m raid1 conversion

In case "lvconvert -mN RaidLV" was used on a degraded
raid1 LV, success was returned instead of an error.

Provide message to inform about the need to repair first
before changing number of mirrors and exit with error.

Add new lvconvert-m-raid1-degraded.sh test.

Resolves: rhbz1573960
---
 WHATS_NEW                                |    1 +
 lib/metadata/raid_manip.c                |   36 ++++++++++++++++++++++-
 test/shell/lvconvert-m-raid1-degraded.sh |   47 ++++++++++++++++++++++++++++++
 3 files changed, 83 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index fbe2418..5b1494b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  lvconvert: don't return success on degraded -m raid1 conversion
   --enable-testing switch for ./configure has been removed.
   --with-snapshots switch for ./configure has been removed.
   --with-mirrors switch for ./configure has been removed.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 7d82a24..1b9ebcf 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -3200,6 +3200,27 @@ static int _raid_remove_images(struct logical_volume *lv, int yes,
 	return 1;
 }
 
+/* Check if single SubLV @slv is degraded. */
+static int _sublv_is_degraded(const struct logical_volume *slv)
+{
+	return !slv || lv_is_partial(slv) || lv_is_virtual(slv);
+}
+
+/* Return failed component SubLV count for @lv. */
+static uint32_t _lv_get_nr_failed_components(const struct logical_volume *lv)
+{
+	uint32_t r = 0, s;
+	struct lv_segment *seg = first_seg(lv);
+
+	for (s = 0; s < seg->area_count; s++)
+		if (_sublv_is_degraded(seg_lv(seg, s)) ||
+		    (seg->meta_areas &&
+		     _sublv_is_degraded(seg_metalv(seg, s))))
+			r++;
+
+	return r;
+}
+
 /*
  * _lv_raid_change_image_count
  * new_count: The absolute count of images (e.g. '2' for a 2-way mirror)
@@ -3215,12 +3236,25 @@ static int _lv_raid_change_image_count(struct logical_volume *lv, int yes, uint3
 				       struct dm_list *allocate_pvs, struct dm_list *removal_lvs,
 				       int commit, int use_existing_area_len)
 {
+	int r;
 	uint32_t old_count = lv_raid_image_count(lv);
 
+	/* If there's failed component SubLVs, require repair first! */
+	if (lv_is_raid(lv) &&
+	    _lv_get_nr_failed_components(lv) &&
+	    new_count >= old_count) {
+		log_error("Can't change number of mirrors of degraded %s.",
+			  display_lvname(lv));
+		log_error("Please run \"lvconvert --repair %s\" first.",
+			  display_lvname(lv));
+		r = 0;
+	} else
+		r = 1;
+
 	if (old_count == new_count) {
 		log_warn("WARNING: %s already has image count of %d.",
 			 display_lvname(lv), new_count);
-		return 1;
+		return r;
 	}
 
 	/*
diff --git a/test/shell/lvconvert-m-raid1-degraded.sh b/test/shell/lvconvert-m-raid1-degraded.sh
new file mode 100644
index 0000000..f8a65d9
--- /dev/null
+++ b/test/shell/lvconvert-m-raid1-degraded.sh
@@ -0,0 +1,47 @@
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
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_raid 1 3 0 || skip
+
+aux lvmconf 'activation/raid_fault_policy = "warn"'
+
+aux prepare_vg 3 32
+get_devs
+
+# Create 2-legged RAID1 and wait for it to complete initial resync
+lvcreate --type raid1 -m 1 -l 4 -n $lv $vg "$dev1" "$dev2"
+aux wait_for_sync $vg $lv
+
+# Disable first PV thus erroring first leg
+aux disable_dev "$dev1"
+
+# Reduce VG by missing PV
+vgreduce --force --removemissing $vg
+check raid_leg_status $vg $lv "DA"
+
+# Conversion to 2 legs must fail on degraded 2-legged raid1 LV
+not lvconvert -y -m1 $vg/$lv
+check raid_leg_status $vg $lv "DA"
+
+# Repair has to succeed
+lvconvert -y --repair $vg/$lv
+aux wait_for_sync $vg $lv
+check raid_leg_status $vg $lv "AA"
+
+lvremove -ff $vg/$lv
+
+vgremove -ff $vg



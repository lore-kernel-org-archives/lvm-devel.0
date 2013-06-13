From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 13 Jun 2013 12:51:58 +0000 (UTC)
Subject: master - thin: vgsplit support for thins
Message-ID: <20130613125158.8D935610C7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fe22089edff17158e6d9264cd671395b2ad6e060
Commit:        fe22089edff17158e6d9264cd671395b2ad6e060
Parent:        ebf0898d69f53664fa5c1f88207aa8bc970b84fc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 13 12:05:53 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 13 14:51:00 2013 +0200

thin: vgsplit support for thins

Support vgsplit for VGs with thin pools and thin volumes.
In case the thin data and thin metadata volumes are moved to a new VG,
move there also all related thin volumes and check that external origins
are also present in this new VG.
---
 WHATS_NEW                  |    1 +
 test/shell/vgsplit-thin.sh |   39 +++++++++++++++++++++++++++++++
 tools/vgsplit.c            |   55 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 95 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 36ad365..86b1f03 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Add support for thin volumes in vgsplit.
   Also filter partitions on mpath components if multipath_component_detection=1.
   Add lvresize support for online thin pool metadata volume resize.
   Add helper functions find_pool_lv() and pool_can_resize_metadata().
diff --git a/test/shell/vgsplit-thin.sh b/test/shell/vgsplit-thin.sh
new file mode 100644
index 0000000..8fed1af
--- /dev/null
+++ b/test/shell/vgsplit-thin.sh
@@ -0,0 +1,39 @@
+#!/bin/sh
+# Copyright (C) 2013 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# Test vgsplit command options for validity
+
+. lib/test
+
+aux have_thin 1 0 0 || skip
+
+aux prepare_devs 5
+
+vgcreate $vg1 $(cat DEVICES)
+lvcreate -T -L8M $vg1/pool1 -V10M -n $lv1 "$dev1" "$dev2"
+lvcreate -T -L8M $vg1/pool2 -V10M -n $lv2 "$dev3" "$dev4"
+
+# Test with external origin if available
+lvcreate -l1 -an -pr --zero n -n eorigin $vg1 "$dev5"
+aux have_thin 1 5 0 && lvcreate -an -s $vg1/eorigin -n $lv3 --thinpool $vg1/pool1
+
+# Cannot move active thin
+not vgsplit $vg1 $vg2 "$dev1" "$dev2" "$dev5"
+
+vgchange -an $vg1
+not vgsplit $vg1 $vg2 "$dev1"
+not vgsplit $vg1 $vg2 "$dev2" "$dev3"
+vgsplit $vg1 $vg2 "$dev1" "$dev2" "$dev5"
+lvs -a -o+devices $vg1 $vg2
+
+vgmerge $vg1 $vg2
+
+vgremove -ff $vg1
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index b52c2f8..de41df7 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -62,6 +62,10 @@ static int _move_lvs(struct volume_group *vg_from, struct volume_group *vg_to)
 		if ((lv->status & MIRRORED))
 			continue;
 
+		if (lv_is_thin_pool(lv) ||
+		    lv_is_thin_volume(lv))
+			continue;
+
 		/* Ensure all the PVs used by this LV remain in the same */
 		/* VG as each other */
 		vg_with = NULL;
@@ -211,6 +215,53 @@ static int _move_mirrors(struct volume_group *vg_from,
 	return 1;
 }
 
+static int _move_thins(struct volume_group *vg_from,
+		       struct volume_group *vg_to)
+{
+	struct dm_list *lvh, *lvht;
+	struct logical_volume *lv, *data_lv;
+	struct lv_segment *seg;
+
+	dm_list_iterate_safe(lvh, lvht, &vg_from->lvs) {
+		lv = dm_list_item(lvh, struct lv_list)->lv;
+
+		if (lv_is_thin_volume(lv)) {
+			seg = first_seg(lv);
+			data_lv = seg_lv(first_seg(seg->pool_lv), 0);
+			if ((_lv_is_in_vg(vg_to, data_lv) ||
+			     _lv_is_in_vg(vg_to, seg->external_lv))) {
+				if (_lv_is_in_vg(vg_from, seg->external_lv) ||
+				    _lv_is_in_vg(vg_from, data_lv)) {
+					log_error("Can't split external origin %s "
+						  "and pool %s between two Volume Groups.",
+						  seg->external_lv->name,
+						  seg->pool_lv->name);
+					return 0;
+				}
+				if (!_move_one_lv(vg_from, vg_to, lvh))
+					return_0;
+			}
+		} else if (lv_is_thin_pool(lv)) {
+			seg = first_seg(lv);
+			data_lv = seg_lv(seg, 0);
+			if (_lv_is_in_vg(vg_to, data_lv) ||
+			    _lv_is_in_vg(vg_to, seg->metadata_lv)) {
+				if (_lv_is_in_vg(vg_from, seg->metadata_lv) ||
+				    _lv_is_in_vg(vg_from, data_lv)) {
+					log_error("Can't split pool data and metadata %s "
+						  "between two Volume Groups.",
+						  lv->name);
+					return 0;
+				}
+				if (!_move_one_lv(vg_from, vg_to, lvh))
+					return_0;
+			}
+		}
+	}
+
+	return 1;
+}
+
 /*
  * Create or open the destination of the vgsplit operation.
  * Returns
@@ -430,6 +481,10 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	if (!(_move_snapshots(vg_from, vg_to)))
 		goto_bad;
 
+	/* Move required pools across */
+	if (!(_move_thins(vg_from, vg_to)))
+		goto_bad;
+
 	/* Split metadata areas and check if both vgs have at least one area */
 	if (!(vg_split_mdas(cmd, vg_from, vg_to)) && vg_from->pv_count) {
 		log_error("Cannot split: Nowhere to store metadata for new Volume Group");



From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Mon, 24 Feb 2014 18:27:31 +0000 (UTC)
Subject: master - pvmove: Disallow pvmove of cache LVs
Message-ID: <20140224182731.61508611E1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ee89ac7b887bc227f9c4d436c0acaa61c7ee4deb
Commit:        ee89ac7b887bc227f9c4d436c0acaa61c7ee4deb
Parent:        fdb7356d6a9be43678c9d001725aef6dca02d178
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Feb 24 12:25:18 2014 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Feb 24 12:25:18 2014 -0600

pvmove: Disallow pvmove of cache LVs

Skip over LVs that have a cache LV in their tree of LV dependencies
when performing a pvmove.

This means that users cannot move a cache pool or a cache LV's origin -
even when that cache LV is used as part of another LV (e.g. a thin pool).

The new test (pvmove-cache-segtypes.sh) currently builds up various LV
stacks that incorporate cache LVs.  pvmove tests are then performed to
ensure that cache related LVs are /not/ moved.  Once pvmove is enabled
for cache, those tests will switch to ensuring that the LVs /are/
moved.
---
 test/shell/pvmove-cache-segtypes.sh |  178 +++++++++++++++++++++++++++++++++++
 tools/pvmove.c                      |   43 +++++++++
 2 files changed, 221 insertions(+), 0 deletions(-)

diff --git a/test/shell/pvmove-cache-segtypes.sh b/test/shell/pvmove-cache-segtypes.sh
new file mode 100644
index 0000000..1c2423e
--- /dev/null
+++ b/test/shell/pvmove-cache-segtypes.sh
@@ -0,0 +1,178 @@
+#!/bin/sh
+# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description="ensure pvmove works with the cache segment types"
+
+. lib/test
+
+# pvmove fails when a RAID LV is the origin of a cache LV
+# pvmoving cache types is currently disabled in tools/pvmove.c
+# So, for now we set everything up and make sure pvmove /isn't/ allowed.
+# This allows us to ensure that it is disallowed even when there are
+# stacking complications to consider.
+
+test -e LOCAL_CLVMD && skip
+which mkfs.ext2 || skip
+which md5sum || skip
+
+aux target_at_least dm-cache 1 3 0 || skip
+# for stacking
+aux target_at_least dm-thin-pool 1 8 0 || skip
+aux target_at_least dm-raid 1 4 2 || skip
+
+aux prepare_vg 5 80
+
+# Each of the following tests does:
+# 1) Create two LVs - one linear and one other segment type
+#    The two LVs will share a PV.
+# 2) Move both LVs together
+# 3) Move only the second LV by name
+
+# Testing pvmove of cache-pool LV (can't check contents though)
+###############################################################
+lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
+lvcreate --type cache-pool -n ${lv1}_pool -l 4 $vg "$dev1"
+check lv_tree_on $vg ${lv1}_foo "$dev1"
+check lv_tree_on $vg ${lv1}_pool "$dev1"
+
+pvmove "$dev1" "$dev5" 2>&1 | tee out
+grep "Skipping cache-pool LV, ${lv1}_pool" out
+grep "Skipping cache-related LV, ${lv1}_pool_cmeta" out
+grep "Skipping cache-related LV, ${lv1}_pool_cdata" out
+check lv_tree_on $vg ${lv1}_foo "$dev5"
+not check lv_tree_on $vg ${lv1}_pool "$dev5"
+
+#pvmove -n ${lv1}_pool "$dev5" "$dev4"
+#check lv_tree_on $vg ${lv1}_pool "$dev4"
+#check lv_tree_on $vg ${lv1}_foo "$dev5"
+
+lvremove -ff $vg
+
+# Testing pvmove of origin LV
+#############################
+lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
+lvcreate --type cache-pool -n ${lv1}_pool -l 4 $vg "$dev5"
+lvcreate --type cache -n $lv1 -l 8 $vg/${lv1}_pool "$dev1"
+
+check lv_tree_on $vg ${lv1}_foo "$dev1"
+check lv_tree_on $vg ${lv1}_pool "$dev5"
+check lv_tree_on $vg ${lv1} "$dev1"
+
+aux mkdev_md5sum $vg $lv1
+pvmove "$dev1" "$dev3" 2>&1 | tee out
+grep "Skipping cache LV, ${lv1}" out
+check lv_tree_on $vg ${lv1}_foo "$dev3"
+#check lv_tree_on $vg ${lv1}_pool "$dev5"
+lvs -a -o name,attr,devices $vg
+not check lv_tree_on $vg ${lv1} "$dev3"
+#check dev_md5sum $vg $lv1
+
+#pvmove -n $lv1 "$dev3" "$dev1"
+#check lv_tree_on $vg ${lv1}_foo "$dev3"
+#check lv_tree_on $vg ${lv1}_pool "$dev5"
+#check lv_tree_on $vg ${lv1} "$dev1"
+#check dev_md5sum $vg $lv1
+lvremove -ff $vg
+
+# Testing pvmove of a RAID origin LV
+####################################
+lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
+lvcreate --type raid1 -m 1 -l 8 -n $lv1 $vg "$dev1" "$dev2"
+lvcreate --type cache -l 4 -n ${lv1}_pool $vg/$lv1 "$dev5"
+check lv_tree_on $vg ${lv1}_foo "$dev1"
+check lv_tree_on $vg ${lv1} "$dev1" "$dev2"
+check lv_tree_on $vg ${lv1}_pool "$dev5"
+
+aux mkdev_md5sum $vg $lv1
+pvmove "$dev1" "$dev3" 2>&1 | tee out
+grep "Skipping cache LV, ${lv1}" out
+check lv_tree_on $vg ${lv1}_foo "$dev3"
+not check lv_tree_on $vg ${lv1} "$dev2" "$dev3"
+#check lv_tree_on $vg ${lv1}_pool "$dev5"
+#check dev_md5sum $vg $lv1 -- THIS IS WHERE THINGS FAIL IF PVMOVE NOT DISALLOWED
+
+#pvmove -n $lv1 "$dev3" "$dev1"
+#check lv_tree_on $vg ${lv1}_foo "$dev3"
+#check lv_tree_on $vg ${lv1} "$dev1" "$dev2"
+#check lv_tree_on $vg ${lv1}_pool "$dev5"
+#check dev_md5sum $vg $lv1
+lvremove -ff $vg
+
+# Testing pvmove of a RAID cachepool (metadata and data)
+########################################################
+lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
+lvcreate --type raid1 -L 2M -n meta $vg "$dev1" "$dev2"
+lvcreate --type raid1 -L 4M -n ${lv1}_pool $vg "$dev1" "$dev2"
+lvconvert --type cache-pool $vg/${lv1}_pool --poolmetadata $vg/meta
+lvcreate --type cache -n $lv1 -L 8M $vg/${lv1}_pool "$dev5"
+
+check lv_tree_on $vg ${lv1}_foo "$dev1"
+check lv_tree_on $vg ${lv1}_pool "$dev1" "$dev2"
+check lv_tree_on $vg ${lv1} "$dev5"
+
+aux mkdev_md5sum $vg $lv1
+# This will move ${lv1}_foo and the cache-pool data & meta
+#  LVs, both of which contain a RAID1 _rimage & _rmeta LV - 5 total LVs
+pvmove "$dev1" "$dev3" 2>&1 | tee out
+grep "Skipping cache-pool LV, ${lv1}_pool" out
+grep "Skipping cache-related LV, ${lv1}_pool_cmeta" out
+grep "Skipping cache-related LV, ${lv1}_pool_cdata" out
+check lv_tree_on $vg ${lv1}_foo "$dev3"
+not check lv_tree_on $vg ${lv1}_pool "$dev2" "$dev3"
+#check lv_tree_on $vg ${lv1} "$dev5"
+#check dev_md5sum $vg $lv1
+
+#pvmove -n ${lv1}_pool "$dev3" "$dev1"
+#check lv_tree_on $vg ${lv1}_foo "$dev3"
+#check lv_tree_on $vg ${lv1}_pool "$dev1" "$dev2"
+#check lv_tree_on $vg ${lv1} "$dev5"
+#check dev_md5sum $vg $lv1
+lvremove -ff $vg
+
+# Testing pvmove of Thin-pool on cache LV on RAID
+#################################################
+lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
+# RAID for cachepool
+lvcreate --type raid1 -m 1 -L 2M -n meta $vg "$dev1" "$dev2"
+lvcreate --type raid1 -m 1 -L 4M -n cachepool $vg "$dev1" "$dev2"
+lvconvert --type cache-pool $vg/cachepool --poolmetadata $vg/meta
+# RAID for thin pool data LV
+lvcreate --type raid1 -m 1 -L 8 -n thinpool $vg "$dev3" "$dev4"
+# Convert thin pool data to a cached LV
+lvconvert --type cache $vg/thinpool --cachepool $vg/cachepool
+# Create simple thin pool meta
+lvcreate -L 2M -n meta $vg "$dev1"
+# Use thin pool data LV to build a thin pool
+lvconvert --thinpool $vg/thinpool --poolmetadata $vg/meta
+# Create a thin lv for fun
+lvcreate -T $vg/thinpool -V 20 -n thin_lv
+
+check lv_tree_on $vg ${lv1}_foo "$dev1"
+check lv_tree_on $vg cachepool "$dev1" "$dev2"
+check lv_tree_on $vg thinpool "$dev1" "$dev3" "$dev4"
+
+aux mkdev_md5sum $vg thin_lv
+lvs -a -o name,attr,devices $vg
+# Should move ${lv1}_foo and thinpool_tmeta from dev1 to dev5
+pvmove "$dev1" "$dev5" 2>&1 | tee out
+lvs -a -o name,attr,devices $vg
+check lv_tree_on $vg ${lv1}_foo "$dev5"
+not check lv_tree_on $vg cachepool "$dev5" "$dev2"
+check lv_tree_on $vg thinpool "$dev3" "$dev4" "$dev5" # Move non-cache tmeta
+#check dev_md5sum $vg/thin_lv
+
+#pvmove -n $vg/cachepool "$dev5" "$dev1"
+#check lv_tree_on $vg ${lv1}_foo "$dev5"
+#check lv_tree_on $vg $vg/cachepool "$dev1" "$dev2"
+#check lv_tree_on $vg $vg/thinpool "$dev3" "$dev4"
+#check dev_md5sum $vg/thin_lv
+
+lvremove -ff $vg
\ No newline at end of file
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 19e1482..a7788ba 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -233,6 +233,32 @@ static int sub_lv_of(struct logical_volume *lv, const char *lv_name)
 	return sub_lv_of(seg->lv, lv_name);
 }
 
+/*
+ * parent_lv_is_cache_type
+ *
+ * FIXME: This function can be removed when 'pvmove' is supported for
+ *        cache types.
+ *
+ * If this LV is below a cache LV (at any depth), return 1.
+ */
+static int parent_lv_is_cache_type(struct logical_volume *lv)
+{
+	struct lv_segment *seg;
+
+	/* Sub-LVs only ever have one segment using them */
+	if (dm_list_size(&lv->segs_using_this_lv) != 1)
+		return 0;
+
+	if (!(seg = get_only_segment_using_this_lv(lv)))
+		return_0;
+
+	if (lv_is_cache_type(seg->lv))
+		return 1;
+
+	/* Continue up the tree */
+	return parent_lv_is_cache_type(seg->lv);
+}
+
 /* Create new LV with mirror segments for the required copies */
 static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 						struct volume_group *vg,
@@ -342,6 +368,23 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 		if (!lv_is_on_pvs(lv, source_pvl))
 			continue;
 
+		if (lv_is_cache_type(lv)) {
+			log_print_unless_silent("Skipping %s LV, %s",
+						lv_is_cache(lv) ? "cache" :
+						lv_is_cache_pool(lv) ?
+						"cache-pool" : "cache-related",
+						lv->name);
+			lv_skipped = 1;
+			continue;
+		}
+
+		if (parent_lv_is_cache_type(lv)) {
+			log_print_unless_silent("Skipping %s because a parent"
+						" is of cache type", lv->name);
+			lv_skipped = 1;
+			continue;
+		}
+
 		/*
 		 * If the VG is clustered, we are unable to handle
 		 * snapshots, origins, thin types, RAID or mirror



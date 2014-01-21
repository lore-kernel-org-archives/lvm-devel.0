From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 21 Jan 2014 12:54:18 +0000 (UTC)
Subject: master - tests: more testing for online thin metadata resize
Message-ID: <20140121125418.6F77260DB2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=efe36fcd43f243de5cdd5838c284b0e5a24ac893
Commit:        efe36fcd43f243de5cdd5838c284b0e5a24ac893
Parent:        22d9daff12b73e72f520ea70f416e1d3057ae740
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 21 10:04:23 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 21 13:53:10 2014 +0100

tests: more testing for online thin metadata resize

Some more tests for online resize, but it's still disabled
by default, since kernel doesn't work yet for this feature.
---
 test/shell/lvextend-thin-metadata-dmeventd.sh |   72 +++++++++++++++++++++++++
 test/shell/lvresize-thin-metadata.sh          |   26 +++++----
 2 files changed, 87 insertions(+), 11 deletions(-)

diff --git a/test/shell/lvextend-thin-metadata-dmeventd.sh b/test/shell/lvextend-thin-metadata-dmeventd.sh
new file mode 100644
index 0000000..4b4ee30
--- /dev/null
+++ b/test/shell/lvextend-thin-metadata-dmeventd.sh
@@ -0,0 +1,72 @@
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
+# Test autoextension of thin metadata volume
+. lib/test
+
+meta_percent_() {
+	get lv_field $vg/pool metadata_percent | cut -d. -f1
+}
+
+wait_for_change_() {
+	# dmeventd only checks every 10 seconds :(
+	for i in $(seq 1 15) ; do
+		test "$(meta_percent_)" != "$1" && return
+		sleep 1
+	done
+
+	return 1  # timeout
+}
+
+#
+# Temporary solution to create some occupied thin metadata
+# This heavily depends on thin metadata output format to stay as is.
+# Currently it expects 2MB thin metadata and 200MB data volume size
+# Argument specifies how many devices should be created.
+fake_metadata_() {
+	echo '<superblock uuid="" time="1" transaction="0" data_block_size="128" nr_data_blocks="3200">'
+	for i in $(seq 1 $1)
+	do
+		echo ' <device dev_id="'$i'" mapped_blocks="785" transaction="0" creation_time="0" snap_time="1">'
+		echo '  <range_mapping origin_begin="0" data_begin="0" length="37" time="0"/>'
+		echo ' </device>'
+	done
+	echo "</superblock>"
+}
+
+aux have_thin 1 10 0 || skip
+
+aux prepare_dmeventd
+
+aux lvmconf "activation/thin_pool_autoextend_percent = 10" \
+	    "activation/thin_pool_autoextend_threshold = 70"
+
+aux prepare_pvs 3 256
+
+vgcreate -s 1M $vg $(cat DEVICES)
+
+# Testing dmeventd autoresize
+lvcreate -L200M -V1G -n thin -T $vg/pool
+lvcreate -L2M -n $lv1 $vg
+
+# Prepare some fake metadata prefilled to ~81% (>70%)
+fake_metadata_ 400 >data
+
+thin_restore -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
+vgchange -an $vg
+# Swap volume with restored fake metadata
+lvconvert -y --thinpool $vg/pool --poolmetadata $vg/$lv1
+
+vgchange -ay $vg
+
+# Check dmeventd resizes metadata
+pre=$(meta_percent_)
+wait_for_change_ $pre
diff --git a/test/shell/lvresize-thin-metadata.sh b/test/shell/lvresize-thin-metadata.sh
index 16a7500..e62d8b6 100644
--- a/test/shell/lvresize-thin-metadata.sh
+++ b/test/shell/lvresize-thin-metadata.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2013 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2013-2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -11,31 +11,35 @@
 
 . lib/test
 
-aux have_thin 9 9 0 || skip
+aux have_thin 1 10 0 || skip
 
-aux prepare_pvs 3 256
+aux prepare_pvs 3 1256
 
 vgcreate -s 1M $vg $(cat DEVICES)
 
 for deactivate in true false; do
-	lvcreate -l1 -T $vg/pool
-
-	test $deactivate && lvchange -an $vg
-
+# Create some thin volumes
+	lvcreate -L20 -V30 -n $lv1 -T $vg/pool
+	lvcreate -s $vg/$lv1
 # Confirm we have basic 2M metadata
 	check lv_field $vg/pool_tmeta size "2.00m"
 
-	lvresize --poolmetadata +2 $vg/pool
+	test $deactivate && lvchange -an $vg
 
+	lvresize --poolmetadata +2M $vg/pool
 # Test it's been resized to 4M
 	check lv_field $vg/pool_tmeta size "4.00m"
 
-# TODO: Add more tests when kernel is fixed
-	lvresize --alloc anywhere --poolmetadata +256 $vg/pool
+	lvresize --poolmetadata +256M $vg/pool
+	check lv_field $vg/pool_tmeta size "260.00m"
+
+	lvresize --poolmetadata +3G $vg/pool
+	check lv_field $vg/pool_tmeta size "3.25g"
 
 	vgchange -an $vg
 	vgchange -ay $vg
 
-# TODO: Make a full metadata device and test dmeventd support
+# TODO: Add more tests
+
 	lvremove -ff $vg
 done



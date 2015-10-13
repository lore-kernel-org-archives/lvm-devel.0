From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:04:45 +0000 (UTC)
Subject: master - tests: more extend testing
Message-ID: <20151013140445.603B660EAD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=acc70de43968961e9a71612cda04642e4fbfd71f
Commit:        acc70de43968961e9a71612cda04642e4fbfd71f
Parent:        cf1c2da836223de64daacd94f0fd40a96f6cd46f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 13 14:33:24 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 16:02:21 2015 +0200

tests: more extend testing

---
 test/shell/lvextend-thin-metadata-dmeventd.sh |   51 +++++++++++++++++++++++--
 1 files changed, 47 insertions(+), 4 deletions(-)

diff --git a/test/shell/lvextend-thin-metadata-dmeventd.sh b/test/shell/lvextend-thin-metadata-dmeventd.sh
index ea081a2..9ecd5ae 100644
--- a/test/shell/lvextend-thin-metadata-dmeventd.sh
+++ b/test/shell/lvextend-thin-metadata-dmeventd.sh
@@ -37,14 +37,20 @@ wait_for_change_() {
 # Currently it expects 2MB thin metadata and 200MB data volume size
 # Argument specifies how many devices should be created.
 fake_metadata_() {
-	echo '<superblock uuid="" time="1" transaction="'$2'" data_block_size="128" nr_data_blocks="3200">'
-	for i in $(seq 1 $1)
+	echo '<superblock uuid="" time="0" transaction="'$2'" data_block_size="128" nr_data_blocks="3200">'
+	echo ' <device dev_id="1" mapped_blocks="0" transaction="0" creation_time="0" snap_time="0">'
+	echo ' </device>'
+	echo ' <device dev_id="2" mapped_blocks="0" transaction="0" creation_time="0" snap_time="0">'
+	echo ' </device>'
+	for i in $(seq 10 $1)
 	do
-		echo ' <device dev_id="'$i'" mapped_blocks="37" transaction="0" creation_time="0" snap_time="1">'
-		echo '  <range_mapping origin_begin="0" data_begin="0" length="37" time="0"/>'
+		echo ' <device dev_id="'$i'" mapped_blocks="30" transaction="0" creation_time="0" snap_time="0">'
+		echo '  <range_mapping origin_begin="0" data_begin="0" length="29" time="0"/>'
 		echo ' </device>'
+		set +x
 	done
 	echo "</superblock>"
+	set -x
 }
 
 test -n "$LVM_TEST_THIN_RESTORE_CMD" || LVM_TEST_THIN_RESTORE_CMD=$(which thin_restore) || skip
@@ -99,4 +105,41 @@ vgchange -ay $vg
 pre=$(meta_percent_)
 wait_for_change_ $pre
 
+lvchange -an $vg
+
+lvs -a $vg
+#
+fake_metadata_ 350 2 >data
+lvchange -ay $vg/$lv1
+"$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
+
+lvs -a $vg
+dmsetup table
+lvconvert -y --chunksize 64k --thinpool $vg/pool --poolmetadata $vg/$lv1
+lvchange -ay $vg/pool  $vg/$lv1
+lvs -a $vg
+
+lvcreate -s -Ky -n $lv2 $vg/thin
+echo 2 >"$DM_DEV_DIR/mapper/$vg-$lv2"
+
+#lvchange -an $vg
+#lvconvert -y --chunksize 64k --thinpool $vg/pool --poolmetadata $vg/$lv1
+#lvchange -ay $vg/$lv1
+#thin_dump "$DM_DEV_DIR/mapper/$vg-$lv1"
+#exit
+
+# no more space for new thin LV
+#
+# TODO:
+# though maybe 'lvcreate' itself should initiate  resize - if dmeventd is not 'fast' enough
+# deploying usage of threshold kernel module paramater would likely help as well
+# for now it stops here:
+not lvcreate -s -Ky -n $lv3 $vg/thin
+lvs -a $vg
+
+pre=$(meta_percent_)
+wait_for_change_ $pre
+
+lvs -a $vg
+
 vgremove -f $vg



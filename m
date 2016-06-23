From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Jun 2016 13:02:06 +0000 (UTC)
Subject: master - tests: aux prepare_thin_metadata
Message-ID: <20160623130206.5844060975@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a67a5d465576d4a7c17b22a737725d6dee059e18
Commit:        a67a5d465576d4a7c17b22a737725d6dee059e18
Parent:        83d483269de367facc14eee9072b79ffabdcaf82
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 13 14:35:09 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 23 14:59:29 2016 +0200

tests:  aux prepare_thin_metadata

---
 test/lib/aux.sh                  |   23 +++++++++++++++++++++++
 test/shell/lvextend-thin-full.sh |   18 +-----------------
 test/shell/thin-flags.sh         |   20 +-------------------
 3 files changed, 25 insertions(+), 36 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index d51a65c..8653149 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -354,6 +354,29 @@ prepare_lvmdbusd() {
 	echo ok
 }
 
+#
+# Temporary solution to create some occupied thin metadata
+# This heavily depends on thin metadata output format to stay as is.
+# Currently it expects 2MB thin metadata and 200MB data volume size
+# Argument specifies how many devices should be created.
+#
+prepare_thin_metadata() {
+	local devices=$1
+	local transaction_id=${2:-0}
+	local data_block_size=${3:-128}
+	local nr_data_blocks=${4:-3200}
+	local i
+
+	echo '<superblock uuid="" time="1" transaction="'$transaction_id'" data_block_size="'$data_block_size'" nr_data_blocks="'$nr_data_blocks'">'
+	for i in $(seq 1 $devices)
+	do
+		echo ' <device dev_id="'$i'" mapped_blocks="37" transaction="'$i'" creation_time="0" snap_time="1">'
+		echo '  <range_mapping origin_begin="0" data_begin="0" length="37" time="0"/>'
+		echo ' </device>'
+	done
+	echo "</superblock>"
+}
+
 teardown_devs_prefixed() {
 	local prefix=$1
 	local stray=${2:-0}
diff --git a/test/shell/lvextend-thin-full.sh b/test/shell/lvextend-thin-full.sh
index cd4705d..8fc89a8 100644
--- a/test/shell/lvextend-thin-full.sh
+++ b/test/shell/lvextend-thin-full.sh
@@ -25,22 +25,6 @@ aux have_thin 1 0 0 || skip
 test -n "$LVM_TEST_THIN_RESTORE_CMD" || LVM_TEST_THIN_RESTORE_CMD=$(which thin_restore) || skip
 "$LVM_TEST_THIN_RESTORE_CMD" -V || skip
 
-#
-# Temporary solution to create some occupied thin metadata
-# This heavily depends on thin metadata output format to stay as is.
-# Currently it expects 2MB thin metadata and 200MB data volume size
-# Argument specifies how many devices should be created.
-fake_metadata_() {
-	echo '<superblock uuid="" time="1" transaction="'$2'" data_block_size="128" nr_data_blocks="3200">'
-	for i in $(seq 1 $1)
-	do
-		echo ' <device dev_id="'$i'" mapped_blocks="37" transaction="0" creation_time="0" snap_time="1">'
-		echo '  <range_mapping origin_begin="0" data_begin="0" length="37" time="0"/>'
-		echo ' </device>'
-	done
-	echo "</superblock>"
-}
-
 aux have_thin 1 10 0 || skip
 
 aux prepare_pvs 3 256
@@ -50,7 +34,7 @@ vgcreate -s 1M $vg $(cat DEVICES)
 aux lvmconf 'activation/thin_pool_autoextend_percent = 30' \
 	    'activation/thin_pool_autoextend_threshold = 70'
 
-fake_metadata_ 400 0 >data
+aux prepare_thin_metadata 400 0 | tee data
 lvcreate -L200 -T $vg/pool
 lvchange -an $vg
 
diff --git a/test/shell/thin-flags.sh b/test/shell/thin-flags.sh
index 3fcafb2..395b98d 100644
--- a/test/shell/thin-flags.sh
+++ b/test/shell/thin-flags.sh
@@ -16,24 +16,6 @@ SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
-
-# TODO - aux/get support for this....
-fake_metadata_() {
-	echo '<superblock uuid="" time="0" transaction="'$2'" data_block_size="128" nr_data_blocks="3200">'
-	echo ' <device dev_id="1" mapped_blocks="0" transaction="0" creation_time="0" snap_time="0">'
-	echo ' </device>'
-	for i in $(seq 10 $1)
-	do
-		echo ' <device dev_id="'$i'" mapped_blocks="30" transaction="0" creation_time="0" snap_time="0">'
-		echo '  <range_mapping origin_begin="0" data_begin="0" length="29" time="0"/>'
-		echo ' </device>'
-		set +x
-	done
-	echo "</superblock>"
-	set -x
-}
-
-
 . lib/inittest
 
 #
@@ -85,7 +67,7 @@ aux lvmconf 'global/thin_check_executable = ""'
 
 # Prepare some fake metadata prefilled to ~100%
 lvcreate -L2 -n $lv1 $vg # tmp for metadata
-fake_metadata_ 500 1 >data
+aux prepare_thin_metadata 500 1 | tee data
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
 
 # Swap volume with restored fake metadata



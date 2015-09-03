From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Sep 2015 21:36:28 +0000 (UTC)
Subject: master - tests: update thin test
Message-ID: <20150903213628.6AECE61018@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5da497d0a81e100d803a1384a9394b0b513f176b
Commit:        5da497d0a81e100d803a1384a9394b0b513f176b
Parent:        dc261f17e96cb4012dd34329fd6ae9f766eb7c11
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 3 23:05:33 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 3 23:34:37 2015 +0200

tests: update thin test

Use slightly better values
---
 test/shell/lvextend-thin-metadata-dmeventd.sh |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvextend-thin-metadata-dmeventd.sh b/test/shell/lvextend-thin-metadata-dmeventd.sh
index 4e80f75..ea081a2 100644
--- a/test/shell/lvextend-thin-metadata-dmeventd.sh
+++ b/test/shell/lvextend-thin-metadata-dmeventd.sh
@@ -40,7 +40,7 @@ fake_metadata_() {
 	echo '<superblock uuid="" time="1" transaction="'$2'" data_block_size="128" nr_data_blocks="3200">'
 	for i in $(seq 1 $1)
 	do
-		echo ' <device dev_id="'$i'" mapped_blocks="785" transaction="0" creation_time="0" snap_time="1">'
+		echo ' <device dev_id="'$i'" mapped_blocks="37" transaction="0" creation_time="0" snap_time="1">'
 		echo '  <range_mapping origin_begin="0" data_begin="0" length="37" time="0"/>'
 		echo ' </device>'
 	done
@@ -68,7 +68,7 @@ lvcreate -L2M -n $lv1 $vg
 lvchange -an $vg/thin $vg/thin2 $vg/pool
 
 # Prepare some fake metadata with unmatching id
-# Transaction_id is lower by 1 and there are no message -> ERROR
+# Transaction_id is lower by 1 and there are no messages -> ERROR
 fake_metadata_ 10 0 >data
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
 lvconvert -y --thinpool $vg/pool --poolmetadata $vg/$lv1
@@ -91,7 +91,7 @@ fake_metadata_ 400 2 >data
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
 
 # Swap volume with restored fake metadata
-lvconvert -y --thinpool $vg/pool --poolmetadata $vg/$lv1
+lvconvert -y --chunksize 64k --thinpool $vg/pool --poolmetadata $vg/$lv1
 
 vgchange -ay $vg
 



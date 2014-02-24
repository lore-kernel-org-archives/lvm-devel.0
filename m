From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 24 Feb 2014 20:17:25 +0000 (UTC)
Subject: master - tests: enhance thin test
Message-ID: <20140224201725.315FA60EBE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=32138969f9f8bd4e33e2b9131ac67db061d75f70
Commit:        32138969f9f8bd4e33e2b9131ac67db061d75f70
Parent:        9c9f4515ae433beb2e6a582aacc422feb73c09dd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 24 09:46:09 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 24 21:13:36 2014 +0100

tests: enhance thin test

Add more tests to also check validaty of transaction_id
and also detect we are not leaving active unusable thin pool LVs.
---
 test/shell/lvextend-thin-metadata-dmeventd.sh |   29 +++++++++++++++++++++---
 1 files changed, 25 insertions(+), 4 deletions(-)

diff --git a/test/shell/lvextend-thin-metadata-dmeventd.sh b/test/shell/lvextend-thin-metadata-dmeventd.sh
index 4b4ee30..cb5261c 100644
--- a/test/shell/lvextend-thin-metadata-dmeventd.sh
+++ b/test/shell/lvextend-thin-metadata-dmeventd.sh
@@ -32,7 +32,7 @@ wait_for_change_() {
 # Currently it expects 2MB thin metadata and 200MB data volume size
 # Argument specifies how many devices should be created.
 fake_metadata_() {
-	echo '<superblock uuid="" time="1" transaction="0" data_block_size="128" nr_data_blocks="3200">'
+	echo '<superblock uuid="" time="1" transaction="'$2'" data_block_size="128" nr_data_blocks="3200">'
 	for i in $(seq 1 $1)
 	do
 		echo ' <device dev_id="'$i'" mapped_blocks="785" transaction="0" creation_time="0" snap_time="1">'
@@ -56,12 +56,31 @@ vgcreate -s 1M $vg $(cat DEVICES)
 # Testing dmeventd autoresize
 lvcreate -L200M -V1G -n thin -T $vg/pool
 lvcreate -L2M -n $lv1 $vg
+lvchange -an $vg/thin $vg/pool
 
-# Prepare some fake metadata prefilled to ~81% (>70%)
-fake_metadata_ 400 >data
+# Prepare some fake metadata with unmatching id
+# Transaction_id is lower by 1 and there are no message -> ERROR
+fake_metadata_ 10 0 >data
+thin_restore -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
+lvconvert -y --thinpool $vg/pool --poolmetadata $vg/$lv1
+not vgchange -ay $vg 2>&1 | tee out
+grep expected out
 
+check inactive $vg pool_tmeta
+
+# Transaction_id is higher by 1
+fake_metadata_ 10 2 >data
 thin_restore -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
-vgchange -an $vg
+lvconvert -y --thinpool $vg/pool --poolmetadata $vg/$lv1
+not vgchange -ay $vg 2>&1 | tee out
+grep expected out
+
+check inactive $vg pool_tmeta
+
+# Prepare some fake metadata prefilled to ~81% (>70%)
+fake_metadata_ 400 1 >data
+thin_restore -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
+
 # Swap volume with restored fake metadata
 lvconvert -y --thinpool $vg/pool --poolmetadata $vg/$lv1
 
@@ -70,3 +89,5 @@ vgchange -ay $vg
 # Check dmeventd resizes metadata
 pre=$(meta_percent_)
 wait_for_change_ $pre
+
+vgremove -f $vg



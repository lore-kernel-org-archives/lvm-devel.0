From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 25 Jun 2023 11:04:01 +0000 (GMT)
Subject: main - tests: correct generated metadata
Message-ID: <20230625110401.1D6FF3858D35@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5848f75278250835dd718fbcacc167133af66b35
Commit:        5848f75278250835dd718fbcacc167133af66b35
Parent:        0a5712ada4753cd034d862389e6e91af387c406f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jun 24 22:34:38 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Jun 25 12:00:57 2023 +0200

tests: correct generated metadata

Newer thin_check actually rejects such restored data.
---
 test/shell/lvextend-thin-metadata-dmeventd.sh | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/test/shell/lvextend-thin-metadata-dmeventd.sh b/test/shell/lvextend-thin-metadata-dmeventd.sh
index 3193cc29c..732f67023 100644
--- a/test/shell/lvextend-thin-metadata-dmeventd.sh
+++ b/test/shell/lvextend-thin-metadata-dmeventd.sh
@@ -48,7 +48,7 @@ fake_metadata_() {
 	for i in $(seq 10 $1)
 	do
 		echo ' <device dev_id="'$i'" mapped_blocks="30" transaction="0" creation_time="0" snap_time="0">'
-		echo '  <range_mapping origin_begin="0" data_begin="0" length="29" time="0"/>'
+		echo '  <range_mapping origin_begin="0" data_begin="0" length="30" time="0"/>'
 		echo ' </device>'
 		set +x
 	done
@@ -98,6 +98,10 @@ DATA=7200  # Newer version of thin-pool have hidden reserve, so use lower value
 test -z "$BIG_DATA" || DATA=7400
 fake_metadata_ "$DATA" 2 >data
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv2"
+
+# Check tha restored metadata are OK for thin_check
+"$LVM_TEST_THIN_CHECK_CMD" "$DM_DEV_DIR/mapper/$vg-$lv2"
+
 # Swap volume with restored fake metadata
 lvconvert -y --chunksize 64k --thinpool $vg/pool --poolmetadata $vg/$lv2
 lvchange -ay $vg/pool


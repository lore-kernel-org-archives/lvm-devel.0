From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Oct 2020 23:38:08 +0000 (GMT)
Subject: stable-2.02 - tests: fsadm test continue after fs repair
Message-ID: <20201023233808.B3D6E3858003@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=67dc22b95e7edfc3c0a96d96af313e7384908546
Commit:        67dc22b95e7edfc3c0a96d96af313e7384908546
Parent:        9a2a59c0ed4320324e908be60693bac7ed507824
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 24 00:29:45 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Oct 24 01:33:39 2020 +0200

tests: fsadm test continue after fs repair

Test case where filesystem has been corrected via fsck.
In such case fsck returns '1' as success and should be
handled in a same way as '0' since fs is correct.
---
 test/shell/fsadm.sh | 27 ++++++++++++++++++++++++++-
 1 file changed, 26 insertions(+), 1 deletion(-)

diff --git a/test/shell/fsadm.sh b/test/shell/fsadm.sh
index 8141da42c..3e7f9083c 100644
--- a/test/shell/fsadm.sh
+++ b/test/shell/fsadm.sh
@@ -61,7 +61,8 @@ cleanup_mounted_and_teardown()
 
 fscheck_ext3()
 {
-	fsck.ext3 -p -F -f "$dev_vg_lv"
+	# fsck with result code '1' is success
+	fsck.ext3 -p -F -f "$dev_vg_lv" || test "$?" -eq 1
 }
 
 fscheck_xfs()
@@ -113,6 +114,30 @@ if check_missing ext2; then
 	fscheck_ext3
 
 	lvresize -f -L20M $vg_lv
+
+	if which debugfs ; then
+		mkfs.ext2 -b4096 -j "$dev_vg_lv"
+		mount "$dev_vg_lv" "$mount_dir"
+		touch "$mount_dir/file"
+		umount "$mount_dir"
+		# generate a 'repariable' corruption
+		# so fsck returns code 1  (fs repaired)
+		debugfs -R "clri file" -w "$dev_vg_lv"
+
+		fsadm -v -f check "$dev_vg_lv"
+
+		# corrupting again
+		mount "$dev_vg_lv" "$mount_dir"
+		touch "$mount_dir/file"
+		umount "$mount_dir"
+		debugfs -R "clri file" -w "$dev_vg_lv"
+
+		mount "$dev_vg_lv" "$mount_dir"
+		fsadm -v -y --lvresize resize $vg_lv 10M
+		lvresize -L+10M -y -r -n $vg_lv
+		umount "$mount_dir" 2>/dev/null || true
+		fscheck_ext3
+	fi
 fi
 
 if check_missing ext3; then



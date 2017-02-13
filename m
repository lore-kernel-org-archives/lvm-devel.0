From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 13 Feb 2017 09:15:02 +0000 (UTC)
Subject: master - tests: update
Message-ID: <20170213091502.32ED5601A5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2923d9e47deb11b28b8b753dd7862da186da051c
Commit:        2923d9e47deb11b28b8b753dd7862da186da051c
Parent:        c3b1f1a07ac4931ee4b7b843741d8ec09d8eea5c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 13 09:32:28 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 13 10:06:19 2017 +0100

tests: update

---
 test/shell/thin-autoumount-dmeventd.sh |   18 ++++++++----------
 1 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/test/shell/thin-autoumount-dmeventd.sh b/test/shell/thin-autoumount-dmeventd.sh
index b2b20a5..5e1c2be 100644
--- a/test/shell/thin-autoumount-dmeventd.sh
+++ b/test/shell/thin-autoumount-dmeventd.sh
@@ -42,8 +42,6 @@ export MKE2FS_CONFIG="$TESTDIR/lib/mke2fs.conf"
 
 aux have_thin 1 0 0 || skip
 
-aux lvmconf "dmeventd/thin_command = \"$PWD/testcmd.sh\""
-
 # Simple implementation of umount when lvextend fails
 cat <<- EOF >testcmd.sh
 #!/bin/sh
@@ -54,26 +52,26 @@ echo "Metadata: \$DMEVENTD_THIN_POOL_METADATA"
 $TESTDIR/lib/lvextend --use-policies \$1 || {
 	umount "$mntdir"  || true
 	umount "$mntusedir" || true
-	return 1
+	return 0
 }
 test \$($TESTDIR/lib/lvs -o selected -S "data_percent>95||metadata_percent>95" --noheadings \$1) -eq 0 || {
 	umount "$mntdir"  || true
 	umount "$mntusedir" || true
-	return 1
+	return 0
 }
 EOF
 chmod +x testcmd.sh
 # Show prepared script
 cat testcmd.sh
 
-aux prepare_dmeventd
-
 # Use autoextend percent 0 - so extension fails and triggers umount...
 aux lvmconf "activation/thin_pool_autoextend_percent = 0" \
-            "activation/thin_pool_autoextend_threshold = 70"
+	    "activation/thin_pool_autoextend_threshold = 70" \
+	    "dmeventd/thin_command = \"/$PWD/testcmd.sh\""
 
-aux prepare_vg 2
+aux prepare_dmeventd
 
+aux prepare_vg 2
 
 lvcreate -L8M -V8M -n $lv1 -T $vg/pool
 lvcreate -V8M -n $lv2 -T $vg/pool
@@ -85,8 +83,8 @@ lvchange --monitor y $vg/pool
 
 mkdir "$mntdir" "$mntusedir"
 trap 'cleanup_mounted_and_teardown' EXIT
-mount "$DM_DEV_DIR/mapper/$vg-$lv1" "$mntdir"
-mount "$DM_DEV_DIR/mapper/$vg-$lv2" "$mntusedir"
+mount "$DM_DEV_DIR/$vg/$lv1" "$mntdir"
+mount "$DM_DEV_DIR/$vg/$lv2" "$mntusedir"
 
 # Check both LVs are opened (~mounted)
 is_lv_opened_ "$vg/$lv1"



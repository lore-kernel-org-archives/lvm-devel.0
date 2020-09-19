From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 19 Sep 2020 22:39:01 +0000 (GMT)
Subject: master - tests: use 4K with mkfs.xfs
Message-ID: <20200919223901.49473395CC7C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=531a475afcc602d573581eb11ecc572e427f0f35
Commit:        531a475afcc602d573581eb11ecc572e427f0f35
Parent:        a1074da20d309cf07be472c82a060e088f78127e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 19 23:58:30 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Sep 20 00:37:21 2020 +0200

tests: use 4K with mkfs.xfs

If the test runs of loop device backend with 512 sectors,
xfs selects this smaller sector size and then data do not fit
(we would need -l9 with most of 'raids').
With 4K sectors data always fits.
---
 test/shell/integrity-dmeventd.sh | 2 +-
 test/shell/integrity.sh          | 6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/test/shell/integrity-dmeventd.sh b/test/shell/integrity-dmeventd.sh
index 043e93371..e82b92142 100644
--- a/test/shell/integrity-dmeventd.sh
+++ b/test/shell/integrity-dmeventd.sh
@@ -39,7 +39,7 @@ _prepare_vg() {
 }
 
 _add_new_data_to_mnt() {
-        mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+	mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg/$lv1"
 
         mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 
diff --git a/test/shell/integrity.sh b/test/shell/integrity.sh
index 1f031e0ed..4da40bcb4 100644
--- a/test/shell/integrity.sh
+++ b/test/shell/integrity.sh
@@ -47,7 +47,7 @@ _prepare_vg() {
 }
 
 _test_fs_with_error() {
-	mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+	mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg/$lv1"
 
 	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 
@@ -97,7 +97,7 @@ _test_fs_with_error() {
 }
 
 _test_fs_with_raid() {
-	mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+	mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg/$lv1"
 
 	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 
@@ -144,7 +144,7 @@ _test_fs_with_raid() {
 }
 
 _add_new_data_to_mnt() {
-	mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+	mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg/$lv1"
 
 	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 



From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Feb 2023 13:31:37 +0000 (GMT)
Subject: main - tests: skip test without mkfs.ext4
Message-ID: <20230213133137.3AD1E383FBA4@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7ea62f640cbe41b981c56ee334d6924da3bb3c0a
Commit:        7ea62f640cbe41b981c56ee334d6924da3bb3c0a
Parent:        2241982f9636592268fc75b17d1a00e0ee786a65
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 10 23:07:52 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 13 13:41:59 2023 +0100

tests: skip test without mkfs.ext4

---
 test/shell/fsadm-crypt-fsresize.sh | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/test/shell/fsadm-crypt-fsresize.sh b/test/shell/fsadm-crypt-fsresize.sh
index 56cd5c508..4ad2ab980 100644
--- a/test/shell/fsadm-crypt-fsresize.sh
+++ b/test/shell/fsadm-crypt-fsresize.sh
@@ -23,6 +23,8 @@ export LVM_TEST_PREFER_BRD=0
 aux prepare_vg 1 300
 
 # Tests require a libblkid version that shows FSLASTBLOCK
+which mkfs.ext4 || skip
+
 lvcreate -n $lv1 -L 100 $vg
 mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
 blkid -p "$DM_DEV_DIR/$vg/$lv1" | grep FSLASTBLOCK || skip


From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 May 2023 14:22:32 +0000 (GMT)
Subject: main - tests: skip this testing without newer blkid
Message-ID: <20230510142232.04CCF385357B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bc28082b990bf752a2ce6ffa13aff9452c655ab8
Commit:        bc28082b990bf752a2ce6ffa13aff9452c655ab8
Parent:        d418fc14f48ba8feb3f5c561f5626a673aef4863
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 10 11:45:50 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 10 16:19:46 2023 +0200

tests: skip this testing without newer blkid

Testing xfs --fs functionality needs new blkid.
---
 test/shell/lvresize-xfs.sh | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/test/shell/lvresize-xfs.sh b/test/shell/lvresize-xfs.sh
index 0a3b89012..7f3193941 100644
--- a/test/shell/lvresize-xfs.sh
+++ b/test/shell/lvresize-xfs.sh
@@ -45,6 +45,11 @@ mkdir -p "$mount_dir_space"
 lvcreate -n $lv -L 300M $vg
 mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
 mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+
+# --fs tests require a libblkid version that shows FSLASTBLOCK
+# so exit 0 test here, if the feature is not present
+blkid -p "$DM_DEV_DIR/$vg/$lv" | grep FSLASTBLOCK || skip
+
 df --output=size "$mount_dir" |tee df1
 dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=10 oflag=direct
 lvextend -L+20M $vg/$lv


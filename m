From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 13 Jul 2017 15:13:10 -0400
Subject: master - tests: wait for udev to minize race windows
Message-ID: <201707131913.v6DJDAJL013607@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f64f6c5e703e6d3632acf68fa353b71f452bbfc7
Commit:        f64f6c5e703e6d3632acf68fa353b71f452bbfc7
Parent:        870c7bc76c291aec4c475436f13328fdc0467881
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 13 21:10:06 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 13 21:11:16 2017 +0200

tests: wait for udev to minize race windows

mkfs can complain about volume in use when meets udev rule processing.
---
 test/shell/snapshot-merge-stack.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/shell/snapshot-merge-stack.sh b/test/shell/snapshot-merge-stack.sh
index 6eca2a0..fe20865 100644
--- a/test/shell/snapshot-merge-stack.sh
+++ b/test/shell/snapshot-merge-stack.sh
@@ -26,6 +26,7 @@ aux prepare_vg 2 100
 snap_and_merge() {
 	lvcreate -s -n $lv2 -L20 $vg/$lv1 "$dev2"
 	#dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv1" bs=1M count=10 conv=fdatasync
+	aux udev_wait
 	mkfs.ext3 "$DM_DEV_DIR/$vg/$lv2"
 	sync
 	lvs -a $vg



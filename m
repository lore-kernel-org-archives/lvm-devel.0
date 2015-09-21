From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 21 Sep 2015 22:11:59 +0000 (UTC)
Subject: master - tests: update removal test
Message-ID: <20150921221159.0E02F60703@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=47f623d64b6432fbb3533cb72132c947eeb01941
Commit:        47f623d64b6432fbb3533cb72132c947eeb01941
Parent:        7e63364529e563cf7609875f6aca10303c03883e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 21 22:44:43 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 22 00:08:45 2015 +0200

tests: update removal test

Test is currently checking a very non-standard use case.
Make it a more resistent against being blocked in kernel.
---
 test/shell/snapshot-remove-dmsetup.sh |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/test/shell/snapshot-remove-dmsetup.sh b/test/shell/snapshot-remove-dmsetup.sh
index b5aad1f..610d3c2 100644
--- a/test/shell/snapshot-remove-dmsetup.sh
+++ b/test/shell/snapshot-remove-dmsetup.sh
@@ -34,11 +34,19 @@ mkfs.ext2 "$DM_DEV_DIR/$vg1/snap"
 mkdir mnt
 mount -o errors=remount-ro "$DM_DEV_DIR/$vg1/snap" mnt
 
+sync
+
 # intetionally suspend layer bellow
 dmsetup suspend $vg-$lv1
 
 # now this should pass without blocking
-dmsetup suspend --noflush --nolockfs $vg1-snap
+#dmsetup suspend --noflush --nolockfs $vg1-snap &
+dmsetup suspend $vg1-snap &
+
+sleep .5
+
+dmsetup info --noheadings -c -o suspended $vg1-snap | tee out
+should grep -i suspend out
 
 # unlock device below
 dmsetup resume $vg-$lv1



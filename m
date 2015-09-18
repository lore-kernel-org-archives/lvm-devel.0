From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 18 Sep 2015 15:46:01 +0000 (UTC)
Subject: master - tests: use remount-ro for extfs
Message-ID: <20150918154601.E6CB9606FB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7d1dd5f52d26ebe15dd6de211001ece975be2c7c
Commit:        7d1dd5f52d26ebe15dd6de211001ece975be2c7c
Parent:        330d584617778b2ac3a852d482c6b8d49818d9eb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 18 15:08:28 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 18 17:45:46 2015 +0200

tests: use remount-ro for extfs

Avoid showing kernel warn of umounting broken fs.
---
 test/shell/snapshot-autoumount-dmeventd.sh |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/test/shell/snapshot-autoumount-dmeventd.sh b/test/shell/snapshot-autoumount-dmeventd.sh
index 9fc1c72..e82a757 100644
--- a/test/shell/snapshot-autoumount-dmeventd.sh
+++ b/test/shell/snapshot-autoumount-dmeventd.sh
@@ -1,5 +1,5 @@
 #!/bin/bash
-# Copyright (C) 2010-2012 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2010-2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -31,18 +31,23 @@ lvcreate -s -L4 -n snap $vg/base
 lvchange --monitor y $vg/snap
 
 mkdir "$mntdir"
-mount "$DM_DEV_DIR/mapper/$vg-snap" "$mntdir"
+# Use remount-ro  to avoid logging kernel WARNING
+mount -o errors=remount-ro "$DM_DEV_DIR/mapper/$vg-snap" "$mntdir"
+
+test $(dmsetup info -c --noheadings -o open $vg-snap) -eq 1
 
 cat /proc/mounts | grep "$mntdir"
-not dd if=/dev/zero of="$mntdir/file$1" bs=1M count=5 conv=fdatasync
+
+# overfill 4M snapshot (with metadata)
+not dd if=/dev/zero of="$mntdir/file$1" bs=1M count=4 conv=fdatasync
 
 # Should be nearly instant check of dmeventd for invalid snapshot.
 # Wait here for umount and open_count drops to 0 as it may
 # take a while to finalize umount operation (it might be already
 # removed from /proc/mounts, but still opened).
 for i in {1..100}; do
-	test $(dmsetup info -c --noheadings -o open $vg-snap) -eq 0 && break
 	sleep .1
+	test $(dmsetup info -c --noheadings -o open $vg-snap) -eq 0 && break
 done
 
 cat /proc/mounts | not grep "$mntdir"



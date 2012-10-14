From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 14 Oct 2012 21:21:20 +0000 (UTC)
Subject: master - test: speedup a bit
Message-ID: <20121014212120.825DF22FD@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c6f2821b9fb74bec2de29a878e71fc64a70d11bb
Commit:        c6f2821b9fb74bec2de29a878e71fc64a70d11bb
Parent:        16060b101bdb541376fdfd7c0e6cac8cf73c0271
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Oct 14 19:45:59 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 14 23:17:33 2012 +0200

test: speedup a bit

Do not wait full 10s if the invalid snapshot is already dropped.
---
 test/shell/snapshot-autoumount-dmeventd.sh |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/test/shell/snapshot-autoumount-dmeventd.sh b/test/shell/snapshot-autoumount-dmeventd.sh
index dbb90df..3b4b711 100644
--- a/test/shell/snapshot-autoumount-dmeventd.sh
+++ b/test/shell/snapshot-autoumount-dmeventd.sh
@@ -1,5 +1,5 @@
 #!/bin/bash
-# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2010-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -32,10 +32,13 @@ mkdir "$mntdir"
 mount "$DM_DEV_DIR/mapper/$vg-snap" "$mntdir"
 mount
 cat /proc/mounts | grep "$mntdir"
-
-dd if=/dev/zero of="$mntdir/file$1" bs=1M count=17
+dd if=/dev/zero of="$mntdir/file$1" bs=1M count=16
 sync
-sleep 10 # dmeventd only checks every 10 seconds :(
+#dmeventd only checks every 10 seconds :(
+for i in {1..10}; do
+	cat /proc/mounts | grep "$mntdir" || break
+	sleep 1
+done
 
 cat /proc/mounts | not grep "$mntdir"
 



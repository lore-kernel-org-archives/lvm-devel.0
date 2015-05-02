From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat,  2 May 2015 22:43:55 +0000 (UTC)
Subject: master - tests: more waits on restart
Message-ID: <20150502224355.B6E7561801@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=224e30a4b18e66f3c269ed97a1ab14229d3e7ec7
Commit:        224e30a4b18e66f3c269ed97a1ab14229d3e7ec7
Parent:        31f1375d23fcc23a35e67bd8780d1ba82db4be56
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun May 3 00:29:06 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun May 3 00:43:15 2015 +0200

tests: more waits on restart

Check for socket presence (hardcoded for now)
---
 test/shell/clvmd-restart.sh |   35 ++++++++++++++++++++---------------
 1 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/test/shell/clvmd-restart.sh b/test/shell/clvmd-restart.sh
index 4a9f12e..cb06bf6 100644
--- a/test/shell/clvmd-restart.sh
+++ b/test/shell/clvmd-restart.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2011-2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -19,9 +19,23 @@ export LVM_BINARY=lvm
 test -e LOCAL_CLVMD || skip
 read LOCAL_CLVMD < LOCAL_CLVMD
 
-aux prepare_pvs 1
+# TODO read from build, for now hardcoded
+CLVMD_SOCKET="/var/run/lvm/clvmd.sock"
 
-vgcreate --clustered y $vg $(cat DEVICES)
+restart_clvmd_() {
+	"$LVM_CLVMD_BINARY" -S
+	ls -la $CLVMD_SOCKET || true
+
+	for i in $(seq 1 20) ; do
+		test -S "$CLVMD_SOCKET" && break
+		sleep .1
+	done
+	# restarted clvmd has the same PID (no fork, only execvp)
+	NEW_LOCAL_CLVMD=$(pgrep clvmd)
+	test "$LOCAL_CLVMD" -eq "$NEW_LOCAL_CLVMD"
+}
+
+aux prepare_vg
 
 lvcreate -an --zero n -n $lv1 -l1 $vg
 lvcreate -an --zero n -n $lv2 -l1 $vg
@@ -30,19 +44,10 @@ lvcreate -l1 $vg
 lvchange -aey $vg/$lv1
 lvchange -aey $vg/$lv2
 
-"$LVM_CLVMD_BINARY" -S
-sleep .2
-# restarted clvmd has the same PID (no fork, only execvp)
-NEW_LOCAL_CLVMD=$(pgrep clvmd)
-test "$LOCAL_CLVMD" -eq "$NEW_LOCAL_CLVMD"
+restart_clvmd_
 
 # try restart once more
-
-"$LVM_CLVMD_BINARY" -S
-sleep .2
-# restarted clvmd has the same PID (no fork, only execvp)
-NEW_LOCAL_CLVMD=$(pgrep clvmd)
-test "$LOCAL_CLVMD" -eq "$NEW_LOCAL_CLVMD"
+restart_clvmd_
 
 # FIXME: Hmm - how could we test exclusivity is preserved in singlenode ?
 lvchange -an $vg/$lv1
@@ -55,7 +60,7 @@ vgchange -an $vg
 
 # Test what happens after 'reboot'
 kill "$LOCAL_CLVMD"
-while test -e "/var/run/clvmd.pid"; do echo -n .; sleep .1; done # wait for the pid removal
+while test -e "$CLVMD_PIDFILE"; do echo -n .; sleep .1; done # wait for the pid removal
 aux prepare_clvmd
 
 vgchange -ay $vg



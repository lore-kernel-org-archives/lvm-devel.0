From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 26 May 2013 17:12:03 +0000 (UTC)
Subject: dev-mornfall-nix - test: Skip the double log failure test on 2.6 kernels as it deadlocks.
Message-ID: <20130526171203.132F061055@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=32408226c7187d4526699bd2d93a6fcfb8c56299
Commit:        32408226c7187d4526699bd2d93a6fcfb8c56299
Parent:        66c0f037fe61b9bf23d623f5c10f750af58870a6
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun May 26 18:53:29 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun May 26 18:54:46 2013 +0200

test: Skip the double log failure test on 2.6 kernels as it deadlocks.

---
 test/shell/lvconvert-repair-replace.sh |   26 ++++++++++++++------------
 1 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/test/shell/lvconvert-repair-replace.sh b/test/shell/lvconvert-repair-replace.sh
index 974628a..8543698 100644
--- a/test/shell/lvconvert-repair-replace.sh
+++ b/test/shell/lvconvert-repair-replace.sh
@@ -28,19 +28,21 @@ aux enable_dev "$dev1" "$dev2"
 
 vgremove -ff $vg; vgcreate -c n $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6"
 
-# 2-way, mirrored log
-# Double log failure, full replace
-lvcreate --mirrorlog mirrored -m 1 --ig -L 1 -n 2way $vg \
-    "$dev1" "$dev2" "$dev3":0 "$dev4":0
-aux disable_dev "$dev3" "$dev4"
-echo y | lvconvert --repair $vg/2way 2>&1 | tee 2way.out
-lvs -a -o +devices $vg | not grep unknown
-not grep "WARNING: Failed" 2way.out
-vgreduce --removemissing $vg
-check mirror $vg 2way
-aux enable_dev "$dev3" "$dev4"
+if kernel_at_least 3 0 0; then
+    # 2-way, mirrored log
+    # Double log failure, full replace
+    lvcreate --mirrorlog mirrored -m 1 --ig -L 1 -n 2way $vg \
+        "$dev1" "$dev2" "$dev3":0 "$dev4":0
+    aux disable_dev "$dev3" "$dev4"
+    echo y | lvconvert --repair $vg/2way 2>&1 | tee 2way.out
+    lvs -a -o +devices $vg | not grep unknown
+    not grep "WARNING: Failed" 2way.out
+    vgreduce --removemissing $vg
+    check mirror $vg 2way
+    aux enable_dev "$dev3" "$dev4"
 
-vgremove -ff $vg; vgcreate -c n $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6"
+    vgremove -ff $vg; vgcreate -c n $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6"
+fi
 
 # 3-way, mirrored log
 # Single log failure, replace



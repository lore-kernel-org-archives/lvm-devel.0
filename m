From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:28:21 +0000 (UTC)
Subject: dev-mornfall-activate - tests: skip the double log failure test on 2.6
Message-ID: <20130604192821.CFCBE6125D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e4cb88009ac05654ffdb011e3a11fd80bfbe283e
Commit:        e4cb88009ac05654ffdb011e3a11fd80bfbe283e
Parent:        249ea4c34c40ed98a649a439c65e4a17c951a2b8
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun May 26 18:53:29 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Jun 2 00:50:09 2013 +0200

tests: skip the double log failure test on 2.6

On 2.6 kernels this deadlocks.
---
 test/shell/lvconvert-repair-replace.sh |   28 +++++++++++++++-------------
 1 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/test/shell/lvconvert-repair-replace.sh b/test/shell/lvconvert-repair-replace.sh
index c85c1cf..73235a4 100644
--- a/test/shell/lvconvert-repair-replace.sh
+++ b/test/shell/lvconvert-repair-replace.sh
@@ -65,19 +65,21 @@ vgremove -ff $vg
 # FIXME  - exclusive activation for mirrors should work here
 test -e LOCAL_CLVMD && exit 0
 
-# 2-way, mirrored log
-# Double log failure, full replace
-vgcreate $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6"
-lvcreate -aey --mirrorlog mirrored -m 1 --ig -L 1 -n 2way $vg \
-    "$dev1" "$dev2" "$dev3":0 "$dev4":0
-aux disable_dev "$dev3" "$dev4"
-lvconvert -y --repair $vg/2way 2>&1 | tee 2way.out
-lvs -a -o +devices $vg | not grep unknown
-not grep "WARNING: Failed" 2way.out
-vgreduce --removemissing $vg
-check mirror $vg 2way
-aux enable_dev "$dev3" "$dev4"
-vgremove -ff $vg
+if kernel_at_least 3 0 0; then
+	# 2-way, mirrored log
+	# Double log failure, full replace
+	vgcreate $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6"
+	lvcreate -aey --mirrorlog mirrored -m 1 --ig -L 1 -n 2way $vg \
+	    "$dev1" "$dev2" "$dev3":0 "$dev4":0
+	aux disable_dev "$dev3" "$dev4"
+	lvconvert -y --repair $vg/2way 2>&1 | tee 2way.out
+	lvs -a -o +devices $vg | not grep unknown
+	not grep "WARNING: Failed" 2way.out
+	vgreduce --removemissing $vg
+	check mirror $vg 2way
+	aux enable_dev "$dev3" "$dev4"
+	vgremove -ff $vg
+fi
 
 # 3-way, mirrored log
 # Single log failure, replace



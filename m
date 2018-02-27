From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 27 Feb 2018 08:38:36 -0500
Subject: master - tests: check vgsplit thin-data and ext.origin
Message-ID: <201802271338.w1RDcaCe012259@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=32bcdd90ae7c847e7b4fc5cc5184c581a4f6484a
Commit:        32bcdd90ae7c847e7b4fc5cc5184c581a4f6484a
Parent:        8e5305f630be818e677572e4c43d2c728a89f54f
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Feb 27 13:45:39 2018 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Feb 27 14:37:47 2018 +0100

tests: check vgsplit thin-data and ext.origin

---
 test/shell/vgsplit-thin.sh |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/test/shell/vgsplit-thin.sh b/test/shell/vgsplit-thin.sh
index 0e4572e..a2d0a0b 100644
--- a/test/shell/vgsplit-thin.sh
+++ b/test/shell/vgsplit-thin.sh
@@ -44,3 +44,23 @@ lvs -a -o+devices $vg1 $vg2
 vgmerge $vg1 $vg2
 
 vgremove -ff $vg1
+
+# Test vgsplit with ext.origin:
+if aux have_thin 1 5 0; then
+vgcreate "$vg1" "${DEVICES[@]}"
+lvcreate -T -L8M $vg1/pool1 -V10M -n $lv1 "$dev1" "$dev2"
+lvcreate -l1 -an -pr -n $lv2 $vg1 "$dev3"
+lvcreate -s $vg1/$lv2 -n $lv3 --thinpool $vg1/pool1
+lvcreate -l1 -n $lv4 $vg1 "$dev4"
+vgchange -an $vg1
+
+# Can not split ext.origin from thin-data:
+not vgsplit $vg1 $vg2 "$dev1" "$dev2"
+not vgsplit $vg1 $vg2 "$dev3"
+
+vgsplit $vg1 $vg2 "$dev1" "$dev2" "$dev3"
+
+vgmerge $vg1 $vg2
+
+vgremove -ff $vg1
+fi



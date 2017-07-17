From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Jul 2017 07:41:08 -0400
Subject: master - tests: extend lvcreate size validation
Message-ID: <201707171141.v6HBf8oU022640@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d15b9ac51003bee0c2fd65697e32e6726f5de773
Commit:        d15b9ac51003bee0c2fd65697e32e6726f5de773
Parent:        567aa60fa1aa1779d0f30c9ff2ad9c4fafec3d23
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jul 16 11:18:13 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 17 12:33:42 2017 +0200

tests: extend lvcreate size validation

---
 test/shell/lvcreate-usage.sh |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvcreate-usage.sh b/test/shell/lvcreate-usage.sh
index a6be443..4b5c2b6 100644
--- a/test/shell/lvcreate-usage.sh
+++ b/test/shell/lvcreate-usage.sh
@@ -27,8 +27,19 @@ grep "Invalid argument for --type" err
 invalid lvcreate --type $RANDOM -l1 -n $lv1 $vg
 invalid lvcreate --type unknown -l1 -n $lv1 $vg
 
+invalid lvcreate -L10000000000000000000 -n $lv $vg 2>&1 | tee err
+grep "Size is too big" err
+invalid lvcreate -L+-10 -n $lv $vg 2>&1 | tee err
+grep "Multiple sign" err
+invalid lvcreate -L-.1 -n $lv $vg  2>&1 | tee err
+grep "Size may not be negative" err
+invalid lvcreate -L..1 -n $lv $vg  2>&1 | tee err
+grep "Can't parse size" err
+
 lvcreate --type linear -aey -m0 -l1 -n $lv1 $vg
 lvcreate --type snapshot -l1 -n $lv2 $vg/$lv1
+# Supporting decimal point with size
+lvcreate -L.1 -n $lv3 $vg
 
 # Reject repeated invocation (run 2 times) (bz178216)
 lvcreate -n $lv -l 4 $vg



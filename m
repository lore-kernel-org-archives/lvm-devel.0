From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 17 Mar 2018 19:37:10 -0400
Subject: master - tests: use 4k extents
Message-ID: <201803172337.w2HNbARN024439@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=08487a30983bfa4b3c0a7bcd9060657b6c1803ae
Commit:        08487a30983bfa4b3c0a7bcd9060657b6c1803ae
Parent:        e5b40e0488ae85e4adf8736e06a973666ea9280c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 18 00:30:43 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Mar 18 00:30:43 2018 +0100

tests: use 4k extents

Use 4K chunks since some older kernels are not capable
to create striped volumes with smaller size.

TODO: lvm2 should detect this ahead and avoid kernel
reporting "Invalid chunk".
---
 test/shell/lvconvert-snapshot.sh |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-snapshot.sh b/test/shell/lvconvert-snapshot.sh
index ecf6b3c..f18115d 100644
--- a/test/shell/lvconvert-snapshot.sh
+++ b/test/shell/lvconvert-snapshot.sh
@@ -30,7 +30,6 @@ lvcreate -L1 -s -n $lv3 $vg/$lv2
 lvcreate -l1 -n $lv4 $vg
 lvcreate -L1 -n $lv5 $vg
 lvcreate -L1 -n $lv6 $vg
-lvcreate -L1 -i2 -n $lv7 $vg
 
 not lvconvert -s $vg/$lv1 $vg/not_exist
 
@@ -61,6 +60,13 @@ grep "smaller" err
 lvconvert --yes -s $vg/$lv2 $vg/$lv5
 lvconvert --yes --type snapshot $vg/$lv2 $vg/$lv6
 
+vgremove -f $vg
+
+# FIXME: older stripe target can't handle 1K chunks
+vgcreate -s 4k "$vg" "${DEVICES[@]}"
+lvcreate -aey -L1 -n $lv2 $vg
+lvcreate -L1 -i2 -n $lv7 $vg
+
 # Striped LV is also supported
 lvconvert --yes --snapshot $vg/$lv2 $vg/$lv7
 



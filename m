From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:49:33 +0000 (GMT)
Subject: dev-next - tests: more skipped tests for lvmpolld
Message-ID: <20210331214933.D86D53858C27@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8e9bc52b15106d0edaf47f56e4f467f8365597f0
Commit:        8e9bc52b15106d0edaf47f56e4f467f8365597f0
Parent:        a55f4a8fe24a89c9a7e42e2fcd11c974eae0e127
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 26 22:13:37 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 26 22:13:37 2021 +0100

tests: more skipped tests for lvmpolld

---
 test/shell/lvmlockd-hello-world.sh | 3 ++-
 test/shell/lvmlockd-lv-types.sh    | 3 ++-
 test/shell/pv-range-overflow.sh    | 1 +
 3 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvmlockd-hello-world.sh b/test/shell/lvmlockd-hello-world.sh
index 43946a54b..2e1d3291c 100644
--- a/test/shell/lvmlockd-hello-world.sh
+++ b/test/shell/lvmlockd-hello-world.sh
@@ -12,6 +12,8 @@
 
 test_description='Hello world for vgcreate $SHARED with lvmlockd and sanlock'
 
+SKIP_WITH_LVMPOLLD=1
+
 . lib/inittest
 
 [ -z "$LVM_TEST_LVMLOCKD" ] && skip
@@ -23,4 +25,3 @@ vgcreate $SHARED $vg "$dev1"
 vgs -o+locktype,lockargs $vg
 
 vgremove $vg
-
diff --git a/test/shell/lvmlockd-lv-types.sh b/test/shell/lvmlockd-lv-types.sh
index 3503f2420..6138e5623 100644
--- a/test/shell/lvmlockd-lv-types.sh
+++ b/test/shell/lvmlockd-lv-types.sh
@@ -12,6 +12,8 @@
 
 test_description='Check lvmlockd lock_args for different LV types'
 
+SKIP_WITH_LVMPOLLD=1
+
 . lib/inittest
 
 [ -z "$LVM_TEST_LVMLOCKD" ] && skip;
@@ -182,4 +184,3 @@ lvchange -an $vg/lv4
 lvremove $vg/lv4
 
 vgremove $vg
-
diff --git a/test/shell/pv-range-overflow.sh b/test/shell/pv-range-overflow.sh
index f880a1311..ab845a942 100644
--- a/test/shell/pv-range-overflow.sh
+++ b/test/shell/pv-range-overflow.sh
@@ -13,6 +13,7 @@
 # 'Ensure that pvmove diagnoses PE-range values 2^32 and larger.'
 
 
+SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 



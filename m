From: David Teigland <teigland@sourceware.org>
Date: Wed, 11 Sep 2019 15:02:25 -0400
Subject: master - tests: skip without xxd
Message-ID: <201909111902.x8BJ2PcY022025@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=447ba5f1c20161d2ca89e0673fc4b219f65209a9
Commit:        447ba5f1c20161d2ca89e0673fc4b219f65209a9
Parent:        31b6a04e4c1e851dc9d51c42a6cb54a82afeb4b4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 11 13:59:16 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Sep 11 14:01:55 2019 -0500

tests: skip without xxd

---
 test/shell/metadata-bad-mdaheader.sh |    6 ++----
 test/shell/metadata-zero-space.sh    |    6 ++----
 2 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/test/shell/metadata-bad-mdaheader.sh b/test/shell/metadata-bad-mdaheader.sh
index cf24936..e9e303d 100644
--- a/test/shell/metadata-bad-mdaheader.sh
+++ b/test/shell/metadata-bad-mdaheader.sh
@@ -12,6 +12,8 @@
 
 . lib/inittest
 
+xxd -v || skip
+
 aux prepare_devs 3
 get_devs
 
@@ -33,8 +35,6 @@ vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3"
 
 pvs
 
-if [ -e "/usr/bin/xxd" ]; then
-
 # read mda_header which is 4k from start of disk
 dd if="$dev1" of=meta1 bs=4k count=1 skip=1
 
@@ -54,8 +54,6 @@ dd if=meta1-bad of="$dev1" bs=4k seek=1
 pvs 2>&1 | tee out
 grep "bad metadata header" out
 
-fi
-
 pvs "$dev1"
 pvs "$dev2"
 pvs "$dev3"
diff --git a/test/shell/metadata-zero-space.sh b/test/shell/metadata-zero-space.sh
index 847ef44..11c358b 100644
--- a/test/shell/metadata-zero-space.sh
+++ b/test/shell/metadata-zero-space.sh
@@ -14,6 +14,8 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+xxd -v || skip
+
 aux prepare_devs 1 256
 get_devs
 
@@ -27,8 +29,6 @@ vgcreate $SHARED "$vg" "$dev1"
 
 for i in `seq 1 50`; do lvcreate -l1 -an $vg; done
 
-if [ -e "/usr/bin/xxd" ]; then
-
 # Check metadata copies are separated by zeroes in the first mda
 
 dd if="$dev1" of=meta.raw bs=1M count=1
@@ -81,6 +81,4 @@ cat meta.count | wc -l
 
 test "$(cat meta.count | wc -l)" -gt 20
 
-fi
-
 vgremove -ff $vg



From: David Teigland <teigland@sourceware.org>
Date: Tue, 4 Feb 2020 11:21:22 -0500
Subject: master - tests: move vgsplit writecache
Message-ID: <97923.120020411211601827@us-mta-174.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c0de37ab1888a53cce97007c3f4fdfb6f85ab5bf
Commit:        c0de37ab1888a53cce97007c3f4fdfb6f85ab5bf
Parent:        c1ee6f0eef24a44cc02ec941f560bc17ac61b3d8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 4 10:20:19 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 4 10:20:19 2020 -0600

tests: move vgsplit writecache

to a different file
---
 test/shell/vgsplit-cache.sh    | 10 +---------
 test/shell/writecache-split.sh | 14 ++++++++++++++
 2 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/test/shell/vgsplit-cache.sh b/test/shell/vgsplit-cache.sh
index 200f0a9..eba85be 100644
--- a/test/shell/vgsplit-cache.sh
+++ b/test/shell/vgsplit-cache.sh
@@ -70,8 +70,7 @@ test 3 -eq "$(get vg_field $vg1 pv_count)"
 
 lvremove -y $vg
 
-# dm-cache or dm-writecache with cachevol must not
-# separated main LV and cachevol
+# dm-cache with cachevol must not separated main LV and cachevol
 
 vgremove -ff $vg
 vgremove -ff $vg1
@@ -85,11 +84,4 @@ fail vgsplit $vg $vg1 "$dev2"
 fail vgsplit $vg $vg1 "$dev3"
 lvremove $vg/$lv1
 
-lvcreate -L6 -n $lv1 -an $vg "$dev2"
-lvcreate -L6 -n $lv2 -an $vg "$dev3"
-lvconvert -y --type writecache --cachevol $lv2 $vg/$lv1
-fail vgsplit $vg $vg1 "$dev2"
-fail vgsplit $vg $vg1 "$dev3"
-lvremove $vg/$lv1
-
 vgremove -ff $vg
diff --git a/test/shell/writecache-split.sh b/test/shell/writecache-split.sh
index 6a7a2cd..7168d02 100644
--- a/test/shell/writecache-split.sh
+++ b/test/shell/writecache-split.sh
@@ -126,3 +126,17 @@ vgchange -an $vg
 vgextend --restoremissing $vg "$dev3"
 
 vgremove -ff $vg
+
+#
+# vgsplit should not separate cachevol from main lv
+#
+
+vgcreate $vg "$dev1" "$dev2" "$dev3" "$dev4"
+lvcreate -L6 -n $lv1 -an $vg "$dev2"
+lvcreate -L6 -n $lv2 -an $vg "$dev3"
+lvconvert -y --type writecache --cachevol $lv2 $vg/$lv1
+fail vgsplit $vg $vg1 "$dev2"
+fail vgsplit $vg $vg1 "$dev3"
+lvremove $vg/$lv1
+
+vgremove -ff $vg




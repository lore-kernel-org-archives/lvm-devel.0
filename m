From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Feb 2021 10:54:34 +0000 (GMT)
Subject: main - tests: lvconvert thin profile conversion
Message-ID: <20210217105434.74177382E818@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3af61d8646765fea95a77618e9bfc7e1c35f7ea2
Commit:        3af61d8646765fea95a77618e9bfc7e1c35f7ea2
Parent:        53666d6ee34260231b9589dddcdb28f77fdab506
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 17 00:07:50 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 17 11:21:35 2021 +0100

tests: lvconvert thin profile conversion

---
 test/shell/profiles-thin.sh | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/test/shell/profiles-thin.sh b/test/shell/profiles-thin.sh
index 40059becc..c62a5f56f 100644
--- a/test/shell/profiles-thin.sh
+++ b/test/shell/profiles-thin.sh
@@ -59,6 +59,24 @@ check lv_field $vg/pool_performance profile "thin-performance"
 $SHOULD check lv_field $vg/pool_performance chunk_size 1.00m
 check lv_field $vg/pool_performance zero ""
 
+lvremove -f $vg
+
+#
+# Repeat same two creations via lvconvert
+#
+lvcreate -L8m --name pool_generic $vg
+lvconvert --yes --type thin-pool $vg/pool_generic
+check lv_field $vg/pool_generic chunk_size 64.00k
+check lv_field $vg/pool_generic zero "zero"
+
+
+lvcreate -L8m --name pool_performance $vg
+lvconvert --yes --type thin-pool --errorwhenfull y --profile thin-performance $vg/pool_performance
+check lv_field $vg/pool_performance profile "thin-performance"
+$SHOULD check lv_field $vg/pool_performance chunk_size 1.00m
+check lv_field $vg/pool_performance zero ""
+check lv_field $vg/pool_performance lv_when_full "error"
+
 vgremove -ff $vg
 
 if test -d "$DM_DEV_DIR/$vg" ; then



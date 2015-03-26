From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 26 Mar 2015 14:11:38 +0000 (UTC)
Subject: master - tests: temporarily trace prepare_vg
Message-ID: <20150326141138.029C860CE5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d24b6cfb1ff1f29eec49c3113f8cef9904cf4a8b
Commit:        d24b6cfb1ff1f29eec49c3113f8cef9904cf4a8b
Parent:        f08154cc7b2051b68b4eda1a6be0de61fc77d637
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 26 15:05:24 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 26 15:11:15 2015 +0100

tests: temporarily trace  prepare_vg

---
 test/shell/lvresize-rounding.sh |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvresize-rounding.sh b/test/shell/lvresize-rounding.sh
index d06dcf1..24ca00b 100644
--- a/test/shell/lvresize-rounding.sh
+++ b/test/shell/lvresize-rounding.sh
@@ -11,9 +11,10 @@
 
 . lib/inittest
 
+# 15 extents
 aux prepare_pvs 3 22
 
-vgcreate -s 32K $vg "$dev1" "$dev2" "$dev3"
+vgcreate -s 32K $vg $(cat DEVICES)
 
 lvcreate -an -Zn -l4 -i3 -I64 $vg
 
@@ -31,7 +32,9 @@ lvresize -l+64 -i3 -I128 $vg/$lv1
 vgremove -f $vg
 
 # 15 extents
+LVM_TEST_AUX_TRACE=yes
 aux prepare_vg 3 22
+unset LVM_TEST_AUX_TRACE
 
 # Block some extents
 lvcreate -an -Zn -l4 -i3 $vg



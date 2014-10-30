From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 30 Oct 2014 23:01:01 +0000 (UTC)
Subject: master - tests: lvcreate snapshot usage update
Message-ID: <20141030230101.D1A1360AA2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8926230f6e7ac46c5bbed70d3e8efbc43e5b444d
Commit:        8926230f6e7ac46c5bbed70d3e8efbc43e5b444d
Parent:        b58a0f5cd31669e789d6944ced5b42ce7c6f4f74
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 30 23:16:03 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 30 23:58:49 2014 +0100

tests: lvcreate snapshot usage update

---
 test/shell/lvcreate-usage.sh |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvcreate-usage.sh b/test/shell/lvcreate-usage.sh
index 05f2515..5d37d9c 100644
--- a/test/shell/lvcreate-usage.sh
+++ b/test/shell/lvcreate-usage.sh
@@ -130,8 +130,16 @@ grep "Redundant" err
 check lv_field $vg/$lv1 segtype "linear"
 lvremove -ff $vg
 
-# Snapshot with virtual origin works
+# Old --type snapshot works with -s
+lvcreate --type snapshot -s -V64 -L32 -n $lv1 $vg
+check lv_field $vg/$lv1 segtype "linear"
+lvcreate --type snapshot -V64 -L32 -n $lv2 $vg
+check lv_field $vg/$lv2 segtype "linear"
+lvremove -ff $vg
+
+# --virtualoriginsize  always makes old snapshot
 lvcreate -s --virtualoriginsize 64m -L 32m -n $lv1 $vg
+check lv_field $vg/$lv1 segtype "linear"
 lvrename $vg/$lv1 $vg/$lv2
 lvcreate -s --virtualoriginsize 64m -L 32m -n $lv1 $vg
 lvchange -a n $vg/$lv1



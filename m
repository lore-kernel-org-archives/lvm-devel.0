From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 14 Oct 2019 09:22:54 -0400
Subject: master - tests: cvol
Message-ID: <201910141322.x9EDMsQR018886@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6666c3934631eddebe0c00125d9df8517bc3da9a
Commit:        6666c3934631eddebe0c00125d9df8517bc3da9a
Parent:        c70bab75311def1a52a42a109737184e1982949c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Oct 13 00:02:58 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 14 15:20:25 2019 +0200

tests: cvol

---
 test/shell/cache-single-types.sh |    2 +-
 test/shell/cache-single-usage.sh |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/shell/cache-single-types.sh b/test/shell/cache-single-types.sh
index 34a799a..8558242 100644
--- a/test/shell/cache-single-types.sh
+++ b/test/shell/cache-single-types.sh
@@ -49,7 +49,7 @@ lvconvert -y --type cache --cachevol $lv2 $vg/$lv1
 
 check lv_field $vg/$lv1 segtype cache
 
-lvs -a $vg/$lv2 --noheadings -o segtype >out
+lvs -a $vg/${lv2}_cvol --noheadings -o segtype >out
 grep raid1 out
 
 lvchange -ay $vg/$lv1
diff --git a/test/shell/cache-single-usage.sh b/test/shell/cache-single-usage.sh
index 4896d7a..a885bf7 100644
--- a/test/shell/cache-single-usage.sh
+++ b/test/shell/cache-single-usage.sh
@@ -52,7 +52,7 @@ lvconvert -y --type cache --cachevol $lv2 $vg/$lv1
 
 check lv_field $vg/$lv1 segtype cache
 
-lvs -a $vg/$lv2 --noheadings -o segtype >out
+lvs -a $vg/${lv2}_cvol --noheadings -o segtype >out
 grep linear out
 
 lvchange -ay $vg/$lv1
@@ -94,7 +94,7 @@ lvconvert -y --type cache --cachevol $lv2 $vg/$lv1
 
 check lv_field $vg/$lv1 segtype cache
 
-lvs -a $vg/$lv2 --noheadings -o segtype >out
+lvs -a $vg/${lv2}_cvol --noheadings -o segtype >out
 grep linear out
 
 lvchange -ay $vg/$lv1



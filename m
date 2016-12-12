From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 12 Dec 2016 10:52:12 +0000 (UTC)
Subject: master - tests: update seg_size_pe
Message-ID: <20161212105212.EFC2760553@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=75ec7c8deeed95f005d78b4b962f70f783f7f0a0
Commit:        75ec7c8deeed95f005d78b4b962f70f783f7f0a0
Parent:        3dd6e2c7e13a8b04829ab6a9a9df29a46b532bf0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 12 11:49:26 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 12 11:51:50 2016 +0100

tests: update seg_size_pe

Default prepare_vg uses 512K - so update test accordingly
---
 test/shell/error-usage.sh |    2 +-
 test/shell/zero-usage.sh  |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/error-usage.sh b/test/shell/error-usage.sh
index c8765a6..062b71e 100644
--- a/test/shell/error-usage.sh
+++ b/test/shell/error-usage.sh
@@ -26,7 +26,7 @@ lvextend -L+1 $vg/$lv1
 check lv_field $vg/$lv1 lv_modules "error"
 check lv_field $vg/$lv1 segtype "error"
 check lv_field $vg/$lv1 seg_count "1"
-check lv_field $vg/$lv1 seg_size_pe "8"   # 8 * 256
+check lv_field $vg/$lv1 seg_size_pe "4"   # 4 * 512 => 2M
 
 # FIXME should we print info we are ignoring stripping?
 lvextend -L+1 -I64 -i2 $vg/$lv1
diff --git a/test/shell/zero-usage.sh b/test/shell/zero-usage.sh
index 5d393f5..68afaaf 100644
--- a/test/shell/zero-usage.sh
+++ b/test/shell/zero-usage.sh
@@ -32,6 +32,6 @@ test "$sum1" = "$sum2"
 check lv_field $vg/$lv1 lv_modules "zero"
 check lv_field $vg/$lv1 segtype "zero"
 check lv_field $vg/$lv1 seg_count "1"
-check lv_field $vg/$lv1 seg_size_pe "8"   # 8 * 256
+check lv_field $vg/$lv1 seg_size_pe "4"   # 4 * 512
 
 vgremove -ff $vg



From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 10 Jul 2014 13:30:39 +0000 (UTC)
Subject: master - tests: LV's zero field now reported as binary field
Message-ID: <20140710133039.3415961042@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1e5ec893c7d9cf243a6ecb17ed6320d37e9a147c
Commit:        1e5ec893c7d9cf243a6ecb17ed6320d37e9a147c
Parent:        e2448bb0dcfa63b2a8fae24b989393a821917120
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jul 10 15:30:28 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jul 10 15:30:28 2014 +0200

tests: LV's zero field now reported as binary field

---
 test/shell/profiles-thin.sh |    6 +++---
 test/shell/thin-defaults.sh |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/test/shell/profiles-thin.sh b/test/shell/profiles-thin.sh
index 704ef2d..3519985 100644
--- a/test/shell/profiles-thin.sh
+++ b/test/shell/profiles-thin.sh
@@ -34,7 +34,7 @@ vgcreate $vg "$dev1"
 lvcreate -L8m -T $vg/pool_generic
 check lv_field $vg/pool_generic profile ""
 check lv_field $vg/pool_generic chunk_size 64.00k
-check lv_field $vg/pool_generic zero 1
+check lv_field $vg/pool_generic zero "zero"
 
 # If "thin-performance" profile is used, the "performance"
 # policy is used to calculate chunk size which is 512KiB
@@ -44,7 +44,7 @@ check lv_field $vg/pool_generic zero 1
 lvcreate --profile thin-performance -L8m -T $vg/pool_performance
 check lv_field $vg/pool_performance profile "thin-performance"
 check lv_field $vg/pool_performance chunk_size 1.00m
-check lv_field $vg/pool_performance zero 0
+check lv_field $vg/pool_performance zero ""
 
 vgremove -ff $vg
 
@@ -56,4 +56,4 @@ lvcreate -L8m -T $vg/pool_performance_inherited
 check vg_field $vg profile "thin-performance"
 check lv_field $vg/pool_performance_inherited profile ""
 check lv_field $vg/pool_performance_inherited chunk_size 1.00m
-check lv_field $vg/pool_performance_inherited zero 0
+check lv_field $vg/pool_performance_inherited zero ""
diff --git a/test/shell/thin-defaults.sh b/test/shell/thin-defaults.sh
index 4f873cc..3a681a1 100644
--- a/test/shell/thin-defaults.sh
+++ b/test/shell/thin-defaults.sh
@@ -30,6 +30,6 @@ lvcreate -T -L8M $vg/pool1
 
 check lv_field $vg/pool1 chunksize "128.00k"
 check lv_field $vg/pool1 discards "ignore"
-check lv_field $vg/pool1 zero 0
+check lv_field $vg/pool1 zero ""
 
 vgremove -f $vg



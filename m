From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 27 Oct 2017 11:11:26 -0400
Subject: master - tests: update checked messages
Message-ID: <201710271511.v9RFBQOO014732@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=eb710cced11a290ebe3e365e3b1cc225920b6b99
Commit:        eb710cced11a290ebe3e365e3b1cc225920b6b99
Parent:        63c50ced89d14f90c3202167e1d07de3514dad60
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 27 17:02:22 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 27 17:07:42 2017 +0200

tests: update checked messages

---
 test/shell/lvconvert-snapshot-cache.sh  |    6 +++---
 test/shell/lvconvert-snapshot-mirror.sh |    4 ++--
 test/shell/lvconvert-snapshot-raid.sh   |    4 ++--
 test/shell/lvconvert-snapshot-thin.sh   |   13 ++++++++++---
 4 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/test/shell/lvconvert-snapshot-cache.sh b/test/shell/lvconvert-snapshot-cache.sh
index 0d9c9c6..d32f4c2 100644
--- a/test/shell/lvconvert-snapshot-cache.sh
+++ b/test/shell/lvconvert-snapshot-cache.sh
@@ -58,13 +58,13 @@ grep "lv_is_visible" err
 
 # Cannot use thin-pool, _tdata, _tmeta as origin
 not lvconvert --yes --type snapshot $vg/cpool $vg/cow 2>&1 | tee err
-grep "invalid" err
+grep "not supported" err
 
 not lvconvert --yes --type snapshot $vg/cpool_cdata $vg/cow 2>&1 | tee err
-grep "invalid" err
+grep "not supported" err
 
 not lvconvert --yes --type snapshot $vg/cpool_cmeta $vg/cow 2>&1 | tee err
-grep "invalid" err
+grep "not supported" err
 
 lvconvert --yes -s $vg/ch $vg/cow
 
diff --git a/test/shell/lvconvert-snapshot-mirror.sh b/test/shell/lvconvert-snapshot-mirror.sh
index 01c19d9..22f40f7 100644
--- a/test/shell/lvconvert-snapshot-mirror.sh
+++ b/test/shell/lvconvert-snapshot-mirror.sh
@@ -42,11 +42,11 @@ grep "lv_is_visible" err
 
 # cannot use _mimage
 not lvconvert --yes --type snapshot $vg/mir_mimage_0 $vg/cow 2>&1 | tee err
-grep "invalid" err
+grep "not supported" err
 
 # cannot use _mlog
 not lvconvert --yes --type snapshot $vg/mir_mlog $vg/cow 2>&1 | tee err
-grep "invalid" err
+grep "not supported" err
 
 lvconvert --yes -s $vg/mir $vg/cow
 
diff --git a/test/shell/lvconvert-snapshot-raid.sh b/test/shell/lvconvert-snapshot-raid.sh
index 91bcd94..8deb60f 100644
--- a/test/shell/lvconvert-snapshot-raid.sh
+++ b/test/shell/lvconvert-snapshot-raid.sh
@@ -44,11 +44,11 @@ grep "lv_is_visible" err
 
 # Cannot use _rimage
 not lvconvert --yes --type snapshot $vg/rd_rimage_0 $vg/cow 2>&1 | tee err
-grep "invalid" err
+grep "not supported" err
 
 # Cannot use _rmeta
 not lvconvert --yes --type snapshot $vg/rd_rmeta_0 $vg/cow 2>&1 | tee err
-grep "invalid" err
+grep "not supported" err
 
 lvconvert --yes -s $vg/rd $vg/cow
 
diff --git a/test/shell/lvconvert-snapshot-thin.sh b/test/shell/lvconvert-snapshot-thin.sh
index ef1218b..f5da459 100644
--- a/test/shell/lvconvert-snapshot-thin.sh
+++ b/test/shell/lvconvert-snapshot-thin.sh
@@ -29,6 +29,7 @@ lvcreate -L1 -n cow $vg
 
 # Thin and snapshot conversion
 lvcreate -T -L1 -V10 -n th $vg/pool
+eval $(lvs -S 'name=~_pmspare' -a -o name --config 'report/mark_hidden_devices=0' --noheading --nameprefixes $vg)
 
 # Cannot create snapshot of pool's meta
 not lvcreate -s -L1 $vg/pool_tmeta 2>&1 | tee err
@@ -45,6 +46,9 @@ grep "not accept" err
 not lvconvert --yes --type snapshot $vg/cow $vg/pool 2>&1 | tee err
 grep "not accept" err
 
+not lvconvert --yes --type snapshot $vg/cow $vg/$LVM2_LV_NAME 2>&1 | tee err
+grep "lv_is_visible" err
+
 not lvconvert --yes --type snapshot $vg/cow $vg/pool_tdata 2>&1 | tee err
 grep "lv_is_visible" err
 
@@ -53,13 +57,16 @@ grep "lv_is_visible" err
 
 # Cannot use thin-pool, _tdata, _tmeta as origin
 not lvconvert --yes --type snapshot $vg/pool $vg/cow 2>&1 | tee err
-grep "invalid" err
+grep "not supported" err
+
+not lvconvert --yes --type snapshot $vg/$LVM2_LV_NAME $vg/cow 2>&1 | tee err
+grep "not supported" err
 
 not lvconvert --yes --type snapshot $vg/pool_tdata $vg/cow 2>&1 | tee err
-grep "invalid" err
+grep "not supported" err
 
 not lvconvert --yes --type snapshot $vg/pool_tmeta $vg/cow 2>&1 | tee err
-grep "invalid" err
+grep "not supported" err
 
 lvconvert --yes -s $vg/th $vg/cow
 



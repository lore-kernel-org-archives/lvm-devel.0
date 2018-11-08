From: David Teigland <teigland@sourceware.org>
Date: Thu, 8 Nov 2018 15:12:57 -0500
Subject: master - tests: specify m1 for raid1 in cache-single-types
Message-ID: <201811082012.wA8KCvrn031294@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2f02e8d33ae908b1db523fac1690a4c9246daee2
Commit:        2f02e8d33ae908b1db523fac1690a4c9246daee2
Parent:        73132bc25414e8eb0a0c85708478b4dd797ce746
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Nov 8 14:08:41 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Nov 8 14:12:42 2018 -0600

tests: specify m1 for raid1 in cache-single-types

---
 test/shell/cache-single-types.sh |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/test/shell/cache-single-types.sh b/test/shell/cache-single-types.sh
index 1804e85..e7c58e2 100644
--- a/test/shell/cache-single-types.sh
+++ b/test/shell/cache-single-types.sh
@@ -30,14 +30,12 @@ aux prepare_devs 4 64
 
 vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4"
 
-lvcreate --type raid1 -n $lv1 -l 8 -an $vg "$dev1" "$dev2"
+lvcreate --type raid1 -m 1 -n $lv1 -l 8 $vg "$dev1" "$dev2"
 
-lvcreate --type raid1 -n $lv2 -l 4 -an $vg "$dev3" "$dev4"
+lvcreate --type raid1 -m 1 -n $lv2 -l 4 $vg "$dev3" "$dev4"
 
 # test1: create fs on LV before cache is attached
 
-lvchange -ay $vg/$lv1
-
 mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg/$lv1"
 
 mount "$DM_DEV_DIR/$vg/$lv1" "$mount_dir"



From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 25 Mar 2014 10:23:59 +0000 (UTC)
Subject: master - tests: update
Message-ID: <20140325102359.E796D60F9D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3c9204a75a31324f661a3a2d7d9ad5494b0c3e35
Commit:        3c9204a75a31324f661a3a2d7d9ad5494b0c3e35
Parent:        36d87eddcf280e9c394e10ac5860ed4d84eaf4a2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 24 23:13:35 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 25 11:23:00 2014 +0100

tests: update

---
 test/shell/lvconvert-repair-policy.sh |   41 +++++++++++++++++----------------
 1 files changed, 21 insertions(+), 20 deletions(-)

diff --git a/test/shell/lvconvert-repair-policy.sh b/test/shell/lvconvert-repair-policy.sh
index f3fe139..cefb0ea 100644
--- a/test/shell/lvconvert-repair-policy.sh
+++ b/test/shell/lvconvert-repair-policy.sh
@@ -18,15 +18,15 @@ aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
 # Clean-up and create a 2-way mirror, where the the
 # leg devices are always on $dev[12] and the log
 # is always on $dev3.  ($dev4 behaves as a spare)
-cleanup() {
+cleanup_() {
 	vgreduce --removemissing $vg
 	for d in "$@"; do aux enable_dev "$d"; done
 	for d in "$@"; do vgextend $vg "$d"; done
 	lvremove -ff $vg/mirror
-	lvcreate -aey --type mirror -m 1 --ignoremonitoring -l 2 -n mirror $vg "$dev1" "$dev2" "$dev3":0
+	lvcreate -aey --type mirror -m 1 --ignoremonitoring -l 2 -n mirror $vg "$dev1" "$dev2" "$dev3:0"
 }
 
-repair() {
+repair_() {
 	lvconvert --repair --use-policies --config "$1" $vg/mirror
 }
 
@@ -36,58 +36,59 @@ lvchange -a n $vg/mirror
 # Fail a leg of a mirror.
 aux disable_dev "$dev1"
 lvchange --partial -aey $vg/mirror
-repair 'activation { mirror_image_fault_policy = "remove" }'
+repair_ 'activation { mirror_image_fault_policy = "remove" }'
 check linear $vg mirror
-cleanup "$dev1"
+cleanup_ "$dev1"
 
 # Fail a leg of a mirror.
 # Expected result: Mirror (leg replaced, should retain log)
 aux disable_dev "$dev1"
-repair 'activation { mirror_image_fault_policy = "replace" mirror_log_fault_policy = "remove" }'
+repair_ 'activation { mirror_image_fault_policy = "replace" mirror_log_fault_policy = "remove" }'
 check mirror $vg mirror
 check active $vg mirror_mlog
-cleanup "$dev1"
+cleanup_ "$dev1"
 
 # Fail a leg of a mirror.
 # Expected result: Mirror (leg replaced)
 aux disable_dev "$dev1"
-repair 'activation { mirror_image_fault_policy = "replace" }'
+repair_ 'activation { mirror_image_fault_policy = "replace" }'
 check mirror $vg mirror
 check active $vg mirror_mlog
-cleanup "$dev1"
+cleanup_ "$dev1"
 
 # Fail a leg of a mirror (use old name for policy specification)
 # Expected result: Mirror (leg replaced)
 aux disable_dev "$dev1"
-repair 'activation { mirror_image_fault_policy = "replace" }'
+repair_ 'activation { mirror_image_fault_policy = "replace" }'
 check mirror $vg mirror
 check active $vg mirror_mlog
-cleanup "$dev1"
+not pvdisplay $vg
+cleanup_ "$dev1"
 
 # Fail a leg of a mirror w/ no available spare
 # Expected result: linear
 #                  (or 2-way with leg/log overlap if alloc anywhere)
 aux disable_dev "$dev2" "$dev4"
-repair 'activation { mirror_image_fault_policy = "replace" }'
+repair_ 'activation { mirror_image_fault_policy = "replace" }'
 check mirror $vg mirror
-not check lv_exists $vg mirror_mlog
-cleanup "$dev2" "$dev4"
+check lv_not_exists $vg mirror_mlog
+cleanup_ "$dev2" "$dev4"
 
 # Fail the log device of a mirror w/ no available spare
 # Expected result: mirror w/ corelog
 aux disable_dev "$dev3" "$dev4"
-repair 'activation { mirror_image_fault_policy = "replace" }' $vg/mirror
+repair_ 'activation { mirror_image_fault_policy = "replace" }' $vg/mirror
 check mirror $vg mirror
-not check lv_exists $vg mirror_mlog
-cleanup "$dev3" "$dev4"
+check lv_not_exists $vg mirror_mlog
+cleanup_ "$dev3" "$dev4"
 
 # Fail the log device with a remove policy
 # Expected result: mirror w/ corelog
 lvchange -aey $vg/mirror
 aux disable_dev "$dev3" "$dev4"
-repair 'activation { mirror_log_fault_policy = "remove" }'
+repair_ 'activation { mirror_log_fault_policy = "remove" }'
 check mirror $vg mirror core
-not check lv_exists $vg mirror_mlog
-cleanup "$dev3" "$dev4"
+check lv_not_exists $vg mirror_mlog
+cleanup_ "$dev3" "$dev4"
 
 vgremove -ff $vg



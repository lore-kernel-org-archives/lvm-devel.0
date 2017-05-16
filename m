From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 16 May 2017 04:53:04 -0400
Subject: master - test: Fix previous commit - skip only RAID6 part
Message-ID: <201705160853.v4G8r4rL023162@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f4f408610c6801a50395f95b8116e2037a58761e
Commit:        f4f408610c6801a50395f95b8116e2037a58761e
Parent:        cdb49216c5b00a4d73dab3f56be76bde8d128186
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue May 16 10:47:53 2017 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue May 16 10:47:53 2017 +0200

test: Fix previous commit - skip only RAID6 part

---
 test/shell/lvconvert-raid-regionsize.sh |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-raid-regionsize.sh b/test/shell/lvconvert-raid-regionsize.sh
index 2cea86e..2884037 100644
--- a/test/shell/lvconvert-raid-regionsize.sh
+++ b/test/shell/lvconvert-raid-regionsize.sh
@@ -15,7 +15,7 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 which mkfs.ext4 || skip
-aux have_raid 1 11 0 || skip
+aux have_raid 1 9 0 || skip
 
 aux prepare_vg 6
 
@@ -61,6 +61,7 @@ fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
 _test_regionsizes raid1
 
+if aux have_raid 1 11 0; then
 # Clean up
 lvremove --yes $vg
 
@@ -78,6 +79,9 @@ _test_regionsizes raid6
 
 # Clean up
 lvremove --yes $vg
+else
+  echo "Skipping RAID6 tests"
+fi
 
 # Create 6-way raid01
 lvcreate --yes -aey --type raid10 -i 3 -m 1 --stripesize 128K -R 256K -L8M -n $lv1 $vg



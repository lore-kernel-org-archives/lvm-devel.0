From: David Teigland <teigland@sourceware.org>
Date: Mon, 22 Mar 2021 15:39:48 +0000 (GMT)
Subject: dev-next - tests: prohibit 4K brd device with integrity
Message-ID: <20210322153948.712EA3854808@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=94c4af232c6118191ac2c81a4130e6f83823f510
Commit:        94c4af232c6118191ac2c81a4130e6f83823f510
Parent:        179f59a0ca7d4d5f779f86d990ebd336c9b13f0e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 20 09:54:30 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 20 10:52:24 2021 +0100

tests: prohibit 4K brd device with integrity

Older kernels hit these errors:

device-mapper: integrity: Bio not aligned on 8 sectors: 0x8ffc, 0x4
---
 test/shell/integrity-blocksize-2.sh | 2 ++
 test/shell/integrity-dmeventd.sh    | 4 +++-
 test/shell/integrity-misc.sh        | 4 +++-
 test/shell/integrity-syncaction.sh  | 4 +++-
 test/shell/integrity.sh             | 4 +++-
 5 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/test/shell/integrity-blocksize-2.sh b/test/shell/integrity-blocksize-2.sh
index 3f6eb9242..ae0e72ec6 100644
--- a/test/shell/integrity-blocksize-2.sh
+++ b/test/shell/integrity-blocksize-2.sh
@@ -15,6 +15,8 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 aux have_integrity 1 5 0 || skip
+# Avoid 4K ramdisk devices on older kernels
+aux kernel_at_least  5 10 || export LVM_TEST_PREFER_BRD=0
 
 mnt="mnt"
 mkdir -p $mnt
diff --git a/test/shell/integrity-dmeventd.sh b/test/shell/integrity-dmeventd.sh
index e82b92142..9049eb0f7 100644
--- a/test/shell/integrity-dmeventd.sh
+++ b/test/shell/integrity-dmeventd.sh
@@ -14,8 +14,10 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-aux have_integrity 1 5 0 || skip
 which mkfs.xfs || skip
+aux have_integrity 1 5 0 || skip
+# Avoid 4K ramdisk devices on older kernels
+aux kernel_at_least  5 10 || export LVM_TEST_PREFER_BRD=0
 
 mnt="mnt"
 mkdir -p $mnt
diff --git a/test/shell/integrity-misc.sh b/test/shell/integrity-misc.sh
index 4ebf42213..e6c108a0f 100644
--- a/test/shell/integrity-misc.sh
+++ b/test/shell/integrity-misc.sh
@@ -14,8 +14,10 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-aux have_integrity 1 5 0 || skip
 which mkfs.xfs || skip
+aux have_integrity 1 5 0 || skip
+# Avoid 4K ramdisk devices on older kernels
+aux kernel_at_least  5 10 || export LVM_TEST_PREFER_BRD=0
 
 mnt="mnt"
 mkdir -p $mnt
diff --git a/test/shell/integrity-syncaction.sh b/test/shell/integrity-syncaction.sh
index a1d96fb0e..e404f6b6d 100644
--- a/test/shell/integrity-syncaction.sh
+++ b/test/shell/integrity-syncaction.sh
@@ -14,9 +14,11 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-aux have_integrity 1 5 0 || skip
 which mkfs.xfs || skip
 which xfs_growfs || skip
+aux have_integrity 1 5 0 || skip
+# Avoid 4K ramdisk devices on older kernels
+aux kernel_at_least  5 10 || export LVM_TEST_PREFER_BRD=0
 
 mnt="mnt"
 mkdir -p $mnt
diff --git a/test/shell/integrity.sh b/test/shell/integrity.sh
index ffac50902..80ff919b2 100644
--- a/test/shell/integrity.sh
+++ b/test/shell/integrity.sh
@@ -14,9 +14,11 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-aux have_integrity 1 5 0 || skip
 which mkfs.xfs || skip
 which xfs_growfs || skip
+aux have_integrity 1 5 0 || skip
+# Avoid 4K ramdisk devices on older kernels
+aux kernel_at_least  5 10 || export LVM_TEST_PREFER_BRD=0
 
 mnt="mnt"
 mkdir -p $mnt



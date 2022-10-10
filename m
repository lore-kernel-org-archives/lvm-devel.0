From: David Teigland <teigland@sourceware.org>
Date: Mon, 10 Oct 2022 18:27:06 +0000 (GMT)
Subject: main - tests: skip lvresize tests without mkfs.xfs
Message-ID: <20221010182706.4F4E53858D37@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fc01dd89006bc0a37351cca9332244bfa8d2f096
Commit:        fc01dd89006bc0a37351cca9332244bfa8d2f096
Parent:        13c63f0cfa22a0bc89b8d528b8e2301c49fc7b0d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Oct 10 13:25:50 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Oct 10 13:25:50 2022 -0500

tests: skip lvresize tests without mkfs.xfs

---
 test/shell/lvresize-fs-crypt.sh | 2 ++
 test/shell/lvresize-fs.sh       | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/test/shell/lvresize-fs-crypt.sh b/test/shell/lvresize-fs-crypt.sh
index 0fbb2716e..e7b8b9426 100644
--- a/test/shell/lvresize-fs-crypt.sh
+++ b/test/shell/lvresize-fs-crypt.sh
@@ -17,6 +17,8 @@ SKIP_WITH_LVMPOLLD=1
 
 aux prepare_vg 3 256
 
+which mkfs.xfs || skip
+
 # Tests require a libblkid version that shows FSLASTBLOCK
 lvcreate -n $lv1 -L 300 $vg
 mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
diff --git a/test/shell/lvresize-fs.sh b/test/shell/lvresize-fs.sh
index e4d315b95..d4b6484c0 100644
--- a/test/shell/lvresize-fs.sh
+++ b/test/shell/lvresize-fs.sh
@@ -17,6 +17,8 @@ SKIP_WITH_LVMPOLLD=1
 
 aux prepare_vg 3 256
 
+which mkfs.xfs || skip
+
 # Test combinations of the following:
 # lvreduce / lvextend
 # no fs / ext4 / xfs


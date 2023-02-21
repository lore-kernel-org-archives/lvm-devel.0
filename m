From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 21 Feb 2023 14:39:16 +0000 (GMT)
Subject: main - pre-release
Message-ID: <20230221143916.B90723858D32@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f7dd2562c53347cec69bc060f838c95839770586
Commit:        f7dd2562c53347cec69bc060f838c95839770586
Parent:        993bd2ffc88003aa3392ddbe3364fd887b65b589
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Feb 21 15:33:32 2023 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Feb 21 15:33:32 2023 +0100

pre-release

---
 VERSION      | 2 +-
 VERSION_DM   | 2 +-
 WHATS_NEW    | 4 ++--
 WHATS_NEW_DM | 2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/VERSION b/VERSION
index 50e9c95ee..5317d59a5 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.03.19(2)-git (2022-12-22)
+2.03.19(2) (2023-02-21)
diff --git a/VERSION_DM b/VERSION_DM
index 21ef672a5..1f8535376 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.191-git (2022-12-22)
+1.02.191 (2023-02-21)
diff --git a/WHATS_NEW b/WHATS_NEW
index 248e30f5c..b54a092d8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,4 +1,4 @@
-version 2.03.19 - 
+version 2.03.19 - 21st February 2023
 ====================================
   Configure supports --with-systemd-run executed from udev rules.
   Enhancement for build with MuslC systemd and non-bash system shells (dash).
@@ -6,7 +6,7 @@ version 2.03.19 -
   Ensure udev is processing origin LV before its thick snapshots LVs.
   Fix and improve runtime memory size detection for VDO volumes.
 
-version 2.03.18 - 22nd december 2022
+version 2.03.18 - 22nd December 2022
 ====================================
   Fix issues reported by coverity scan.
   Fix warning for thin pool overprovisioning on lvextend (2.03.17).
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 1f94e5e27..e50a4d131 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,4 +1,4 @@
-Version 1.02.191 - 
+Version 1.02.191 - 21st February 2023
 =====================================
   Improve parallel creation of /dev/mapper/control device node.
   Import previous ID_FS_* udev records in 13-dm-disk.rules for suspended DM dev.


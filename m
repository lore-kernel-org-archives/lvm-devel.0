From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 10 Nov 2022 13:22:21 +0000 (GMT)
Subject: main - pre-release
Message-ID: <20221110132221.273AC3858D38@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f8127c45c5fa8fc8e163565bfa2001a0bb8ae72e
Commit:        f8127c45c5fa8fc8e163565bfa2001a0bb8ae72e
Parent:        6b96bf7bc2f548e7ce1de879251c8b90ab40b634
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Nov 10 10:23:38 2022 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Nov 10 14:11:32 2022 +0100

pre-release

---
 VERSION      | 2 +-
 VERSION_DM   | 2 +-
 WHATS_NEW    | 7 +++++--
 WHATS_NEW_DM | 4 ++--
 4 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/VERSION b/VERSION
index 7f1382bbe..d011ad748 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.03.17(2)-git (2022-05-18)
+2.03.17(2) (2022-11-10)
diff --git a/VERSION_DM b/VERSION_DM
index 35b742cd4..3f4240a76 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.187-git (2022-05-18)
+1.02.187 (2022-11-10)
diff --git a/WHATS_NEW b/WHATS_NEW
index 2942b0e53..2f4ffd894 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
-Version 2.03.17 - 
-===============================
+Version 2.03.17 - 10th November 2022
+====================================
+  Add new options (--fs, --fsmode) for FS handling when resizing LVs.
   Fix 'lvremove -S|--select LV' to not also remove its historical LV right away.
   Fix lv_active field type to binary so --select and --binary applies properly.
   Switch to use mallinfo2 and use it only with glibc.
@@ -11,6 +12,8 @@ Version 2.03.17 -
   Fix lvconvert --test --type vdo-pool execution.
   Add json_std output format for more JSON standard compliant version of output.
   Fix vdo_slab_size_mb value for converted VDO volume.
+  Fix many corner cases in device_id, including handling of S/N duplicates.
+  Fix various issues in lvmdbusd.
 
 Version 2.03.16 - 18th May 2022
 ===============================
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 6856f4302..f676ff7e1 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.187 - 
-================================
+Version 1.02.187 - 10th November 2022
+=====================================
   Add DM_REPORT_GROUP_JSON_STD for more JSON standard compliant output format.
 
 Version 1.02.185 - 18th May 2022


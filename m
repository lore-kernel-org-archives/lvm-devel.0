From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 13 Jun 2018 13:16:47 -0400
Subject: 2018-06-01-stable - post-release
Message-ID: <201806131716.w5DHGl9h001485@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fdb362b998930e381595e07475d2b5d7b516f957
Commit:        fdb362b998930e381595e07475d2b5d7b516f957
Parent:        06accf13953d0bc3a5ffef918e562bad1d802249
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu May 24 15:23:08 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Jun 13 19:09:07 2018 +0200

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    6 ++++++
 WHATS_NEW_DM |    6 ++++++
 4 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index 3c684c9..f30ea0c 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.178(2) (2018-06-13)
+2.02.179(2)-git (2018-06-13)
diff --git a/VERSION_DM b/VERSION_DM
index cbe4e78..e6cd382 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.147 (2018-06-13)
+1.02.148-git (2018-06-13)
diff --git a/WHATS_NEW b/WHATS_NEW
index b8dceb3..8f40b46 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,4 +1,10 @@
+Version 2.02.179 -
+====================================
+
 Version 2.02.178 - 13th June 2018
+=================================
+
+Version 2.02.178-rc1 - 24th May 2018
 ====================================
   Add libaio dependency for build.
   Remove lvm1 and pool format handling and add filter to ignore them.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 4961f56..131cbee 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,4 +1,10 @@
+Version 1.02.148 -
+====================================
+
 Version 1.02.147 - 13th June 2018
+=================================
+
+Version 1.02.147-rc1 - 24th May 2018
 ====================================
   Reuse uname() result for mirror target.
   Recognize also mounted btrfs through dm_device_has_mounted_fs().



From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 13 Jun 2018 13:16:42 -0400
Subject: 2018-06-01-stable - pre-release
Message-ID: <201806131716.w5DHGgDw001319@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=06accf13953d0bc3a5ffef918e562bad1d802249
Commit:        06accf13953d0bc3a5ffef918e562bad1d802249
Parent:        adae8ee1c2926d59c85dc9fc253375f07f262819
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Jun 13 14:13:35 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Jun 13 14:13:35 2018 +0200

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    2 +-
 WHATS_NEW_DM |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/VERSION b/VERSION
index 1594f32..3c684c9 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.178(2)-rc1 (2018-05-24)
+2.02.178(2) (2018-06-13)
diff --git a/VERSION_DM b/VERSION_DM
index e95d765..cbe4e78 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.147-rc1 (2018-05-24)
+1.02.147 (2018-06-13)
diff --git a/WHATS_NEW b/WHATS_NEW
index 620c9d5..b8dceb3 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,4 +1,4 @@
-Version 2.02.178-rc1 - 24th May 2018
+Version 2.02.178 - 13th June 2018
 ====================================
   Add libaio dependency for build.
   Remove lvm1 and pool format handling and add filter to ignore them.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index a40ca4e..4961f56 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,4 +1,4 @@
-Version 1.02.147-rc1 - 24th May 2018
+Version 1.02.147 - 13th June 2018
 ====================================
   Reuse uname() result for mirror target.
   Recognize also mounted btrfs through dm_device_has_mounted_fs().



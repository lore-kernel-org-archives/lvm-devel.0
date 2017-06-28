From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 28 Jun 2017 12:01:15 -0400
Subject: master - pre-release
Message-ID: <201706281601.v5SG1F1o008071@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=08ce545449a7076965e153e6a9df1c49f833d33e
Commit:        08ce545449a7076965e153e6a9df1c49f833d33e
Parent:        7ba6896962d8fe34139d3d6d49fc08430fbc641a
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jun 28 16:38:46 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jun 28 16:38:46 2017 +0100

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |   10 +++++-----
 WHATS_NEW_DM |    4 ++--
 4 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/VERSION b/VERSION
index 1e823ec..1774a41 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.172(2)-git (2017-05-03)
+2.02.172(2)-git (2017-06-28)
diff --git a/VERSION_DM b/VERSION_DM
index 36b0104..0f1b1a3 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.141-git (2017-05-03)
+1.02.141-git (2017-06-28)
diff --git a/WHATS_NEW b/WHATS_NEW
index 2872dbb..895e29c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,17 +1,17 @@
-Version 2.02.172 - 
-===============================
+Version 2.02.172 - 28th June 2017
+=================================
   Add missing NULL to argv array when spliting cmdline arguments.
   Add display_percent helper function for printing percent values.
-  Lvconvert --repair handles failing raid legs (present but marked 'D'ead).
+  lvconvert --repair handles failing raid legs (present but marked 'D'ead).
   Do not lvdisplay --maps unset settings of cache pool.
   Fix lvdisplay --maps for cache pool without policy settings.
   Support aborting of flushing cache LV.
   Reenable conversion of data and metadata thin-pool volumes to raid.
   Improve raid status reporting with lvs.
-  No longer necessary to '--force' a repair for RAID1
+  No longer necessary to '--force' a repair for RAID1.
   Linear to RAID1 upconverts now use "recover" sync action, not "resync".
   Improve lvcreate --cachepool arg validation.
-  Limit maximal size of thin-pool for specific chunk size.
+  Limit maximum size of thin-pool for specific chunk size.
   Print a warning about in-use PVs with no VG using them.
   Disable automatic clearing of PVs that look like in-use orphans.
   Cache format2 flag is now using segment name type field.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 2e31b9a..44d548a 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.141 - 
-===============================
+Version 1.02.141 - 28th June 2017
+=================================
   Fix reusing of dm_task structure for status reading (used by dmeventd).
   Add dm_percent_to_round_float for adjusted percentage rounding.
   Reset array with dead rimage devices once raid gets in sync.



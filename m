From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 3 May 2017 06:30:57 -0400
Subject: master - pre-release
Message-ID: <201705031030.v43AUvXX017473@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fb4bf1f4eae9ce49f9e0d606240867320dcb8dac
Commit:        fb4bf1f4eae9ce49f9e0d606240867320dcb8dac
Parent:        6bdbb283d54c7f91abd75c0c463a8475ac5435ff
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed May 3 11:23:31 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed May 3 11:23:31 2017 +0100

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    5 +++--
 WHATS_NEW_DM |    4 ++--
 4 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/VERSION b/VERSION
index a13212a..4f7cf0e 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.171(2)-git (2017-04-13)
+2.02.171(2)-git (2017-05-03)
diff --git a/VERSION_DM b/VERSION_DM
index de580ee..bc37b73 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.140-git (2017-04-13)
+1.02.140-git (2017-05-03)
diff --git a/WHATS_NEW b/WHATS_NEW
index 846e998..33a27e8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
-Version 2.02.171 - 
-==================================
+Version 2.02.171 - 3rd May 2017
+===============================
+  Fix memory warnings by using mempools for command definition processing.
   Fix running commands from a script file.
   Add pvcreate prompt when device size doesn't match setphysicalvolumesize.
   lvconvert - preserve region size on raid1 image count changes
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index c88516d..20d6220 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.140 - 
-==================================
+Version 1.02.140 - 3rd May 2017
+===============================
   Add missing configure --enable-dmfilemapd status message and fix --disable.
 
 Version 1.02.139 - 13th April 2017


